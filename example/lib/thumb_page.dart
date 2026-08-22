import 'package:flutter/material.dart';
import 'package:than_audiotag/core/my_native/workers/tag_picture_worker.dart';

class ThumbPage extends StatelessWidget {
  const ThumbPage({super.key, required this.list});
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thumb Page')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) => item(list[index]),
      ),
    );
  }

  Widget item(String path) {
    return FutureBuilder(
      future: TagPictureWorker.instance.getImageBytes(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        final data = snapshot.data;
        if (data != null) {
          if (data.isErr) {
            return Text('Error: ${data.unwrapError()}');
          }
          return Image.memory(data.unwrap());
        }

        return Text('Unkown Error:');
      },
    );
  }
}
