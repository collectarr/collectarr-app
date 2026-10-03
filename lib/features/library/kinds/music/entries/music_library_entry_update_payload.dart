import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';

final class MusicLibraryEntryUpdatePayload
    implements LibraryEntryUpdatePayload {
  const MusicLibraryEntryUpdatePayload({
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
    this.ownerLabel = const Patch.unchanged(),
  });

  factory MusicLibraryEntryUpdatePayload.partial({
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
    Patch<MusicEntryDetailsDraft> details = const Patch.unchanged(),
    Patch<String?> ownerLabel = const Patch.unchanged(),
  }) =>
      MusicLibraryEntryUpdatePayload(
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
        ownerLabel: ownerLabel,
      );
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
  final Patch<MusicEntryDetailsDraft> details;
  final Patch<String?> ownerLabel;

  MusicLibraryEntry applyTo(
    MusicLibraryEntry existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    final existingPersonal = existing.personal;
    final codec = const MusicEntryDetailsCodec();
    final resolvedDetails = details.when(
      unchanged: () => existingPersonal.details,
      set: (draft) {
        final value = draft.toDetails();
        return value;
      },
      clear: () => codec.defaultDetails(),
    );
    final updatedPersonal = existingPersonal.copyWith(
      isDigital: isDigital.when(
        unchanged: () => existingPersonal.isDigital,
        set: (value) => value,
        clear: () => null,
      ),
      details: resolvedDetails,
      condition: condition.when(
        unchanged: () => existingPersonal.condition,
        set: (value) => value,
        clear: () => null,
      ),
      grade: grade.when(
        unchanged: () => existingPersonal.grade,
        set: (value) => value,
        clear: () => null,
      ),
      purchaseDate: purchaseDate.when(
        unchanged: () => existingPersonal.purchaseDate,
        set: (value) => value,
        clear: () => null,
      ),
      pricePaidCents: pricePaidCents.when(
        unchanged: () => existingPersonal.pricePaidCents,
        set: (value) => value,
        clear: () => null,
      ),
      currency: currency.when(
        unchanged: () => existingPersonal.currency,
        set: (value) => value,
        clear: () => null,
      ),
      personalNotes: personalNotes.when(
        unchanged: () => existingPersonal.personalNotes,
        set: (value) => value,
        clear: () => null,
      ),
      locationId: locationId.when(
        unchanged: () => existingPersonal.locationId,
        set: (value) => value,
        clear: () => null,
      ),
      purchaseStore: purchaseStore.when(
        unchanged: () => existingPersonal.purchaseStore,
        set: (value) => value,
        clear: () => null,
      ),
      collectionStatus: collectionStatus.when(
        unchanged: () => existingPersonal.collectionStatus,
        set: (value) => value,
        clear: () => null,
      ),
      tags: tags.when(
        unchanged: () => existingPersonal.tags,
        set: (value) => value,
        clear: () => null,
      ),
      soldAt: soldAt.when(
        unchanged: () => existingPersonal.soldAt,
        set: (value) => value,
        clear: () => null,
      ),
      sellPriceCents: sellPriceCents.when(
        unchanged: () => existingPersonal.sellPriceCents,
        set: (value) => value,
        clear: () => null,
      ),
      soldTo: soldTo.when(
        unchanged: () => existingPersonal.soldTo,
        set: (value) => value,
        clear: () => null,
      ),
      marketValueCents: marketValueCents.when(
        unchanged: () => existingPersonal.marketValueCents,
        set: (value) => value,
        clear: () => null,
      ),
      ownerUserId: existingPersonal.ownerUserId ?? fallbackOwnerUserId,
      ownerLabel: ownerLabel.when(
        unchanged: () => existingPersonal.ownerLabel ?? fallbackOwnerLabel,
        set: (value) => value,
        clear: () => null,
      ),
      indexNumber: indexNumber.when(
        unchanged: () => existingPersonal.indexNumber,
        set: (value) => value,
        clear: () => null,
      ),
    );
    final updated = existing.copyWith(
      createdAt: existing.createdAt ?? updatedAt,
      personal: updatedPersonal,
      updatedAt: updatedAt,
    );
    return updated;
  }
}
