import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/drift.dart';

final class MangaCollectionItemLocalMapper {
  const MangaCollectionItemLocalMapper._();

  static MangaCollectionItemsRowsCompanion toRow(MangaCollectionItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.manga) {
      throw StateError('Cannot persist an invalid MangaCollectionItem');
    }

    final details = item.details;
    return MangaCollectionItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
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

  static MangaCollectionItem fromRow(MangaCollectionItemsRow row) {
    return MangaCollectionItem(
      id: CollectionItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: CatalogMediaKind.manga,
        entityType: CatalogEntityTypeId.catalogItem,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
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

}
