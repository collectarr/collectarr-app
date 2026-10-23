import 'dart:io';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_completeness.dart';
import 'package:flutter_test/flutter_test.dart';

String _fixture(String kind, String name) =>
    File('test/fixtures/imports/$kind/clz_web/$name.xml').readAsStringSync();
void main() {
  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ]) {
    test('CLZ ${kind.apiValue} preserves typed metadata and personal fields',
        () {
      final importer = libraryImportForKind(kind).sources.single.importer!;
      final source = _fixture(kind.apiValue, 'optional');
      final row = importer.parse(source).single;
      final record = LibraryEntryRecord.fromJson(row.fullEntryPayload!);
      expect(row.mediaKind, kind);
      expect(record.kind, kind);
      expect(importer.parse(source).single.itemId, row.itemId);
      expect(record.catalogData['release_date_parts'], {'year': 2020});
      expect(record.personalData['purchase_date_parts'],
          {'year': 2022, 'month': 4});
      expect(record.personalData['price_paid_cents'], 1234);
      expect(record.personalData['market_value_cents'], 1758);
      expect(record.personalData['quantity'], 2);
      expect(record.personalData['index_number'], 7);
      expect(record.personalData['rating'], 8);
      expect(record.personalData['owner_label'], 'Alex QA');
      expect(record.personalData['tags'], ['A, B', 'Gift']);
      expect(record.personalData['collection_status'], 'Wish List');
      expect(record.updatedAt, DateTime.utc(2021, 1, 2));
      expect(record.sourceCatalogRef, isNull);
    });
    test(
        'CLZ ${kind.apiValue} refuses another inventory without reclassification',
        () {
      final importer = libraryImportForKind(kind).sources.single.importer!;
      expect(() => importer.parse(_fixture(kind.apiValue, 'invalid')),
          throwsFormatException);
    });
  }
  test(
      'CLZ Hardware serial remains personal and Toys never acquires game state',
      () {
    final hardware = LibraryEntryRecord.fromJson(
        libraryImportForKind(CatalogMediaKind.gameHardware)
            .sources
            .single
            .importer!
            .parse(_fixture('game_hardware', 'optional'))
            .single
            .fullEntryPayload!);
    final typed = GameHardwareLibraryEntry.fromJson(hardware.toKindJson());
    expect(typed.personal.details.serialNumber, 'LOCAL-SERIAL-42');
    expect(typed.metadata.toJson(), isNot(contains('serial_number')));
    expect(typed.createdAt, DateTime.utc(2021));
    final toy = LibraryEntryRecord.fromJson(
        libraryImportForKind(CatalogMediaKind.gameToy)
            .sources
            .single
            .importer!
            .parse(_fixture('game_toy', 'optional'))
            .single
            .fullEntryPayload!);
    final figure = GameToyLibraryEntry.fromJson(toy.toKindJson());
    expect(figure.metadata.toyType, 'Figure');
    expect(figure.personal.details.completeness, GameToyCompleteness.newSealed);
    expect(figure.personal.details.toJson(), isNot(contains('game_completed')));
    expect(figure.personal.details.toJson(),
        isNot(contains('game_toy_has_manual')));
  });
  test(
      'CLZ Games completion is scoped to Games and duplicate copies stay independent',
      () {
    final importer =
        libraryImportForKind(CatalogMediaKind.game).sources.single.importer!;
    final source = _fixture('game', 'optional');
    final record = LibraryEntryRecord.fromJson(
        importer.parse(source).single.fullEntryPayload!);
    final game = GameLibraryEntry.fromJson(record.toKindJson());
    expect(game.personal.details.completed, isTrue);
    expect(game.metadata.platforms, ['PC']);
    expect(game.personal.details.completedDate!.isoString, '2023-01-02');
    final start = source.indexOf('<game>');
    final end = source.indexOf('</game>') + 7;
    final duplicate = source.replaceFirst(
        '</gamelist>', '${source.substring(start, end)}</gamelist>');
    final rows = importer.parse(duplicate);
    expect(rows.map((row) => row.itemId).toSet(), hasLength(2));
  });
  test('CLZ import rejects invalid calendar dates and invalid money', () {
    final importer = libraryImportForKind(CatalogMediaKind.gameHardware)
        .sources
        .single
        .importer!;
    final source = _fixture('game_hardware', 'optional');
    expect(
        () => importer.parse(
            source.replaceFirst('<month>04</month>', '<month>13</month>')),
        throwsFormatException);
    expect(() => importer.parse(source.replaceFirst('12.34', 'bad')),
        throwsFormatException);
  });
}
