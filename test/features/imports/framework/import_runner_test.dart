import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/imports/framework/import_runner.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderPersonalEntry _entry(String id, String title,
    {CatalogMediaKind kind = CatalogMediaKind.anime}) {
  return ProviderPersonalEntry(
    provider: ProviderId.myAnimeList,
    remoteItemId: id,
    kind: kind,
    title: title,
    status: ProviderEntryStatus.completed,
    rating: 80.0,
  );
}

CatalogEntityRef _ref(String id) => CatalogEntityRef(
      kind: 'anime',
      entityType: CatalogEntityType.work,
      id: id,
    );

class _Source implements ImportSource {
  _Source(this.rows);

  final List<ProviderPersonalEntry> rows;

  @override
  ProviderId get provider => ProviderId.myAnimeList;

  @override
  Future<List<ProviderPersonalEntry>> readRows() async => rows;
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
      matcher: (row) async =>
          ImportMapping.matched(row, _ref('anime-${row.remoteItemId}')),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );

    final result = await runner.run(
      [_entry('1', 'Cowboy Bebop'), _entry('2', 'Trigun')],
      config,
    );

    expect(result.rows, 2);
    expect(result.matched, 2);
    expect(result.imported, 2);
    expect(result.unmatched, 0);
    expect(result.hasConflicts, isFalse);
  });

  test('runner passes the configured mutation origin to the applier', () async {
    MutationOrigin? appliedOrigin;
    final runner = ImportRunner(
      matcher: (entry) async => ImportMapping.matched(entry, _ref('anime-1')),
      applier: (mapping, config) async {
        appliedOrigin = config.origin;
        return ImportRowOutcome.imported;
      },
    );

    await runner.run(
      [_entry('1', 'Cowboy Bebop')],
      const ImportRunConfig(
        provider: ProviderId.myAnimeList,
        collectionLabel: 'Anime',
        origin: MutationOrigin.fileImport,
      ),
    );

    expect(appliedOrigin, MutationOrigin.fileImport);
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

    final result = await runner.run([_entry('1', 'Berserk')], config);

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

    final result = await runner.run([_entry('99', 'Obscure OVA')], config);

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
        handled.add(row.remoteItemId);
      },
    );

    final result = await runner.runSource(
      _Source([_entry('7', 'Baki')]),
      config,
    );

    expect(handled, ['7']);
    expect(result.rows, 1);
    expect(result.proposed, 1);
  });

  test('result maps onto a provider history entry', () async {
    final runner = ImportRunner(
      matcher: (row) async =>
          ImportMapping.matched(row, _ref('anime-${row.remoteItemId}')),
      applier: (mapping, cfg) async => ImportRowOutcome.imported,
    );
    final result = await runner.run([_entry('1', 'Steins;Gate')], config);

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
