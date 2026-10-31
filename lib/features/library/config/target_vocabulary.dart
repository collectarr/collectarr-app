/// User-facing names for a kind's canonical catalog item and local entry.
final class LibraryTargetVocabulary {
  const LibraryTargetVocabulary({
    required this.catalogItem,
    required this.libraryEntry,
  });

  final LibraryTargetLabel catalogItem;
  final LibraryTargetLabel libraryEntry;
}

final class LibraryTargetLabel {
  const LibraryTargetLabel({
    required this.singular,
    required this.plural,
  });

  final String singular;
  final String plural;
}
