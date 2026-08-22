// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:than_audiotag/core/my_native/result_t.dart';
import 'package:than_audiotag/core/my_native/t_tag.dart';

part 'tag_picture_bg_worker.dart';

class TagPictureWorker {
  static final TagPictureWorker instance = TagPictureWorker._();
  TagPictureWorker._();
  factory TagPictureWorker() => instance;

  Isolate? _isolate;
  SendPort? _workerPort;
  int _calledCount = 0;

  /// read && save
  Future<Result<bool, String>> generate(
    String path,
    String outpath, {
    bool isOverride = false,
  }) async {
    final f = File(outpath);
    if (isOverride == false && f.existsSync()) return Ok(false);

    _closeTimer?.cancel();

    _calledCount++;

    final rec = ReceivePort();
    try {
      await _init();

      _workerPort?.send({
        'reply': rec.sendPort,
        'command': TagPictureBgWorkerCommand.generate,
        'path': path,
        'outpath': outpath,
      });

      final map = await rec.first as Map;
      bool success = map['success'] ?? false;
      if (!success) {
        final message = map['message'] as String;
        return Err(message);
      }
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    } finally {
      rec.close();
      _calledCount--;
      if (_calledCount == 0) {
        // exists
        _autoCloseTimer();
      }
    }
  }

  /// read && bytes
  Future<Result<Uint8List, String>> getImageBytes(String path) async {
    _closeTimer?.cancel();

    _calledCount++;

    final rec = ReceivePort();
    try {
      await _init();

      _workerPort?.send({
        'reply': rec.sendPort,
        'command': TagPictureBgWorkerCommand.reqImageBytes,
        'path': path,
      });

      final map = await rec.first as Map;
      bool success = map['success'] as bool;
      if (!success) {
        final message = map['message'] as String;
        return Err(message);
      }
      final data = map['data'] as TransferableTypedData;

      return Ok(data.materialize().asUint8List());
    } catch (e) {
      return Err(e.toString());
    } finally {
      rec.close();
      _calledCount--;
      if (_calledCount == 0) {
        // exists
        _autoCloseTimer();
      }
    }
  }

  Completer<void>? _completer;
  Future<void> _init() async {
    if (_workerPort != null) {
      return;
    }
    if (_completer != null) {
      return await _completer?.future;
    }
    _completer = Completer();
    try {
      await _initIsolate();
      _completer?.complete();
      _completer = null;
    } catch (e) {
      _completer?.completeError(e);
      _completer = null;
    }
  }

  Future<void> _initIsolate() async {
    final rec = ReceivePort();
    _isolate = await Isolate.spawn(_tagPicturBgWroker, rec.sendPort);
    _workerPort = await rec.first as SendPort;
    rec.close();
    print('[TagPictureWorker:_initIsolate]: isolate initalized!');
  }

  Timer? _closeTimer;
  void _autoCloseTimer() {
    _closeTimer?.cancel();
    print('[TagPictureWorker:_autoCloseTimer]: 5 secs waiting.....');
    _closeTimer = Timer(Duration(seconds: 5), close);
  }

  Future<void> close({bool waitClose = true}) async {
    try {
      final rec = ReceivePort();
      _workerPort?.send({
        'reply': rec.sendPort,
        'command': TagPictureBgWorkerCommand.close,
      });
      // wait return
      if (waitClose) {
        // print('req close bg');
        await rec.first;
      }
      rec.close();
    } catch (e) {
      print('[TagPictureWorker:close]: Wait Kill Error!: $e');
    } finally {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _workerPort = null;
      _completer = null;
      print('[TagPictureWorker:close]: isolate closed!');
    }
  }
}
