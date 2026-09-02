import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';

export 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart'
    show ProviderEntryStatus;

/// Legacy alias for [ProviderEntryStatus].
typedef ImportItemStatus = ProviderEntryStatus;

extension ImportItemStatusCompatibility on ProviderEntryStatus {
  static const completed = ProviderEntryStatus.completed;
  static const inProgress = ProviderEntryStatus.current;
  static const planned = ProviderEntryStatus.planning;
  static const paused = ProviderEntryStatus.paused;
  static const dropped = ProviderEntryStatus.dropped;
  static const wishlist = ProviderEntryStatus.planning;
  static const unknown = ProviderEntryStatus.planning;
}

/// A single normalized row read from any [ImportSource], now backed by [ProviderPersonalEntry].
class ImportRow {
  const ImportRow({
    required this.sourceId,
    required this.title,
    this.mediaKind,
    this.status = ProviderEntryStatus.planning,
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
  final ProviderEntryStatus? status;

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

  ProviderPersonalEntry toProviderPersonalEntry([ProviderId? provider]) {
    final effectiveProvider = provider ??
        ProviderId.fromValue(
          externalIds.keys.isNotEmpty ? externalIds.keys.first : 'tmdb',
        ) ??
        ProviderId.tmdb;
    return ProviderPersonalEntry(
      provider: effectiveProvider,
      remoteItemId: sourceId,
      kind: mediaKind != null
          ? catalogMediaKindFromValue(mediaKind!)
          : CatalogMediaKind.unknown,
      title: title,
      externalIds: externalIds,
      status: status,
      rating: rating?.toDouble(),
      progress: progress,
      startedAt: startedAt,
      completedAt: finishedAt,
      rawPayload: raw,
    );
  }

  factory ImportRow.fromProviderPersonalEntry(ProviderPersonalEntry entry) {
    return ImportRow(
      sourceId: entry.remoteItemId,
      title: entry.title ?? '',
      mediaKind: entry.kind.name,
      status: entry.status,
      rating: entry.rating?.round(),
      progress: entry.progress,
      startedAt: entry.startedAt,
      finishedAt: entry.completedAt,
      externalIds: entry.externalIds,
      raw: entry.rawPayload,
    );
  }
}

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

  final dynamic entry;
  final ImportMappingState state;
  final CatalogEntityRef? target;
  final List<CatalogEntityRef> candidates;
  final EntrySyncDiff? diff;

  dynamic get row => entry;
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

  final dynamic entry;
  final ImportConflictKind kind;
  final String description;
  final CatalogEntityRef? target;
  final FieldDiff<dynamic>? diff;

  dynamic get row => entry;
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

  final ProviderId provider;
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
  ProviderId _providerId = ProviderId.tmdb;
  String _collectionLabel = '';
  String _sourceLabel = '';

  void bindContext(ImportRunConfig config) {
    _providerId = config.provider;
    _collectionLabel = config.collectionLabel;
    _sourceLabel = config.sourceLabel;
  }
}
