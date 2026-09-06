import 'dart:ffi';

import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

export 'core/chatgpt_native/index.dart';
export 'core/my_native/props/index.dart';
export 'core/my_native/workers/tag_picture_worker.dart';

final _dylib = DynamicLibrary.open('libtag.so');

ThanAudiotagBindings getTag({String? libPath}) {
  DynamicLibrary dylib = _dylib;
  if (libPath != null) {
    dylib = DynamicLibrary.open(libPath);
  }

  // dev
  // final dylib = DynamicLibrary.open(
  //   '/home/thancoder/projects/dart_plugins/than_audiotag/src/lib/linux-64/libtag.so',
  // );

  return ThanAudiotagBindings(dylib);
}
