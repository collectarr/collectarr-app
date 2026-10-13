import 'dart:convert';
import 'dart:typed_data';

/// A validated, upright, static Gilroy face supplied by this device.
class LocalFontFace {
  LocalFontFace._(this.bytes, this.weight, this.name, this.source);
  final Uint8List bytes;
  final int weight;
  final String name;
  final String source;

  factory LocalFontFace.parse(Uint8List bytes, {required String source}) {
    if (bytes.length < 12 || bytes.length > 2 * 1024 * 1024) {
      throw const FormatException('Choose a valid TTF or OTF font under 2 MB.');
    }
    final data = ByteData.sublistView(bytes);
    final signature = data.getUint32(0);
    if (![0x00010000, 0x4f54544f, 0x74727565].contains(signature)) {
      throw const FormatException('Choose an individual TTF or OTF face.');
    }
    final count = data.getUint16(4);
    if (12 + count * 16 > bytes.length) {
      throw const FormatException('The font directory is incomplete.');
    }
    final tables = <String, (int, int)>{};
    for (var i = 0; i < count; i++) {
      final entry = 12 + i * 16;
      final tag = ascii.decode(bytes.sublist(entry, entry + 4));
      final offset = data.getUint32(entry + 8);
      final length = data.getUint32(entry + 12);
      if (offset > bytes.length || length > bytes.length - offset) {
        throw const FormatException('The font contains an invalid table.');
      }
      tables[tag] = (offset, length);
    }
    if (tables.containsKey('fvar')) {
      throw const FormatException(
          'Choose static Gilroy faces, not a variable font.');
    }
    final names = tables['name'];
    final os2 = tables['OS/2'];
    if (names == null || names.$2 < 6 || os2 == null || os2.$2 < 64) {
      throw const FormatException(
          'Font family and weight metadata are missing.');
    }
    final nameCount = data.getUint16(names.$1 + 2);
    final stringOffset = data.getUint16(names.$1 + 4);
    if (6 + nameCount * 12 > names.$2 || stringOffset > names.$2) {
      throw const FormatException('The font name table is incomplete.');
    }
    final values = <int, String>{};
    for (var i = 0; i < nameCount; i++) {
      final record = names.$1 + 6 + i * 12;
      final platform = data.getUint16(record);
      final id = data.getUint16(record + 6);
      final length = data.getUint16(record + 8);
      final start = stringOffset + data.getUint16(record + 10);
      if (start + length > names.$2) {
        throw const FormatException('The font name string is incomplete.');
      }
      final raw = bytes.sublist(names.$1 + start, names.$1 + start + length);
      String text;
      if (platform == 0 || platform == 3) {
        if (length.isOdd) {
          throw const FormatException('Invalid Unicode font name.');
        }
        text = String.fromCharCodes([
          for (var j = 0; j < length; j += 2) (raw[j] << 8) | raw[j + 1],
        ]);
      } else if (platform == 1) {
        text = latin1.decode(raw);
      } else {
        continue;
      }
      values.putIfAbsent(id, () => text);
    }
    final family = values[16] ?? values[1] ?? '';
    if (!RegExp(r'^Gilroy(?:\s|$)', caseSensitive: false).hasMatch(family)) {
      throw const FormatException('Choose Gilroy font files.');
    }
    final style = values[17] ?? values[2] ?? '';
    if ((data.getUint16(os2.$1 + 62) & 1) != 0 ||
        RegExp('italic|oblique', caseSensitive: false).hasMatch(style)) {
      throw const FormatException('Choose upright Gilroy faces, not italics.');
    }
    final weight = data.getUint16(os2.$1 + 4);
    if (weight < 100 || weight > 900 || weight % 100 != 0) {
      throw const FormatException('The font has an unsupported weight.');
    }
    return LocalFontFace._(Uint8List.fromList(bytes).asUnmodifiableView(),
        weight, values[4] ?? family, source);
  }

  Map<String, Object> toJson() => {
        'data': base64Encode(bytes),
        'source': source,
      };
}
