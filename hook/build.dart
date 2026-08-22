import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;
    final srcLib = input.packageRoot.path.join('src').join('lib');
    late File file;
    if (targetOS == .linux) {
      file = File(srcLib.join('linux-64').join('libtag.so'));
    } else if (targetOS == .android) {
      if (targetArchitecture == .arm) {
        file = File(srcLib.join('android').join('arm').join('libtag.so'));
      } else if (targetArchitecture == .arm64) {
        file = File(srcLib.join('android').join('arm64').join('libtag.so'));
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
