import 'dart:ffi';

import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

export 'core/chatgpt_native/index.dart';
export 'core/my_native/props/index.dart';
export 'core/my_native/workers/tag_picture_worker.dart';

ThanAudiotagBindings getTag({String? libPath}) {
  if (libPath != null) {
    return ThanAudiotagBindings(DynamicLibrary.open(libPath));
  }
  // final dylib = DynamicLibrary.open('libtag.so');

  final dylib = DynamicLibrary.open(
    '/home/thancoder/Downloads/taglib-v1.13.1-native-so/libtag.so',
  );

  return ThanAudiotagBindings(dylib);
}
