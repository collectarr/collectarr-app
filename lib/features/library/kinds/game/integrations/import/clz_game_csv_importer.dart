import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/formats/clz_csv_values.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import '../../domain/game_metadata.dart';
import '../../domain/game_personal_data.dart';
import '../../entries/game_entry_details.dart';
import '../../vocabulary/game_vocabularies.dart';

/// Maps the columns of a CLZ Games CSV/TXT export (or any similar file) onto
/// Games entries. Header labels follow the CLZ column names.
final class GameMappedCsvImporter implements LibraryMappedCsvImporter {
  const GameMappedCsvImporter();

  @override
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
    List<String> headers = const [],
  }) {
    final records =
        readClzCsvRecords(rows, mappings: mappings, headers: headers);
    final ids = ClzImportIdentities(CatalogMediaKind.game);
    return List.unmodifiable(
        [for (final record in records) _row(record, multiValueDelimiter, ids)]);
  }

  CollectionImportRow _row(
      ClzCsvRecord record, String delimiter, ClzImportIdentities ids) {
    final title = record.text('title') ?? '';
    final platform = record.text('platform');
    final identity = '$title/${platform ?? ''}/${record.text('barcode') ?? ''}';
    final id = ids.next('csv/$identity');
    final metadata = GameCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, record.text('sort_title')),
      barcode: record.text('barcode'),
      seriesTitle: record.text('series'),
      releaseDateParts: record.date('release_date', 'Release Date'),
      description: record.text('description'),
      platforms: [if (platform != null) platform],
      developers: record.list('developer', delimiter),
      publisher: joinGamePublishers(record.list('publisher', delimiter)),
      genres: record.list('genre', delimiter),
      physicalFormat: record.text('format'),
      editionTitle: record.text('edition'),
      releaseRegion: record.text('region'),
      audienceRating: record.text('audience_rating'),
    );
    final purchase = record.date('purchase_date', 'Purchase Date');
    final personal = GamePersonalData(
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
        details: GameEntryDetails(
            completeness: _completeness(record.text('completeness')),
            hasBox: record.boolean('box', 'Box'),
            hasManual: record.boolean('manual', 'Manual'),
            storageDevice: record.text('storage_device'),
            storageSlot: record.text('storage_slot'),
            completed: record.boolean('completed', 'Completed'),
            completedDate: record.date('completed_date', 'Completed Date')));
    return clzImportRow(
        kind: CatalogMediaKind.game,
        id: id,
        title: title,
        subtitle: metadata.seriesTitle,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: record.instant('added_date', 'Added Date'),
        updatedAt: record.instant('modified_date', 'Modified Date'),
        loan: record.loan,
        customFieldValues: record.customFields);
  }
}

String? _completeness(String? value) => switch (value?.toLowerCase()) {
      null || 'n/a' => null,
      'loose' => 'loose',
      'cib' => 'cib',
      'new' => 'new',
      'graded' => 'graded',
      _ => throw LibraryImportFormatException(
          'Unsupported Games completeness "$value".'),
    };
