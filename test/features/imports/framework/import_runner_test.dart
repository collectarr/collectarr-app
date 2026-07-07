import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/imports/framework/import_runner.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:flutter_test/flutter_test.dart';

ImportRow _row(String id, String title, {String kind = 'anime'}) {
  return ImportRow(
    sourceId: id,
    title: title,
    mediaKind: kind,
    status: ImportItemStatus.completed,
    rating: 80,
  );
}

CatalogEntityRef _ref(String id) => CatalogEntityRef(
      kind: 'anime',
      entityType: CatalogEntityType.work,
      id: id,
    );

void main() {
  const config = ImportRunConfig(
    provider: ProviderImportId.myAnimeList,
    collectionLabel: 'Anime',
    sourceLabel: 'mal-export.xml',
    proposeUnmatched: true,
  );

  test('runner imports matched rows and counts them', () async {
    final runner = ImportRunner(
      matcher: (row) async =>
          ImportMapping.matched(row, _ref('anime-${row.sourceId}')),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );

    final result = await runner.run(
      [_row('1', 'Cowboy Bebop'), _row('2', 'Trigun')],
      config,
    );

    expect(result.rows, 2);
    expect(result.matched, 2);
    expect(result.imported, 2);
    expect(result.unmatched, 0);
    expect(result.hasConflicts, isFalse);
  });

  test('runner surfaces conflicts and keeps local when applier says so',
      () async {
    final runner = ImportRunner(
      matcher: (row) async => ImportMapping.matched(row, _ref('anime-1')),
      conflictDetector: (mapping) async => [
        ImportConflict(
          row: mapping.row,
          kind: ImportConflictKind.ratingDiffers,
          description: 'Local rating differs from imported rating',
          target: mapping.target,
        ),
      ],
      applier: (mapping, cfg) async => ImportRowOutcome.keptLocal,
    );

    final result = await runner.run([_row('1', 'Berserk')], config);

    expect(result.matched, 1);
    expect(result.keptLocal, 1);
    expect(result.imported, 0);
    expect(result.conflicts, hasLength(1));
    expect(result.conflicts.single.kind, ImportConflictKind.ratingDiffers);
  });

  test('runner proposes unmatched rows when configured', () async {
    final runner = ImportRunner(
      matcher: (row) async => ImportMapping.unmatched(row),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );

    final result = await runner.run([_row('99', 'Obscure OVA')], config);

    expect(result.matched, 0);
    expect(result.unmatched, 1);
    expect(result.proposed, 1);
    expect(result.imported, 0);
  });

  test('result maps onto a provider history entry', () async {
    final runner = ImportRunner(
      matcher: (row) async =>
          ImportMapping.matched(row, _ref('anime-${row.sourceId}')),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );
    final result = await runner.run([_row('1', 'Steins;Gate')], config);

    final entry = result.toHistoryEntry(
      id: 'run-1',
      createdAt: DateTime.utc(2026, 7, 7),
    );

    expect(entry.provider, ProviderImportId.myAnimeList);
    expect(entry.collectionLabel, 'Anime');
    expect(entry.sourceLabel, 'mal-export.xml');
    expect(entry.rows, 1);
    expect(entry.imported, 1);
  });
}
