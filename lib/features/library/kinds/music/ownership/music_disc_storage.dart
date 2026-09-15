import 'package:flutter/foundation.dart';

/// Physical storage assigned to one Music medium in an owned copy.
///
/// This belongs to Music ownership, not to catalog metadata: two owned copies
/// of the same release can live in different devices and slots.
@immutable
final class MusicDiscStorage {
  const MusicDiscStorage({
    required this.mediumIndex,
    this.storageDevice,
    this.storageSlot,
  });

  final int mediumIndex;
  final String? storageDevice;
  final String? storageSlot;

  bool get isEmpty =>
      (storageDevice == null || storageDevice!.trim().isEmpty) &&
      (storageSlot == null || storageSlot!.trim().isEmpty);

  Map<String, dynamic> toJson() => {
        'medium_index': mediumIndex,
        if (storageDevice != null && storageDevice!.trim().isNotEmpty)
          'storage_device': storageDevice,
        if (storageSlot != null && storageSlot!.trim().isNotEmpty)
          'storage_slot': storageSlot,
      };

  factory MusicDiscStorage.fromJson(Map<String, dynamic> json) {
    return MusicDiscStorage(
      mediumIndex: _int(json['medium_index']) ?? 1,
      storageDevice: _text(json['storage_device']),
      storageSlot: _text(json['storage_slot']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicDiscStorage &&
          mediumIndex == other.mediumIndex &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot;

  @override
  int get hashCode => Object.hash(mediumIndex, storageDevice, storageSlot);
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
