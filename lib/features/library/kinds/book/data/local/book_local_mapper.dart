import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/drift.dart';

final class BookLocalMapper {
  const BookLocalMapper._();

  static BookMediaRowsCompanion toMediaRow(BookMedia media) {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot persist BookMedia without an id');
    }

    return BookMediaRowsCompanion.insert(
      id: media.id.value,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      firstPublicationDate: Value(media.firstPublicationDate),
      originalLanguage: Value(media.originalLanguage),
      originalPublicationDate: Value(media.originalPublicationDate),
      subtitle: Value(media.subtitle),
      searchAliasesJson: Value(_encodeList(media.searchAliases)),
      genresJson: Value(_encodeList(media.genres)),
      contributorsJson: Value(_encodeList(media.contributors)),
      seriesJson: Value(_encodeList(media.series)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static BookMedia fromMediaRow(
    BookMediaRow row, {
    List<BookRelease> editions = const <BookRelease>[],
  }) {
    return BookMedia(
      id: BookMediaId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      firstPublicationDate: row.firstPublicationDate,
      originalLanguage: row.originalLanguage,
      originalPublicationDate: row.originalPublicationDate,
      subtitle: row.subtitle,
      searchAliases: _decodeStringList(row.searchAliasesJson),
      genres: _decodeStringList(row.genresJson),
      contributors: _decodeList(row.contributorsJson),
      editions: editions,
      series: _decodeList(row.seriesJson),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static BookReleaseRowsCompanion toReleaseRow(
    BookMediaId mediaId,
    BookRelease release,
  ) {
    if (mediaId.value.isEmpty || release.id.isEmpty) {
      throw StateError('Cannot persist BookRelease without an id');
    }

    return BookReleaseRowsCompanion.insert(
      mediaId: mediaId.value,
      id: release.id,
      title: release.title,
      workId: Value(release.workId),
      titleValue: Value(release.titleValue),
      displayTitle: Value(release.displayTitle),
      ageRating: Value(release.ageRating),
      audioLengthMinutes: Value(release.audioLengthMinutes),
      binding: Value(release.binding),
      contributorsJson: Value(_encodeList(release.contributors)),
      coverImageKey: Value(release.coverImageKey),
      publisher: Value(release.publisher),
      distributor: Value(release.distributor),
      description: Value(release.description),
      editionStatement: Value(release.editionStatement),
      isbn: Value(release.isbn),
      identifiersJson: Value(_encodeList(release.identifiers)),
      imprint: Value(release.imprint),
      upc: Value(release.upc),
      pageCount: Value(release.pageCount),
      language: Value(release.language),
      region: Value(release.region),
      releaseDate: Value(release.releaseDate),
      releaseStatus: Value(release.releaseStatus),
      physicalFormat: Value(release.physicalFormat),
      physicalFormatLabel: Value(release.physicalFormatLabel),
      coverImageUrl: Value(release.coverImageUrl),
      thumbnailImageUrl: Value(release.thumbnailImageUrl),
      dimensions: Value(release.dimensions),
      firstEdition: Value(release.firstEdition),
      variantsJson: Value(_encodeVariants(release.variants)),
    );
  }

  static BookRelease fromReleaseRow(BookReleaseRow row) {
    return BookRelease(
      id: row.id,
      title: row.title,
      workId: row.workId,
      titleValue: row.titleValue,
      displayTitle: row.displayTitle,
      ageRating: row.ageRating,
      audioLengthMinutes: row.audioLengthMinutes,
      binding: row.binding,
      contributors: _decodeList(row.contributorsJson),
      coverImageKey: row.coverImageKey,
      publisher: row.publisher,
      distributor: row.distributor,
      description: row.description,
      editionStatement: row.editionStatement,
      isbn: row.isbn,
      identifiers: _decodeList(row.identifiersJson),
      imprint: row.imprint,
      upc: row.upc,
      pageCount: row.pageCount,
      language: row.language,
      region: row.region,
      releaseDate: row.releaseDate,
      releaseStatus: row.releaseStatus,
      physicalFormat: row.physicalFormat,
      physicalFormatLabel: row.physicalFormatLabel,
      coverImageUrl: row.coverImageUrl,
      thumbnailImageUrl: row.thumbnailImageUrl,
      dimensions: row.dimensions,
      firstEdition: row.firstEdition,
      variants: _decodeVariants(row.variantsJson),
    );
  }

  static BookOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    BookOwnedDetails details,
  ) {
    if (ownedItemId.isEmpty) {
      throw StateError('Cannot persist BookOwnedDetails without an id');
    }

    return BookOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      signedBy: Value(details.signedBy),
      dustJacketPresent: Value(details.dustJacketPresent),
      dustJacketCondition: Value(details.dustJacketCondition),
    );
  }

  static BookOwnedDetails fromOwnedDetailsRow(BookOwnedDetailsRow row) {
    return BookOwnedDetails(
      signedBy: row.signedBy,
      dustJacketPresent: row.dustJacketPresent,
      dustJacketCondition: row.dustJacketCondition,
    );
  }

  static BookOwnedItemsRowsCompanion toOwnedItemRow(BookOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.book) {
      throw StateError('Cannot persist an invalid BookOwnedItem');
    }

    final details = item.details;
    return BookOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      anchorType: Value(item.anchor?.apiValue),
      editionId: Value(item.anchor?.editionId),
      variantId: Value(item.anchor?.variantId),
      bundleReleaseId: Value(item.anchor?.bundleReleaseId),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
      signedBy: Value(details.signedBy),
      dustJacketPresent: Value(details.dustJacketPresent),
      dustJacketCondition: Value(details.dustJacketCondition),
    );
  }

