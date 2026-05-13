import 'package:collectarr_app/features/collection/shelf_controller.dart';

Map<String, int> topComicsSeriesCounts(List<ShelfEntry> entries) {
  return _countBy(entries, (entry) => entry.catalogItem?.title ?? 'Missing');
}

Map<String, int> topComicsPublisherCounts(List<ShelfEntry> entries) {
  return _countBy(
    entries,
    (entry) => entry.catalogItem?.publisher ?? 'Unknown',
  );
}

int missingComicsMetadataCount(List<ShelfEntry> entries) {
  var count = 0;
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null ||
        item.displayCoverUrl == null ||
        item.publisher == null ||
        item.releaseDate == null ||
        item.synopsis == null) {
      count++;
    }
  }
  return count;
}

Map<String, int> _countBy(
  Iterable<ShelfEntry> entries,
  String Function(ShelfEntry entry) keyFor,
) {
  final counts = <String, int>{};
  for (final entry in entries) {
    final key = _ifEmpty(keyFor(entry).trim(), 'Unknown');
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

String _ifEmpty(String value, String fallback) {
  return value.isEmpty ? fallback : value;
}
