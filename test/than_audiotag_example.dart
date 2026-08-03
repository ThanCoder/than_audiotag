// ignore_for_file: avoid_print, unused_local_variable, unused_import

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:than_audiotag/models/audio_tag.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_audiotag/than_audiotag_bindings_generated.dart';

void main() {
  final name =
      "《芒种》音阙诗听⧸赵方婧 官方高画质 Official HD MV丨Grain in Ear丨Mang Chủng [q2WvTaqe9zU].opus";
  // final name = "Imagine dragons - BABA YAGA (Original Lyric video).mp3";
  // final path = "/home/thancoder/Music/New 2/$name";
  final path =
      "/home/thancoder/Videos/Black Panther Wakanda Forever (2022).mp4";

  // Metadata ဖတ်
  final file = ThanAudioTag.open(path);

  print('title: ${file.tag.title}');
  print('artist: ${file.tag.artist}');
  print('album: ${file.tag.album}');
  print('genre: ${file.tag.genre}');
  print('track: ${file.tag.track}');
  print('year: ${file.tag.year}');
  // Audio properties
  // final info = ThanAudioTag.readProperties(path);
  final info = file.properties;

  print('duration: ${info.duration}');
  print('bitrate: ${info.bitrate}');
  print('sampleRate: ${info.sampleRate}');
  print('channels: ${info.channels}');
  // Cover ဖတ်
  final cover = file.cover;

  if (cover != null) {
    print('cover mimeType: ${cover.mimeType}');
    print('cover length: ${cover.data.length}');
  }

  file.close();

  // final im = File('/home/thancoder/Pictures/logo.png');
  // ThanAudioTag.writeCoverFile(
  //   path,
  //   im.readAsBytesSync(),
  //   mimeType: 'image/png',
  // );
}
