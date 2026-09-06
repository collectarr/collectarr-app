import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/drift.dart';

final class MangaLocalMapper {
  const MangaLocalMapper._();

  static MangaMediaRowsCompanion toMediaRow(MangaMedia media) {
    if (media.id.isEmpty) {
      throw StateError('Cannot persist MangaMedia without an id');
    }

    return MangaMediaRowsCompanion.insert(
      id: media.id,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      firstPublicationDate: Value(media.firstPublicationDate),
      originalLanguage: Value(media.originalLanguage),
      originalPublicationDate: Value(media.originalPublicationDate),
      status: Value(media.status),
      subtitle: Value(media.subtitle),
      chaptersJson: Value(_encodeList(media.chapters)),
      characterAppearancesJson: Value(_encodeList(media.characterAppearances)),
      contributionsJson: Value(_encodeList(media.contributions)),
      identifiersJson: Value(_encodeList(media.identifiers)),
      seriesJson: Value(_encodeList(media.series)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static MangaMedia fromMediaRow(MangaMediaRow row) {
    return MangaMedia(
      id: row.id,
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      firstPublicationDate: row.firstPublicationDate,
      originalLanguage: row.originalLanguage,
      originalPublicationDate: row.originalPublicationDate,
      status: row.status,
      subtitle: row.subtitle,
      chapters: _decodeList(row.chaptersJson),
      characterAppearances: _decodeList(row.characterAppearancesJson),
      contributions: _decodeList(row.contributionsJson),
      identifiers: _decodeList(row.identifiersJson),
      series: _decodeList(row.seriesJson),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MangaOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    MangaOwnedDetails details,
  ) {
    if (ownedItemId.isEmpty) {
      throw StateError('Cannot persist MangaOwnedDetails without an id');
    }

    return MangaOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      rawOrSlabbed: Value(details.grading.rawOrSlabbed),
      gradingCompany: Value(details.gradingCompany),
      graderNotes: Value(details.graderNotes),
      labelType: Value(details.grading.labelType),
      customLabel: Value(details.grading.customLabel),
      pageQuality: Value(details.grading.pageQuality),
      certificationNumber: Value(details.grading.certificationNumber),
      signedBy: Value(details.signedBy),
      obiStripPresent: Value(details.obiStripPresent),
      slipcoverPresent: Value(details.slipcoverPresent),
      dustJacketPresent: Value(details.dustJacketPresent),
      dustJacketCondition: Value(details.dustJacketCondition),
      boxSetOuterCondition: Value(details.boxSetOuterCondition),
      insertsPresent: Value(details.insertsPresent),
      printing: Value(details.printing),
      localizedEdition: Value(details.localizedEdition),
    );
  }

  static MangaOwnedDetails fromOwnedDetailsRow(
    MangaOwnedDetailsRow row,
  ) {
    return MangaOwnedDetails(
      grading: MangaGradingDetails(
        rawOrSlabbed: row.rawOrSlabbed,
        gradingCompany: row.gradingCompany,
        graderNotes: row.graderNotes,
        labelType: row.labelType,
        customLabel: row.customLabel,
        pageQuality: row.pageQuality,
        certificationNumber: row.certificationNumber,
      ),
      signature: MangaSignatureDetails(signedBy: row.signedBy),
      obiStripPresent: row.obiStripPresent,
      slipcoverPresent: row.slipcoverPresent,
      dustJacketPresent: row.dustJacketPresent,
      dustJacketCondition: row.dustJacketCondition,
      boxSetOuterCondition: row.boxSetOuterCondition,
      insertsPresent: row.insertsPresent,
      printing: row.printing,
      localizedEdition: row.localizedEdition,
    );
  }

  static MangaOwnedItemsRowsCompanion toOwnedItemRow(MangaOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.manga) {
      throw StateError('Cannot persist an invalid MangaOwnedItem');
    }

    final details = item.details;
    return MangaOwnedItemsRowsCompanion.insert(
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
      rawOrSlabbed: Value(details.grading.rawOrSlabbed),
      gradingCompany: Value(details.gradingCompany),
      graderNotes: Value(details.graderNotes),
      labelType: Value(details.grading.labelType),
      customLabel: Value(details.grading.customLabel),
      pageQuality: Value(details.grading.pageQuality),
      certificationNumber: Value(details.grading.certificationNumber),
      signedBy: Value(details.signedBy),
      obiStripPresent: Value(details.obiStripPresent),
      slipcoverPresent: Value(details.slipcoverPresent),
      dustJacketPresent: Value(details.dustJacketPresent),
      dustJacketCondition: Value(details.dustJacketCondition),
      boxSetOuterCondition: Value(details.boxSetOuterCondition),
      insertsPresent: Value(details.insertsPresent),
      printing: Value(details.printing),
      localizedEdition: Value(details.localizedEdition),
    );
  }

  static MangaOwnedItem fromOwnedItemRow(MangaOwnedItemsRow row) {
    return MangaOwnedItem(
      id: MangaOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'manga',
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
      details: MangaOwnedDetails(
        grading: MangaGradingDetails(
          rawOrSlabbed: row.rawOrSlabbed,
          gradingCompany: row.gradingCompany,
          graderNotes: row.graderNotes,
          labelType: row.labelType,
          customLabel: row.customLabel,
          pageQuality: row.pageQuality,
          certificationNumber: row.certificationNumber,
        ),
        signature: MangaSignatureDetails(signedBy: row.signedBy),
        obiStripPresent: row.obiStripPresent,
        slipcoverPresent: row.slipcoverPresent,
        dustJacketPresent: row.dustJacketPresent,
        dustJacketCondition: row.dustJacketCondition,
        boxSetOuterCondition: row.boxSetOuterCondition,
        insertsPresent: row.insertsPresent,
        printing: row.printing,
        localizedEdition: row.localizedEdition,
      ),
    );
  }

  static String _encodeList(List<dynamic> values) => jsonEncode(values);

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

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }
}
