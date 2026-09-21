import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// Human-readable labels for one structural library entity.
final class LibraryEntityDescriptor {
  const LibraryEntityDescriptor({
    required this.scope,
    required this.singularLabel,
    required this.pluralLabel,
  });

  final LibraryEntityScope scope;
  final String singularLabel;
  final String pluralLabel;
}

/// Structural topology owned by a library kind.
///
/// This is deliberately independent from browser, navigation, and editor
/// policy. Content hierarchy (seasons, discs, chapters, and so on) remains in
/// [LibraryHierarchyCapability].
final class LibraryKindTopology {
  const LibraryKindTopology({
    this.work = const LibraryEntityDescriptor(
      scope: LibraryEntityScope.work,
      singularLabel: 'Work',
      pluralLabel: 'Works',
    ),
    this.release = const LibraryEntityDescriptor(
      scope: LibraryEntityScope.release,
      singularLabel: 'Release',
      pluralLabel: 'Releases',
    ),
    this.copy = const LibraryEntityDescriptor(
      scope: LibraryEntityScope.copy,
      singularLabel: 'Copy',
      pluralLabel: 'Copies',
    ),
  });

  final LibraryEntityDescriptor work;
  final LibraryEntityDescriptor release;
  final LibraryEntityDescriptor copy;
}
