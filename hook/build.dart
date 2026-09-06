import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;
    final srcLib = input.packageRoot.path.join('src').join('lib');
    final assets = input.packageRoot.path
        .join('.dart_tool')
        .join('native_assets');

    late File file;
    if (targetOS == .linux) {
      final zipPath = srcLib.join('linux-64.zip');
      file = File(assets.join('linux').join('libtag.so'));
      await extractLib(zipPath, file);
    } else if (targetOS == .android) {
      if (targetArchitecture == .arm) {
        final zipPath = srcLib.join('android').join('armeabi-v7a.zip');
        file = File(
          assets.join('android').join('armeabi-v7a').join('libtag.so'),
        );
        await extractLib(zipPath, file);

        file = File(srcLib.join('android').join('arm').join('libtag.so'));
      } else if (targetArchitecture == .arm64) {
        final zipPath = srcLib.join('android').join('arm64-v8a.zip');
        file = File(assets.join('android').join('arm64-v8a').join('libtag.so'));
        await extractLib(zipPath, file);
      }
    }

    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: '${packageName}_bindings_generated.dart',
        linkMode: DynamicLoadingBundled(),
        file: file.uri,
      ),
    );
  });
}

extension PathStr on String {
  String join(String name) {
    return '$this${Platform.pathSeparator}$name';
  }
}

Future<void> extractLib(String sourcePath, File outFile) async {
  if (outFile.existsSync()) return;
  final archive = ZipDecoder().decodeBytes(File(sourcePath).readAsBytesSync());

  for (final entry in archive) {
    if (entry.isFile && entry.name.endsWith('.so')) {
      final fileBytes = entry.readBytes()!;
      outFile
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      return;
    }
  }
}
