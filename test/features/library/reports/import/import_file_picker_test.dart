import 'dart:convert';
import 'dart:typed_data';
import 'package:collectarr_app/features/library/reports/import/import_file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'import files decode UTF-8 and both UTF-16 byte orders without losing Unicode',
      () {
    const text = 'Title,Artist\n\u015ee\u97f3\ud83c\udfb5,Mira';
    expect(
        decodeImportFile(
            Uint8List.fromList([0xef, 0xbb, 0xbf, ...utf8.encode(text)])),
        text);
    for (final endian in [Endian.little, Endian.big]) {
      final bytes = Uint8List(2 + text.codeUnits.length * 2);
      final data = ByteData.sublistView(bytes)..setUint16(0, 0xfeff, endian);
      for (var i = 0; i < text.codeUnits.length; i++) {
        data.setUint16(2 + i * 2, text.codeUnits[i], endian);
      }
      expect(decodeImportFile(bytes), text);
    }
    expect(() => decodeImportFile(Uint8List.fromList([0xff, 0xfe, 0x41])),
        throwsFormatException);
    expect(() => decodeImportFile(Uint8List.fromList([0xc3])),
        throwsFormatException);
  });
}
