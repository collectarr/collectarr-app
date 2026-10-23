import '../domain/game_hardware_completeness.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

const Object _unset = Object();

@immutable
final class GameHardwareEntryDetails implements JsonEncodable {
  const GameHardwareEntryDetails(
      {this.completeness,
      this.hasBox,
      this.priceChartingId,
      this.valueIsLocked,
      this.hasManual,
      this.serialNumber});
  final GameHardwareCompleteness? completeness;
  final bool? hasBox;
  final String? priceChartingId;
  final bool? valueIsLocked;
  final bool? hasManual;
  final String? serialNumber;
  @override
  Map<String, dynamic> toJson() => {
        if (completeness != null)
          'game_hardware_completeness': completeness?.value,
        if (hasBox != null) 'game_hardware_has_box': hasBox,
        if (priceChartingId != null)
          'game_hardware_price_charting_id': priceChartingId,
        if (valueIsLocked != null)
          'game_hardware_value_is_locked': valueIsLocked,
        if (hasManual != null) 'game_hardware_has_manual': hasManual,
        if (serialNumber != null) 'game_hardware_serial_number': serialNumber,
      };
  factory GameHardwareEntryDetails.fromJson(Map<String, dynamic> json) =>
      GameHardwareEntryDetails(
        completeness:
            GameHardwareCompleteness.parse(json['game_hardware_completeness']),
        hasBox: json['game_hardware_has_box'] as bool?,
        priceChartingId: json['game_hardware_price_charting_id'] as String?,
        valueIsLocked: json['game_hardware_value_is_locked'] as bool?,
        hasManual: json['game_hardware_has_manual'] as bool?,
        serialNumber: json['game_hardware_serial_number'] as String?,
      );
  GameHardwareEntryDetails copyWith(
          {Object? completeness = _unset,
          Object? hasBox = _unset,
          Object? priceChartingId = _unset,
          Object? valueIsLocked = _unset,
          Object? hasManual = _unset,
          Object? serialNumber = _unset}) =>
      GameHardwareEntryDetails(
        completeness: identical(completeness, _unset)
            ? this.completeness
            : completeness as GameHardwareCompleteness?,
        hasBox: identical(hasBox, _unset) ? this.hasBox : hasBox as bool?,
        priceChartingId: identical(priceChartingId, _unset)
            ? this.priceChartingId
            : priceChartingId as String?,
        valueIsLocked: identical(valueIsLocked, _unset)
            ? this.valueIsLocked
            : valueIsLocked as bool?,
        hasManual:
            identical(hasManual, _unset) ? this.hasManual : hasManual as bool?,
        serialNumber: identical(serialNumber, _unset)
            ? this.serialNumber
            : serialNumber as String?,
      );
  @override
  bool operator ==(Object other) =>
      other is GameHardwareEntryDetails &&
      completeness == other.completeness &&
      hasBox == other.hasBox &&
      priceChartingId == other.priceChartingId &&
      valueIsLocked == other.valueIsLocked &&
      hasManual == other.hasManual &&
      serialNumber == other.serialNumber;
  @override
  int get hashCode => Object.hash(completeness, hasBox, priceChartingId,
      valueIsLocked, hasManual, serialNumber);
}
