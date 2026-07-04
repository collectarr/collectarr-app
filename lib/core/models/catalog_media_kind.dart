enum CatalogMediaKind {
  comic('comic'),
  manga('manga'),
  anime('anime'),
  book('book'),
  game('game'),
  boardgame('boardgame'),
  movie('movie'),
  tv('tv'),
  music('music'),
  unknown('unknown');

  const CatalogMediaKind(this.apiValue);

  final String apiValue;
}

extension CatalogMediaKindLibrarySemantics on CatalogMediaKind {
  CatalogMediaKind get libraryKind => this;

  bool get isVideoLibraryKind {
    return switch (this) {
      CatalogMediaKind.movie ||
      CatalogMediaKind.tv ||
      CatalogMediaKind.anime =>
        true,
      _ => false,
    };
  }
}

CatalogMediaKind catalogMediaKindFromValue(Object? value) {
  if (value is CatalogMediaKind) {
    return value;
  }
  if (value is String?) {
    return catalogMediaKindFromApiValue(value);
  }
  return CatalogMediaKind.unknown;
}

CatalogMediaKind catalogMediaKindFromApiValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null) return CatalogMediaKind.unknown;

  for (final kind in CatalogMediaKind.values) {
    if (kind.apiValue == normalized) {
      return kind;
    }
  }
  return CatalogMediaKind.unknown;
}
