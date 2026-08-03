class AudioTag {
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String comment;
  final int track;
  final int year;
  const AudioTag({
    this.title = '',
    this.artist = '',
    this.album = '',
    this.genre = '',
    this.comment = '',
    this.track = 0,
    this.year = 0,
  });
  AudioTag copyWith({
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? comment,
    int? track,
    int? year,
  }) {
    return AudioTag(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      comment: comment ?? this.comment,
      track: track ?? this.track,
      year: year ?? this.year,
    );
  }

  @override
  String toString() {
    return 'AudioTag('
        'title: $title, '
        'artist: $artist, '
        'album: $album, '
        'genre: $genre, '
        'comment: $comment, '
        'track: $track, '
        'year: $year'
        ')';
  }
}
