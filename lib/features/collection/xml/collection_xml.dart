import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:xml/xml.dart';

/// Exports a generic collection XML containing all shelf entries.
class CollectionXml {
  const CollectionXml();

  String serialize(
    List<ShelfEntry> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('CollectarrExport', nest: () {
      builder.attribute('version', '1');
      builder.attribute('exportedAt', DateTime.now().toUtc().toIso8601String());
      builder.attribute('count', entries.length.toString());

      for (final entry in entries) {
        builder.element('Item', nest: () {
          final metadata = entry.catalogItem?.kindMetadata;
          final item = entry.catalogItem;
          final owned = entry.ownedItem;

          _textElement(builder, 'ItemId', entry.itemId);
          _textElement(
              builder,
              'Status',
              entry.isOwned
                  ? 'owned'
                  : entry.isWishlisted
                      ? 'wishlist'
                      : 'tracked');

          if (metadata is ComicCatalogMetadata) {
            builder.element('Catalog', nest: () {
              _textElement(builder, 'Kind', 'comic');
              _textElement(builder, 'Title', metadata.title);
              _textElement(builder, 'ItemNumber', metadata.issueNumber);
              _textElement(builder, 'EditionTitle', metadata.editionTitle);
              _textElement(builder, 'PhysicalFormat', metadata.physicalFormat);
              _textElement(builder, 'Publisher', metadata.publisher);
              _textElement(builder, 'Barcode', metadata.barcode);
              _textElement(builder, 'Variant', metadata.variant);
              _textElement(builder, 'SeriesTitle', metadata.seriesTitle);
              if (metadata.series?.volumeNumber != null) {
                _textElement(
                    builder, 'VolumeName', metadata.series!.volumeName);
              }
              if (metadata.releaseDate != null) {
                _textElement(builder, 'ReleaseDate',
                    metadata.releaseDate!.toIso8601String().split('T').first);
                _textElement(builder, 'ReleaseYear',
                    metadata.releaseDate!.year.toString());
              }
              if (metadata.pageCount != null) {
                _textElement(
                    builder, 'PageCount', metadata.pageCount.toString());
              }
              _textElement(builder, 'Synopsis', metadata.synopsis);
            });
          } else if (item != null) {
            builder.element('Catalog', nest: () {
              final payload = item.payload;
              final pubMap = payload['publishing'] as Map?;
              final seriesMap = payload['series'] as Map?;
              _textElement(builder, 'Kind', item.kind);
              _textElement(builder, 'Title', item.title);
              _textElement(
                  builder,
                  'ItemNumber',
                  (payload['item_number'] ?? pubMap?['issue_number'])
                      as String?);
              _textElement(
                  builder,
                  'EditionTitle',
                  (payload['edition_title'] ?? pubMap?['edition_title'])
                      as String?);
              _textElement(
                  builder,
                  'PhysicalFormat',
                  (payload['physical_format'] ?? pubMap?['physical_format'])
                      as String?);
              _textElement(
                  builder,
                  'Publisher',
                  (payload['publisher'] ?? pubMap?['original_publisher'])
                      as String?);
              _textElement(builder, 'Barcode',
                  (payload['barcode'] ?? pubMap?['barcode']) as String?);
              _textElement(builder, 'Variant',
                  (payload['variant'] ?? pubMap?['variant']) as String?);
              _textElement(builder, 'SeriesTitle',
                  seriesMap?['series_title'] as String?);
              _textElement(
                  builder, 'VolumeName', seriesMap?['volume_name'] as String?);
              final releaseDate = _parseDate(payload['release_date']);
              if (releaseDate != null) {
                _textElement(builder, 'ReleaseDate',
                    releaseDate.toIso8601String().split('T').first);
              }
              final releaseYear = payload['release_year'];
              if (releaseYear != null) {
                _textElement(builder, 'ReleaseYear', releaseYear.toString());
              }
              if (pubMap?['page_count'] != null) {
                _textElement(
                    builder, 'PageCount', pubMap!['page_count'].toString());
              }
              _textElement(builder, 'Synopsis', item.synopsis);
              _textElement(builder, 'CoverImageUrl', item.coverImageUrl);
            });
          }

          if (owned != null) {
            builder.element('Collection', nest: () {
              _textElement(builder, 'OwnedId', owned.id);
              _textElement(builder, 'Condition', owned.condition);
              _textElement(builder, 'Grade', owned.grade);
              if (owned.purchaseDate != null) {
                _textElement(builder, 'PurchaseDate',
                    owned.purchaseDate!.toIso8601String().split('T').first);
              }
              if (owned.pricePaidCents != null) {
                _textElement(
                    builder, 'PricePaidCents', owned.pricePaidCents.toString());
              }
              _textElement(builder, 'Currency', owned.currency);
              _textElement(builder, 'PersonalNotes', owned.personalNotes);
              _textElement(builder, 'Quantity', owned.quantity.toString());
              _textElement(builder, 'LocationId', owned.locationId);
              if (owned.indexNumber != null) {
                _textElement(
                    builder, 'IndexNumber', owned.indexNumber.toString());
              }
              final details = owned.details;
              final comic = details is ComicOwnedDetails ? details : null;
              _textElement(builder, 'RawOrSlabbed', comic?.rawOrSlabbed);
              _textElement(builder, 'GradingCompany', comic?.gradingCompany);
              _textElement(builder, 'GraderNotes', comic?.graderNotes);
              _textElement(builder, 'SignedBy', comic?.signedBy);
              if (comic?.keyComic == true) {
                _textElement(builder, 'KeyComic', 'true');
              }
              _textElement(builder, 'KeyReason', comic?.keyReason);
              if (owned.rating != null) {
                _textElement(builder, 'Rating', owned.rating.toString());
              }
              _textElement(builder, 'ReadStatus', owned.readStatus);
              if (owned.startedAt != null) {
                _textElement(builder, 'StartedAt',
                    owned.startedAt!.toIso8601String().split('T').first);
              }
              if (owned.finishedAt != null) {
                _textElement(builder, 'FinishedAt',
                    owned.finishedAt!.toIso8601String().split('T').first);
              }
              _textElement(builder, 'Tags', owned.tags);
              if (owned.soldAt != null) {
                _textElement(builder, 'SoldAt',
                    owned.soldAt!.toIso8601String().split('T').first);
              }
              if (owned.sellPriceCents != null) {
                _textElement(
                    builder, 'SellPriceCents', owned.sellPriceCents.toString());
              }
              _textElement(builder, 'SoldTo', owned.soldTo);
            });
          }

          // Custom fields
          final cfValues = customFieldValuesByItem[owned?.id];
          if (cfValues != null && cfValues.isNotEmpty) {
            builder.element('CustomFields', nest: () {
              for (final cfv in cfValues) {
                final def = customFieldDefinitions
                    .where((d) => d.id == cfv.fieldDefinitionId)
                    .firstOrNull;
                if (def == null || cfv.value == null) continue;
                builder.element('Field', nest: () {
                  builder.attribute('name', def.name);
                  builder.attribute('type', def.fieldType);
                  builder.text(cfv.value!);
                });
              }
            });
          }
        });
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _textElement(XmlBuilder builder, String name, String? value) {
    if (value == null || value.isEmpty) return;
    builder.element(name, nest: value);
  }
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) {
    return value;
  }
  final raw = value?.toString().trim();
  return raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);
}
