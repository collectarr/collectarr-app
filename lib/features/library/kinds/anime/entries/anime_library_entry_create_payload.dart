import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';

final class AnimeLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const AnimeLibraryEntryCreatePayload({
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
  });

  factory AnimeLibraryEntryCreatePayload.fromTypedItem(
    AnimeLibraryEntry item,
  ) {
    return AnimeLibraryEntryCreatePayload(
      details: AnimeEntryDetailsCodec().draftFromDetails(item.details),
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
    );
  }

  final AnimeEntryDetailsDraft details;

  @override
  AnimeEntryDetailsDraft get detailsDraft => details;
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

  AnimeLibraryEntry toLibraryEntry({
    required String id,
    required CatalogItemDto sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.mediaKind != CatalogMediaKind.anime) {
      throw ArgumentError.value(
        sourceCatalogItem.mediaKind,
        'sourceCatalogItem',
        'Anime entries require an Anime catalog item.',
      );
    }
    return AnimeLibraryEntry(
      id: LibraryEntryId(id),
      metadata: AnimeMetadata.fromJson(sourceCatalogItem.kindData),
      personal: AnimePersonalData(
        isDigital: isDigital ?? existingIsDigital,
        details: details.toDetails(),
        condition: condition,
        grade: grade,
        purchaseDate: purchaseDate,
        pricePaidCents: pricePaidCents,
        currency: currency,
        personalNotes: personalNotes,
        locationId: locationId,
        purchaseStore: purchaseStore,
        collectionStatus: collectionStatus,
        tags: tags,
        ownerUserId: ownerUserId,
        ownerLabel: this.ownerLabel ?? ownerLabel,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
