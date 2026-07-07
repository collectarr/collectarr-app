import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';

/// Normalized personal-list status across third-party providers (MAL, AniList,
/// Trakt, Simkl, Kitsu, ...). Each source maps its own vocabulary onto these.
enum ImportItemStatus {
  completed,
  inProgress,
  planned,
  paused,
  dropped,
  wishlist,
  unknown,
}

/// A single normalized row read from any [ImportSource].
///
/// This is the provider-agnostic shape the rest of the pipeline operates on, so
/// matching, conflict detection, and applying are written once and reused for
/// every provider.
class ImportRow {
  const ImportRow({
    required this.sourceId,
    required this.title,
    this.mediaKind,
    this.status = ImportItemStatus.unknown,
    this.rating,
    this.startedAt,
    this.finishedAt,
    this.progress,
    this.externalIds = const <String, String>{},
    this.raw = const <String, dynamic>{},
  });

  /// The provider's identifier for this row (e.g. MAL/AniList media id).
  final String sourceId;
  final String title;

  /// Target app kind if known (`movie`, `tv`, `anime`, `book`, ...).
  final String? mediaKind;
  final ImportItemStatus status;

  /// Normalized rating on a 0-100 scale, or null when unrated.
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  /// Episodes watched / chapters read, when the source tracks progress.
  final int? progress;

  /// Cross-provider identifiers (`imdb`, `tmdb`, `mal`, `anilist`, ...).
  final Map<String, String> externalIds;

  /// The untouched source payload, for debugging and re-mapping.
  final Map<String, dynamic> raw;
}

enum ImportMappingState { matched, unmatched, ambiguous }

/// The result of resolving an [ImportRow] against the catalog.
class ImportMapping {
  const ImportMapping({
    required this.row,
    required this.state,
    this.target,
    this.candidates = const <CatalogEntityRef>[],
  });

  const ImportMapping.matched(this.row, CatalogEntityRef this.target)
      : state = ImportMappingState.matched,
        candidates = const <CatalogEntityRef>[];

  const ImportMapping.unmatched(this.row)
      : state = ImportMappingState.unmatched,
        target = null,
        candidates = const <CatalogEntityRef>[];

  const ImportMapping.ambiguous(this.row, this.candidates)
      : state = ImportMappingState.ambiguous,
        target = null;

  final ImportRow row;
  final ImportMappingState state;
  final CatalogEntityRef? target;
  final List<CatalogEntityRef> candidates;
}

enum ImportConflictKind {
  alreadyOwned,
  alreadyTracked,
  ratingDiffers,
  statusDiffers,
}

/// A conflict between an incoming row and existing local state.
class ImportConflict {
  const ImportConflict({
    required this.row,
    required this.kind,
    required this.description,
    this.target,
  });

  final ImportRow row;
  final ImportConflictKind kind;
  final String description;
  final CatalogEntityRef? target;
}

/// What happened to a single row after a run.
enum ImportRowOutcome { imported, proposed, keptLocal, skipped, unmatched }

/// How to resolve conflicts with existing local data.
enum ImportConflictPolicy {
  /// Keep the existing local value, ignore the incoming one.
  keepLocal,

  /// Overwrite local state with the incoming value.
  overwrite,

  /// Only fill fields that are currently empty locally.
  fillEmpty,
}

/// Configuration for one import run.
class ImportRunConfig {
  const ImportRunConfig({
    required this.provider,
    required this.collectionLabel,
    this.sourceLabel = '',
    this.proposeUnmatched = false,
    this.conflictPolicy = ImportConflictPolicy.keepLocal,
  });

  final ProviderImportId provider;
  final String collectionLabel;
  final String sourceLabel;

  /// When true, unmatched rows are queued as metadata proposals instead of
  /// being dropped.
  final bool proposeUnmatched;
  final ImportConflictPolicy conflictPolicy;
}

/// Aggregated outcome of an import run. Mirrors the counters used by
/// [ProviderImportHistoryEntry] so a run can be recorded directly in history.
class ImportResult {
  ImportResult({
    this.rows = 0,
    this.matched = 0,
    this.unmatched = 0,
    this.imported = 0,
    this.proposed = 0,
    this.keptLocal = 0,
    this.skipped = 0,
    List<ImportConflict>? conflicts,
  }) : conflicts = conflicts ?? <ImportConflict>[];

  int rows;
  int matched;
  int unmatched;
  int imported;
  int proposed;
  int keptLocal;
  int skipped;
  final List<ImportConflict> conflicts;

  bool get hasConflicts => conflicts.isNotEmpty;

  void record(ImportRowOutcome outcome) {
    switch (outcome) {
      case ImportRowOutcome.imported:
        imported++;
      case ImportRowOutcome.proposed:
        proposed++;
      case ImportRowOutcome.keptLocal:
        keptLocal++;
      case ImportRowOutcome.skipped:
        skipped++;
      case ImportRowOutcome.unmatched:
        unmatched++;
    }
  }

  ProviderImportHistoryEntry toHistoryEntry({
    required String id,
    required DateTime createdAt,
    ProviderImportHistoryStatus status = ProviderImportHistoryStatus.success,
    String message = '',
  }) {
    return ProviderImportHistoryEntry(
      id: id,
      provider: _providerId,
      status: status,
      collectionLabel: _collectionLabel,
      sourceLabel: _sourceLabel,
      message: message,
      createdAt: createdAt,
      rows: rows,
      matched: matched,
      unmatched: unmatched,
      imported: imported,
      proposed: proposed,
      keptLocal: keptLocal,
    );
  }

  // Set by ImportRunner so toHistoryEntry can reproduce the run context.
  ProviderImportId _providerId = ProviderImportId.tmdb;
  String _collectionLabel = '';
  String _sourceLabel = '';

  void bindContext(ImportRunConfig config) {
    _providerId = config.provider;
    _collectionLabel = config.collectionLabel;
    _sourceLabel = config.sourceLabel;
  }
}
