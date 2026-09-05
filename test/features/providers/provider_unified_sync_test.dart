import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unified Provider and Sync Architecture Tests', () {
    test('Canonical ProviderId covers all 18 external services', () {
      expect(ProviderId.values.length, 18);
      expect(ProviderId.fromValue('anilist'), ProviderId.aniList);
      expect(ProviderId.fromValue('bgg'), ProviderId.bgg);
      expect(ProviderId.fromValue('comicvine'), ProviderId.comicVine);
      expect(ProviderId.fromValue('gcd'), ProviderId.gcd);
      expect(ProviderId.fromValue('hardcover'), ProviderId.hardcover);
      expect(ProviderId.fromValue('igdb'), ProviderId.igdb);
      expect(ProviderId.fromValue('mangadex'), ProviderId.mangaDex);
      expect(ProviderId.fromValue('musicbrainz'), ProviderId.musicBrainz);
      expect(ProviderId.fromValue('openlibrary'), ProviderId.openLibrary);
      expect(ProviderId.fromValue('tmdb'), ProviderId.tmdb);
      expect(ProviderId.fromValue('trakt'), ProviderId.trakt);
      expect(ProviderId.fromValue('simkl'), ProviderId.simkl);
      expect(ProviderId.fromValue('myanimelist'), ProviderId.myAnimeList);
      expect(ProviderId.fromValue('kitsu'), ProviderId.kitsu);
      expect(ProviderId.fromValue('imdb'), ProviderId.imdb);
      expect(ProviderId.fromValue('goodreads'), ProviderId.goodReads);
      expect(ProviderId.fromValue('howlongtobeat'), ProviderId.howLongToBeat);
      expect(ProviderId.fromValue('steam'), ProviderId.steam);
    });

    test('ProviderPersonalEntry serializes and deserializes cleanly', () {
      final entry = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '12345',
        kind: CatalogMediaKind.anime,
        title: 'Sousou no Frieren',
        externalIds: const {'anilist': '12345', 'myanimelist': '52991'},
        status: ProviderEntryStatus.completed,
        rating: 95.0,
        progress: 28,
        totalProgress: 28,
        startedAt: DateTime(2023, 9, 29),
        completedAt: DateTime(2024, 3, 22),
        repeatCount: 1,
        notes: 'Masterpiece',
      );

      final json = entry.toJson();
      final restored = ProviderPersonalEntry.fromJson(json);

      expect(restored.provider, ProviderId.aniList);
      expect(restored.remoteItemId, '12345');
      expect(restored.kind, CatalogMediaKind.anime);
      expect(restored.title, 'Sousou no Frieren');
      expect(restored.externalIds['myanimelist'], '52991');
      expect(restored.status, ProviderEntryStatus.completed);
      expect(restored.rating, 95.0);
      expect(restored.progress, 28);
      expect(restored.repeatCount, 1);
      expect(restored.notes, 'Masterpiece');
    });

    test('ExternalStateEngine detects clean local and remote changes', () {
      const engine = ExternalStateEngine();

      final base = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80.0,
        progress: 5,
      );

      // Remote progressed to 10
      final remote = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80.0,
        progress: 10,
      );

      // Local rated 85
      const local = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 85.0,
        progress: 5,
      );

      final diff = engine.diffEntry(
        remote: remote,
        base: base,
        local: local,
        localRef: const CatalogEntityRef(
          id: 'local_1',
          kind: 'anime',
          entityType: CatalogEntityType.work,
        ),
      );

      expect(diff.hasConflicts, isFalse);
      expect(diff.diffs.length, 4);

      final progressDiff =
          diff.diffs.firstWhere((d) => d.field == SyncField.progress);
      expect(progressDiff.state, FieldDiffState.remoteChanged);
      expect(progressDiff.resolvedValue, 10);

      final ratingDiff =
          diff.diffs.firstWhere((d) => d.field == SyncField.rating);
      expect(ratingDiff.state, FieldDiffState.localChanged);
      expect(ratingDiff.resolvedValue, 85.0);

      final statusDiff =
          diff.diffs.firstWhere((d) => d.field == SyncField.status);
      expect(statusDiff.state, FieldDiffState.unchanged);
    });

    test('sync policy fields match engine dimensions and diff history', () {
      const policy = ProviderSyncPolicy();
      expect(
        policy.toJson().keys,
        containsAll(['status', 'rating', 'progress', 'history']),
      );
      expect(policy.toJson().containsKey('wishlist'), isFalse);

      final base = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: 'history-1',
        kind: CatalogMediaKind.anime,
        startedAt: DateTime.utc(2024, 1, 1),
        repeatCount: 1,
        notes: 'base',
      );
      final remote = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: 'history-1',
        kind: CatalogMediaKind.anime,
        startedAt: DateTime.utc(2024, 1, 1),
        completedAt: DateTime.utc(2024, 2, 1),
        repeatCount: 2,
        notes: 'remote',
      );

      final diff = const ExternalStateEngine().diffEntry(
        remote: remote,
        base: base,
        local: base,
        policy: policy,
      );
      final historyDiff =
          diff.diffs.firstWhere((entry) => entry.field == SyncField.history);

      expect(historyDiff.state, FieldDiffState.remoteChanged);
      expect(historyDiff.resolvedValue, isA<ProviderHistorySnapshot>());
    });

    test('ExternalStateEngine flags conflicts when both sides change', () {
      const engine = ExternalStateEngine();

      const base = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        progress: 5,
      );

      const remote = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.dropped,
        progress: 6,
      );

      const local = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '100',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.completed,
        progress: 12,
      );

      final diff = engine.diffEntry(
        remote: remote,
        base: base,
        local: local,
      );

      expect(diff.hasConflicts, isTrue);
      final statusDiff =
          diff.diffs.firstWhere((d) => d.field == SyncField.status);
      expect(statusDiff.state, FieldDiffState.conflictBothChanged);
      expect(statusDiff.resolvedValue, isNull);
    });

    test('MutationOrigin correctly flags echo prevention', () {
      expect(MutationOrigin.user.shouldEchoToExternalProvider, isTrue);
      expect(
        MutationOrigin.collectarrSync.shouldEchoToExternalProvider,
        isTrue,
      );

      const providerOrigin = MutationOrigin(
        source: MutationSourceType.externalProvider,
        provider: ProviderId.aniList,
      );
      expect(providerOrigin.shouldEchoToExternalProvider, isFalse);

      const fileOrigin = MutationOrigin(
        source: MutationSourceType.fileImport,
      );
      expect(fileOrigin.shouldEchoToExternalProvider, isFalse);
    });
  });
}
