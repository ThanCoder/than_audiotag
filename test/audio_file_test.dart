import 'package:test/test.dart';
import 'package:than_audiotag/than_audiotag.dart';

void main() {
  late TTag tag;

  setUp(() {
    tag = TTag();

    final result = tag.openFile('/home/thancoder/Music/test.mp3');

    expect(result.isOk, true);
    expect(result.unwrap(), true);
  });

  tearDown(() {
    tag.close();
  });

  test('open Audio File', () {
    expect(tag.opened, true);
  });

  // test('audio tags', () {
  //   final t = tag.tag;

  //   expect(t, isA<AuTag>());

  //   expect(t.title, isNotEmpty);
  //   expect(t.album, isNotEmpty);
  //   expect(t.artist, isNotEmpty);
  //   expect(t.comment, isNotEmpty);
  //   expect(t.genre, isNotEmpty);
  //   expect(t.track, isNonZero);
  //   expect(t.year, isNonZero);
  // });

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
