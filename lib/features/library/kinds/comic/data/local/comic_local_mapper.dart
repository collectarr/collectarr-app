import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:drift/drift.dart';

final class ComicLocalMapper {
  const ComicLocalMapper._();

  static ComicOwnedItemsRowsCompanion toOwnedItemRow(ComicOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.comic) {
      throw StateError('Cannot persist an invalid ComicOwnedItem');
    }

    final details = item.details;
    return ComicOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      targetRefJson: Value(_encodeTargetRef(item.targetRef)),
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
      rawOrSlabbed: Value(details.rawOrSlabbed),
      gradingCompany: Value(details.gradingCompany),
      graderNotes: Value(details.graderNotes),
      labelType: Value(details.labelType),
      customLabel: Value(details.customLabel),
      pageQuality: Value(details.pageQuality),
      certificationNumber: Value(details.certificationNumber),
      signedBy: Value(details.signedBy),
      keyComic: Value(details.keyComic),
      keyReason: Value(details.keyReason),
      keyCategory: Value(details.keyCategory),
      keySeverity: Value(details.keySeverity),
      coverPriceCents: Value(details.coverPriceCents),
      lastBagBoardDate: Value(details.lastBagBoardDate),
    );
  }

  static ComicOwnedItem fromOwnedItemRow(
    ComicOwnedItemsRow row, {
    ComicReadingState reading = const ComicReadingState(),
  }) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: const CatalogEntityTypeId('work'),
      id: row.itemId,
    );
    return ComicOwnedItem(
      id: ComicOwnedCopyId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      targetRef: _decodeTargetRef(row.targetRefJson),
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
      details: ComicOwnedDetails(
        rawOrSlabbed: row.rawOrSlabbed,
        gradingCompany: row.gradingCompany,
        graderNotes: row.graderNotes,
        labelType: row.labelType,
        customLabel: row.customLabel,
        pageQuality: row.pageQuality,
        certificationNumber: row.certificationNumber,
        signedBy: row.signedBy,
        keyComic: row.keyComic,
        keyReason: row.keyReason,
        keyCategory: row.keyCategory,
        keySeverity: row.keySeverity,
        coverPriceCents: row.coverPriceCents,
        lastBagBoardDate: row.lastBagBoardDate,
      ),
      reading: reading,
    );
  }

  static ComicReadingRowsCompanion toReadingRow(ComicOwnedItem item) {
    return ComicReadingRowsCompanion.insert(
      ownedRefKey: OwnedCopyRef(
        kind: CatalogMediaKind.comic,
        itemId: item.catalogRef.rootScope.id,
        id: OwnedCopyId(item.id.value),
      ).key,
      rating: Value(item.reading.rating),
      status: Value(item.reading.status),
      startedAt: Value(item.reading.startedAt),
      finishedAt: Value(item.reading.finishedAt),
    );
  }

  static ComicReadingState fromReadingRow(ComicReadingRow row) {
    return ComicReadingState(
      rating: row.rating,
      status: row.status,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
    );
  }

  static String? _encodeTargetRef(CatalogEntityRef? targetRef) =>
      targetRef == null ? null : jsonEncode(targetRef.toJson());

  static CatalogEntityRef? _decodeTargetRef(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return null;
    return CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded));
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

}
