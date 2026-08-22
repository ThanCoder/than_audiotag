import 'package:test/test.dart';
import 'package:than_audiotag/core/my_native/t_tag.dart';
import 'package:than_audiotag/core/my_native/props/types.dart';

void main() {
  late TTag tag;

  setUp(() {
    tag = TTag();
  });

  tearDown(() {
    tag.close();
  });

  test('Audio File Error', () {
    final result = tag.openFile('test-not-found.mp3');

    expect(result.isErr, true);
    expect(result.unwrapError(), isA<AudioTagError>());
    expect(result.unwrapError().code, isA<AudioTagErrorCode>());
  });
}
