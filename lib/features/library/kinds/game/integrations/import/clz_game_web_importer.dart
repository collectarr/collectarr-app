import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/imports/formats/clz_web_xml.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import '../../domain/game_metadata.dart';
import '../../domain/game_personal_data.dart';
import '../../entries/game_entry_details.dart';
import '../../vocabulary/game_vocabularies.dart';

final class ClzGameWebImporter implements LibraryGuidedImporter {
  const ClzGameWebImporter();
  @override
  List<CollectionImportRow> parse(String source) {
    final records = readClzWebRecords(source,
        section: 'gameinfo', list: 'gamelist', record: 'game');
    final ids = ClzImportIdentities(CatalogMediaKind.game);
    return List.unmodifiable([for (final raw in records) _parse(raw, ids)]);
  }

  CollectionImportRow _parse(ClzXmlRecord raw, ClzImportIdentities ids) {
    raw.requireItemType(0, field: 'gameitemtype');
    final title = raw.text('title') ?? '';
    final externalId = raw.text('hash') ?? title;
    final identity = '${raw.text('collection/hash') ?? ''}/$externalId';
    final id = ids.next(identity);
    final metadata = GameCatalogMetadata(
      title: title,
      sortKey: resolveSortTitle(title, raw.text('sorttitle')),
      barcode: raw.text('barcode'),
      seriesTitle: raw.text('series'),
      releaseDateParts: raw.date('releasedate'),
      description: raw.text('description'),
      coverImageUrl: raw.text('coverfrontdefault'),
      platforms: [if (raw.text('platform') case final value?) value],
      developers: raw.values('developers', 'developer'),
      publisher: joinGamePublishers(raw.values('publishers', 'publisher')),
      genres: raw.values('genres', 'genre'),
      physicalFormat: raw.text('format'),
      editionTitle: raw.text('edition'),
      releaseRegion: raw.text('region'),
      audienceRating: raw.text('audiencerating'),
    );
    final purchase = raw.date('purchasedate');
    final personal = GamePersonalData(
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
        details: GameEntryDetails(
            completeness: _completeness(raw.text('completeness')),
            hasBox: raw.boolean('hasbox'),
            hasManual: raw.boolean('hasmanual'),
            storageDevice: raw.text('storagedevice'),
            storageSlot: raw.text('storageslot'),
            completed: raw.boolean('completed'),
            completedDate: raw.date('completiondate'),
            priceChartingId: raw.text('pricechartingid'),
            valueIsLocked: raw.boolean('valueislocked')));
    return clzImportRow(
        kind: CatalogMediaKind.game,
        id: id,
        title: title,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: raw.instant('addeddate'),
        updatedAt: raw.instant('modifieddate'));
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
