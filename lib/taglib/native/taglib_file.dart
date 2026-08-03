import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:than_audiotag/models/audio_properties.dart';
import 'package:than_audiotag/models/audio_tag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

class TagLibFile {
  final ffi.Pointer<TagLib_File> pointer;
  bool _closed = false;
  TagLibFile._(this.pointer);

  factory TagLibFile.open(String path) {
    final pathPtr = path.toNativeUtf8();
    try {
      final pointer = taglib_file_new(pathPtr.cast());
      if (pointer == ffi.nullptr) {
        throw StateError('TagLib cannot open file: $path');
      }
      if (taglib_file_is_valid(pointer) == 0) {
        taglib_file_free(pointer);
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
    final tag = taglib_file_tag(pointer);
    if (tag == ffi.nullptr) {
      return const AudioTag();
    }
    return AudioTag(
      title: _readString(taglib_tag_title(tag)),
      artist: _readString(taglib_tag_artist(tag)),
      album: _readString(taglib_tag_album(tag)),
      genre: _readString(taglib_tag_genre(tag)),
      comment: _readString(taglib_tag_comment(tag)),
      track: taglib_tag_track(tag),
      year: taglib_tag_year(tag),
    );
  }

  AudioProperties readProperties() {
    _checkOpen();
    final properties = taglib_file_audioproperties(pointer);
    if (properties == ffi.nullptr) {
      return const AudioProperties();
    }
    return AudioProperties(
      duration: taglib_audioproperties_length(properties),
      bitrate: taglib_audioproperties_bitrate(properties),
      sampleRate: taglib_audioproperties_samplerate(properties),
      channels: taglib_audioproperties_channels(properties),
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
    final tag = taglib_file_tag(pointer);
    if (tag == ffi.nullptr) {
      throw StateError('Tag is unavailable');
    }
    if (title != null) {
      _setString(title, (value) => taglib_tag_set_title(tag, value));
    }
    if (artist != null) {
      _setString(artist, (value) => taglib_tag_set_artist(tag, value));
    }
    if (album != null) {
      _setString(album, (value) => taglib_tag_set_album(tag, value));
    }
    if (genre != null) {
      _setString(genre, (value) => taglib_tag_set_genre(tag, value));
    }
    if (comment != null) {
      _setString(comment, (value) => taglib_tag_set_comment(tag, value));
    }
    if (track != null) {
      taglib_tag_set_track(tag, track);
    }
    if (year != null) {
      taglib_tag_set_year(tag, year);
    }
  }

  void save() {
    _checkOpen();
    final result = taglib_file_save(pointer);
    if (result == 0) {
      throw StateError('TagLib failed to save file');
    }
  }

  /// ### Frees and closes the file.
  void close() {
    if (_closed) {
      return;
    }
    taglib_file_free(pointer);
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
