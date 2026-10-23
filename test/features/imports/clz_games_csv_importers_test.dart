import 'dart:io';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_completeness.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_import_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parses a CLZ CSV fixture the way the import panel does: the header row is
/// auto-mapped through the kind's field labels and aliases.
List<CollectionImportRow> _rows(CatalogMediaKind kind, String name) {
  final capability = libraryImportForKind(kind);
  final rows = const CsvReader().read(
      File('test/fixtures/imports/${kind.apiValue}/clz_csv/$name.csv')
          .readAsStringSync());
  final header = rows.first;
  final mappings = <int, String>{};
  for (var column = 0; column < header.length; column++) {
    final label = header[column].trim().toLowerCase();
    for (final field in capability.mappableFields) {
      if (field.label.toLowerCase() == label ||
          field.aliases.any((alias) => alias.toLowerCase() == label)) {
        mappings[column] = field.key;
        break;
      }
    }
    // Unrecognized columns are the user's to import as custom fields.
    if (!mappings.containsKey(column) && header[column] == 'Shelf Code') {
      mappings[column] = importCustomFieldMappingKey;
    }
  }
  return capability.mappedCsvImporter!.parse(rows.skip(1).toList(),
      mappings: mappings, multiValueDelimiter: ';', headers: header);
}

List<LibraryEntryRecord> _import(CatalogMediaKind kind, String name) => [
      for (final row in _rows(kind, name))
        LibraryEntryRecord.fromJson(row.fullEntryPayload!)
    ];

void main() {
  const kinds = [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ];
  for (final kind in kinds) {
    test('CLZ ${kind.apiValue} CSV minimal rows import as typed entries', () {
      final record = _import(kind, 'minimal').single;
      expect(record.kind, kind);
      expect(record.personalData['collection_status'], 'In Collection');
      expect(record.personalData['quantity'], 1);
      expect(record.updatedAt, DateTime.utc(2026, 10, 18));
      expect(_import(kind, 'minimal').single.id, record.id);
    });
    test('CLZ ${kind.apiValue} CSV preserves CLZ dates, money and lists', () {
      final record = _import(kind, 'optional').single;
      expect(record.catalogData['description'], isNotNull);
      expect(record.personalData['purchase_date_parts'],
          {'year': 2022, 'month': 4, 'day': 3});
      expect(record.personalData['price_paid_cents'], 1234);
      expect(record.personalData['market_value_cents'], 1758);
      expect(record.personalData['quantity'], 2);
      expect(record.personalData['index_number'], 7);
      expect(record.personalData['rating'], 8);
      expect(record.personalData['owner_label'], 'Alex QA');
      expect(record.personalData['tags'], ['A', 'Gift']);
      expect(record.personalData['created_at'], '2021-01-02T00:00:00.000Z');
    });
    test('CLZ ${kind.apiValue} CSV rejects invalid values', () {
      expect(() => _import(kind, 'invalid'), throwsFormatException);
    });
  }
  for (final kind in kinds) {
    test('CLZ ${kind.apiValue} CSV carries loans and custom field columns', () {
      final row = _rows(kind, 'optional').single;
      expect(row.loan!.borrowerName, 'Sam Example');
      expect(row.loan!.lentDate, DateTime.utc(2024, 3, 1));
      expect(row.loan!.dueDate, DateTime.utc(2024, 3, 15));
      expect(row.customFieldValues, {'Shelf Code': 'A-12'});
      expect(_rows(kind, 'minimal').single.loan, isNull);
      expect(_rows(kind, 'minimal').single.customFieldValues, isEmpty);
    });
  }
  test('CLZ Games CSV keeps platform, list values and completion state', () {
    final record = _import(CatalogMediaKind.game, 'optional').single;
    final game = GameLibraryEntry.fromJson(record.toKindJson());
    expect(game.metadata.platforms, ['PlayStation 5']);
    expect(game.metadata.genres, ['Action', 'Open World']);
    expect(game.metadata.releaseDateParts?.isoString, '2018-04-20');
    expect(game.metadata.sortKey, 'Quest, The');
    expect(game.personal.details.completeness, 'cib');
    expect(game.personal.details.hasBox, isTrue);
    expect(game.personal.details.hasManual, isTrue);
    expect(game.personal.details.completed, isTrue);
    expect(game.personal.details.completedDate!.isoString, '2023-01-02');
    expect(game.personal.details.storageDevice, 'Disc shelf');
    expect(record.personalData['collection_status'], 'Wish List');
  });
  test('CLZ Hardware CSV keeps the serial personal', () {
    final record = _import(CatalogMediaKind.gameHardware, 'optional').single;
    final hardware = GameHardwareLibraryEntry.fromJson(record.toKindJson());
    expect(hardware.personal.details.serialNumber, 'LOCAL-SERIAL-42');
    expect(hardware.metadata.toJson(), isNot(contains('serial_number')));
    expect(hardware.metadata.platform, 'Nintendo Switch');
    expect(hardware.metadata.hardwareType, 'Console');
  });
  test('CLZ Toys CSV never acquires Games state and accepts a year-only date',
      () {
    final record = _import(CatalogMediaKind.gameToy, 'optional').single;
    final toy = GameToyLibraryEntry.fromJson(record.toKindJson());
    expect(toy.metadata.toyType, 'Figure');
    expect(toy.metadata.toySubtype, 'Hero');
    expect(toy.metadata.releaseDateParts?.year, 2020);
    expect(toy.metadata.releaseDateParts?.month, isNull);
    expect(toy.personal.details.completeness, GameToyCompleteness.newSealed);
    expect(toy.personal.details.toJson(), isNot(contains('game_completed')));
  });
  test('CLZ CSV import needs a Title mapping and unique destinations', () {
    final importer =
        libraryImportForKind(CatalogMediaKind.game).mappedCsvImporter!;
    expect(
        () => importer.parse([
              ['PC']
            ], mappings: {
              0: 'platform'
            }, multiValueDelimiter: ';'),
        throwsFormatException);
    expect(
        () => importer.parse([
              ['A', 'B']
            ], mappings: {
              0: 'title',
              1: 'title'
            }, multiValueDelimiter: ';'),
        throwsFormatException);
  });
}
