import 'dart:typed_data';

import 'package:collectarr_app/core/fonts/font_weight.dart';
import 'package:collectarr_app/core/fonts/local_font_face.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_font_fixture.dart';

Map<int, String> _names(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final directory = [
    for (var i = 0; i < data.getUint16(4); i++) 12 + i * 16,
  ].singleWhere((entry) => data.getUint32(entry) == 0x6e616d65);
  final start = data.getUint32(directory + 8);
  final storage = start + data.getUint16(start + 4);
  final result = <int, String>{};
  for (var i = 0; i < data.getUint16(start + 2); i++) {
    final record = start + 6 + i * 12;
    final length = data.getUint16(record + 8);
    final offset = storage + data.getUint16(record + 10);
    result[data.getUint16(record + 6)] = String.fromCharCodes([
      if (data.getUint16(record) == 1)
        ...bytes.sublist(offset, offset + length)
      else
        for (var j = 0; j < length; j += 2) data.getUint16(offset + j),
    ]);
  }
  return result;
}

void main() {
  for (final (weight, style) in [(400, 'Regular'), (500, 'Medium')]) {
    test('weight $weight also updates DirectWrite subfamily metadata', () {
      final original = fontFixture(weight: 600, subfamily: 'SemiBold');
      final saved = Uint8List.fromList(original);
      final result = fontBytesAtWeight(original, weight);
      expect(fontWeight(result), weight);
      expect(_names(result)[2], style);
      expect(_names(result)[17], style);
      expect(_names(result)[1], _names(original)[1]);
      expect(_names(result)[4], _names(original)[4]);
      expect(LocalFontFace.parse(result, source: 'Imported').weight, weight);
      expect(original, saved);
    });
  }

  test('longer style names and files without typographic subfamilies work', () {
    final result = fontBytesAtWeight(fontFixture(subfamily: 'Light'), 800);
    expect(_names(result)[2], 'ExtraBold');
    expect(_names(result)[17], 'ExtraBold');
    expect(_names(fontBytesAtWeight(fontFixture(), 500))[2], 'Medium');
    expect(
        _names(fontBytesAtWeight(fontFixture(), 500)).containsKey(17), false);
  });

  for (final platform in [0, 1, 3]) {
    test('platform $platform names retain encoding and language tags', () {
      final original = fontFixture(
          weight: 600,
          subfamily: 'SemiBold',
          namePlatform: platform,
          languageTaggedNames: true);
      final result = fontBytesAtWeight(original, 400);
      expect(_names(result)[2], 'Regular');
      expect(_names(result)[17], 'Regular');
      final data = ByteData.sublistView(result);
      final entries = [for (var i = 0; i < data.getUint16(4); i++) 12 + i * 16];
      final name = data.getUint32(
          entries.singleWhere((e) => data.getUint32(e) == 0x6e616d65) + 8);
      expect(data.getUint16(name), 1);
      final tags = name + 6 + data.getUint16(name + 2) * 12;
      expect(data.getUint16(tags), 1);
      final length = data.getUint16(tags + 2);
      final start = name + data.getUint16(name + 4) + data.getUint16(tags + 4);
      expect(
          String.fromCharCodes([
            for (var i = 0; i < length; i += 2) data.getUint16(start + i),
          ]),
          'en-US');
    });
  }

  test('repacked tables are aligned and the whole-font checksum stays valid',
      () {
    final result =
        fontBytesAtWeight(fontFixture(weight: 600, subfamily: 'SemiBold'), 400);
    final data = ByteData.sublistView(result);
    for (var i = 0; i < data.getUint16(4); i++) {
      expect(data.getUint32(12 + i * 16 + 8) % 4, 0);
    }
    var checksum = 0;
    for (var i = 0; i < result.length; i += 4) {
      checksum = (checksum + data.getUint32(i)) & 0xffffffff;
    }
    expect(checksum, 0xb1b0afba);
  });
}
