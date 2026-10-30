import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/formats/clz_csv_values.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import '../../domain/game_toy_metadata.dart';
import '../../domain/game_toy_personal_data.dart';
import '../../entries/game_toy_entry_details.dart';
import '../../domain/game_toy_completeness.dart';

/// Maps the columns of a CLZ Games CSV/TXT export of a Toys collection onto
/// Toys entries. Header labels follow the CLZ column names.
final class GameToyMappedCsvImporter implements LibraryMappedCsvImporter {
  const GameToyMappedCsvImporter();

  @override
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
    List<String> headers = const [],
  }) {
    final records =
        readClzCsvRecords(rows, mappings: mappings, headers: headers);
    final ids = ClzImportIdentities(CatalogMediaKind.gameToy);
    return List.unmodifiable(
        [for (final record in records) _row(record, multiValueDelimiter, ids)]);
  }

  CollectionImportRow _row(
      ClzCsvRecord record, String delimiter, ClzImportIdentities ids) {
    final title = record.text('title') ?? '';
    final identity =
        '$title/${record.text('series') ?? ''}/${record.text('barcode') ?? ''}';
    final id = ids.next('csv/$identity');
    final metadata = GameToyCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, record.text('sort_title')),
      barcode: record.text('barcode'),
      seriesTitle: record.text('series'),
      releaseDateParts: record.date('release_date', 'Release Date'),
      description: record.text('description'),
      toyType: record.text('toy_type'),
      toySubtype: record.text('toy_subtype'),
    );
    final purchase = record.date('purchase_date', 'Purchase Date');
    final personal = GameToyPersonalData(
        ownerLabel: record.text('owner'),
        personalNotes: record.text('notes'),
        tags: record.list('tags', delimiter),
        condition: record.text('condition'),
        rating: record.integer('my_rating', 'My Rating', max: 10),
        quantity: record.integer('quantity', 'Quantity') ?? 1,
        indexNumber: record.integer('index', 'Index'),
        pricePaidCents: record.money('purchase_price', 'Purchase Price'),
        marketValueCents: record.money('value', 'Value'),
        purchaseStore: record.text('purchase_store'),
        collectionStatus: record.collectionStatus,
        purchaseDateParts: purchase,
        purchaseDate: purchase?.asDateTime,
        details: GameToyEntryDetails(
            completeness: _completeness(record.text('completeness')),
            hasBox: record.boolean('box', 'Box')));
    return clzImportRow(
        kind: CatalogMediaKind.gameToy,
        id: id,
        title: title,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: record.instant('added_date', 'Added Date'),
        updatedAt: record.instant('modified_date', 'Modified Date'),
        loan: record.loan,
        customFieldValues: record.customFields);
  }
}

GameToyCompleteness _completeness(String? value) =>
    switch (value?.toLowerCase()) {
      null || 'loose' => GameToyCompleteness.loose,
      'new' => GameToyCompleteness.newSealed,
      _ => throw LibraryImportFormatException(
          'Unsupported Toys completeness "$value".'),
    };
