import 'dart:io';

String get libName {
  if (Platform.isWindows) {
    return 'libthan_audiotag.dll';
  }

  return 'libthan_audiotag.so';
}

const String linuxLibUrl =
    'https://github.com/ThanCoder/than_audiotag/releases/download/taglib-2.3.2-native-so/taglib-2.3.2-native-so-linux.zip';
const String windowLibUrl =
    'https://github.com/ThanCoder/than_audiotag/releases/download/taglib-2.3.2-native-so/taglib-2.3.2-native-so-window.zip';
const String androidArmLibUrl =
    'https://github.com/ThanCoder/than_audiotag/releases/download/taglib-2.3.2-native-so/taglib-2.3.2-native-so-android-arm.zip';
const String androidArm64LibUrl =
    'https://github.com/ThanCoder/than_audiotag/releases/download/taglib-2.3.2-native-so/taglib-2.3.2-native-so-android-arm64.zip';
