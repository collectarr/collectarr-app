import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

import '../../domain/library_target_ref.dart';
import 'library_workspace_kind_data.dart';

/// Canonical target and kind-owned presentation data for one workspace row.
///
/// A local entry keeps its own target and summary. Optional Core provenance
/// belongs to that entry summary and is never inferred from a local ID.
final class WorkspaceItem {
  const WorkspaceItem({
    required this.target,
    this.presentation,
    this.entrySummary,
    this.kindPresentationData,
    this.libraryEntryDispatch,
    this.searchTokens = const <String>[],
  });

  final LibraryTargetRef target;
  final CatalogDisplaySummary? presentation;
  final LibraryEntrySummary? entrySummary;
  final Object? kindPresentationData;
  final LibraryEntryDispatch? libraryEntryDispatch;
  final List<String> searchTokens;

  String get id => target.id;
  CatalogMediaKind get kind => target.kind;

  String get title {
    final kindLabel = switch (kindPresentationData) {
      LibraryWorkspaceKindData(:final displayLabel) => displayLabel.trim(),
      _ => '',
    };
    if (kindLabel.isNotEmpty) return kindLabel;
    final displayTitle = presentation?.primaryLabel.trim();
    if (displayTitle != null && displayTitle.isNotEmpty) return displayTitle;
    throw StateError(
      'Workspace item ${kind.apiValue}:$id has no kind presentation title.',
    );
  }
}
