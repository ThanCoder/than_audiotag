import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:than_audiotag/core/my_native/t_tag.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final dir = await getTemporaryDirectory();
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final file = File('${dir.path}/test.m4a');

  if (!file.existsSync()) {
    final data = await rootBundle.load('assets/test.m4a');
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  late TTag tag;

  setUp(() {
    tag = TTag();

    final result = tag.openFile(file.path);

    expect(result.isOk, true);
    expect(result.unwrap(), true);
  });

  tearDown(() {
    tag.close();
  });

  test('open Audio File', () {
    expect(tag.opened, true);
  });

  test('tags', () {
    final res = tag.tag;

    expect(res.isOk, true);
    final t = res.unwrap();

    expect(t, isA<AuTag>());

    expect(t.title, isNotEmpty);
    expect(t.album, isNotEmpty);
    expect(t.artist, isNotEmpty);
    expect(t.comment, isNotEmpty);
    expect(t.genre, isNotEmpty);
    expect(t.track, isNonZero);
    expect(t.year, isNonZero);
  });

  test('read audio properties', () {
    final res = tag.readProperties;

    expect(res.isOk, true);

    final props = res.unwrap();

    expect(props, isA<AuProperties>());

    expect(props.bitrate, greaterThan(0));
    expect(props.channels, greaterThan(0));
    expect(props.samplerate, greaterThan(0));
    expect(props.duration, greaterThan(0));
  });
  test('read audio picture', () {
    final pic = tag.readPicture;

    expect(pic.isOk, true);
    expect(pic.unwrap(), isA<AuPicture>());
  });
}
