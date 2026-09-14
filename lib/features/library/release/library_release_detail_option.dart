import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

/// Structural release projection consumed by the generic release-detail host.
///
/// The owning kind resolves matching, target identity, and source semantics
/// before this value crosses into the shared UI. The host only coordinates
/// navigation and renders the already-projected values.
final class LibraryReleaseDetailOption {
  const LibraryReleaseDetailOption({
    required this.targetRef,
    required this.summary,
    required this.sourceLabel,
    this.isCatalogRelease = false,
    this.isTitleSnapshotRelease = false,
  });

  final CatalogEntityRef targetRef;
  final LibraryWorkspaceReleaseSummary summary;
  final String sourceLabel;
  final bool isCatalogRelease;
  final bool isTitleSnapshotRelease;

  String get id => summary.id;
}
