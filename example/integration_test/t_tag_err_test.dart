import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:than_audiotag/core/my_native/props/types.dart';
import 'package:than_audiotag/core/my_native/t_tag.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test("Open", () {
    final f = TTag();
    final res = f.openFile('not-found-audio.mp3');

    expect(res.isErr, true);
    expect(f.opened, false);

    final err = res.unwrapError();
    expect(err, isA<AudioTagError>());
    expect(err.code, isA<AudioTagErrorCode>());
    expect(err.message, isNotEmpty);
  });

  test("Tag", () {
    final f = TTag();
    final res = f.openFile('not-found-audio.mp3');

    expect(res.isErr, true);

    final tagRes = f.tag;

    expect(tagRes.isErr, true);
    expect(tagRes.unwrapError(), isNotEmpty);
  });
  test("Properties", () {
    final f = TTag();
    final res = f.openFile('not-found-audio.mp3');

    expect(res.isErr, true);

    final prps = f.readProperties;
    expect(prps.isErr, true);

    final err = prps.unwrapError();
    expect(err, isA<AudioTagError>());
  });
  test("Picture", () {
    final f = TTag();
    final res = f.openFile('not-found-audio.mp3');

    expect(res.isErr, true);

    final pic = f.readPicture;
    expect(pic.isErr, true);

    final err = pic.unwrapError();
    expect(err, isA<AudioTagError>());
  });
}
