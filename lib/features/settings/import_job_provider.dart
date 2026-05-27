import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/settings/provider_import_history_store.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ImportJobPhase { fetching, matching, importing, done, failed }

class ImportJobState {
  const ImportJobState({
    required this.id,
    required this.provider,
    required this.label,
    this.phase = ImportJobPhase.fetching,
    this.total = 0,
    this.processed = 0,
    this.matched = 0,
    this.imported = 0,
    this.unmatched = 0,
    this.proposed = 0,
    this.keptLocal = 0,
    this.skipped = 0,
    this.error,
    required this.startedAt,
    this.finishedAt,
  });

  final String id;
  final ProviderImportId provider;
  final String label;
  final ImportJobPhase phase;
  final int total;
  final int processed;
  final int matched;
  final int imported;
  final int unmatched;
  final int proposed;
  final int keptLocal;
  final int skipped;
  final String? error;
  final DateTime startedAt;
  final DateTime? finishedAt;

  bool get isActive =>
      phase == ImportJobPhase.fetching ||
      phase == ImportJobPhase.matching ||
      phase == ImportJobPhase.importing;

  double get progress => total > 0 ? processed / total : 0;

  String get phaseLabel => switch (phase) {
        ImportJobPhase.fetching => 'Fetching…',
        ImportJobPhase.matching => 'Matching…',
        ImportJobPhase.importing => 'Importing…',
        ImportJobPhase.done => 'Done',
        ImportJobPhase.failed => 'Failed',
      };

  String get summary {
    if (phase == ImportJobPhase.failed) return error ?? 'Import failed';
    if (phase == ImportJobPhase.done) {
      final parts = <String>[];
      if (imported > 0) parts.add('$imported imported');
      if (proposed > 0) parts.add('$proposed proposed');
      if (keptLocal > 0) parts.add('$keptLocal kept local');
      if (skipped > 0) parts.add('$skipped skipped');
      return parts.isEmpty ? 'No items processed' : parts.join(' · ');
    }
    if (total > 0) return '$processed / $total';
    return phaseLabel;
  }

  ImportJobState copyWith({
    ImportJobPhase? phase,
    int? total,
    int? processed,
    int? matched,
    int? imported,
    int? unmatched,
    int? proposed,
    int? keptLocal,
    int? skipped,
    String? error,
    DateTime? finishedAt,
  }) {
    return ImportJobState(
      id: id,
      provider: provider,
      label: label,
      phase: phase ?? this.phase,
      total: total ?? this.total,
      processed: processed ?? this.processed,
      matched: matched ?? this.matched,
      imported: imported ?? this.imported,
      unmatched: unmatched ?? this.unmatched,
      proposed: proposed ?? this.proposed,
      keptLocal: keptLocal ?? this.keptLocal,
      skipped: skipped ?? this.skipped,
      error: error ?? this.error,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}

class ImportJobsNotifier extends StateNotifier<List<ImportJobState>> {
  ImportJobsNotifier(this._ref) : super(const []);

  static const _unmatchedConcurrency = 4;
  final Ref _ref;
  final TmdbImportService _service = TmdbImportService();
  final TmdbPendingImportStore _pendingStore = const TmdbPendingImportStore();
  final ProviderImportHistoryStore _historyStore =
      const ProviderImportHistoryStore();

  void _updateJob(String id, ImportJobState Function(ImportJobState) update) {
    state = [
      for (final job in state)
        if (job.id == id) update(job) else job,
    ];
  }

  void dismissJob(String id) {
    state = [
      for (final job in state)
        if (job.id != id) job,
    ];
  }

  Future<void> startTmdbAccountImport({
    required TmdbImportCredentials credentials,
    required TmdbImportCollection collection,
    required bool keepUnmatchedLocally,
  }) async {
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: ProviderImportId.tmdb,
        label: 'TMDB · ${collection.label}',
        startedAt: DateTime.now(),
      ),
    ];

    try {
      // Phase 1: Fetch from TMDB API
      final entries = await _service.fetchCollection(credentials, collection);
      _updateJob(jobId, (j) => j.copyWith(
        phase: ImportJobPhase.matching,
        total: entries.length,
      ));

      // Phase 2 & 3: Match + Import
      await _matchAndImport(
        jobId: jobId,
        collection: collection,
        entries: entries,
        sourceLabel: 'TMDB account sync',
        keepUnmatchedLocally: keepUnmatchedLocally,
        apiKey: credentials.apiKey,
      );
    } catch (error) {
      _updateJob(jobId, (j) => j.copyWith(
        phase: ImportJobPhase.failed,
        error: _describeError(error),
        finishedAt: DateTime.now(),
      ));
    }
  }

