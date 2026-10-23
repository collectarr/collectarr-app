import '../domain/game_toy_completeness.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

const Object _unset = Object();

@immutable
final class GameToyEntryDetails implements JsonEncodable {
  const GameToyEntryDetails(
      {this.completeness = GameToyCompleteness.loose,
      this.hasBox,
      this.priceChartingId,
      this.valueIsLocked});
  final GameToyCompleteness completeness;
  final bool? hasBox;
  final String? priceChartingId;
  final bool? valueIsLocked;
  @override
  Map<String, dynamic> toJson() => {
        'game_toy_completeness': completeness.value,
        if (hasBox != null) 'game_toy_has_box': hasBox,
        if (priceChartingId != null)
          'game_toy_price_charting_id': priceChartingId,
        if (valueIsLocked != null) 'game_toy_value_is_locked': valueIsLocked,
      };
  factory GameToyEntryDetails.fromJson(Map<String, dynamic> json) =>
      GameToyEntryDetails(
        completeness:
            GameToyCompleteness.parse(json['game_toy_completeness']) ??
                GameToyCompleteness.loose,
        hasBox: json['game_toy_has_box'] as bool?,
        priceChartingId: json['game_toy_price_charting_id'] as String?,
        valueIsLocked: json['game_toy_value_is_locked'] as bool?,
      );
  GameToyEntryDetails copyWith(
          {Object? completeness = _unset,
          Object? hasBox = _unset,
          Object? priceChartingId = _unset,
          Object? valueIsLocked = _unset}) =>
      GameToyEntryDetails(
        completeness: identical(completeness, _unset)
            ? this.completeness
            : completeness as GameToyCompleteness,
        hasBox: identical(hasBox, _unset) ? this.hasBox : hasBox as bool?,
        priceChartingId: identical(priceChartingId, _unset)
            ? this.priceChartingId
            : priceChartingId as String?,
        valueIsLocked: identical(valueIsLocked, _unset)
            ? this.valueIsLocked
            : valueIsLocked as bool?,
      );
  @override
  bool operator ==(Object other) =>
      other is GameToyEntryDetails &&
      completeness == other.completeness &&
      hasBox == other.hasBox &&
      priceChartingId == other.priceChartingId &&
      valueIsLocked == other.valueIsLocked;
  @override
  int get hashCode =>
      Object.hash(completeness, hasBox, priceChartingId, valueIsLocked);
}