  static BookOwnedItem fromOwnedItemRow(BookOwnedItemsRow row) {
    return BookOwnedItem(
      id: BookOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: row.anchorType,
        editionId: row.editionId,
        variantId: row.variantId,
        bundleReleaseId: row.bundleReleaseId,
      ),
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
      details: BookOwnedDetails(
        signedBy: row.signedBy,
        dustJacketPresent: row.dustJacketPresent,
        dustJacketCondition: row.dustJacketCondition,
      ),
    );
  }

  static String _encodeList(Iterable<dynamic> values) =>
      jsonEncode(values.toList(growable: false));

  static String _encodeVariants(Iterable<BookVariantRef> values) {
    return jsonEncode([
      for (final variant in values)
        {
          'id': variant.id,
          'name': variant.name,
          if (variant.variantType != null) 'variant_type': variant.variantType,
          if (variant.sku != null) 'sku': variant.sku,
          if (variant.barcode != null) 'barcode': variant.barcode,
          if (variant.isbn != null) 'isbn': variant.isbn,
          if (variant.region != null) 'region': variant.region,
          if (variant.coverImageUrl != null)
            'cover_image_url': variant.coverImageUrl,
          if (variant.thumbnailImageUrl != null)
            'thumbnail_image_url': variant.thumbnailImageUrl,
          if (variant.physicalFormat != null)
            'physical_format': variant.physicalFormat,
          if (variant.physicalFormatLabel != null)
            'physical_format_label': variant.physicalFormatLabel,
          if (variant.isPrimary) 'is_primary': true,
        },
    ]);
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<dynamic> _decodeList(String raw) {
    final decoded = _decodeJson(raw);
    return decoded is List ? List<dynamic>.from(decoded) : const <dynamic>[];
  }

  static List<String> _decodeStringList(String raw) {
    return _decodeList(raw).whereType<String>().toList(growable: false);
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  static List<BookVariantRef> _decodeVariants(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <BookVariantRef>[];
    return [
      for (final entry in decoded)
        if (entry is Map<Object?, Object?>)
          BookVariantRef(
            id: entry['id']?.toString() ?? '',
            name: entry['name']?.toString() ?? 'Variant',
            variantType: entry['variant_type']?.toString(),
            sku: entry['sku']?.toString(),
            barcode: entry['barcode']?.toString(),
            isbn: entry['isbn']?.toString(),
            region: entry['region']?.toString(),
            coverImageUrl: entry['cover_image_url']?.toString(),
            thumbnailImageUrl: entry['thumbnail_image_url']?.toString(),
            physicalFormat: entry['physical_format']?.toString(),
            physicalFormatLabel: entry['physical_format_label']?.toString(),
            isPrimary: entry['is_primary'] == true,
          ),
    ];
  }
}
