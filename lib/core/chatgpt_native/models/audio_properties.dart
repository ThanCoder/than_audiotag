class AudioProperties {
  /// ### Returns the length of the file in seconds.
  final int duration;

  /// ### Returns the bitrate of the file in kb/s.
  final int bitrate;

  /// ### Returns the sample rate of the file in Hz.
  final int sampleRate;

  /// ### Returns the number of channels in the audio stream.
  final int channels;
  const AudioProperties({
    this.duration = 0,
    this.bitrate = 0,
    this.sampleRate = 0,
    this.channels = 0,
  });

  Duration get durationAsDuration {
    return Duration(seconds: duration);
  }

  @override
  String toString() {
    return 'AudioProperties('
        'duration: $duration, '
        'bitrate: $bitrate, '
        'sampleRate: $sampleRate, '
        'channels: $channels'
        ')';
  }
}
