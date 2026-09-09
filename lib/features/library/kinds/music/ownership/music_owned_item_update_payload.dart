import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

final class MusicOwnedItemUpdatePayload
    implements OwnedItemUpdatePayload<MusicOwnedItem> {
  const MusicOwnedItemUpdatePayload({
    required this.targetRef,
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

  factory MusicOwnedItemUpdatePayload.partial({
    Patch<CatalogEntityRef?> targetRef = const Patch.unchanged(),
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
    Patch<MusicOwnedDetailsDraft> details = const Patch.unchanged(),
  }) =>
      MusicOwnedItemUpdatePayload(
        targetRef: targetRef,
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

  final Patch<CatalogEntityRef?> targetRef;
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
  final Patch<MusicOwnedDetailsDraft> details;

  @override
  bool canApplyTo(MusicOwnedItem existing) => true;

  @override
  MusicOwnedItem applyTo(
    MusicOwnedItem existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    final existingDetails = existing.details as MusicOwnedDetails;
    final codec = const MusicOwnedDetailsCodec();
    final resolvedDetails = details.when(
      unchanged: () => existingDetails,
      set: (draft) {
        final value = draft.toDetails();
        codec.validate(value);
        return value;
      },
      clear: () => codec.defaultDetails(),
    );
    return existing.copyWith(
      createdAt: existing.createdAt ?? updatedAt,
      isDigital: isDigital.when(
        unchanged: () => existing.isDigital,
        set: (value) => value,
        clear: () => null,
      ),
      targetRef: targetRef.when(
        unchanged: () => existing.targetRef,
        set: (value) => value?.copyWith(
          rootId: value.rootId ??
              existing.catalogRef.rootId ??
              existing.catalogRef.id,
        ),
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
    );
  }
}
