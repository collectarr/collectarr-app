import 'package:csv/csv.dart' as csv;

/// Generic CSV parsing mechanics shared by collection/import hosts.
///
/// This layer deliberately knows nothing about collection columns or media
/// kinds. Domain profiles own headers, aliases, validation, and row mapping.
final class CsvReader {
  const CsvReader({
    this.fieldDelimiter = ',',
    this.textDelimiter,
    this.dynamicTyping = false,
    this.strict = false,
  });

  final String fieldDelimiter;
  final String? textDelimiter;
  final bool dynamicTyping;
  final bool strict;

  List<List<String>> read(String source) {
    source = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (strict) _validateQuotes(source);
    final rows = csv.CsvDecoder(
      fieldDelimiter: fieldDelimiter,
      quoteCharacter: textDelimiter == '' ? '\u0000' : textDelimiter ?? '"',
      dynamicTyping: dynamicTyping,
    ).convert(source);
    final normalized = [
      for (final row in rows)
        [for (final value in row) value?.toString() ?? ''],
    ];
    if (normalized.isNotEmpty && normalized.first.isNotEmpty) {
      normalized[0][0] = normalized[0][0].replaceFirst('\ufeff', '');
    }
    return normalized;
  }

  void _validateQuotes(String source) {
    final quote = textDelimiter ?? '"';
    if (quote.isEmpty) return;
    var quoted = false;
    var start = true;
    var closed = false;
    final input = source.replaceFirst('\ufeff', '');
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (quoted) {
        if (char == quote) {
          if (i + 1 < input.length && input[i + 1] == quote) {
            i++;
          } else {
            quoted = false;
            closed = true;
          }
        }
      } else if (char == fieldDelimiter || char == '\n' || char == '\r') {
        start = true;
        closed = false;
      } else if (char == quote && start) {
        quoted = true;
        start = false;
      } else {
        if (char == quote || closed) {
          throw FormatException('Invalid CSV quoting near character ${i + 1}.');
        }
        start = false;
      }
    }
    if (quoted) {
      throw const FormatException('Truncated CSV: unclosed quoted field.');
    }
  }
}

/// Generic CSV serialization mechanics shared by collection/import hosts.
final class CsvWriter {
  const CsvWriter({this.lineDelimiter = '\n'});

  final String lineDelimiter;

  String write(Iterable<Iterable<Object?>> rows) {
    return csv.CsvEncoder(lineDelimiter: lineDelimiter).convert([
      for (final row in rows) row.toList(growable: false),
    ]);
  }
}
