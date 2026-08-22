import 'dart:ffi';

import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

export 'core/chatgpt_native/index.dart';
export 'core/my_native/index.dart';

ThanAudiotagBindings getTag({String? libPath}) {
  final dynamicLibrary = DynamicLibrary.open(libPath ?? 'libtag.so');
  return ThanAudiotagBindings(dynamicLibrary);
}
