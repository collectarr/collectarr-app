import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';

/// Structural slots understood by the generic target-selection host.
///
/// The owning kind decides whether a slot is an edition, release, episode,
/// track, or another entity. Generic code only needs to distinguish the
/// position in the target path.
enum LibraryCatalogTargetLevel { root, first, second, group }

/// Structural target selection supplied by a generic Add/Edit host.
///
/// The host only carries ordered selection slots. The owning kind decides what
/// those slots mean and how they become a [CatalogEntityRef].
final class LibraryCatalogTargetSelection {
  const LibraryCatalogTargetSelection({
    required this.referenceType,
    this.firstId,
    this.secondId,
    this.groupId,
  });

  final LibraryAddReferenceType referenceType;
  final String? firstId;
  final String? secondId;
  final String? groupId;
}

/// Kind-owned interpretation of catalog target selection and target paths.
///
/// Generic code never branches on entity-type strings. It hands the selected
/// slots to this capability and receives either a complete ref or structural
/// path parts for display-only purposes.
abstract interface class LibraryCatalogTargetCapability {
  const LibraryCatalogTargetCapability();

  CatalogEntityRef resolve(
    CatalogEntityRef root,
    LibraryCatalogTargetSelection selection,
  );

  LibraryCatalogTargetParts parts(CatalogEntityRef? ref);
}

/// Opaque path projection used by generic selection widgets.
final class LibraryCatalogTargetParts {
  const LibraryCatalogTargetParts({
    this.firstId,
    this.secondId,
    this.groupId,
  });

  final String? firstId;
  final String? secondId;
  final String? groupId;
}
