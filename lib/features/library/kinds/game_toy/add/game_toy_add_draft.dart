import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details_draft.dart';
import 'package:flutter/foundation.dart';

const Object _gameAddDraftUnset = Object();

/// Personal state of one GameToy copy being added: the reference Value and
/// Personal tabs and the Index and Quantity footer.
@immutable
final class GameToyAddDraft extends LibraryAddKindDraft {
  const GameToyAddDraft({
    this.grade = 'Ungraded',
    this.details = const GameToyEntryDetails(),
    this.quantity = 1,
    this.indexNumber,
    this.rating,
    this.marketValueCents,
    this.purchaseDateParts,
  });

  final String? grade;
  final GameToyEntryDetails details;
  final int quantity;
  final int? indexNumber;
  final int? rating;
  final int? marketValueCents;
  final PartialDate? purchaseDateParts;

  GameToyAddDraft copyWith({
    GameToyEntryDetails? details,
    int? quantity,
    Object? indexNumber = _gameAddDraftUnset,
    Object? rating = _gameAddDraftUnset,
    Object? marketValueCents = _gameAddDraftUnset,
    Object? purchaseDateParts = _gameAddDraftUnset,
  }) {
    T pick<T>(Object? value, T current) =>
        identical(value, _gameAddDraftUnset) ? current : value as T;
    return GameToyAddDraft(
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
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;

  @override
  JsonEncodable toEntryDetailsDraft() => GameToyEntryDetailsDraft(details);
}
