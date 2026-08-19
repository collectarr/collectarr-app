import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/storage_details.dart';

const Object _musicDetailsUnset = Object();

@immutable
class MusicOwnedDetails extends OwnedItemDetails {
  const MusicOwnedDetails({
    this.storage = const StorageDetails(),
    String? storageDevice,
    String? storageSlot,
  })  : _storageDevice = storageDevice,
        _storageSlot = storageSlot;

  final StorageDetails storage;
  final String? _storageDevice;
  final String? _storageSlot;

  String? get storageDevice => _storageDevice ?? storage.storageDevice;
  String? get storageSlot => _storageSlot ?? storage.storageSlot;

  @override
  Map<String, dynamic> toJson() => {
        if (storageDevice != null) 'storage_device': storageDevice,
        if (storageSlot != null) 'storage_slot': storageSlot,
      };

  factory MusicOwnedDetails.fromJson(Map<String, dynamic> json) {
    return MusicOwnedDetails(
      storage: StorageDetails.fromJson(json),
    );
  }

  MusicOwnedDetails copyWith({
    Object? storageDevice = _musicDetailsUnset,
    Object? storageSlot = _musicDetailsUnset,
    StorageDetails? storage,
  }) {
    return MusicOwnedDetails(
      storageDevice: identical(storageDevice, _musicDetailsUnset)
          ? this.storageDevice
          : storageDevice as String?,
      storageSlot: identical(storageSlot, _musicDetailsUnset)
          ? this.storageSlot
          : storageSlot as String?,
      storage: storage ?? this.storage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicOwnedDetails &&
          runtimeType == other.runtimeType &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot;

  @override
  int get hashCode => Object.hash(storageDevice, storageSlot);
}
