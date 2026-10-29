import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import '../domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';

/// Comic-entry personal-copy values for the Add command.
///
/// Universal-looking fields are intentionally repeated in each kind payload;
/// they are part of the kind's complete Entry lifecycle and not a shared
/// domain aggregate.
final class ComicLibraryEntryCreatePayload
    implements LibraryEntryCreatePayload {
  const ComicLibraryEntryCreatePayload({
    required this.details,
    this.quantity = 1,
    this.indexNumber,
    this.reading = const ComicReadingState(),
    this.marketValueCents,
    this.soldAt,
    this.sellPriceCents,
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
  });

  factory ComicLibraryEntryCreatePayload.fromTypedItem(
    ComicLibraryEntry item,
  ) {
    return ComicLibraryEntryCreatePayload(
      details: ComicEntryDetailsCodec().draftFromDetails(item.personal.details),
      quantity: item.personal.quantity,
      indexNumber: item.personal.indexNumber,
      reading: item.personal.reading,
      marketValueCents: item.personal.marketValueCents,
      soldAt: item.personal.soldAt,
      sellPriceCents: item.personal.sellPriceCents,
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

  final ComicEntryDetailsDraft details;
  final int quantity;
  final int? indexNumber;
  final ComicReadingState reading;
  final int? marketValueCents;
  final DateTime? soldAt;
  final int? sellPriceCents;

  @override
  ComicEntryDetailsDraft get detailsDraft => details;
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

  ComicLibraryEntry toLibraryEntry({
    required String id,
    required CatalogSearchCandidate sourceCatalogItem,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    if (sourceCatalogItem.reference.kind != CatalogMediaKind.comic) {
      throw ArgumentError.value(
        sourceCatalogItem.reference.kind,
        'sourceCatalogItem',
        'Comic entries require a Comic catalog item.',
      );
    }
    return ComicLibraryEntry(
      id: LibraryEntryId(id),
      metadata: sourceCatalogItem.kindCapability.mapTransport(
        (item) => ComicCatalogItem.fromJson(item.kindData),
      ),
      sourceCatalogRef: !sourceCatalogItem.kindCapability.isPrivateLocal
          ? sourceCatalogItem.reference
          : null,
      createdAt: createdAt,
      personal: ComicPersonalData(
        quantity: quantity,
        indexNumber: indexNumber,
        reading: reading,
        marketValueCents: marketValueCents,
        soldAt: soldAt,
        sellPriceCents: sellPriceCents,
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
      updatedAt: createdAt,
    );
  }
}
