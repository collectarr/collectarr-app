import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportRow <-> ProviderPersonalEntry Conversions', () {
    test('converts ImportRow to ProviderPersonalEntry correctly', () {
      final started = DateTime.utc(2025, 1, 1);
      final completed = DateTime.utc(2025, 2, 1);
      final row = ImportRow(
        sourceId: 'item-100',
        title: 'Chainsaw Man',
        mediaKind: 'manga',
        status: ProviderEntryStatus.completed,
        rating: 90,
        progress: 100,
        startedAt: started,
        finishedAt: completed,
        externalIds: const {'anilist': '100', 'mal': '200'},
        raw: const {'custom': 'value'},
      );

      final entry = row.toProviderPersonalEntry(ProviderId.aniList);

      expect(entry.provider, ProviderId.aniList);
      expect(entry.remoteItemId, 'item-100');
      expect(entry.title, 'Chainsaw Man');
      expect(entry.kind, CatalogMediaKind.manga);
      expect(entry.status, ProviderEntryStatus.completed);
      expect(entry.rating, 90.0);
      expect(entry.progress, 100);
      expect(entry.startedAt, started);
      expect(entry.completedAt, completed);
      expect(entry.externalIds['mal'], '200');
      expect(entry.rawPayload['custom'], 'value');
    });

    test('converts ProviderPersonalEntry to ImportRow correctly', () {
      final started = DateTime.utc(2025, 1, 1);
      final completed = DateTime.utc(2025, 2, 1);
      final entry = ProviderPersonalEntry(
        provider: ProviderId.mangaDex,
        remoteItemId: 'md-999',
        title: 'Berserk',
        kind: CatalogMediaKind.manga,
        status: ProviderEntryStatus.current,
        rating: 95.0,
        progress: 364,
        startedAt: started,
        completedAt: completed,
        externalIds: const {'mangadex': 'md-999'},
        rawPayload: const {'source': 'api'},
      );

      final row = ImportRow.fromProviderPersonalEntry(entry);

      expect(row.sourceId, 'md-999');
      expect(row.title, 'Berserk');
      expect(row.mediaKind, 'manga');
      expect(row.status, ProviderEntryStatus.current);
      expect(row.rating, 95);
      expect(row.progress, 364);
      expect(row.startedAt, started);
      expect(row.finishedAt, completed);
      expect(row.externalIds['mangadex'], 'md-999');
      expect(row.raw['source'], 'api');
    });
  });
}
