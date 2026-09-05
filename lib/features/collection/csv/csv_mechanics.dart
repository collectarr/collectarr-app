import 'package:csv/csv.dart' as csv;

/// Generic CSV parsing mechanics shared by collection/import hosts.
///
/// This layer deliberately knows nothing about collection columns or media
/// kinds. Domain profiles own headers, aliases, validation, and row mapping.
final class CsvReader {
  const CsvReader({
    this.fieldDelimiter = ',',
    this.dynamicTyping = false,
  });

  final String fieldDelimiter;
  final bool dynamicTyping;

  List<List<String>> read(String source) {
    final rows = csv.CsvDecoder(
      fieldDelimiter: fieldDelimiter,
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
