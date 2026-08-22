// ignore_for_file: public_member_api_docs, sort_constructors_first
enum AudioTagErrorCode {
  fileOpenFailed,
  invalidFile,
  tagNotFound,
  audioPropertiesNotFound,
  pictureNotFound,
}

class AudioTagError {
  final AudioTagErrorCode code;
  final String message;
  const AudioTagError({required this.code, required this.message});

  @override
  String toString() => 'AudioTagError(code: $code, message: $message)';
}
