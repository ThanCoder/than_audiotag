part of '../t_tag.dart';

class AuProperties {
  const AuProperties({
    required this.bitrate,
    required this.channels,
    required this.duration,
    required this.samplerate,
  });

  ///! Returns the bitrate of the file in kb/s.
  final int bitrate;

  ///! Returns the number of channels in the audio stream.
  final int channels;

  ///! Returns the length of the file in seconds.
  final int duration;

  ///! Returns the sample rate of the file in Hz.
  final int samplerate;

  factory AuProperties.fromPointer(Pointer<TagLib_AudioProperties> pros) {
    final bitrate = _lib.taglib_audioproperties_bitrate(pros);
    final channels = _lib.taglib_audioproperties_channels(pros);
    final duration = _lib.taglib_audioproperties_length(pros);
    final samplerate = _lib.taglib_audioproperties_samplerate(pros);
    return .new(
      bitrate: bitrate,
      channels: channels,
      duration: duration,
      samplerate: samplerate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bitrate': bitrate,
      'channels': channels,
      'duration': duration,
      'samplerate': samplerate,
    };
  }

  factory AuProperties.fromMap(Map<String, dynamic> map) {
    return AuProperties(
      bitrate: map['bitrate'] as int,
      channels: map['channels'] as int,
      duration: map['duration'] as int,
      samplerate: map['samplerate'] as int,
    );
  }

  @override
  String toString() {
    return 'AuProperties(bitrate: $bitrate, channels: $channels, duration: $duration, samplerate: $samplerate)';
  }
}
