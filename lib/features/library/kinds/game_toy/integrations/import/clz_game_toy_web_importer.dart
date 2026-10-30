import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/imports/formats/clz_web_xml.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import '../../domain/game_toy_metadata.dart';
import '../../domain/game_toy_personal_data.dart';
import '../../entries/game_toy_entry_details.dart';
import '../../domain/game_toy_completeness.dart';

final class ClzGameToyWebImporter implements LibraryGuidedImporter {
  const ClzGameToyWebImporter();
  @override
  List<CollectionImportRow> parse(String source) {
    final records = readClzWebRecords(source,
        section: 'gameinfo', list: 'gamelist', record: 'game');
    final ids = ClzImportIdentities(CatalogMediaKind.gameToy);
    return List.unmodifiable([for (final raw in records) _parse(raw, ids)]);
  }

  CollectionImportRow _parse(ClzXmlRecord raw, ClzImportIdentities ids) {
    raw.requireItemType(2, field: 'gameitemtype');
    final title = raw.text('title') ?? '';
    final externalId = raw.text('hash') ?? title;
    final identity = '${raw.text('collection/hash') ?? ''}/$externalId';
    final id = ids.next(identity);
    final metadata = GameToyCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, raw.text('sorttitle')),
      barcode: raw.text('barcode'),
      seriesTitle: raw.text('series'),
      releaseDateParts: raw.date('releasedate'),
      description: raw.text('description'),
      coverImageUrl: raw.text('coverfrontdefault'),
      toyType: raw.text('toytype'),
      toySubtype: raw.text('toysubtype'),
    );
    final purchase = raw.date('purchasedate');
    final personal = GameToyPersonalData(
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
        details: GameToyEntryDetails(
            completeness: _completeness(raw.text('completeness')),
            hasBox: raw.boolean('hasbox'),
            priceChartingId: raw.text('pricechartingid'),
            valueIsLocked: raw.boolean('valueislocked')));
    return clzImportRow(
        kind: CatalogMediaKind.gameToy,
        id: id,
        title: title,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: raw.instant('addeddate'),
        updatedAt: raw.instant('modifieddate'));
  }
}

GameToyCompleteness _completeness(String? value) =>
    switch (value?.toLowerCase()) {
      null || 'loose' => GameToyCompleteness.loose,
      'new' => GameToyCompleteness.newSealed,
      _ => throw LibraryImportFormatException(
          'Unsupported Toys completeness "$value".'),
    };
