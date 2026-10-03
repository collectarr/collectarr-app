import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// User-facing names for a kind's canonical catalog item and local entry.
final class LibraryEntityVocabulary {
  const LibraryEntityVocabulary({
    required this.catalogItem,
    required this.libraryEntry,
  });

  final LibraryEntityLabel catalogItem;
  final LibraryEntityLabel libraryEntry;

  LibraryEntityLabel forScope(LibraryEntityScope scope) => switch (scope) {
        LibraryEntityScope.catalogItem => catalogItem,
        LibraryEntityScope.libraryEntry => libraryEntry,
      };
}

final class LibraryEntityLabel {
  const LibraryEntityLabel({
    required this.singular,
    required this.plural,
  });

  final String singular;
  final String plural;
}
