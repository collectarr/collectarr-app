import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';

final class MovieOwnedItemUpdatePayload implements OwnedItemUpdatePayload {
  const MovieOwnedItemUpdatePayload({
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

  factory MovieOwnedItemUpdatePayload.fromCommand(
    UpdateOwnedItemCommand<OwnedDetailsDraft> command,
  ) =>
      MovieOwnedItemUpdatePayload(
        anchor: command.anchor,
        quantity: command.quantity,
        condition: command.condition,
        grade: command.grade,
        purchaseDate: command.purchaseDate,
        pricePaidCents: command.pricePaidCents,
        currency: command.currency,
        personalNotes: command.personalNotes,
        locationId: command.locationId,
        purchaseStore: command.purchaseStore,
        collectionStatus: command.collectionStatus,
        isDigital: command.isDigital,
        tags: command.tags,
        soldAt: command.soldAt,
        sellPriceCents: command.sellPriceCents,
        soldTo: command.soldTo,
        marketValueCents: command.marketValueCents,
        indexNumber: command.indexNumber,
        details: command.details.when(
          unchanged: () => const Patch.unchanged(),
          set: (value) => Patch.set(value as MovieOwnedDetailsDraft),
          clear: () => const Patch.clear(),
        ),
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
  final Patch<MovieOwnedDetailsDraft> details;

  @override
  bool canApplyTo(OwnedItem existing) => existing.details is MovieOwnedDetails;

  @override
  OwnedItem applyTo(
    OwnedItem existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    final existingDetails = existing.details as MovieOwnedDetails;
    final codec = const MovieOwnedDetailsCodec();
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
    );
  }
}
