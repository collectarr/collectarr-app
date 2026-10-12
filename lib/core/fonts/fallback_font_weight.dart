import 'dart:typed_data';

/// Gives the bundled 800 face an explicit 900 selection slot, so a missing
/// Gilroy 900 uses the fallback rather than a synthesized Gilroy 800.
/// Glyphs remain the bundled ExtraBold face; only selection metadata changes.
Uint8List fallbackFontAtWeight(Uint8List input, int weight) {
  final bytes = Uint8List.fromList(input);
  final data = ByteData.sublistView(bytes);
  int? head;
  for (var i = 0; i < data.getUint16(4); i++) {
    final entry = 12 + i * 16;
    final tag = data.getUint32(entry);
    final offset = data.getUint32(entry + 8);
    final length = data.getUint32(entry + 12);
    if (tag == 0x68656164) head = offset;
    if (tag == 0x4f532f32) {
      data.setUint16(offset + 4, weight);
      data.setUint32(entry + 4, _checksum(bytes, offset, length));
    }
  }
  if (head == null) {
    throw const FormatException('Fallback font lacks a head table.');
  }
  data.setUint32(head + 8, 0);
  data.setUint32(
      head + 8, (0xb1b0afba - _checksum(bytes, 0, bytes.length)) & 0xffffffff);
  return bytes;
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
