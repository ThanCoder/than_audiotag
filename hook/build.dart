// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;
import 'package:than_audiotag/keys.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final packageRootDir = input.packageRoot.toFilePath();
    final sourceLib = p.join(packageRootDir, '.dart_tool', 'native_assets');

    final targetLib = ArchiveTarget.create(input.config.code);
    final libFile = File(
      p.join(sourceLib, targetLib.platform, targetLib.arch, libName),
    );

    await extractLib(targetLib, sourceLib: sourceLib, libFile: libFile);

    output.assets.code.add(
      .new(
        package: packageName,
        name: libName,
        linkMode: DynamicLoadingBundled(),
        file: libFile.uri,
      ),
    );
  });
}

Future<void> extractLib(
  ArchiveTarget target, {
  required String sourceLib,
  required File libFile,
}) async {
  final zipFile = File(
    p.join(sourceLib, '${target.platform}-${target.arch}.zip'),
  );
  if (libFile.existsSync()) return;
  if (zipFile.existsSync()) {
    await extractZip(zipFile, target: target, output: libFile);
    return;
  }
  await downloadLib(target.downloadUrl, zipFile);
  await extractZip(zipFile, target: target, output: libFile);
}

Future<void> downloadLib(String url, File output) async {
  final client = HttpClient();

  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Download failed: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }

    await output.parent.create(recursive: true);

    final sink = output.openWrite();

    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }
  } catch (e) {
    if (await output.exists()) {
      await output.delete();
    }

    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<void> extractZip(
  File input, {
  required ArchiveTarget target,
  required File output,
}) async {
  final bytes = input.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  final member = archive.findFile(target.libPath);
  if (member == null) {
    throw Exception(
      'lib archive ${input.path} does not contain ${target.libPath}.',
    );
  }

  await output.parent.create(recursive: true);
  await output.writeAsBytes(member.content as List<int>);
}

class ArchiveTarget {
  const ArchiveTarget({
    required this.config,
    required this.downloadUrl,
    required this.libPath,
    required this.libName,
    required this.arch,
    required this.platform,
  });

  final CodeConfig config;
  final String downloadUrl;
  final String libPath;
  final String libName;
  final String arch;
  final String platform;

  factory ArchiveTarget.create(CodeConfig cf) {
    final targetOS = cf.targetOS;
    final targetArch = cf.targetArchitecture;

    if (cf.targetOS == .linux) {
      return .new(
        config: cf,
        downloadUrl: linuxLibUrl,
        libPath: 'libthan_audiotag.so',
        libName: 'libthan_audiotag.so',
        arch: 'x64',
        platform: targetOS.name,
      );
    }
    if (cf.targetOS == .windows) {
      return .new(
        config: cf,
        downloadUrl: windowLibUrl,
        libPath: 'libthan_audiotag.dll',
        libName: 'libthan_audiotag.dll',
        arch: 'x64',
        platform: targetOS.name,
      );
    }
    if (targetOS == .android) {
      final url = switch (targetArch) {
        .arm => androidArmLibUrl,
        .arm64 => androidArm64LibUrl,
        _ => throw UnsupportedError(
          'Not Supported Url: OS:${targetOS.name} - Arch:${targetArch.name}',
        ),
      };
      return .new(
        config: cf,
        downloadUrl: url,
        libPath: 'libthan_audiotag.so',
        libName: 'libthan_audiotag.so',
        arch: targetArch.name,
        platform: targetOS.name,
      );
    }

    throw UnsupportedError(
      'Not Supported: OS:${targetOS.name} - Arch:${targetArch.name}',
    );
  }
}
