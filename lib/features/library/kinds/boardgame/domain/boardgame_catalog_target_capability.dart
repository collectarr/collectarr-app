import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/config/library_catalog_target_capability.dart';

/// BoardGame-owned interpretation of nested catalog target references.
final class BoardGameCatalogTargetCapability
    implements LibraryCatalogTargetCapability {
  const BoardGameCatalogTargetCapability();

  @override
  CatalogEntityRef resolve(
    CatalogEntityRef root,
    LibraryCatalogTargetSelection selection,
  ) {
    final rootRef = root.rootScope;
    final first = _normalized(selection.firstId);
    final second = _normalized(selection.secondId);
    final group = _normalized(selection.groupId);

    if (group != null) {
      return CatalogEntityRef(
        kind: rootRef.kind,
        entityType: const CatalogEntityTypeId('bundle_release'),
        id: group,
        rootId: rootRef.id,
      );
    }

    switch (selection.referenceType) {
      case LibraryAddReferenceType.media:
        return rootRef;
      case LibraryAddReferenceType.bundleRelease:
        return rootRef;
      case LibraryAddReferenceType.edition:
        if (second != null) {
          return CatalogEntityRef(
            kind: rootRef.kind,
            entityType: const CatalogEntityTypeId('release'),
            id: second,
            rootId: rootRef.id,
            parentId: first,
          );
        }
        if (first != null) {
          return CatalogEntityRef(
            kind: rootRef.kind,
            entityType: const CatalogEntityTypeId('edition'),
            id: first,
            rootId: rootRef.id,
          );
        }
        return rootRef;
    }
  }

  @override
  LibraryCatalogTargetParts parts(CatalogEntityRef? ref) {
    if (ref == null) return const LibraryCatalogTargetParts();
    return switch (ref.entityType.apiValue) {
      'edition' => LibraryCatalogTargetParts(firstId: ref.id),
      'release' => LibraryCatalogTargetParts(
          firstId: ref.parentId,
          secondId: ref.id,
        ),
      'bundle_release' => LibraryCatalogTargetParts(groupId: ref.id),
      _ => const LibraryCatalogTargetParts(),
    };
  }

  String? _normalized(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
