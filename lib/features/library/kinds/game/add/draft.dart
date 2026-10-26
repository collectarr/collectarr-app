import '../domain/game_packaging_selection.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:flutter/foundation.dart';
import '../domain/game_completeness_selection.dart';

const Object _gameAddDraftUnset = Object();

/// Personal state of one Game copy being added: the reference Value and
/// Personal tabs and the Index and Quantity footer.
@immutable
final class GameAddDraft extends LibraryAddKindDraft {
  const GameAddDraft({
    this.grade = 'Ungraded',
    this.details = const GameEntryDetails(),
    this.quantity = 1,
    this.indexNumber,
    this.rating,
    this.marketValueCents,
    this.purchaseDateParts,
  });

  final String? grade;
  final GameEntryDetails details;
  final int quantity;
  final int? indexNumber;
  final int? rating;
  final int? marketValueCents;
  final PartialDate? purchaseDateParts;

  GameAddDraft selectCompleteness(String? completeness) {
    final selection = GameCompletenessSelection(
        current: details,
        valueCents: marketValueCents,
        completeness: completeness);
    return copyWith(
        details: selection.details, marketValueCents: selection.valueCents);
  }

  GameAddDraft selectPackaging(
      {required bool hasBox,
      required bool hasManual,
      required String currency}) {
    final selection = GamePackagingSelection(
        current: details,
        valueCents: marketValueCents,
        currency: currency,
        hasBox: hasBox,
        hasManual: hasManual);
    return copyWith(
        details: selection.details, marketValueCents: selection.valueCents);
  }

  GameAddDraft copyWith({
    GameEntryDetails? details,
    int? quantity,
    Object? indexNumber = _gameAddDraftUnset,
    Object? rating = _gameAddDraftUnset,
    Object? marketValueCents = _gameAddDraftUnset,
    Object? purchaseDateParts = _gameAddDraftUnset,
  }) {
    T pick<T>(Object? value, T current) =>
        identical(value, _gameAddDraftUnset) ? current : value as T;
    return GameAddDraft(
      grade: grade,
      details: details ?? this.details,
      quantity: quantity ?? this.quantity,
      indexNumber: pick(indexNumber, this.indexNumber),
      rating: pick(rating, this.rating),
      marketValueCents: pick(marketValueCents, this.marketValueCents),
      purchaseDateParts: pick(purchaseDateParts, this.purchaseDateParts),
    );
  }

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  JsonEncodable toEntryDetailsDraft() => GameEntryDetailsDraft(details);
}
