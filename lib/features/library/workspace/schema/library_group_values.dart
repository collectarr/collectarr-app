/// Shared label for items without a value for the selected grouping field.
const libraryEmptyGroupLabel = '[None]';

/// Sort the empty group before named groups, as in CLZ's folder list.
int compareLibraryGroupBuckets(String first, String second) {
  if (first == second) return 0;
  if (first == libraryEmptyGroupLabel) return -1;
  if (second == libraryEmptyGroupLabel) return 1;
  return first.compareTo(second);
}

/// Normalize scalar and multi-value group projections into distinct buckets.
/// Empty projections are displayed using [libraryEmptyGroupLabel].
List<String> libraryGroupBucketValues(Object? raw) => List.unmodifiable({
      for (final value in raw is Iterable ? raw : [raw])
        if (value != null && value.toString().trim().isNotEmpty)
          value.toString().trim(),
    });
