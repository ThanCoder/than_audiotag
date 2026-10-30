import 'dart:ffi';

import 'package:than_audiotag/keys.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

export 'core/chatgpt_native/index.dart';
export 'core/my_native/props/index.dart';
export 'core/my_native/workers/tag_picture_worker.dart';

///
/// custom path => `getTag(libPath: 'custom path');`
///
ThanAudiotagBindings getTagLib({String? libPath}) {
  if (libPath != null) {
    return ThanAudiotagBindings(DynamicLibrary.open(libPath));
  }

  final dylib = DynamicLibrary.open(libName);

  return ThanAudiotagBindings(dylib);
}
