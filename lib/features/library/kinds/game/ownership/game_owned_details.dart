import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const Object _gameDetailsUnset = Object();

@immutable
class GameOwnedDetails implements JsonEncodable {
  const GameOwnedDetails({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.coreRegion,
    this.valueIsLocked,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final String? coreRegion;
  final bool? valueIsLocked;

  @override
  Map<String, dynamic> toJson() => {
        if (completeness != null) 'game_completeness': completeness,
        if (hasBox != null) 'game_has_box': hasBox,
        if (hasManual != null) 'game_has_manual': hasManual,
        if (priceChartingId != null) 'game_pricecharting_id': priceChartingId,
        if (coreRegion != null) 'game_core_region': coreRegion,
        if (valueIsLocked != null) 'game_value_is_locked': valueIsLocked,
      };

  factory GameOwnedDetails.fromJson(Map<String, dynamic> json) {
    return GameOwnedDetails(
      completeness: json['game_completeness'] as String?,
      hasBox: json['game_has_box'] as bool?,
      hasManual: json['game_has_manual'] as bool?,
      priceChartingId: json['game_pricecharting_id'] as String?,
      coreRegion: json['game_core_region'] as String?,
      valueIsLocked: json['game_value_is_locked'] as bool?,
    );
  }

  GameOwnedDetails copyWith({
    Object? completeness = _gameDetailsUnset,
    Object? hasBox = _gameDetailsUnset,
    Object? hasManual = _gameDetailsUnset,
    Object? priceChartingId = _gameDetailsUnset,
    Object? coreRegion = _gameDetailsUnset,
    Object? valueIsLocked = _gameDetailsUnset,
  }) {
    return GameOwnedDetails(
      completeness: identical(completeness, _gameDetailsUnset)
          ? this.completeness
          : completeness as String?,
      hasBox:
          identical(hasBox, _gameDetailsUnset) ? this.hasBox : hasBox as bool?,
      hasManual: identical(hasManual, _gameDetailsUnset)
          ? this.hasManual
          : hasManual as bool?,
      priceChartingId: identical(priceChartingId, _gameDetailsUnset)
          ? this.priceChartingId
          : priceChartingId as String?,
      coreRegion: identical(coreRegion, _gameDetailsUnset)
          ? this.coreRegion
          : coreRegion as String?,
      valueIsLocked: identical(valueIsLocked, _gameDetailsUnset)
          ? this.valueIsLocked
          : valueIsLocked as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameOwnedDetails &&
          runtimeType == other.runtimeType &&
          completeness == other.completeness &&
          hasBox == other.hasBox &&
          hasManual == other.hasManual &&
          priceChartingId == other.priceChartingId &&
          coreRegion == other.coreRegion &&
          valueIsLocked == other.valueIsLocked;

  @override
  int get hashCode => Object.hash(
        completeness,
        hasBox,
        hasManual,
        priceChartingId,
        coreRegion,
        valueIsLocked,
      );
}
