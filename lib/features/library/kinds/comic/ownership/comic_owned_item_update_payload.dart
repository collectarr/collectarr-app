import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';

/// Comic-owned update values.
///
/// The common-looking personal fields intentionally live in this Comic
/// payload. This keeps Comic detail validation and persistence reconstruction
/// in the Comic vertical.
final class ComicOwnedItemUpdatePayload
    implements OwnedItemUpdatePayload<ComicOwnedItem> {
  const ComicOwnedItemUpdatePayload({
    required this.anchor,
    required this.quantity,
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.locationId,
    required this.purchaseStore,
    required this.collectionStatus,
    required this.isDigital,
    required this.tags,
    required this.soldAt,
    required this.sellPriceCents,
    required this.soldTo,
    required this.marketValueCents,
    required this.indexNumber,
    required this.details,
  });

  factory ComicOwnedItemUpdatePayload.partial({
    Patch<PersonalItemAnchor?> anchor = const Patch.unchanged(),
    Patch<int> quantity = const Patch.unchanged(),
    Patch<String?> condition = const Patch.unchanged(),
    Patch<String?> grade = const Patch.unchanged(),
    Patch<DateTime?> purchaseDate = const Patch.unchanged(),
    Patch<int?> pricePaidCents = const Patch.unchanged(),
    Patch<String?> currency = const Patch.unchanged(),
    Patch<String?> personalNotes = const Patch.unchanged(),
    Patch<String?> locationId = const Patch.unchanged(),
    Patch<String?> purchaseStore = const Patch.unchanged(),
    Patch<String?> collectionStatus = const Patch.unchanged(),
    Patch<bool?> isDigital = const Patch.unchanged(),
    Patch<String?> tags = const Patch.unchanged(),
    Patch<DateTime?> soldAt = const Patch.unchanged(),
    Patch<int?> sellPriceCents = const Patch.unchanged(),
    Patch<String?> soldTo = const Patch.unchanged(),
    Patch<int?> marketValueCents = const Patch.unchanged(),
    Patch<int?> indexNumber = const Patch.unchanged(),
    Patch<ComicOwnedDetailsDraft> details = const Patch.unchanged(),
  }) =>
      ComicOwnedItemUpdatePayload(
        anchor: anchor,
        quantity: quantity,
        condition: condition,
        grade: grade,
        purchaseDate: purchaseDate,
        pricePaidCents: pricePaidCents,
        currency: currency,
        personalNotes: personalNotes,
        locationId: locationId,
        purchaseStore: purchaseStore,
        collectionStatus: collectionStatus,
        isDigital: isDigital,
        tags: tags,
        soldAt: soldAt,
        sellPriceCents: sellPriceCents,
        soldTo: soldTo,
        marketValueCents: marketValueCents,
        indexNumber: indexNumber,
        details: details,
      );

  final Patch<PersonalItemAnchor?> anchor;
  final Patch<int> quantity;
  final Patch<String?> condition;
  final Patch<String?> grade;
  final Patch<DateTime?> purchaseDate;
  final Patch<int?> pricePaidCents;
  final Patch<String?> currency;
  final Patch<String?> personalNotes;
  final Patch<String?> locationId;
  final Patch<String?> purchaseStore;
  final Patch<String?> collectionStatus;
  final Patch<bool?> isDigital;
  final Patch<String?> tags;
  final Patch<DateTime?> soldAt;
  final Patch<int?> sellPriceCents;
  final Patch<String?> soldTo;
  final Patch<int?> marketValueCents;
  final Patch<int?> indexNumber;
  final Patch<ComicOwnedDetailsDraft> details;

  @override
  bool canApplyTo(ComicOwnedItem existing) => true;

  @override
  ComicOwnedItem applyTo(
    ComicOwnedItem existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    final existingDetails = existing.details as ComicOwnedDetails;
    final detailsCodec = const ComicOwnedDetailsCodec();
    final resolvedDetails = details.when(
      unchanged: () => existingDetails,
      set: (draft) {
        final resolved = draft.toDetails();
        detailsCodec.validate(resolved);
        return resolved;
      },
      clear: () => detailsCodec.defaultDetails(),
    );

    return ComicOwnedItem(
      id: existing.id,
      catalogRef: existing.catalogRef,
      createdAt: existing.createdAt ?? updatedAt,
      isDigital: isDigital.when(
        unchanged: () => existing.isDigital,
        set: (value) => value,
        clear: () => null,
      ),
      anchor: anchor.when(
        unchanged: () => existing.anchor,
        set: (value) => value,
        clear: () => null,
      ),
      details: resolvedDetails,
      condition: condition.when(
        unchanged: () => existing.condition,
        set: (value) => value,
        clear: () => null,
      ),
      grade: grade.when(
        unchanged: () => existing.grade,
        set: (value) => value,
        clear: () => null,
      ),
      purchaseDate: purchaseDate.when(
        unchanged: () => existing.purchaseDate,
        set: (value) => value,
        clear: () => null,
      ),
      pricePaidCents: pricePaidCents.when(
        unchanged: () => existing.pricePaidCents,
        set: (value) => value,
        clear: () => null,
      ),
      currency: currency.when(
        unchanged: () => existing.currency,
        set: (value) => value,
        clear: () => null,
      ),
      personalNotes: personalNotes.when(
        unchanged: () => existing.personalNotes,
        set: (value) => value,
        clear: () => null,
      ),
      quantity: quantity.when(
        unchanged: () => existing.quantity,
        set: (value) => value,
        clear: () => 1,
      ),
      locationId: locationId.when(
        unchanged: () => existing.locationId,
        set: (value) => value,
        clear: () => null,
      ),
      purchaseStore: purchaseStore.when(
        unchanged: () => existing.purchaseStore,
        set: (value) => value,
        clear: () => null,
      ),
      collectionStatus: collectionStatus.when(
        unchanged: () => existing.collectionStatus,
        set: (value) => value,
        clear: () => null,
      ),
      tags: tags.when(
        unchanged: () => existing.tags,
        set: (value) => value,
        clear: () => null,
      ),
      soldAt: soldAt.when(
        unchanged: () => existing.soldAt,
        set: (value) => value,
        clear: () => null,
      ),
      sellPriceCents: sellPriceCents.when(
        unchanged: () => existing.sellPriceCents,
        set: (value) => value,
        clear: () => null,
      ),
      soldTo: soldTo.when(
        unchanged: () => existing.soldTo,
        set: (value) => value,
        clear: () => null,
      ),
      marketValueCents: marketValueCents.when(
        unchanged: () => existing.marketValueCents,
        set: (value) => value,
        clear: () => null,
      ),
      ownerUserId: existing.ownerUserId ?? fallbackOwnerUserId,
      ownerLabel: existing.ownerLabel ?? fallbackOwnerLabel,
      indexNumber: indexNumber.when(
        unchanged: () => existing.indexNumber,
        set: (value) => value,
        clear: () => null,
      ),
      updatedAt: updatedAt,
      deletedAt: existing.deletedAt,
      reading: existing.reading,
    );
  }
}
