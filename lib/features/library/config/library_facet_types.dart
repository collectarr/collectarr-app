import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart'
    show LibraryFacetId;

@immutable
class LibraryTypedFacetId<TKind, TValue> {
  const LibraryTypedFacetId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryTypedFacetId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LibraryTypedFacetId($value)';
}

@immutable
class LibraryFacetBucket<TValue> {
  const LibraryFacetBucket({
    required this.key,
    required this.label,
    required this.count,
    this.value,
  });

  final String key;
  final String label;
  final int count;
  final TValue? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryFacetBucket &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label &&
          count == other.count;

  @override
  int get hashCode => Object.hash(key, label, count);
}

@immutable
class LibraryFacetQuery<TValue> {
  const LibraryFacetQuery({
    required this.facetId,
    this.searchQuery,
    this.limit = 50,
    this.offset = 0,
  });

  final String facetId;
  final String? searchQuery;
  final int limit;
  final int offset;
}

@immutable
class LibraryFacetDefinition<TKind, TDto, TValue> {
  const LibraryFacetDefinition({
    required this.id,
    required this.label,
    required this.extractValues,
  });

  final LibraryTypedFacetId<TKind, TValue> id;
  final String label;
  final Iterable<TValue> Function(TDto dto) extractValues;
}