  Future<void> startTmdbFileImport({
    required Uint8List bytes,
    required String fileName,
    required TmdbImportCollection collection,
    required bool keepUnmatchedLocally,
    String? apiKey,
  }) async {
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: ProviderImportId.tmdb,
        label: 'TMDB · $fileName',
        startedAt: DateTime.now(),
      ),
    ];

    try {
      // Phase 1: Parse file
      final entries = _service.parseCollectionFileBytes(
        bytes,
        fileName: fileName,
        collection: collection,
      );
      _updateJob(jobId, (j) => j.copyWith(
        phase: ImportJobPhase.matching,
        total: entries.length,
      ));

      // Phase 2 & 3: Match + Import
      await _matchAndImport(
        jobId: jobId,
        collection: collection,
        entries: entries,
        sourceLabel: fileName,
        keepUnmatchedLocally: keepUnmatchedLocally,
        apiKey: apiKey,
      );
    } catch (error) {
      _updateJob(jobId, (j) => j.copyWith(
        phase: ImportJobPhase.failed,
        error: _describeError(error),
        finishedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _matchAndImport({
    required String jobId,
    required TmdbImportCollection collection,
    required List<TmdbImportEntry> entries,
    required String sourceLabel,
    required bool keepUnmatchedLocally,
    String? apiKey,
  }) async {
    final api = _ref.read(apiClientProvider);

    // Phase 2: Match against catalog
    final preview = await _service.previewImport(
      collection: collection,
      entries: entries,
      searchCatalog: (entry) {
        final type = _resolvedTypeForEntry(entry);
        return searchLibraryMetadata(
          api,
          type,
          query: entry.title,
          year: entry.releaseYear,
          limit: 10,
        );
      },
    );

    final matchedCount =
        preview.matches.where((m) => m.catalogItem != null).length;
    final unmatchedCount =
        preview.matches.where((m) => m.catalogItem == null).length;

    _updateJob(jobId, (j) => j.copyWith(
      phase: ImportJobPhase.importing,
      total: preview.matches.length,
      matched: matchedCount,
      unmatched: unmatchedCount,
      processed: 0,
    ));

    // Phase 3: Import
    Map<String, TmdbImportEntry> enrichmentCache = const {};
    try {
      enrichmentCache = await _service.batchEnrichEntries(
        api: api,
        entries: entries,
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'tmdb_import',
        message: 'Server-side batch enrichment failed. Falling back.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final mutations = _ref.read(collectionMutationsProvider);
    var importedCount = 0;
    var proposedCount = 0;
    var keptLocalCount = 0;
    var skippedCount = 0;
    final unmatchedMatches = <TmdbImportMatch>[];

    for (final match in preview.matches) {
      final item = match.catalogItem;
      if (item != null) {
        final enrichedEntry = _enrichFromCache(
          match.entry, enrichmentCache, apiKey,
        );
        final enriched = await enrichedEntry;
        final mergedItem = _service.mergeMatchedCatalogItem(item, enriched);
        if (_shouldUpdateCatalogSnapshot(item, mergedItem)) {
          await mutations.updateCatalogSnapshot(mergedItem, notify: false);
        }
        if (match.entry.collection.isRated) {
          await mutations.upsertTrackingEntry(
            item.id,
            sourceType: TrackingSourceType.streaming,
            status: MediaTrackingStatus.completed,
            rating: _normalizedRating(match.entry.rating),
            timesCompleted: 1,
          );
        } else {
          await mutations.addToWishlist(item.id);
        }
        importedCount += 1;
      } else if (keepUnmatchedLocally) {
        unmatchedMatches.add(match);
      } else {
        skippedCount += 1;
      }

      _updateJob(jobId, (j) => j.copyWith(
        processed: importedCount + skippedCount + unmatchedMatches.length,
        imported: importedCount,
        skipped: skippedCount,
      ));
    }

    // Process unmatched
    if (unmatchedMatches.isNotEmpty) {
      final queue = List<TmdbImportMatch>.from(unmatchedMatches);
      Future<void> worker() async {
        while (queue.isNotEmpty) {
          final match = queue.removeLast();
          final enriched = await _enrichFromCache(
            match.entry, enrichmentCache, apiKey,
          );
          final type = _resolvedTypeForEntry(enriched);
          try {
            final truncatedQuery = enriched.query.length > 255
                ? enriched.query.substring(0, 255)
                : enriched.query;
            final truncatedTitle = enriched.title.length > 255
                ? enriched.title.substring(0, 255)
                : enriched.title;
            final response = await createAndRecordLibraryMetadataProposal(
              api: api,
              type: type,
              provider: 'tmdb',
              providerItemId: enriched.tmdbId.toString(),
              query: truncatedQuery,
              title: truncatedTitle,
              summary: enriched.overview,
              imageUrl: enriched.posterUrl,
              metadataPayload: enriched.rawPayload,
              source: 'TMDB import',
            );
            proposedCount += 1;

            final localItem = _service.localSyntheticCatalogItem(enriched);
            if (enriched.collection.isRated) {
              await mutations.addLocalOnlyTrackingEntry(
                localItem,
                sourceType: TrackingSourceType.streaming,
                status: MediaTrackingStatus.completed,
                rating: _normalizedRating(enriched.rating),
                timesCompleted: 1,
              );
            } else {
              await mutations.addLocalOnlyWishlistItem(localItem);
            }
            await _pendingStore.upsert(
              TmdbPendingImportRecord(
                localItemId: localItem.id,
                entry: enriched,
                createdAt: DateTime.now().toUtc(),
                proposalServerId: response['id']?.toString(),
              ),
            );
            keptLocalCount += 1;
          } catch (error, stackTrace) {
            logRecoverableError(
              source: 'tmdb_import',
              message:
                  'Failed to create metadata proposal for ${enriched.title}.',
              error: error,
              stackTrace: stackTrace,
            );
            skippedCount += 1;
          }

          _updateJob(jobId, (j) => j.copyWith(
            processed: importedCount + proposedCount + skippedCount,
            imported: importedCount,
            proposed: proposedCount,
            keptLocal: keptLocalCount,
            skipped: skippedCount,
          ));
        }
      }

      await Future.wait([
        for (var i = 0;
            i < math.min(_unmatchedConcurrency, queue.length);
            i++)
          worker(),
      ]);
    }

    // Record history
    await _historyStore.append(
      ProviderImportHistoryEntry(
        id: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
        provider: ProviderImportId.tmdb,
        status: ProviderImportHistoryStatus.success,
        collectionLabel: collection.label,
        sourceLabel: sourceLabel,
        message: _buildResultMessage(
          importedCount, proposedCount, keptLocalCount, skippedCount,
        ),
        createdAt: DateTime.now().toUtc(),
        rows: preview.matches.length,
        matched: matchedCount,
        unmatched: unmatchedCount,
        imported: importedCount,
        proposed: proposedCount,
        keptLocal: keptLocalCount,
      ),
    );

    _updateJob(jobId, (j) => j.copyWith(
      phase: ImportJobPhase.done,
      processed: preview.matches.length,
      imported: importedCount,
      proposed: proposedCount,
      keptLocal: keptLocalCount,
      skipped: skippedCount,
      finishedAt: DateTime.now(),
    ));
  }

  Future<TmdbImportEntry> _enrichFromCache(
    TmdbImportEntry entry,
    Map<String, TmdbImportEntry> cache,
    String? apiKey,
  ) async {
    final pid = entry.mediaType.providerItemId(entry.tmdbId);
    final cached = cache[pid];
    if (cached != null) return cached;
    if (apiKey == null || apiKey.trim().isEmpty) return entry;
    try {
      return await _service.enrichEntry(apiKey: apiKey, entry: entry);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'tmdb_import',
        message: 'Failed to enrich TMDB entry ${entry.tmdbId}.',
        error: error,
        stackTrace: stackTrace,
      );
      return entry;
    }
  }

  LibraryTypeConfig _resolvedTypeForEntry(TmdbImportEntry entry) {
    final config = entry.looksLikeAnime
        ? animeLibraryConfig
        : switch (entry.mediaType) {
            TmdbMediaType.movie => moviesLibraryConfig,
            TmdbMediaType.tv => tvLibraryConfig,
          };
    return _ref.read(resolvedLibraryTypeProvider(config));
  }

  int? _normalizedRating(num? value) {
    if (value == null) return null;
    return value.round().clamp(1, 10);
  }

  bool _shouldUpdateCatalogSnapshot(CatalogItem current, CatalogItem next) {
    return current.displayTitle != next.displayTitle ||
        current.localizedTitle != next.localizedTitle ||
        current.originalTitle != next.originalTitle ||
        current.synopsis != next.synopsis ||
        current.coverImageUrl != next.coverImageUrl ||
        current.thumbnailImageUrl != next.thumbnailImageUrl ||
        current.publisher != next.publisher ||
        current.releaseDate != next.releaseDate ||
        current.releaseYear != next.releaseYear ||
        current.country != next.country ||
        current.language != next.language ||
        current.video?.runtimeMinutes != next.video?.runtimeMinutes ||
        current.displayCoverUrl != next.displayCoverUrl;
  }

  String _describeError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode == 401) {
        return 'TMDB credentials rejected. Check API key, account ID, and session ID.';
      }
      if (statusCode != null) return 'Request failed with status $statusCode.';
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        return 'TMDB took too long to respond.';
      }
      return 'Couldn\'t reach TMDB.';
    }
    return error.toString();
  }

  String _buildResultMessage(
    int imported, int proposed, int keptLocal, int skipped,
  ) {
    final parts = <String>['Imported $imported items.'];
    if (proposed > 0) parts.add('Sent $proposed metadata proposals.');
    if (keptLocal > 0) parts.add('Kept $keptLocal unmatched locally.');
    if (skipped > 0) parts.add('Skipped $skipped unmatched rows.');
    return parts.join(' ');
  }
}

final importJobsProvider =
    StateNotifierProvider<ImportJobsNotifier, List<ImportJobState>>((ref) {
  return ImportJobsNotifier(ref);
});
