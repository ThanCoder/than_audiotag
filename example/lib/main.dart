// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_audiotag_example/thumb_page.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Placeholder(), floatingActionButton: _btn());
  }

  FloatingActionButton _btn() {
    return FloatingActionButton(
      onPressed: () async {
        final dir = Directory('/home/thancoder/Music/New 2');

        final list = <String>[];
        for (var f in dir.listSync()) {
          if (f is File) {
            list.add(f.path);
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ThumbPage(list: list)),
        );
      },
    );
  }
}
