import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';

export 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart'
    show ProviderEntryStatus;

enum ImportMappingState { matched, unmatched, ambiguous }

/// The result of resolving an incoming entry against the catalog.
class ImportMapping {
  const ImportMapping({
    required this.entry,
    required this.state,
    this.target,
    this.candidates = const <CatalogEntityRef>[],
    this.diff,
  });

  const ImportMapping.matched(
    this.entry,
    CatalogEntityRef this.target, {
    this.diff,
  })  : state = ImportMappingState.matched,
        candidates = const <CatalogEntityRef>[];

  const ImportMapping.unmatched(this.entry)
      : state = ImportMappingState.unmatched,
        target = null,
        candidates = const <CatalogEntityRef>[],
        diff = null;

  const ImportMapping.ambiguous(this.entry, this.candidates)
      : state = ImportMappingState.ambiguous,
        target = null,
        diff = null;

  final ProviderPersonalEntry entry;
  final ImportMappingState state;
  final CatalogEntityRef? target;
  final List<CatalogEntityRef> candidates;
  final EntrySyncDiff? diff;
}

enum ImportConflictKind {
  alreadyOwned,
  alreadyTracked,
  ratingDiffers,
  statusDiffers,
}

/// A conflict between an incoming entry and existing local state.
class ImportConflict {
  const ImportConflict({
    required this.entry,
    required this.kind,
    required this.description,
    this.target,
    this.diff,
  });

  final ProviderPersonalEntry entry;
  final ImportConflictKind kind;
  final String description;
  final CatalogEntityRef? target;
  final FieldDiff<dynamic>? diff;
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
    this.origin = MutationOrigin.fileImport,
  });

  final ProviderId provider;
  final String collectionLabel;
  final String sourceLabel;

  /// When true, unmatched rows are queued as metadata proposals instead of
  /// being dropped.
  final bool proposeUnmatched;
  final ImportConflictPolicy conflictPolicy;
  final MutationOrigin origin;
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
  ProviderId _providerId = ProviderId.tmdb;
  String _collectionLabel = '';
  String _sourceLabel = '';

  void bindContext(ImportRunConfig config) {
    _providerId = config.provider;
    _collectionLabel = config.collectionLabel;
    _sourceLabel = config.sourceLabel;
  }
}
