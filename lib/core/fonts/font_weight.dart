import 'dart:typed_data';

/// Registers a copy in an explicit engine weight slot, like a CSS font-face.
/// Glyph tables and the caller's original bytes remain unchanged.
Uint8List fontBytesAtWeight(Uint8List input, int weight) {
  if (weight < 100 || weight > 900 || weight % 100 != 0) {
    throw ArgumentError.value(weight, 'weight', 'Expected 100 through 900');
  }
  final original = ByteData.sublistView(input);
  final count = original.getUint16(4);
  final tables = <(int, Uint8List)>[];
  var size = 12 + count * 16;
  for (var i = 0; i < count; i++) {
    final entry = 12 + i * 16;
    final tag = original.getUint32(entry);
    final offset = original.getUint32(entry + 8);
    final length = original.getUint32(entry + 12);
    var table = Uint8List.fromList(input.sublist(offset, offset + length));
    if (tag == 0x4f532f32) {
      ByteData.sublistView(table).setUint16(4, weight);
    } else if (tag == 0x6e616d65) {
      table = _nameTableAtWeight(table, weight);
    } else if (tag == 0x68656164) {
      ByteData.sublistView(table).setUint32(8, 0);
    }
    tables.add((tag, table));
    size += (table.length + 3) & ~3;
  }
  final bytes = Uint8List(size);
  bytes.setRange(0, 12, input);
  final data = ByteData.sublistView(bytes);
  var offset = 12 + count * 16;
  int? head;
  for (final (i, (tag, table)) in tables.indexed) {
    final entry = 12 + i * 16;
    data.setUint32(entry, tag);
    data.setUint32(entry + 4, _checksum(table, 0, table.length));
    data.setUint32(entry + 8, offset);
    data.setUint32(entry + 12, table.length);
    bytes.setRange(offset, offset + table.length, table);
    if (tag == 0x68656164) head = offset;
    offset += (table.length + 3) & ~3;
  }
  if (head == null) {
    throw const FormatException('Font lacks a head table.');
  }
  data.setUint32(
      head + 8, (0xb1b0afba - _checksum(bytes, 0, bytes.length)) & 0xffffffff);
  return bytes;
}

Uint8List _nameTableAtWeight(Uint8List input, int weight) {
  final original = ByteData.sublistView(input);
  final count = original.getUint16(2);
  final stringOffset = original.getUint16(4);
  final records = Uint8List.fromList(input.sublist(0, stringOffset));
  final data = ByteData.sublistView(records);
  // Preserve other names and format-1 language tags at their existing offsets.
  final strings = BytesBuilder()..add(input.sublist(stringOffset));
  const styles = [
    'Thin',
    'ExtraLight',
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'Black',
  ];
  final style = styles[weight ~/ 100 - 1];
  for (var i = 0; i < count; i++) {
    final record = 6 + i * 12;
    final nameId = original.getUint16(record + 6);
    if (nameId != 2 && nameId != 17) continue;
    // DirectWrite also infers weight from subfamily names. Changing only OS/2
    // leaves a conflicting SemiBold name, so normal text can select Light.
    final platform = original.getUint16(record);
    final encoded = platform == 0 || platform == 3
        ? [
            for (final c in style.codeUnits) ...[0, c]
          ]
        : style.codeUnits;
    if (strings.length + encoded.length > 0xffff) {
      throw const FormatException('Font name storage exceeds its limit.');
    }
    data.setUint16(record + 8, encoded.length);
    data.setUint16(record + 10, strings.length);
    strings.add(encoded);
  }
  return (BytesBuilder()
        ..add(records)
        ..add(strings.takeBytes()))
      .takeBytes();
}

int _checksum(Uint8List bytes, int offset, int length) {
  var sum = 0;
  for (var i = 0; i < length; i += 4) {
    var word = 0;
    for (var j = 0; j < 4; j++) {
      word = (word << 8) | (i + j < length ? bytes[offset + i + j] : 0);
    }
    sum = (sum + word) & 0xffffffff;
  }
  return sum;
}
