import 'dart:io';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_import_contributors.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ]) {
    test('CLZ ${kind.apiValue} CSV persists its loan and custom field once',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final events = CollectionEventBus();
      addTearDown(events.dispose);
      final container = ProviderContainer(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        collectionMutationRunnerProvider.overrideWithValue(
            CollectionMutationRunner(database: db, events: events)),
      ]);
      addTearDown(container.dispose);
      final capability = libraryImportForKind(kind);
      final csv = const CsvReader().read(
          File('test/fixtures/imports/${kind.apiValue}/clz_csv/optional.csv')
              .readAsStringSync());
      final mappings = <int, String>{};
      for (var column = 0; column < csv.first.length; column++) {
        final label = csv.first[column].toLowerCase();
        final field = capability.mappableFields.where((field) =>
            field.label.toLowerCase() == label ||
            field.aliases.any((alias) => alias.toLowerCase() == label));
        mappings[column] =
            field.isEmpty ? importCustomFieldMappingKey : field.first.key;
      }
      // Derived export columns (Release Year ...) are not destinations.
      mappings.removeWhere((column, key) =>
          key == importCustomFieldMappingKey &&
          csv.first[column] != 'Shelf Code');
      // Without an Index in the file, the new entry takes the first free one.
      final data = [
        for (final row in csv.skip(1))
          [
            for (var i = 0; i < row.length; i++)
              csv.first[i] == 'Index' ? '' : row[i]
          ]
      ];
      final rows = capability.mappedCsvImporter!.parse(data,
          mappings: mappings, multiValueDelimiter: ';', headers: csv.first);
      final importer = container.read(collectionImportOrchestratorProvider);
      expect(await importer.importRows(rows), 1);
      expect(await entryContributorForKind(kind).nextOrdinal(db), 2);
      expect(await importer.importRows(rows), 1);
      expect(await entryContributorForKind(kind).nextOrdinal(db), 2);

      final ref =
          LibraryEntryRef(kind: kind, id: LibraryEntryId(rows.single.itemId));
      final loans = await LoanRepository(db).getLoansForItem(ref);
      expect(loans, hasLength(1));
      expect(loans.single.borrowerName, 'Sam Example');
      expect(loans.single.dueDate!.toUtc(), DateTime.utc(2024, 3, 15));
      final values = await CustomFieldRepository(db).listValuesForTarget(
          targetId: ref.key, targetScope: CustomFieldTargetScope.libraryEntry);
      expect(values, hasLength(1));
      expect(values.single.value, 'A-12');
    });
  }
}
