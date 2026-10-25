import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';

const Object _gameDetailsUnset = Object();

@immutable
class GameEntryDetails implements JsonEncodable {
  /// Personal details for one local Game entry. The PriceCharting identifier
  /// and tiered amounts describe the user's valuation snapshot; they are not
  /// canonical Core metadata and travel with this personal entry.
  const GameEntryDetails({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.valuations,
    this.valueIsLocked,
    this.storageDevice,
    this.storageSlot,
    this.completed,
    this.completedDate,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final GameValuationSet? valuations;
  final bool? valueIsLocked;

  /// Console, drive or card the game is installed on, as in the reference.
  final String? storageDevice;
  final String? storageSlot;
  final bool? completed;
  final PartialDate? completedDate;

  @override
  Map<String, dynamic> toJson() => {
        if (completeness != null) 'game_completeness': completeness,
        if (hasBox != null) 'game_has_box': hasBox,
        if (hasManual != null) 'game_has_manual': hasManual,
        if (priceChartingId != null) 'game_pricecharting_id': priceChartingId,
        if (valuations != null) 'game_valuations': valuations!.toJson(),
        if (valueIsLocked != null) 'game_value_is_locked': valueIsLocked,
        if (storageDevice != null) 'game_storage_device': storageDevice,
        if (storageSlot != null) 'game_storage_slot': storageSlot,
        if (completed != null) 'game_completed': completed,
        if (completedDate != null)
          'game_completed_date_parts': completedDate!.toJson(),
      };

  factory GameEntryDetails.fromJson(Map<String, dynamic> json) {
    return GameEntryDetails(
      completeness: json['game_completeness'] as String?,
      hasBox: json['game_has_box'] as bool?,
      hasManual: json['game_has_manual'] as bool?,
      priceChartingId: json['game_pricecharting_id'] as String?,
      valuations: json['game_valuations'] is Map
          ? GameValuationSet.fromJson(
              Map<String, dynamic>.from(json['game_valuations'] as Map),
            )
          : null,
      valueIsLocked: json['game_value_is_locked'] as bool?,
      storageDevice: json['game_storage_device'] as String?,
      storageSlot: json['game_storage_slot'] as String?,
      completed: json['game_completed'] as bool?,
      completedDate: PartialDate.tryParse(json['game_completed_date_parts']),
    );
  }

  GameEntryDetails copyWith({
    Object? completeness = _gameDetailsUnset,
    Object? hasBox = _gameDetailsUnset,
    Object? hasManual = _gameDetailsUnset,
    Object? priceChartingId = _gameDetailsUnset,
    Object? valuations = _gameDetailsUnset,
    Object? valueIsLocked = _gameDetailsUnset,
    Object? storageDevice = _gameDetailsUnset,
    Object? storageSlot = _gameDetailsUnset,
    Object? completed = _gameDetailsUnset,
    Object? completedDate = _gameDetailsUnset,
  }) {
    T pick<T>(Object? value, T current) =>
        identical(value, _gameDetailsUnset) ? current : value as T;
    return GameEntryDetails(
      completeness: pick(completeness, this.completeness),
      hasBox: pick(hasBox, this.hasBox),
      hasManual: pick(hasManual, this.hasManual),
      priceChartingId: pick(priceChartingId, this.priceChartingId),
      valuations: pick(valuations, this.valuations),
      valueIsLocked: pick(valueIsLocked, this.valueIsLocked),
      storageDevice: pick(storageDevice, this.storageDevice),
      storageSlot: pick(storageSlot, this.storageSlot),
      completed: pick(completed, this.completed),
      completedDate: pick(completedDate, this.completedDate),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameEntryDetails &&
          runtimeType == other.runtimeType &&
          completeness == other.completeness &&
          hasBox == other.hasBox &&
          hasManual == other.hasManual &&
          priceChartingId == other.priceChartingId &&
          valuations == other.valuations &&
          valueIsLocked == other.valueIsLocked &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot &&
          completed == other.completed &&
          completedDate?.isoString == other.completedDate?.isoString;

  @override
  int get hashCode => Object.hash(
        completeness,
        hasBox,
        hasManual,
        priceChartingId,
        valuations,
        valueIsLocked,
        storageDevice,
        storageSlot,
        completed,
        completedDate?.isoString,
      );
}
