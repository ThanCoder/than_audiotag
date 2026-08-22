import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

final lib = getTag();

class TagLibFile {
  final ffi.Pointer<TagLib_File> pointer;
  bool _closed = false;
  TagLibFile._(this.pointer);

  factory TagLibFile.open(String path) {
    final pathPtr = path.toNativeUtf8();
    try {
      final pointer = lib.taglib_file_new(pathPtr.cast());
      if (pointer == ffi.nullptr) {
        throw StateError('TagLib cannot open file: $path');
      }
      if (lib.taglib_file_is_valid(pointer) == 0) {
        lib.taglib_file_free(pointer);
        throw StateError('Invalid or unsupported audio file: $path');
      }
      return TagLibFile._(pointer);
    } finally {
      calloc.free(pathPtr);
    }
  }
  bool get isClosed => _closed;
  void _checkOpen() {
    if (_closed) {
      throw StateError('TagLibFile is already closed');
    }
  }

  AudioTag readTag() {
    _checkOpen();
    final tag = lib.taglib_file_tag(pointer);
    if (tag == ffi.nullptr) {
      return const AudioTag();
    }
    return AudioTag(
      title: _readString(lib.taglib_tag_title(tag)),
      artist: _readString(lib.taglib_tag_artist(tag)),
      album: _readString(lib.taglib_tag_album(tag)),
      genre: _readString(lib.taglib_tag_genre(tag)),
      comment: _readString(lib.taglib_tag_comment(tag)),
      track: lib.taglib_tag_track(tag),
      year: lib.taglib_tag_year(tag),
    );
  }

  AudioProperties readProperties() {
    _checkOpen();
    final properties = lib.taglib_file_audioproperties(pointer);
    if (properties == ffi.nullptr) {
      return const AudioProperties();
    }
    return AudioProperties(
      duration: lib.taglib_audioproperties_length(properties),
      bitrate: lib.taglib_audioproperties_bitrate(properties),
      sampleRate: lib.taglib_audioproperties_samplerate(properties),
      channels: lib.taglib_audioproperties_channels(properties),
    );
  }

  void writeTag({
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? comment,
    int? track,
    int? year,
  }) {
    _checkOpen();
    final tag = lib.taglib_file_tag(pointer);
    if (tag == ffi.nullptr) {
      throw StateError('Tag is unavailable');
    }
    if (title != null) {
      _setString(title, (value) => lib.taglib_tag_set_title(tag, value));
    }
    if (artist != null) {
      _setString(artist, (value) => lib.taglib_tag_set_artist(tag, value));
    }
    if (album != null) {
      _setString(album, (value) => lib.taglib_tag_set_album(tag, value));
    }
    if (genre != null) {
      _setString(genre, (value) => lib.taglib_tag_set_genre(tag, value));
    }
    if (comment != null) {
      _setString(comment, (value) => lib.taglib_tag_set_comment(tag, value));
    }
    if (track != null) {
      lib.taglib_tag_set_track(tag, track);
    }
    if (year != null) {
      lib.taglib_tag_set_year(tag, year);
    }
  }

  void save() {
    _checkOpen();
    final result = lib.taglib_file_save(pointer);
    if (result == 0) {
      throw StateError('TagLib failed to save file');
    }
  }

  /// ### Frees and closes the file.
  void close() {
    if (_closed) {
      return;
    }
    lib.taglib_file_free(pointer);
    _closed = true;
  }

  void dispose() {
    close();
  }

  static String _readString(ffi.Pointer<ffi.Char> pointer) {
    if (pointer == ffi.nullptr) {
      return '';
    }
    return pointer.cast<Utf8>().toDartString();
  }

  static void _setString(
    String value,
    void Function(ffi.Pointer<ffi.Char>) setter,
  ) {
    final ptr = value.toNativeUtf8();
    try {
      setter(ptr.cast());
    } finally {
      calloc.free(ptr);
    }
  }
}
