import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// Kind-owned names for the universal Work -> Release -> Copy structure.
///
/// The structure itself is shared by every library kind. Only the words shown
/// to users vary by kind, so this vocabulary deliberately contains no topology
/// or navigation behavior.
final class LibraryEntityVocabulary {
  const LibraryEntityVocabulary({
    required this.work,
    required this.release,
    required this.copy,
  });

  final LibraryEntityLabel work;
  final LibraryEntityLabel release;
  final LibraryEntityLabel copy;

  LibraryEntityLabel forScope(LibraryEntityScope scope) => switch (scope) {
        LibraryEntityScope.work => work,
        LibraryEntityScope.release => release,
        LibraryEntityScope.copy => copy,
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
