import 'dart:typed_data';
import 'package:collectarr_app/core/fonts/local_font_face.dart';
import 'package:flutter_test/flutter_test.dart';
import 'local_font_fixture.dart';

void main() {
  test('reads actual family and weight metadata, not a filename', () {
    final face =
        LocalFontFace.parse(fontFixture(weight: 600), source: 'Imported');
    expect(face.weight, 600);
    expect(face.name, 'Gilroy 600');
    expect(() => face.bytes[0] = 0, throwsUnsupportedError);
  });
  for (final scenario in [
    'unrelated',
    'italic',
    'variable',
    'weight',
    'truncated',
    'signature',
    'offset'
  ]) {
    test('rejects $scenario face before registration', () {
      var bytes = fontFixture(
          family: scenario == 'unrelated' ? 'Other' : 'Gilroy',
          italic: scenario == 'italic',
          variable: scenario == 'variable',
          weight: scenario == 'weight' ? 425 : 400);
      if (scenario == 'truncated') {
        bytes = Uint8List.fromList(bytes.sublist(0, 40));
      }
      if (scenario == 'signature') bytes[0] = 255;
      if (scenario == 'offset') {
        ByteData.sublistView(bytes).setUint32(20, 0xffffffff);
      }
      expect(() => LocalFontFace.parse(bytes, source: 'Imported'),
          throwsFormatException);
    });
  }
}
