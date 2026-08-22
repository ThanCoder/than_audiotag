import 'dart:typed_data';

import 'package:than_audiotag/core/chatgpt_native/models/audio_properties.dart';
import 'package:than_audiotag/core/chatgpt_native/models/audio_tag.dart';
import 'package:than_audiotag/core/chatgpt_native/models/cover_art.dart';
import 'package:than_audiotag/core/chatgpt_native/native/taglib_file.dart';
import 'package:than_audiotag/core/chatgpt_native/native/taglib_picture.dart';

class ThanAudioTag {
  final String path;
  final TagLibFile _file;
  late final TagLibPicture _picture;
  bool _closed = false;

  ThanAudioTag._(this.path, this._file) {
    _picture = TagLibPicture(_file.pointer);
  }

  factory ThanAudioTag.open(String path) {
    final file = TagLibFile.open(path);
    return ThanAudioTag._(path, file);
  }
  AudioTag get tag {
    _checkOpen();
    return _file.readTag();
  }

  AudioProperties get properties {
    _checkOpen();
    return _file.readProperties();
  }

  CoverArt? get cover {
    _checkOpen();
    return _picture.read();
  }

  void updateTag({
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? comment,
    int? track,
    int? year,
    bool save = true,
  }) {
    _checkOpen();
    _file.writeTag(
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      comment: comment,
      track: track,
      year: year,
    );
    if (save) {
      _file.save();
    }
  }

  void writeCover(
    Uint8List imageData, {
    String mimeType = 'image/jpeg',
    String description = '',
    String pictureType = 'Front Cover',
    bool save = true,
  }) {
    _checkOpen();
    _picture.write(
      imageData,
      mimeType: mimeType,
      description: description,
      pictureType: pictureType,
    );
    if (save) {
      _file.save();
    }
  }

  void removeCover({bool save = true}) {
    _checkOpen();
    _picture.remove();
    if (save) {
      _file.save();
    }
  }

  void save() {
    _checkOpen();
    _file.save();
  }

  /// ### Frees and closes the file.
  void close() {
    if (_closed) {
      return;
    }
    _file.close();
    _closed = true;
  }

  /// ### Frees and closes the file.
  void dispose() {
    close();
  }

  void _checkOpen() {
    if (_closed) {
      throw StateError('ThanAudioTag is already closed');
    }
  } // ------------------------------------------------------------ // Convenient static API // ------------------------------------------------------------

  static AudioTag read(String path) {
    final audio = ThanAudioTag.open(path);
    try {
      return audio.tag;
    } finally {
      audio.close();
    }
  }

  static AudioProperties readProperties(String path) {
    final audio = ThanAudioTag.open(path);
    try {
      return audio.properties;
    } finally {
      audio.close();
    }
  }

  static CoverArt? readCover(String path) {
    final audio = ThanAudioTag.open(path);
    try {
      return audio.cover;
    } finally {
      audio.close();
    }
  }

  static void writeTags(
    String path, {
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? comment,
    int? track,
    int? year,
  }) {
    final audio = ThanAudioTag.open(path);
    try {
      audio.updateTag(
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        comment: comment,
        track: track,
        year: year,
      );
    } finally {
      audio.close();
    }
  }

  static void writeCoverFile(
    String path,
    Uint8List imageData, {
    String mimeType = 'image/jpeg',
    String description = '',
    String pictureType = 'Front Cover',
  }) {
    final audio = ThanAudioTag.open(path);
    try {
      audio.writeCover(
        imageData,
        mimeType: mimeType,
        description: description,
        pictureType: pictureType,
      );
    } finally {
      audio.close();
    }
  }

  static void removeCoverImage(String path) {
    final audio = ThanAudioTag.open(path);
    try {
      audio.removeCover();
    } finally {
      audio.close();
    }
  }
}
