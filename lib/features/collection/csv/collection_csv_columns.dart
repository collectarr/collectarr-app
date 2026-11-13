/// Maps each header cell to its column, read through a kind's aliases, so a
/// file may name a column by its schema key or by any accepted label.
Map<String, int> collectionCsvHeaderIndex(
  List<String> header,
  Map<String, List<String>> columnAliases,
) {
  // The first column that lists an alias owns it.
  final canonicalByAlias = <String, String>{};
  for (final entry in columnAliases.entries) {
    for (final alias in entry.value) {
      canonicalByAlias.putIfAbsent(
        normalizeCollectionCsvColumn(alias),
        () => entry.key,
      );
    }
  }
  final index = <String, int>{};
  for (var i = 0; i < header.length; i++) {
    final normalized = normalizeCollectionCsvColumn(header[i]);
    final canonical = columnAliases.containsKey(normalized)
        ? normalized
        : canonicalByAlias[normalized] ?? normalized;
    index[canonical] = i;
  }
  return index;
}

String collectionCsvValue(
  Map<String, int> index,
  List<String> values,
  String column,
) {
  final valueIndex = index[normalizeCollectionCsvColumn(column)];
  if (valueIndex == null || valueIndex >= values.length) return '';
  return values[valueIndex];
}

String? collectionCsvOptionalValue(
  Map<String, int> index,
  List<String> values,
  String column,
) {
  final value = collectionCsvValue(index, values, column).trim();
  return value.isEmpty ? null : value;
}

String normalizeCollectionCsvColumn(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(_nonColumnCharacters, '_')
    .replaceAll(_edgeUnderscores, '');

final _nonColumnCharacters = RegExp(r'[^a-z0-9]+');
final _edgeUnderscores = RegExp(r'^_+|_+$');

/// The date as `yyyy-MM-dd` in UTC, or an empty cell.
String formatCollectionCsvDate(DateTime? value) {
  if (value == null) return '';
  final utc = value.toUtc();
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';
}
