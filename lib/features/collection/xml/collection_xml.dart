import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
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
          final catalog = entry.catalogItem;
          final owned = entry.ownedItem;

          _textElement(builder, 'ItemId', entry.itemId);
          _textElement(builder, 'Status',
              entry.isOwned ? 'owned' : entry.isWishlisted ? 'wishlist' : 'tracked');

          if (catalog != null) {
            builder.element('Catalog', nest: () {
              _textElement(builder, 'Kind', catalog.kind);
              _textElement(builder, 'Title', catalog.title);
              _textElement(builder, 'ItemNumber', catalog.itemNumber);
              _textElement(builder, 'EditionTitle', catalog.editionTitle);
              _textElement(builder, 'PhysicalFormat', catalog.physicalFormat);
              _textElement(builder, 'Publisher', catalog.publisher);
              _textElement(builder, 'Barcode', catalog.barcode);
              _textElement(builder, 'Variant', catalog.variant);
              _textElement(builder, 'SeriesTitle', catalog.series?.seriesTitle);
              _textElement(builder, 'VolumeName', catalog.series?.volumeName);
              if (catalog.releaseDate != null) {
                _textElement(builder, 'ReleaseDate',
                    catalog.releaseDate!.toIso8601String().split('T').first);
              }
              if (catalog.releaseYear != null) {
                _textElement(builder, 'ReleaseYear',
                    catalog.releaseYear.toString());
              }
              if (catalog.publishing?.pageCount != null) {
                _textElement(builder, 'PageCount',
                    catalog.publishing!.pageCount.toString());
              }
              _textElement(builder, 'Synopsis', catalog.synopsis);
              _textElement(builder, 'CoverImageUrl', catalog.coverImageUrl);
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
                _textElement(builder, 'PricePaidCents',
                    owned.pricePaidCents.toString());
              }
              _textElement(builder, 'Currency', owned.currency);
              _textElement(builder, 'PersonalNotes', owned.personalNotes);
              _textElement(builder, 'Quantity', owned.quantity.toString());
              _textElement(builder, 'StorageBox', owned.storageBox);
              if (owned.indexNumber != null) {
                _textElement(builder, 'IndexNumber',
                    owned.indexNumber.toString());
              }
              _textElement(builder, 'RawOrSlabbed', owned.rawOrSlabbed);
              _textElement(builder, 'GradingCompany', owned.gradingCompany);
              _textElement(builder, 'GraderNotes', owned.graderNotes);
              _textElement(builder, 'SignedBy', owned.signedBy);
              if (owned.keyComic) {
                _textElement(builder, 'KeyComic', 'true');
              }
              _textElement(builder, 'KeyReason', owned.keyReason);
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
                _textElement(builder, 'SellPriceCents',
                    owned.sellPriceCents.toString());
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
