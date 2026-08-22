part of 'tag_picture_worker.dart';

enum TagPictureBgWorkerCommand { generate, reqImageBytes, close }

Future<void> _tagPicturBgWroker(SendPort mainPort) async {
  final rec = ReceivePort();
  mainPort.send(rec.sendPort);

  rec.listen((map) {
    final reply = map['reply'] as SendPort;
    final command = map['command'] as TagPictureBgWorkerCommand;

    if (command == .generate) {
      final path = map['path'] as String;
      final outpath = map['outpath'] as String;
      //tag
      final t = TTag();
      final res = t.openFile(path);
      if (res.isErr) {
        reply.send({'success': false, 'message': res.unwrapError().message});
        return;
      }
      final ipcRes = t.savePicture(outpath);
      if (ipcRes.isErr) {
        t.close();
        reply.send({'success': false, 'message': ipcRes.unwrapError()});
        return;
      }
      t.close();
      reply.send({'success': true, 'message': 'writed'});
    }
    if (command == .reqImageBytes) {
      final path = map['path'] as String;
      //tag
      final t = TTag();
      final res = t.openFile(path);
      if (res.isErr) {
        reply.send({'success': false, 'message': res.unwrapError().message});
        return;
      }
      final ipcRes = t.readPicture;
      if (ipcRes.isErr) {
        t.close();
        reply.send({'success': false, 'message': ipcRes.unwrapError().message});
        return;
      }
      t.close();
      reply.send({
        'success': true,
        'data': TransferableTypedData.fromList([ipcRes.unwrap().data]),
      });
    }
    if (command == .close) {
      rec.close();
      reply.send(true);
    }
  });
}
