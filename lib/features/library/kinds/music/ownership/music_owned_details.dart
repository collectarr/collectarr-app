import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/storage_details.dart';

const Object _musicDetailsUnset = Object();

@immutable
class MusicMatrixRunout {
  const MusicMatrixRunout({
    this.mediumIndex = 1,
    required this.side,
    required this.runoutText,
  });

  final int mediumIndex;
  final String side;
  final String runoutText;

  Map<String, dynamic> toJson() => {
        'medium_index': mediumIndex,
        'side': side,
        'runout_text': runoutText,
      };

  factory MusicMatrixRunout.fromJson(Map<String, dynamic> json) {
    return MusicMatrixRunout(
      mediumIndex: json['medium_index'] as int? ?? 1,
      side: (json['side'] as String?) ?? '',
      runoutText: (json['runout_text'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicMatrixRunout &&
          runtimeType == other.runtimeType &&
          mediumIndex == other.mediumIndex &&
          side == other.side &&
          runoutText == other.runoutText;

  @override
  int get hashCode => Object.hash(mediumIndex, side, runoutText);
}

@immutable
class MusicOwnedDetails extends OwnedItemDetails {
  const MusicOwnedDetails({
    this.storage = const StorageDetails(),
    String? storageDevice,
    String? storageSlot,
    this.signedBy,
    this.lastCleanedDate,
    this.matrixRunouts = const [],
  })  : _storageDevice = storageDevice,
        _storageSlot = storageSlot;

  final StorageDetails storage;
  final String? _storageDevice;
  final String? _storageSlot;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final List<MusicMatrixRunout> matrixRunouts;

  String? get storageDevice => _storageDevice ?? storage.storageDevice;
  String? get storageSlot => _storageSlot ?? storage.storageSlot;

  @override
  Map<String, dynamic> toJson() => {
        if (storageDevice != null) 'storage_device': storageDevice,
        if (storageSlot != null) 'storage_slot': storageSlot,
        if (signedBy != null) 'signed_by': signedBy,
        if (lastCleanedDate != null)
          'last_cleaned_date': lastCleanedDate!.toIso8601String(),
        if (matrixRunouts.isNotEmpty)
          'matrix_runouts': matrixRunouts.map((e) => e.toJson()).toList(),
      };

  factory MusicOwnedDetails.fromJson(Map<String, dynamic> json) {
    return MusicOwnedDetails(
      storage: StorageDetails.fromJson(json),
      signedBy: json['signed_by'] as String?,
      lastCleanedDate: json['last_cleaned_date'] != null
          ? DateTime.tryParse(json['last_cleaned_date'] as String)
          : null,
      matrixRunouts: (json['matrix_runouts'] as List<dynamic>?)
              ?.map(
                  (e) => MusicMatrixRunout.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  MusicOwnedDetails copyWith({
    Object? storageDevice = _musicDetailsUnset,
    Object? storageSlot = _musicDetailsUnset,
    StorageDetails? storage,
    Object? signedBy = _musicDetailsUnset,
    Object? lastCleanedDate = _musicDetailsUnset,
    List<MusicMatrixRunout>? matrixRunouts,
  }) {
    return MusicOwnedDetails(
      storageDevice: identical(storageDevice, _musicDetailsUnset)
          ? this.storageDevice
          : storageDevice as String?,
      storageSlot: identical(storageSlot, _musicDetailsUnset)
          ? this.storageSlot
          : storageSlot as String?,
      storage: storage ?? this.storage,
      signedBy: identical(signedBy, _musicDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      lastCleanedDate: identical(lastCleanedDate, _musicDetailsUnset)
          ? this.lastCleanedDate
          : lastCleanedDate as DateTime?,
      matrixRunouts: matrixRunouts ?? this.matrixRunouts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicOwnedDetails &&
          runtimeType == other.runtimeType &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot &&
          signedBy == other.signedBy &&
          lastCleanedDate == other.lastCleanedDate &&
          listEquals(matrixRunouts, other.matrixRunouts);

  @override
  int get hashCode => Object.hash(
        storageDevice,
        storageSlot,
        signedBy,
        lastCleanedDate,
        Object.hashAll(matrixRunouts),
      );
}
