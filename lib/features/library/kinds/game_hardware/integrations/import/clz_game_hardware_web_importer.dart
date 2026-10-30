import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/imports/formats/clz_web_xml.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import '../../domain/game_hardware_metadata.dart';
import '../../domain/game_hardware_personal_data.dart';
import '../../entries/game_hardware_entry_details.dart';
import '../../domain/game_hardware_completeness.dart';

final class ClzGameHardwareWebImporter implements LibraryGuidedImporter {
  const ClzGameHardwareWebImporter();
  @override
  List<CollectionImportRow> parse(String source) {
    final records = readClzWebRecords(source,
        section: 'gameinfo', list: 'gamelist', record: 'game');
    final ids = ClzImportIdentities(CatalogMediaKind.gameHardware);
    return List.unmodifiable([for (final raw in records) _parse(raw, ids)]);
  }

  CollectionImportRow _parse(ClzXmlRecord raw, ClzImportIdentities ids) {
    raw.requireItemType(1, field: 'gameitemtype');
    final title = raw.text('title') ?? '';
    final externalId = raw.text('hash') ?? title;
    final identity = '${raw.text('collection/hash') ?? ''}/$externalId';
    final id = ids.next(identity);
    final metadata = GameHardwareCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, raw.text('sorttitle')),
      barcode: raw.text('barcode'),
      seriesTitle: raw.text('series'),
      releaseDateParts: raw.date('releasedate'),
      description: raw.text('description'),
      coverImageUrl: raw.text('coverfrontdefault'),
      platform: raw.text('platform'),
      hardwareType: raw.text('hardwaretype'),
    );
    final purchase = raw.date('purchasedate');
    final personal = GameHardwarePersonalData(
        ownerLabel: raw.text('owner'),
        personalNotes: raw.text('notes'),
        tags: raw.values('tags', 'tag'),
        condition: raw.text('condition'),
        rating: raw.integer('myrating', max: 10),
        quantity: raw.integer('quantity') ?? 1,
        indexNumber: raw.integer('index'),
        pricePaidCents: raw.money('purchaseprice'),
        marketValueCents: raw.money('currentvalue'),
        currency: raw.text('currency'),
        purchaseStore: raw.text('store'),
        collectionStatus: raw.collectionStatus,
        purchaseDateParts: purchase,
        purchaseDate: purchase?.asDateTime,
        details: GameHardwareEntryDetails(
            completeness: _completeness(raw.text('completeness')),
            hasBox: raw.boolean('hasbox'),
            hasManual: raw.boolean('hasmanual'),
            serialNumber: raw.text('serialnr'),
            priceChartingId: raw.text('pricechartingid'),
            valueIsLocked: raw.boolean('valueislocked')));
    return clzImportRow(
        kind: CatalogMediaKind.gameHardware,
        id: id,
        title: title,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: raw.instant('addeddate'),
        updatedAt: raw.instant('modifieddate'));
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
