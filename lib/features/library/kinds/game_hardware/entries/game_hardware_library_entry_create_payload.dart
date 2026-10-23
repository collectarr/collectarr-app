import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details_draft.dart';

final class GameHardwareLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const GameHardwareLibraryEntryCreatePayload({
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

  factory GameHardwareLibraryEntryCreatePayload.fromTypedItem(
    GameHardwareLibraryEntry item,
  ) {
    return GameHardwareLibraryEntryCreatePayload(
      details: GameHardwareEntryDetailsCodec()
          .draftFromDetails(item.personal.details),
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

  final GameHardwareEntryDetailsDraft details;

  @override
  GameHardwareEntryDetailsDraft get detailsDraft => details;
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

  GameHardwareLibraryEntry toLibraryEntry({
    required String id,
    required CatalogSearchCandidate sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.reference.kind != CatalogMediaKind.gameHardware) {
      throw ArgumentError.value(
        sourceCatalogItem.reference.kind,
        'sourceCatalogItem',
        'GameHardware entries require a GameHardware catalog item.',
      );
    }
    return GameHardwareLibraryEntry(
      id: LibraryEntryId(id),
      metadata: sourceCatalogItem.kindCapability.mapTransport(
        (item) => GameHardwareCatalogMetadata.fromJson(item.kindData),
      ),
      sourceCatalogRef: !sourceCatalogItem.kindCapability.isPrivateLocal
          ? sourceCatalogItem.reference
          : null,
      personal: GameHardwarePersonalData(
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
