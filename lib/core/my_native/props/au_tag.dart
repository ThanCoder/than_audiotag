// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../t_tag.dart';

class AuTag {
  final String title;
  final String artist;
  final String album;
  final String comment;
  final String genre;
  final int track;
  final int year;
  const AuTag({
    required this.title,
    required this.artist,
    required this.album,
    required this.comment,
    required this.genre,
    required this.track,
    required this.year,
  });

  factory AuTag.fromPointerTag(Pointer<TagLib_Tag> tag) {
    final title = _getStringOr(_lib.taglib_tag_title(tag));
    final artist = _getStringOr(_lib.taglib_tag_artist(tag));
    final album = _getStringOr(_lib.taglib_tag_album(tag));
    final comment = _getStringOr(_lib.taglib_tag_comment(tag));
    final genre = _getStringOr(_lib.taglib_tag_genre(tag));

    final track = _lib.taglib_tag_track(tag);
    final year = _lib.taglib_tag_year(tag);

    return .new(
      title: title,
      artist: artist,
      album: album,
      comment: comment,
      genre: genre,
      track: track,
      year: year,
    );
  }

  static String _getStringOr(Pointer<Char> ptr) {
    if (ptr == nullptr) return '';
    return ptr.cast<Utf8>().toDartString();
  }

  Result<AuTag, String> updateTag(Pointer<TagLib_Tag> tagPtr) {
    try {
      final titlePtr = title.toNativeUtf8();
      _lib.taglib_tag_set_title(tagPtr, titlePtr.cast<Char>());
      malloc.free(titlePtr);

      final artistPtr = artist.toNativeUtf8();
      _lib.taglib_tag_set_artist(tagPtr, artistPtr.cast<Char>());
      malloc.free(artistPtr);

      final albumPtr = album.toNativeUtf8();
      _lib.taglib_tag_set_album(tagPtr, albumPtr.cast<Char>());
      malloc.free(albumPtr);

      final commentPtr = comment.toNativeUtf8();
      _lib.taglib_tag_set_comment(tagPtr, commentPtr.cast<Char>());
      malloc.free(commentPtr);

      final genrePtr = genre.toNativeUtf8();
      _lib.taglib_tag_set_genre(tagPtr, genrePtr.cast<Char>());
      malloc.free(genrePtr);

      // int
      _lib.taglib_tag_set_track(tagPtr, track);
      _lib.taglib_tag_set_year(tagPtr, year);

      return Ok(this);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  String toString() {
    return 'AuTag(title: $title, artist: $artist, album: $album, comment: $comment, genre: $genre, track: $track, year: $year)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'artist': artist,
      'album': album,
      'comment': comment,
      'genre': genre,
      'track': track,
      'year': year,
    };
  }

  factory AuTag.fromMap(Map<String, dynamic> map) {
    return AuTag(
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      comment: map['comment'] as String,
      genre: map['genre'] as String,
      track: map['track'] as int,
      year: map['year'] as int,
    );
  }

  AuTag copyWith({
    String? title,
    String? artist,
    String? album,
    String? comment,
    String? genre,
    int? track,
    int? year,
  }) {
    return AuTag(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      comment: comment ?? this.comment,
      genre: genre ?? this.genre,
      track: track ?? this.track,
      year: year ?? this.year,
    );
  }
}
