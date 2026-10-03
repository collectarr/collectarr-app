import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';

final class MusicLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const MusicLibraryEntryCreatePayload({
    required this.details,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.locationId,
    this.purchaseStore,
    this.ownerLabel,
    this.collectionStatus,
    this.isDigital,
    this.tags,
    this.indexNumber,
    this.marketValueCents,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
  });

  factory MusicLibraryEntryCreatePayload.fromTypedItem(
    MusicLibraryEntry item,
  ) {
    return MusicLibraryEntryCreatePayload(
      details: MusicEntryDetailsCodec().draftFromDetails(item.details),
      condition: item.condition,
      grade: item.grade,
      purchaseDate: item.purchaseDate,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      personalNotes: item.personalNotes,
      locationId: item.locationId,
      purchaseStore: item.purchaseStore,
      ownerLabel: item.ownerLabel,
      collectionStatus: item.collectionStatus,
      isDigital: item.isDigital,
      tags: item.tags,
      indexNumber: item.indexNumber,
      marketValueCents: item.marketValueCents,
      soldAt: item.soldAt,
      sellPriceCents: item.sellPriceCents,
      soldTo: item.soldTo,
    );
  }

  final MusicEntryDetailsDraft details;

  @override
  MusicEntryDetailsDraft get detailsDraft => details;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final String? locationId;
  final String? purchaseStore;
  final String? ownerLabel;
  final String? collectionStatus;
  @override
  final bool? isDigital;
  final String? tags;
  final int? indexNumber;
  final int? marketValueCents;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;

  MusicLibraryEntry toLibraryEntry({
    required String id,
    required CatalogItemDto sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.mediaKind != CatalogMediaKind.music) {
      throw ArgumentError.value(
        sourceCatalogItem.mediaKind,
        'sourceCatalogItem',
        'Music entries require a Music catalog item.',
      );
    }
    final localCatalogItem = CatalogItemDto.raw(
      id: id,
      mediaKind: CatalogMediaKind.music,
      kindData: sourceCatalogItem.kindData,
      origin: CatalogItemOrigin.privateLocal,
    );
    final item = MusicLibraryEntry(
      id: LibraryEntryId(id),
      metadata: MusicCatalogMapper.mapMetadataItemToMusic(localCatalogItem),
      personal: MusicPersonalData(
        isDigital: isDigital ?? existingIsDigital,
        condition: condition,
        grade: grade,
        purchaseDate: purchaseDate,
        pricePaidCents: pricePaidCents,
        currency: currency,
        personalNotes: personalNotes,
        indexNumber: indexNumber,
        tags: tags,
        locationId: locationId,
        purchaseStore: purchaseStore,
        collectionStatus: collectionStatus,
        soldAt: soldAt,
        sellPriceCents: sellPriceCents,
        soldTo: soldTo,
        marketValueCents: marketValueCents,
        ownerUserId: ownerUserId,
        ownerLabel: this.ownerLabel ?? ownerLabel,
        details: details.toDetails(),
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    return item;
  }
}
