import 'package:flutter/material.dart';
import 'package:than_audiotag/core/my_native/t_tag.dart';

class MetaInfoPage extends StatefulWidget {
  const MetaInfoPage({super.key, required this.path});

  final String path;

  @override
  State<MetaInfoPage> createState() => _MetaInfoPageState();
}

class _MetaInfoPageState extends State<MetaInfoPage> {
  final tag = TTag();
  @override
  void initState() {
    tag.openFile(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    tag.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Info')),
      body: Column(
        crossAxisAlignment: .start,
        children: [tagWidget, Divider(), propsWidget],
      ),
    );
  }

  Widget get tagWidget {
    final res = tag.tag;
    if (res.isErr) {
      return Text('Error: ${res.unwrapError()}');
    }
    final t = res.unwrap();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('title: ${t.title}'),
        Text('album: ${t.album}'),
        Text('artist: ${t.artist}'),
        Text('comment: ${t.comment}'),
        Text('genre: ${t.genre}'),
        Text('track: ${t.track}'),
        Text('year: ${t.year}'),
      ],
    );
  }

  Widget get propsWidget {
    final res = tag.readProperties;
    if (res.isErr) {
      return Text('Error: ${res.unwrapError()}');
    }
    final t = res.unwrap();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('bitrate: ${t.bitrate}'),
        Text('channels: ${t.channels}'),
        Text('duration: ${t.duration}'),
        Text('samplerate: ${t.samplerate}'),
      ],
    );
  }
}
