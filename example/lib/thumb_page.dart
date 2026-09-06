import 'package:flutter/material.dart';
import 'package:than_audiotag/core/my_native/workers/tag_picture_worker.dart';
import 'package:than_audiotag_example/meta_info_page.dart';

class ThumbPage extends StatefulWidget {
  const ThumbPage({super.key, required this.list});
  final List<String> list;

  @override
  State<ThumbPage> createState() => _ThumbPageState();
}

class _ThumbPageState extends State<ThumbPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thumb Page')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
        ),
        itemCount: widget.list.length,
        itemBuilder: (context, index) => item(widget.list[index]),
      ),
    );
  }

  Widget item(String path) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MetaInfoPage(path: path)),
        );
      },
      child: FutureBuilder(
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
      ),
    );
  }
}
