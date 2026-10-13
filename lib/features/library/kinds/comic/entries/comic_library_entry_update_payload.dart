import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';

/// Comic-entry update values.
///
/// The common-looking personal fields intentionally live in this Comic
/// payload. This keeps Comic detail validation and persistence reconstruction
/// in the Comic vertical.
final class ComicLibraryEntryUpdatePayload
    implements LibraryEntryUpdatePayload {
  const ComicLibraryEntryUpdatePayload({
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

  factory ComicLibraryEntryUpdatePayload.partial({
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
    Patch<ComicEntryDetailsDraft> details = const Patch.unchanged(),
  }) =>
      ComicLibraryEntryUpdatePayload(
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
  final Patch<ComicEntryDetailsDraft> details;

  bool canApplyTo(ComicLibraryEntry existing) => true;

  ComicLibraryEntry applyTo(
    ComicLibraryEntry existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    final existingPersonal = existing.personal;
    final existingDetails = existingPersonal.details;
    final detailsCodec = const ComicEntryDetailsCodec();
    final resolvedDetails = details.when(
      unchanged: () => existingDetails,
      set: (draft) {
        final resolved = draft.toDetails();
        return resolved;
      },
      clear: () => detailsCodec.defaultDetails(),
    );

    return ComicLibraryEntry(
      id: existing.id,
      metadata: existing.metadata,
      createdAt: existing.createdAt ?? updatedAt,
      personal: existing.personal.copyWith(
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
        ownerLabel: existingPersonal.ownerLabel ?? fallbackOwnerLabel,
        indexNumber: indexNumber.when(
          unchanged: () => existingPersonal.indexNumber,
          set: (value) => value,
          clear: () => null,
        ),
        reading: existingPersonal.reading,
      ),
      updatedAt: updatedAt,
      deletedAt: existing.deletedAt,
    );
  }
}
