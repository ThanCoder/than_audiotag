// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

const String linuxLibUrl =
    'https://github.com/ThanCoder/than_audiotag/releases/download/than_audiotag_lib/than_audiotag_linux-64.zip';
const String androidArmLibUr =
    'https://github.com/ThanCoder/than_audiotag/releases/download/than_audiotag_lib/than_audiotag_android_arm.zip';
const String androidArm64LibUr =
    'https://github.com/ThanCoder/than_audiotag/releases/download/than_audiotag_lib/than_audiotag_android_arm64.zip';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;

    //**********Lib So***************** */
    final libName = 'libthan_audiotag.so';
    final sourceLib = input.packageRoot.path
        .join('.dart_tool')
        .join('native_assets');

    final libFile = await extraceLibSo(
      sourceLib,
      libName: libName,
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
    );

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

extension StringJoin on String {
  String join(String name) {
    return '$this${Platform.pathSeparator}$name';
  }
}

Future<File> extraceLibSo(
  String sourceLib, {
  required String libName,
  required OS targetOS,
  required Architecture targetArchitecture,
}) async {
  if (targetOS == .linux) {
    final libFile = File(sourceLib.join(targetOS.name).join(libName));
    if (libFile.existsSync()) return libFile;
    final sourceZipFile = File(sourceLib.join(targetOS.name).join('linux.zip'));
    // zip ရှိရင်
    if (sourceZipFile.existsSync()) {
      await extractZip(sourceZipFile, libFile);
      return libFile;
    }

    await downloadLib(linuxLibUrl, sourceZipFile);
    await extractZip(sourceZipFile, libFile);
    return libFile;
  }
  // android
  if (targetOS == .android) {
    final androidLibPath = sourceLib.join(targetOS.name);
    final libFile = File(
      androidLibPath.join(targetArchitecture.name).join(libName),
    );
    if (libFile.existsSync()) return libFile;

    // မရှိရင်
    if (targetArchitecture == .arm) {
      final sourceZipFile = File(androidLibPath.join('arm.zip'));
      if (sourceZipFile.existsSync()) {
        await extractZip(sourceZipFile, libFile);
        return libFile;
      }
      await downloadLib(androidArmLibUr, sourceZipFile);
      await extractZip(sourceZipFile, libFile);
    }

    if (targetArchitecture == .arm64) {
      final sourceZipFile = File(androidLibPath.join('arm64.zip'));

      if (sourceZipFile.existsSync()) {
        await extractZip(sourceZipFile, libFile);
        return libFile;
      }
      await downloadLib(androidArm64LibUr, sourceZipFile);
      await extractZip(sourceZipFile, libFile);
    }

    return libFile;
  }
  throw UnsupportedError(
    'Os: `$targetOS` - Architecture: `$targetArchitecture`',
  );
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

Future<void> extractZip(File input, File output) async {
  final bytes = input.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile && entry.name.endsWith('.so')) {
      output.parent.createSync(recursive: true);
      await output.writeAsBytes(entry.content, flush: true);
    }
  }
}
