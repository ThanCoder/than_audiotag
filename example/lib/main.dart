// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:than_audiotag/core/chatgpt_native/than_audio_tag.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final name =
              "《芒种》音阙诗听⧸赵方婧 官方高画质 Official HD MV丨Grain in Ear丨Mang Chủng [q2WvTaqe9zU].opus";
          // final name = "Imagine dragons - BABA YAGA (Original Lyric video).mp3";
          final path = "/home/thancoder/Music/New 2/$name";
          // final path =
          //     "/home/thancoder/Videos/Black Panther Wakanda Forever (2022).mp4";

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
        },
      ),
    );
  }
}
