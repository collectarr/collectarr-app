import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/formats/clz_csv_values.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import '../../domain/game_hardware_metadata.dart';
import '../../domain/game_hardware_personal_data.dart';
import '../../entries/game_hardware_entry_details.dart';
import '../../domain/game_hardware_completeness.dart';

/// Maps the columns of a CLZ Games CSV/TXT export of a Hardware collection
/// onto Hardware entries. Header labels follow the CLZ column names.
final class GameHardwareMappedCsvImporter implements LibraryMappedCsvImporter {
  const GameHardwareMappedCsvImporter();

  @override
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
    List<String> headers = const [],
  }) {
    final records =
        readClzCsvRecords(rows, mappings: mappings, headers: headers);
    final occurrences = <String, int>{};
    return List.unmodifiable([
      for (final record in records)
        _row(record, multiValueDelimiter, occurrences)
    ]);
  }

  CollectionImportRow _row(
      ClzCsvRecord record, String delimiter, Map<String, int> occurrences) {
    final title = record.text('title') ?? '';
    final identity = '$title/${record.text('platform') ?? ''}/'
        '${record.text('serial_number') ?? ''}/${record.text('barcode') ?? ''}';
    final copy =
        occurrences.update(identity, (value) => value + 1, ifAbsent: () => 1);
    final id =
        clzImportEntryId(CatalogMediaKind.gameHardware, 'csv/$identity', copy);
    final metadata = GameHardwareCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, record.text('sort_title')),
      barcode: record.text('barcode'),
      seriesTitle: record.text('series'),
      releaseDateParts: record.date('release_date', 'Release Date'),
      description: record.text('description'),
      platform: record.text('platform'),
      hardwareType: record.text('hardware_type'),
    );
    final purchase = record.date('purchase_date', 'Purchase Date');
    final personal = GameHardwarePersonalData(
        ownerLabel: record.text('owner'),
        personalNotes: record.text('notes'),
        tags: record.list('tags', delimiter),
        condition: record.text('condition'),
        rating: record.integer('my_rating', 'My Rating', max: 10),
        quantity: record.integer('quantity', 'Quantity', min: 1) ?? 1,
        indexNumber: record.integer('index', 'Index'),
        pricePaidCents: record.money('purchase_price', 'Purchase Price'),
        marketValueCents: record.money('value', 'Value'),
        purchaseStore: record.text('purchase_store'),
        collectionStatus: record.collectionStatus,
        purchaseDateParts: purchase,
        purchaseDate: purchase?.asDateTime,
        details: GameHardwareEntryDetails(
            completeness: _completeness(record.text('completeness')),
            hasBox: record.boolean('box', 'Box'),
            hasManual: record.boolean('manual', 'Manual'),
            serialNumber: record.text('serial_number')));
    return clzImportRow(
        kind: CatalogMediaKind.gameHardware,
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

GameHardwareCompleteness? _completeness(String? value) =>
    switch (value?.toLowerCase()) {
      null || 'n/a' => null,
      'loose' => GameHardwareCompleteness.loose,
      'cib' => GameHardwareCompleteness.cib,
      'new' => GameHardwareCompleteness.newSealed,
      'graded' => GameHardwareCompleteness.graded,
      _ => throw LibraryImportFormatException(
          'Unsupported Hardware completeness "$value".'),
    };
