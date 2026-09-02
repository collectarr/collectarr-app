import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/imports/framework/import_runner.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:flutter_test/flutter_test.dart';

ImportRow _row(String id, String title, {String kind = 'anime'}) {
  return ImportRow(
    sourceId: id,
    title: title,
    mediaKind: kind,
    status: ProviderEntryStatus.completed,
    rating: 80,
  );
}

CatalogEntityRef _ref(String id) => CatalogEntityRef(
      kind: 'anime',
      entityType: CatalogEntityType.work,
      id: id,
    );

class _Source implements ImportSource {
  _Source(this.rows);

  final List<ImportRow> rows;

  @override
  ProviderId get provider => ProviderId.myAnimeList;

  @override
  Future<List<ImportRow>> readRows() async => rows;
}

void main() {
  const config = ImportRunConfig(
    provider: ProviderId.myAnimeList,
    collectionLabel: 'Anime',
    sourceLabel: 'mal-export.xml',
    proposeUnmatched: true,
  );

  test('runner imports matched rows and counts them', () async {
    final runner = ImportRunner(
      matcher: (row) async => ImportMapping.matched(
          row, _ref('anime-${(row as ImportRow).sourceId}')),
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
          entry: mapping.entry,
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

  test('runner can read rows from a source and call unmatched handler',
      () async {
    final handled = <String>[];
    final runner = ImportRunner(
      matcher: (row) async => ImportMapping.unmatched(row),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
      unmatchedHandler: (row, cfg) async {
        handled.add((row as ImportRow).sourceId);
      },
    );

    final result = await runner.runSource(
      _Source([_row('7', 'Baki')]),
      config,
    );

    expect(handled, ['7']);
    expect(result.rows, 1);
    expect(result.proposed, 1);
  });

  test('result maps onto a provider history entry', () async {
    final runner = ImportRunner(
      matcher: (row) async => ImportMapping.matched(
          row, _ref('anime-${(row as ImportRow).sourceId}')),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );
    final result = await runner.run([_row('1', 'Steins;Gate')], config);

    final entry = result.toHistoryEntry(
      id: 'run-1',
      createdAt: DateTime.utc(2026, 7, 7),
    );

    expect(entry.provider, ProviderId.myAnimeList);
    expect(entry.collectionLabel, 'Anime');
    expect(entry.sourceLabel, 'mal-export.xml');
    expect(entry.rows, 1);
    expect(entry.imported, 1);
  });

  test(
      'runner integrates with ProviderPersonalEntry and ExternalStateEngine diff',
      () async {
    const engine = ExternalStateEngine();
    const entry = ProviderPersonalEntry(
      provider: ProviderId.myAnimeList,
      remoteItemId: '1',
      kind: CatalogMediaKind.anime,
      title: 'Death Note',
      status: ProviderEntryStatus.completed,
      rating: 90.0,
      progress: 37,
    );

    final diff = engine.diffEntry(
      remote: entry,
      base: null,
      local: const ProviderPersonalEntry(
        provider: ProviderId.myAnimeList,
        remoteItemId: '1',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80.0,
      ),
      mode: SyncEngineMode.oneShotImport,
    );

    expect(diff.hasConflicts, isTrue);

    final runner = ImportRunner(
      engine: engine,
      matcher: (e) async => ImportMapping.matched(
        e,
        _ref('anime-1'),
        diff: diff,
      ),
      conflictDetector: (mapping) async => [
        if (mapping.diff?.hasConflicts ?? false)
          ImportConflict(
            entry: mapping.entry,
            kind: ImportConflictKind.statusDiffers,
            description: 'Status or rating conflict detected',
            target: mapping.target,
            diff: mapping.diff?.diffs.firstWhere((d) => d.hasConflict),
          ),
      ],
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );

    final result = await runner.run([entry], config);
    expect(result.rows, 1);
    expect(result.matched, 1);
    expect(result.hasConflicts, isTrue);
    expect(result.conflicts.first.diff?.field, SyncField.status);
  });
}
