import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

/// Mutable Copy-owned state for Music's dedicated copy editor.
final class MusicOwnedEditDraft {
  MusicOwnedEditDraft.fromItem(MusicOwnedItem item)
      : original = item,
        media = List<MusicOwnedMediumDetails>.of(item.details.media),
        condition = item.condition,
        grade = item.grade,
        purchaseDate = item.purchaseDate,
        pricePaidCents = item.pricePaidCents,
        currency = item.currency,
        personalNotes = item.personalNotes,
        quantity = item.quantity,
        indexNumber = item.indexNumber,
        tags = item.tags,
        soldAt = item.soldAt,
        sellPriceCents = item.sellPriceCents,
        soldTo = item.soldTo,
        ownerLabel = item.ownerLabel,
        locationId = item.locationId,
        purchaseStore = item.purchaseStore,
        collectionStatus = item.collectionStatus,
        marketValueCents = item.marketValueCents,
        isDigital = item.isDigital,
        signedBy = item.details.signedBy,
        lastCleanedDate = item.details.lastCleanedDate;

  final MusicOwnedItem original;
  List<MusicOwnedMediumDetails> media;
  String? condition;
  String? grade;
  DateTime? purchaseDate;
  int? pricePaidCents;
  String? currency;
  String? personalNotes;
  int quantity;
  int? indexNumber;
  String? tags;
  DateTime? soldAt;
  int? sellPriceCents;
  String? soldTo;
  String? ownerLabel;
  String? locationId;
  String? purchaseStore;
  String? collectionStatus;
  int? marketValueCents;
  bool? isDigital;
  String? signedBy;
  DateTime? lastCleanedDate;

  MusicOwnedDetailsDraft toDetailsDraft() => MusicOwnedDetailsDraft(
        media: List.unmodifiable(media),
        signedBy: _text(signedBy),
        lastCleanedDate: lastCleanedDate,
      );

  void updateMedium(MusicOwnedMediumDetails updated) {
    final index = media.indexWhere(
      (entry) => entry.mediumIndex == updated.mediumIndex,
    );
    if (index < 0) {
      media = [...media, updated];
    } else {
      media[index] = updated;
    }
  }
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
