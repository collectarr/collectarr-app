// Kind marker types for static type safety across schemas and identifiers.

sealed class MangaKind {
  const MangaKind();
}

sealed class ComicKind {
  const ComicKind();
}

sealed class BookKind {
  const BookKind();
}

sealed class GameKind {
  const GameKind();
}

sealed class BoardGameKind {
  const BoardGameKind();
}

sealed class MovieKind {
  const MovieKind();
}

sealed class TvKind {
  const TvKind();
}

sealed class AnimeKind {
  const AnimeKind();
}

sealed class MusicKind {
  const MusicKind();
}

/// Controlled runtime interface for field identifiers to allow heterogeneous collection handling without type erasure to dynamic.
abstract interface class LibraryFieldIdRuntime {
  String get value;
}

/// Controlled runtime interface for group identifiers to allow heterogeneous collection handling without type erasure to dynamic.
abstract interface class LibraryGroupIdRuntime {
  String get value;
}

/// Controlled runtime interface for sort identifiers to allow heterogeneous collection handling without type erasure to dynamic.
abstract interface class LibrarySortIdRuntime {
  String get value;
}

/// Strongly typed field identifier bound to a concrete kind [TKind] and field value type [TValue].
final class LibraryFieldId<TKind, TValue> implements LibraryFieldIdRuntime {
  const LibraryFieldId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibraryFieldId<TKind, TValue> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(TKind, TValue, value);

  @override
  String toString() => value;
}

/// Dynamic or decoded runtime field identifier.
final class DynamicLibraryFieldId implements LibraryFieldIdRuntime {
  const DynamicLibraryFieldId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      other is LibraryFieldIdRuntime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Strongly typed sort identifier bound to a concrete kind [TKind].
final class LibrarySortId<TKind> implements LibrarySortIdRuntime {
  const LibrarySortId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibrarySortId<TKind> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(TKind, value);

  @override
  String toString() => value;
}

/// Dynamic or decoded runtime sort identifier.
final class DynamicLibrarySortId implements LibrarySortIdRuntime {
  const DynamicLibrarySortId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      other is LibrarySortIdRuntime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Strongly typed group identifier bound to a concrete kind [TKind] and group key type [TValue].
final class LibraryGroupId<TKind, TValue> implements LibraryGroupIdRuntime {
  const LibraryGroupId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibraryGroupId<TKind, TValue> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(TKind, TValue, value);

  @override
  String toString() => value;
}

/// Dynamic or decoded runtime group identifier.
final class DynamicLibraryGroupId implements LibraryGroupIdRuntime {
  const DynamicLibraryGroupId(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      other is LibraryGroupIdRuntime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Strongly typed facet identifier bound to a concrete kind [TKind] and facet value type [TValue].
final class LibraryFacetId<TKind, TValue> {
  const LibraryFacetId(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return other is LibraryFacetId<TKind, TValue> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(TKind, TValue, value);

  @override
  String toString() => value;
}
