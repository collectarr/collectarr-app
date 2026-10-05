import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';

final class GameLibraryEntryCreatePayload implements LibraryEntryCreatePayload {
  const GameLibraryEntryCreatePayload({
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

  factory GameLibraryEntryCreatePayload.fromTypedItem(
    GameLibraryEntry item,
  ) {
    return GameLibraryEntryCreatePayload(
      details: GameEntryDetailsCodec().draftFromDetails(item.personal.details),
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

  final GameEntryDetailsDraft details;

  @override
  GameEntryDetailsDraft get detailsDraft => details;
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

  GameLibraryEntry toLibraryEntry({
    required String id,
    required CatalogItemDto sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.mediaKind != CatalogMediaKind.game) {
      throw ArgumentError.value(
        sourceCatalogItem.mediaKind,
        'sourceCatalogItem',
        'Game entries require a Game catalog item.',
      );
    }
    return GameLibraryEntry(
      id: LibraryEntryId(id),
      metadata: GameCatalogMetadata.fromJson(sourceCatalogItem.kindData),
      sourceCatalogRef: sourceCatalogItem.origin == CatalogItemOrigin.core
          ? sourceCatalogItem.catalogItemRef
          : null,
      personal: GamePersonalData(
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
