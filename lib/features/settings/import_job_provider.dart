import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:collectarr_app/features/imports/personal_lists/anime_list_import_service.dart';
import 'package:collectarr_app/features/imports/personal_lists/provider_csv_import_service.dart';
import 'package:collectarr_app/features/settings/provider_import_history_store.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final ProviderId provider;
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

class ImportJobsNotifier extends Notifier<List<ImportJobState>> {
  @override
  List<ImportJobState> build() => const [];

  static const _unmatchedConcurrency = 4;
  final TmdbImportService _service = TmdbImportService();
  final AnimeListImportService _animeListService =
      const AnimeListImportService();
  final ProviderCsvImportService _providerCsvService =
      const ProviderCsvImportService();
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
    final normalizedCredentials = credentials.normalized();
    final accountId = _tmdbProviderAccountId(normalizedCredentials.accountId);
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: ProviderId.tmdb,
        label: 'TMDB · ${collection.label}',
        startedAt: DateTime.now(),
      ),
    ];

    try {
      // Phase 1: Fetch from TMDB API
      final entries =
          await _service.fetchCollection(normalizedCredentials, collection);
      await _ensureTmdbAccount(normalizedCredentials, accountId);
      _updateJob(
          jobId,
          (j) => j.copyWith(
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
        apiKey: normalizedCredentials.apiKey,
        accountId: accountId,
        origin: MutationOrigin.externalProvider(ProviderId.tmdb, accountId),
      );
    } catch (error) {
      _updateJob(
          jobId,
          (j) => j.copyWith(
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
    String? accountId,
  }) async {
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: ProviderId.tmdb,
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
      _updateJob(
          jobId,
          (j) => j.copyWith(
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
        accountId: accountId,
        origin: MutationOrigin.fileImport,
      );
    } catch (error) {
      _updateJob(
          jobId,
          (j) => j.copyWith(
                phase: ImportJobPhase.failed,
                error: _describeError(error),
                finishedAt: DateTime.now(),
              ));
    }
  }

  Future<void> startAnimeListFileImport({
    required Uint8List bytes,
    required String fileName,
    required ProviderId provider,
    required bool keepUnmatchedLocally,
    String? accountId,
  }) async {
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: provider,
        label: '${provider.label} · $fileName',
        startedAt: DateTime.now(),
      ),
    ];

    try {
      final rows = _animeListService.parseFileBytes(
        bytes,
        fileName: fileName,
        provider: provider,
      );
      _updateJob(
        jobId,
        (j) => j.copyWith(
          phase: ImportJobPhase.matching,
          total: rows.length,
        ),
      );
      await _matchAndImportEntries(
        jobId: jobId,
        provider: provider,
        entries: rows,
        sourceLabel: fileName,
        keepUnmatchedLocally: keepUnmatchedLocally,
        accountId: accountId,
        origin: MutationOrigin.fileImport,
      );
    } catch (error) {
      _updateJob(
        jobId,
        (j) => j.copyWith(
          phase: ImportJobPhase.failed,
          error: _describeError(error),
          finishedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> startProviderCsvFileImport({
    required Uint8List bytes,
    required String fileName,
    required ProviderId provider,
    required bool keepUnmatchedLocally,
    String? accountId,
  }) async {
    final jobId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ImportJobState(
        id: jobId,
        provider: provider,
        label: '${provider.label} · $fileName',
        startedAt: DateTime.now(),
      ),
    ];

    try {
      final rows = _providerCsvService.parseFileBytes(
        bytes,
        fileName: fileName,
        provider: provider,
      );
      _updateJob(
        jobId,
        (j) => j.copyWith(
          phase: ImportJobPhase.matching,
          total: rows.length,
        ),
      );
      await _matchAndImportEntries(
        jobId: jobId,
        provider: provider,
        entries: rows,
        sourceLabel: fileName,
        keepUnmatchedLocally: keepUnmatchedLocally,
        accountId: accountId,
        origin: MutationOrigin.fileImport,
      );
    } catch (error) {
      _updateJob(
        jobId,
        (j) => j.copyWith(
          phase: ImportJobPhase.failed,
          error: _describeError(error),
          finishedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _matchAndImportEntries({
    required String jobId,
    required ProviderId provider,
    required List<ProviderPersonalEntry> entries,
    required String sourceLabel,
    required bool keepUnmatchedLocally,
    String? accountId,
    MutationOrigin origin = MutationOrigin.fileImport,
  }) async {
    accountId = await _validatedAccountId(provider, accountId);
    final api = ref.read(apiClientProvider);
    final wishlistMutations = ref.read(wishlistMutationsProvider);
    final trackingMutations = ref.read(trackingMutationsProvider);
    final matches = <_GenericImportMatch>[];

    for (final entry in entries) {
      final type = _resolvedTypeForEntry(entry);
      if (type == null) {
        matches.add(_GenericImportMatch(entry: entry, catalogItem: null));
        continue;
      }
      final year = entry.startedAt?.year ?? entry.completedAt?.year;
      final candidates = await searchLibraryMetadata(
        api,
        type,
        query: entry.title ?? '',
        year: year,
        limit: 10,
      );
      matches.add(
        _GenericImportMatch(
          entry: entry,
          catalogItem: _bestImportMatch(entry, candidates),
        ),
      );
    }

    final matchedCount =
        matches.where((match) => match.catalogItem != null).length;
    final unmatchedCount = matches.length - matchedCount;
    _updateJob(
      jobId,
      (j) => j.copyWith(
        phase: ImportJobPhase.importing,
        total: matches.length,
        matched: matchedCount,
        unmatched: unmatchedCount,
        processed: 0,
      ),
    );

    var importedCount = 0;
    var keptLocalCount = 0;
    var skippedCount = 0;

    for (final match in matches) {
      final item = match.catalogItem;
      if (item != null) {
        await _applyEntry(
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          item: item,
          entry: match.entry,
          origin: origin,
        );
        await _linkImportedEntry(
          accountId: accountId,
          localEntityRef: item.catalogRef,
          entry: match.entry,
        );
        importedCount += 1;
      } else if (keepUnmatchedLocally) {
        final localItem = _syntheticImportCatalogItem(provider, match.entry);
        await _applyLocalOnlyEntry(
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          item: localItem,
          entry: match.entry,
          origin: origin,
        );
        await _linkImportedEntry(
          accountId: accountId,
          localEntityRef: localItem.catalogRef,
          entry: match.entry,
        );
        keptLocalCount += 1;
      } else {
        skippedCount += 1;
      }

      _updateJob(
        jobId,
        (j) => j.copyWith(
          processed: importedCount + keptLocalCount + skippedCount,
          imported: importedCount,
          keptLocal: keptLocalCount,
          skipped: skippedCount,
        ),
      );
    }

    await _historyStore.append(
      ProviderImportHistoryEntry(
        id: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
        provider: provider,
        status: ProviderImportHistoryStatus.success,
        collectionLabel: '${provider.label} import',
        sourceLabel: sourceLabel,
        message: _buildResultMessage(
          importedCount,
          0,
          keptLocalCount,
          skippedCount,
        ),
        createdAt: DateTime.now().toUtc(),
        rows: matches.length,
        matched: matchedCount,
        unmatched: unmatchedCount,
        imported: importedCount,
        proposed: 0,
        keptLocal: keptLocalCount,
      ),
    );

    _updateJob(
      jobId,
      (j) => j.copyWith(
        phase: ImportJobPhase.done,
        processed: matches.length,
        imported: importedCount,
        keptLocal: keptLocalCount,
        skipped: skippedCount,
        finishedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _matchAndImport({
    required String jobId,
    required TmdbImportCollection collection,
    required List<TmdbImportEntry> entries,
    required String sourceLabel,
    required bool keepUnmatchedLocally,
    String? apiKey,
    String? accountId,
    required MutationOrigin origin,
  }) async {
    accountId = await _validatedAccountId(ProviderId.tmdb, accountId);
    final api = ref.read(apiClientProvider);

    // Phase 2: Match against catalog
    final preview = await _service.previewImport(
      collection: collection,
      entries: entries,
      searchCatalog: (entry) {
        final type = _resolvedTypeForTmdbEntry(entry);
        return searchLibraryMetadata(
          api,
          type,
          query: entry.title,
          year: entry.releaseYear,
          limit: 10,
        ).then((items) => [
              for (final item in items) item,
            ]);
      },
    );

    final matchedCount =
        preview.matches.where((m) => m.catalogItem != null).length;
    final unmatchedCount =
        preview.matches.where((m) => m.catalogItem == null).length;

    _updateJob(
        jobId,
        (j) => j.copyWith(
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

    final ownedMutations = ref.read(ownedItemMutationsProvider);
    final wishlistMutations = ref.read(wishlistMutationsProvider);
    final trackingMutations = ref.read(trackingMutationsProvider);
    var importedCount = 0;
    var proposedCount = 0;
    var keptLocalCount = 0;
    var skippedCount = 0;
    final unmatchedMatches = <TmdbImportMatch>[];

    for (final match in preview.matches) {
      final item = match.catalogItem;
      if (item != null) {
        final enrichedEntry = _enrichFromCache(
          match.entry,
          enrichmentCache,
          apiKey,
        );
        final enriched = await enrichedEntry;
        final mergedItem = _service.mergeMatchedCatalogItem(item, enriched);
        if (_shouldUpdateCatalogSnapshot(item, mergedItem)) {
          await ownedMutations.updateCatalogSnapshot(
            mergedItem,
            origin: origin,
          );
        }
        if (match.entry.collection.isRated) {
          await trackingMutations.upsertTrackingEntry(
            TrackingTarget.catalog(item.catalogRef),
            sourceType: TrackingSourceType.streaming,
            status: MediaTrackingStatus.completed,
            rating: _normalizedRating(match.entry.rating),
            timesCompleted: 1,
            origin: origin,
          );
        } else {
          await wishlistMutations.addToWishlist(
            item.id,
            fallbackKind: item.kind,
            origin: origin,
          );
        }
        await _importTvSeasons(
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          seriesEntry: enriched,
          apiKey: apiKey,
          origin: origin,
        );
        await _linkImportedEntry(
          accountId: accountId,
          localEntityRef: item.catalogRef,
          entry: enriched.toProviderPersonalEntry(),
        );
        importedCount += 1;
      } else if (keepUnmatchedLocally) {
        unmatchedMatches.add(match);
      } else {
        skippedCount += 1;
      }

      _updateJob(
          jobId,
          (j) => j.copyWith(
                processed:
                    importedCount + skippedCount + unmatchedMatches.length,
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
            match.entry,
            enrichmentCache,
            apiKey,
          );
          final type = _resolvedTypeForTmdbEntry(enriched);
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
              await trackingMutations.addLocalOnlyTrackingEntry(
                localItem,
                anchorType: 'season',
                sourceType: TrackingSourceType.streaming,
                status: MediaTrackingStatus.completed,
                rating: _normalizedRating(enriched.rating),
                timesCompleted: 1,
                origin: origin,
              );
            } else {
              await wishlistMutations.addLocalOnlyWishlistItem(
                localItem,
                origin: origin,
              );
            }
            await _importTvSeasons(
              wishlistMutations: wishlistMutations,
              trackingMutations: trackingMutations,
              seriesEntry: enriched,
              apiKey: apiKey,
              origin: origin,
            );
            await _linkImportedEntry(
              accountId: accountId,
              localEntityRef: localItem.catalogRef,
              entry: enriched.toProviderPersonalEntry(),
            );
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

          _updateJob(
              jobId,
              (j) => j.copyWith(
                    processed: importedCount + proposedCount + skippedCount,
                    imported: importedCount,
                    proposed: proposedCount,
                    keptLocal: keptLocalCount,
                    skipped: skippedCount,
                  ));
        }
      }

      await Future.wait([
        for (var i = 0; i < math.min(_unmatchedConcurrency, queue.length); i++)
          worker(),
      ]);
    }

    // Record history
    await _historyStore.append(
      ProviderImportHistoryEntry(
        id: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
        provider: ProviderId.tmdb,
        status: ProviderImportHistoryStatus.success,
        collectionLabel: collection.label,
        sourceLabel: sourceLabel,
        message: _buildResultMessage(
          importedCount,
          proposedCount,
          keptLocalCount,
          skippedCount,
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

    _updateJob(
        jobId,
        (j) => j.copyWith(
              phase: ImportJobPhase.done,
              processed: preview.matches.length,
              imported: importedCount,
              proposed: proposedCount,
              keptLocal: keptLocalCount,
              skipped: skippedCount,
              finishedAt: DateTime.now(),
            ));
  }

  String _tmdbProviderAccountId(String remoteAccountId) {
    return 'tmdb:${remoteAccountId.trim()}';
  }

  Future<void> _ensureTmdbAccount(
    TmdbImportCredentials credentials,
    String accountId,
  ) async {
    final accountStore = ref.read(providerAccountStoreProvider);
    final existing = await accountStore.getAccount(accountId);
    await accountStore.saveAccount(
      ProviderAccount(
        id: accountId,
        provider: ProviderId.tmdb,
        displayName: existing?.displayName ??
            'TMDb account ${credentials.accountId.trim()}',
        authType: ProviderAuthType.apiKey,
        remoteAccountId: credentials.accountId.trim(),
        remoteHandle: existing?.remoteHandle,
        username: existing?.username,
        avatarUrl: existing?.avatarUrl,
        connectedAt: existing?.connectedAt ?? DateTime.now().toUtc(),
        lastSyncAt: existing?.lastSyncAt,
        enabledCapabilities:
            existing?.enabledCapabilities ?? const {'personalRead'},
        syncPolicy: existing?.syncPolicy ?? const ProviderSyncPolicy(),
      ),
    );
  }

  Future<void> _linkImportedEntry({
    required String? accountId,
    required CatalogEntityRef localEntityRef,
    required ProviderPersonalEntry entry,
  }) async {
    if (accountId == null) return;
    final linkStore = ref.read(providerLinkStoreProvider);
    await linkStore.saveLink(
      ProviderItemLink.fromImportedEntry(
        accountId: accountId,
        localEntityRef: localEntityRef,
        entry: entry,
      ),
    );
  }

  Future<String?> _validatedAccountId(
    ProviderId provider,
    String? accountId,
  ) async {
    if (accountId == null) return null;
    final account =
        await ref.read(providerAccountStoreProvider).getAccount(accountId);
    if (account == null || account.provider != provider) {
      throw StateError(
        'Provider account $accountId is not available for ${provider.value}',
      );
    }
    return accountId;
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

  LibraryKindRuntime _resolvedTypeForTmdbEntry(TmdbImportEntry entry) {
    final runtime = entry.looksLikeAnime
        ? libraryKindRuntimeForKind(CatalogMediaKind.movie)
        : switch (entry.mediaType) {
            TmdbMediaType.movie =>
              libraryKindRuntimeForKind(CatalogMediaKind.movie),
            TmdbMediaType.tv => libraryKindRuntimeForKind(CatalogMediaKind.tv),
          };
    return ref.read(resolvedLibraryTypeProvider(runtime));
  }

  Future<void> _importTvSeasons({
    required WishlistMutations wishlistMutations,
    required TrackingMutations trackingMutations,
    required TmdbImportEntry seriesEntry,
    required String? apiKey,
    required MutationOrigin origin,
  }) async {
    if (seriesEntry.mediaType != TmdbMediaType.tv) {
      return;
    }
    final seasonEntries = await _seasonEntriesFor(seriesEntry, apiKey);
    if (seasonEntries.isEmpty) {
      return;
    }
    for (final seasonEntry in seasonEntries) {
      final seasonItem = _service.localSyntheticSeasonCatalogItem(
        seriesEntry,
        seasonEntry,
      );
      final seasonNumber =
          (seasonEntry.rawPayload['season_number'] as num?)?.toInt();
      if (seriesEntry.collection.isRated) {
        await trackingMutations.addLocalOnlyTrackingEntry(
          seasonItem,
          anchorType: 'season',
          sourceType: TrackingSourceType.streaming,
          status: MediaTrackingStatus.completed,
          rating: _normalizedRating(seriesEntry.rating),
          timesCompleted: 1,
          seasonNumber: seasonNumber,
          origin: origin,
        );
      } else {
        await wishlistMutations.addLocalOnlyWishlistItem(
          seasonItem,
          anchorType: 'season',
          origin: origin,
        );
      }
    }
  }

  Future<List<TmdbImportEntry>> _seasonEntriesFor(
    TmdbImportEntry entry,
    String? apiKey,
  ) async {
    final direct = _service.seasonEntriesFor(entry);
    if (direct.isNotEmpty || apiKey == null || apiKey.trim().isEmpty) {
      return direct;
    }
    try {
      final detailed = await _service.enrichEntry(apiKey: apiKey, entry: entry);
      return _service.seasonEntriesFor(detailed);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'tmdb_import',
        message: 'Failed to load seasons for ${entry.title}.',
        error: error,
        stackTrace: stackTrace,
      );
      return const <TmdbImportEntry>[];
    }
  }

  int? _normalizedRating(num? value) {
    if (value == null) return null;
    return value.round().clamp(1, 10);
  }

  LibraryKindRuntime? _resolvedTypeForEntry(ProviderPersonalEntry entry) {
    if (entry.kind.isUnknown) {
      return null;
    }
    return ref.read(
      resolvedLibraryTypeProvider(libraryKindRuntimeForKind(entry.kind)),
    );
  }

  CatalogItem? _bestImportMatch(
      ProviderPersonalEntry entry, List<CatalogItem> candidates) {
    if (candidates.isEmpty) {
      return null;
    }
    final title = entry.title ?? '';
    final normalizedTitle = title.trim().toLowerCase();
    for (final candidate in candidates) {
      final names = <String?>[
        candidate.title,
        candidate.displayTitle,
        candidate.localizedTitle,
        candidate.originalTitle,
        ...?candidate.searchAliases,
      ];
      if (names.whereType<String>().any(
            (name) => name.trim().toLowerCase() == normalizedTitle,
          )) {
        return candidate;
      }
    }
    return candidates.first;
  }

  Future<void> _applyEntry({
    required WishlistMutations wishlistMutations,
    required TrackingMutations trackingMutations,
    required CatalogItem item,
    required ProviderPersonalEntry entry,
    required MutationOrigin origin,
  }) async {
    final trackingStatus = _trackingStatusForEntry(entry);
    if (trackingStatus == null) {
      await wishlistMutations.addToWishlist(
        item.id,
        fallbackKind: item.kind,
        origin: origin,
      );
      return;
    }
    final catalogRef = CatalogEntityRef(
      kind: item.kind,
      entityType: CatalogEntityType.work,
      id: item.id,
    );
    await trackingMutations.upsertTrackingEntry(
      TrackingTarget.catalog(catalogRef),
      sourceType: TrackingSourceType.streaming,
      status: trackingStatus,
      rating: entry.rating == null || entry.rating == 0
          ? null
          : (entry.rating! / 10).round().clamp(1, 10),
      startedAt: entry.startedAt,
      finishedAt: entry.completedAt,
      progressCurrent: entry.progress,
      timesCompleted:
          trackingStatus == MediaTrackingStatus.completed ? 1 : null,
      origin: origin,
    );
  }

  Future<void> _applyLocalOnlyEntry({
    required WishlistMutations wishlistMutations,
    required TrackingMutations trackingMutations,
    required dynamic item,
    required ProviderPersonalEntry entry,
    required MutationOrigin origin,
  }) async {
    final trackingStatus = _trackingStatusForEntry(entry);
    if (trackingStatus == null) {
      await wishlistMutations.addLocalOnlyWishlistItem(
        item,
        origin: origin,
      );
      return;
    }
    await trackingMutations.addLocalOnlyTrackingEntry(
      item,
      sourceType: TrackingSourceType.streaming,
      status: trackingStatus,
      rating: entry.rating == null || entry.rating == 0
          ? null
          : (entry.rating! / 10).round().clamp(1, 10),
      startedAt: entry.startedAt,
      finishedAt: entry.completedAt,
      progressCurrent: entry.progress,
      timesCompleted:
          trackingStatus == MediaTrackingStatus.completed ? 1 : null,
      allowEmpty: true,
      origin: origin,
    );
  }

  CatalogItem _syntheticImportCatalogItem(
    ProviderId provider,
    ProviderPersonalEntry entry,
  ) {
    final title = entry.title ?? 'Untitled';
    final sourceKey = entry.remoteItemId.trim().isEmpty
        ? title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        : entry.remoteItemId.trim();
    return typedCatalogItemFromMap({
      'id': '${provider.storageValue}-local:$sourceKey',
      'kind': entry.kind.apiValue,
      'title': title,
      'display_title': title,
      'localized_title': title,
      'original_title': title,
      'search_aliases': [title],
      if (entry.startedAt != null)
        'release_date': entry.startedAt!.toIso8601String()
      else if (entry.completedAt != null)
        'release_date': entry.completedAt!.toIso8601String(),
    });
  }

  MediaTrackingStatus? _trackingStatusForEntry(ProviderPersonalEntry entry) {
    return switch (entry.status) {
      ProviderEntryStatus.completed => MediaTrackingStatus.completed,
      ProviderEntryStatus.current ||
      ProviderEntryStatus.repeating =>
        MediaTrackingStatus.inProgress,
      ProviderEntryStatus.paused => MediaTrackingStatus.paused,
      ProviderEntryStatus.dropped => MediaTrackingStatus.dropped,
      ProviderEntryStatus.planning ||
      null =>
        entry.progress != null && entry.progress! > 0
            ? MediaTrackingStatus.inProgress
            : null,
    };
  }

  bool _shouldUpdateCatalogSnapshot(CatalogItem current, CatalogItem next) {
    return current.displayTitle != next.displayTitle ||
        current.localizedTitle != next.localizedTitle ||
        current.originalTitle != next.originalTitle ||
        current.synopsis != next.synopsis ||
        current.coverImageUrl != next.coverImageUrl ||
        current.thumbnailImageUrl != next.thumbnailImageUrl ||
        current.releaseDate != next.releaseDate ||
        current.releaseYear != next.releaseYear ||
        current.payload != next.payload ||
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
    int imported,
    int proposed,
    int keptLocal,
    int skipped,
  ) {
    final parts = <String>['Imported $imported items.'];
    if (proposed > 0) parts.add('Sent $proposed metadata proposals.');
    if (keptLocal > 0) parts.add('Kept $keptLocal unmatched locally.');
    if (skipped > 0) parts.add('Skipped $skipped unmatched rows.');
    return parts.join(' ');
  }
}

final importJobsProvider =
    NotifierProvider<ImportJobsNotifier, List<ImportJobState>>(
  ImportJobsNotifier.new,
);

class _GenericImportMatch {
  const _GenericImportMatch({
    required this.entry,
    required this.catalogItem,
  });

  final ProviderPersonalEntry entry;
  final CatalogItem? catalogItem;

  ProviderPersonalEntry get row => entry;
}
