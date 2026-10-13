import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
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
      details: AnimeEntryDetailsCodec().draftFromDetails(item.personal.details),
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
    required CatalogSearchCandidate sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.reference.kind != CatalogMediaKind.anime) {
      throw ArgumentError.value(
        sourceCatalogItem.reference.kind,
        'sourceCatalogItem',
        'Anime entries require an Anime catalog item.',
      );
    }
    return AnimeLibraryEntry(
      id: LibraryEntryId(id),
      metadata: sourceCatalogItem.kindCapability.mapTransport(
        (item) => AnimeMetadata.fromJson(item.kindData),
      ),
      sourceCatalogRef: !sourceCatalogItem.kindCapability.isPrivateLocal
          ? sourceCatalogItem.reference
          : null,
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
