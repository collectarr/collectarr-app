import 'dart:typed_data';

Uint8List fontFixture(
    {int weight = 400,
    String family = 'Gilroy',
    bool italic = false,
    bool variable = false}) {
  final strings = <int, String>{
    1: family,
    2: italic ? 'Italic' : 'Regular',
    4: '$family $weight',
    16: family
  };
  final raw = <int>[];
  final records = <List<int>>[];
  for (final entry in strings.entries) {
    final bytes = [
      for (final c in entry.value.codeUnits) ...[c >> 8, c & 255]
    ];
    records.add([entry.key, bytes.length, raw.length]);
    raw.addAll(bytes);
  }
  final tables = variable ? 3 : 2;
  final os2 = 12 + tables * 16;
  final name = os2 + 64;
  final nameLength = 6 + records.length * 12 + raw.length;
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
  if (variable) table(2, 0x66766172, 0, 0);
  data.setUint16(os2 + 4, weight);
  data.setUint16(os2 + 62, italic ? 1 : 0);
  data.setUint16(name + 2, records.length);
  data.setUint16(name + 4, 6 + records.length * 12);
  for (var i = 0; i < records.length; i++) {
    final record = name + 6 + i * 12;
    data.setUint16(record, 3);
    data.setUint16(record + 2, 1);
    data.setUint16(record + 4, 0x409);
    data.setUint16(record + 6, records[i][0]);
    data.setUint16(record + 8, records[i][1]);
    data.setUint16(record + 10, records[i][2]);
  }
  bytes.setRange(name + 6 + records.length * 12, bytes.length, raw);
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
