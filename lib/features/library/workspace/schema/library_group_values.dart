/// Normalize scalar and multi-value group projections into distinct buckets.
/// Empty projections are resolved by the caller's unknown-value label.
List<String> libraryGroupBucketValues(Object? raw) => List.unmodifiable({
      for (final value in raw is Iterable ? raw : [raw])
        if (value != null && value.toString().trim().isNotEmpty)
          value.toString().trim(),
    });
