import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details_draft.dart';

final class GameToyLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const GameToyLibraryEntryCreatePayload({
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
    this.tags = const [],
    this.quantity = 1,
    this.indexNumber,
    this.rating,
    this.marketValueCents,
    this.purchaseDateParts,
  });

  factory GameToyLibraryEntryCreatePayload.fromTypedItem(
    GameToyLibraryEntry item,
  ) {
    return GameToyLibraryEntryCreatePayload(
      details:
          GameToyEntryDetailsCodec().draftFromDetails(item.personal.details),
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
      quantity: item.personal.quantity,
      indexNumber: item.personal.indexNumber,
      rating: item.personal.rating,
      marketValueCents: item.personal.marketValueCents,
      purchaseDateParts: item.personal.purchaseDateParts,
    );
  }

  final GameToyEntryDetailsDraft details;

  @override
  GameToyEntryDetailsDraft get detailsDraft => details;
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
  final List<String> tags;
  final int quantity;
  final int? indexNumber;
  final int? rating;
  final int? marketValueCents;
  final PartialDate? purchaseDateParts;

  GameToyLibraryEntry toLibraryEntry({
    required String id,
    required CatalogSearchCandidate sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.reference.kind != CatalogMediaKind.gameToy) {
      throw ArgumentError.value(
        sourceCatalogItem.reference.kind,
        'sourceCatalogItem',
        'GameToy entries require a GameToy catalog item.',
      );
    }
    return GameToyLibraryEntry(
      id: LibraryEntryId(id),
      metadata: sourceCatalogItem.kindCapability.mapTransport(
        (item) => GameToyCatalogMetadata.fromJson(item.kindData),
      ),
      sourceCatalogRef: !sourceCatalogItem.kindCapability.isPrivateLocal
          ? sourceCatalogItem.reference
          : null,
      personal: GameToyPersonalData(
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
        quantity: quantity,
        indexNumber: indexNumber,
        rating: rating,
        marketValueCents: marketValueCents,
        purchaseDateParts: purchaseDateParts,
        ownerUserId: ownerUserId,
        ownerLabel: this.ownerLabel ?? ownerLabel,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
