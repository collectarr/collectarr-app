import 'dart:typed_data';

Uint8List fontFixture(
    {int weight = 400,
    String family = 'Gilroy',
    String? subfamily,
    int namePlatform = 3,
    bool languageTaggedNames = false,
    bool italic = false,
    bool variable = false}) {
  final strings = <int, String>{
    1: family,
    2: subfamily ?? (italic ? 'Italic' : 'Regular'),
    4: '$family $weight',
    16: family,
    if (subfamily != null) 17: subfamily,
  };
  final raw = <int>[];
  final records = <List<int>>[];
  for (final entry in strings.entries) {
    final bytes = namePlatform == 1
        ? entry.value.codeUnits
        : [
            for (final c in entry.value.codeUnits) ...[c >> 8, c & 255]
          ];
    records.add([entry.key, bytes.length, raw.length]);
    raw.addAll(bytes);
  }
  final tables = variable ? 4 : 3;
  final head = 12 + tables * 16;
  final os2 = head + 56;
  final name = os2 + 64;
  final language = languageTaggedNames
      ? [
          for (final c in 'en-US'.codeUnits) ...[0, c]
        ]
      : <int>[];
  final stringOffset = 6 + records.length * 12 + (languageTaggedNames ? 6 : 0);
  final nameLength = stringOffset + raw.length + language.length;
  final bytes = Uint8List(name + nameLength);
  final data = ByteData.sublistView(bytes);
  data.setUint32(0, 0x00010000);
  data.setUint16(4, tables);
  void table(int index, int tag, int offset, int length) {
    final entry = 12 + index * 16;
    data.setUint32(entry, tag);
    data.setUint32(entry + 8, offset);
    data.setUint32(entry + 12, length);
  }

  table(0, 0x4f532f32, os2, 64);
  table(1, 0x6e616d65, name, nameLength);
  table(2, 0x68656164, head, 54);
  if (variable) table(3, 0x66766172, 0, 0);
  data.setUint16(os2 + 4, weight);
  data.setUint16(os2 + 62, italic ? 1 : 0);
  data.setUint16(name, languageTaggedNames ? 1 : 0);
  data.setUint16(name + 2, records.length);
  data.setUint16(name + 4, stringOffset);
  for (var i = 0; i < records.length; i++) {
    final record = name + 6 + i * 12;
    data.setUint16(record, namePlatform);
    data.setUint16(record + 2, 1);
    data.setUint16(record + 4, languageTaggedNames ? 0x8000 : 0x409);
    data.setUint16(record + 6, records[i][0]);
    data.setUint16(record + 8, records[i][1]);
    data.setUint16(record + 10, records[i][2]);
  }
  bytes.setRange(name + stringOffset, name + stringOffset + raw.length, raw);
  if (languageTaggedNames) {
    final tags = name + 6 + records.length * 12;
    data.setUint16(tags, 1);
    data.setUint16(tags + 2, language.length);
    data.setUint16(tags + 4, raw.length);
    bytes.setRange(name + stringOffset + raw.length, bytes.length, language);
  }
  return bytes;
}

int fontWeight(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  for (var i = 0; i < data.getUint16(4); i++) {
    final entry = 12 + i * 16;
    if (data.getUint32(entry) == 0x4f532f32) {
      return data.getUint16(data.getUint32(entry + 8) + 4);
    }
  }
  throw StateError('No OS/2 table');
}
