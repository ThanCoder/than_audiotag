// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_audiotag_example/thumb_page.dart';
import 'package:than_pkg/than_pkg.dart';

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
        if (Platform.isAndroid) {
          if (!await ThanPkg.platform.isStoragePermissionGranted()) {
            await ThanPkg.platform.requestStoragePermission();
            return;
          }
        }
        String path = Platform.isAndroid
            ? '/storage/emulated/0/Music'
            : '/home/thancoder/Downloads/Music';
        final dir = Directory(path);
        final exts = ['mp3', 'm4a', 'opus'];
        final list = <String>[];
        for (var f in dir.listSync()) {
          final name = f.path.split('/').last;
          print('name: $name');
          if (f is File && exts.any((e) => name.endsWith('.$e'))) {
            list.add(f.path);
          }
        }
        print(list);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ThumbPage(list: list)),
        );
      },
    );
  }
}
