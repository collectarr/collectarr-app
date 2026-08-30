import 'package:flutter/foundation.dart';

@immutable
class StorageDetails {
  const StorageDetails({
    this.storageDevice,
    this.storageSlot,
  });

  final String? storageDevice;
  final String? storageSlot;

  Map<String, dynamic> toJson() => {
        if (storageDevice != null) 'storage_device': storageDevice,
        if (storageSlot != null) 'storage_slot': storageSlot,
      };

  factory StorageDetails.fromJson(Map<String, dynamic> json) {
    return StorageDetails(
      storageDevice: json['storage_device'] as String?,
      storageSlot: json['storage_slot'] as String?,
    );
  }

  StorageDetails copyWith({
    String? storageDevice,
    String? storageSlot,
  }) {
    return StorageDetails(
      storageDevice: storageDevice ?? this.storageDevice,
      storageSlot: storageSlot ?? this.storageSlot,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageDetails &&
          runtimeType == other.runtimeType &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot;

  @override
  int get hashCode => Object.hash(storageDevice, storageSlot);
}
