import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';

final class MusicLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const MusicLibraryEntryCreatePayload({
    required this.details,
    this.initialListens = const [],
    this.quantity = 1,
    this.rating,
    this.mediaCondition,
    this.purchaseDateParts,
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
      details: MusicEntryDetailsCodec().draftFromDetails(item.personal.details),
      quantity: item.personal.quantity,
      rating: item.personal.rating,
      mediaCondition: item.personal.mediaCondition,
      purchaseDateParts: item.personal.purchaseDateParts,
      condition: item.personal.condition,
      grade: item.personal.grade,
      purchaseDate: item.personal.purchaseDate,
      pricePaidCents: item.personal.pricePaidCents,
      currency: item.personal.currency,
      personalNotes: item.personal.personalNotes,
      locationId: item.personal.locationId,
      purchaseStore: item.personal.purchaseStore,
      ownerLabel: item.personal.ownerLabel,
      collectionStatus: item.personal.collectionStatus,
      isDigital: item.personal.isDigital,
      tags: item.personal.tags,
      indexNumber: item.personal.indexNumber,
      marketValueCents: item.personal.marketValueCents,
      soldAt: item.personal.soldAt,
      sellPriceCents: item.personal.sellPriceCents,
      soldTo: item.personal.soldTo,
    );
  }

  final MusicEntryDetailsDraft details;
  final List<MusicListenEvent> initialListens;

  @override
  MusicEntryDetailsDraft get detailsDraft => details;
  final int quantity;
  final int? rating;
  final String? mediaCondition;
  final PartialDate? purchaseDateParts;
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
    required CatalogSearchCandidate sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.reference.kind != CatalogMediaKind.music) {
      throw ArgumentError.value(
        sourceCatalogItem.reference.kind,
        'sourceCatalogItem',
        'Music entries require a Music catalog item.',
      );
    }
    final sourceMetadata = sourceCatalogItem.kindCapability
        .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
    final localMetadata = Map<String, dynamic>.from(sourceMetadata.toJson())
      ..remove('id')
      ..remove('kind');
    final item = MusicLibraryEntry(
      id: LibraryEntryId(id),
      metadata: MusicAlbum.fromJson(localMetadata),
      sourceCatalogRef: !sourceCatalogItem.kindCapability.isPrivateLocal
          ? sourceCatalogItem.reference
          : null,
      personal: MusicPersonalData(
        isDigital: isDigital ?? existingIsDigital,
        quantity: quantity,
        rating: rating,
        mediaCondition: mediaCondition,
        purchaseDateParts: purchaseDateParts ??
            (purchaseDate == null
                ? null
                : PartialDate.fromDateTime(purchaseDate!)),
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
