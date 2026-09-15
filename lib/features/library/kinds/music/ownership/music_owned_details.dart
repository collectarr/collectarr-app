import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_disc_storage.dart';

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
      mediumIndex: _int(json['medium_index']) ?? 1,
      side: _text(json['side']) ?? '',
      runoutText: _text(json['runout_text']) ?? '',
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
class MusicOwnedDetails implements JsonEncodable {
  const MusicOwnedDetails({
    this.storageDevice,
    this.storageSlot,
    this.signedBy,
    this.lastCleanedDate,
    this.matrixRunouts = const [],
    this.discStorage = const [],
  });

  final String? storageDevice;
  final String? storageSlot;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final List<MusicMatrixRunout> matrixRunouts;
  final List<MusicDiscStorage> discStorage;

  @override
  Map<String, dynamic> toJson() => {
        if (storageDevice != null) 'storage_device': storageDevice,
        if (storageSlot != null) 'storage_slot': storageSlot,
        if (signedBy != null) 'signed_by': signedBy,
        if (lastCleanedDate != null)
          'last_cleaned_date': lastCleanedDate!.toUtc().toIso8601String(),
        if (matrixRunouts.isNotEmpty)
          'matrix_runouts': matrixRunouts.map((e) => e.toJson()).toList(),
        if (discStorage.isNotEmpty)
          'disc_storage': discStorage
              .where((entry) => !entry.isEmpty)
              .map((entry) => entry.toJson())
              .toList(),
      };

  factory MusicOwnedDetails.fromJson(Map<String, dynamic> json) {
    final lastCleanedDate = json['last_cleaned_date'];
    return MusicOwnedDetails(
      storageDevice: _text(json['storage_device']),
      storageSlot: _text(json['storage_slot']),
      signedBy: json['signed_by'] as String?,
      lastCleanedDate: lastCleanedDate is String
          ? DateTime.tryParse(lastCleanedDate)?.toUtc()
          : null,
      matrixRunouts: (json['matrix_runouts'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) =>
                  MusicMatrixRunout.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      discStorage: (json['disc_storage'] as List<dynamic>?)
              ?.whereType<Map<Object?, Object?>>()
              .map((e) =>
                  MusicDiscStorage.fromJson(Map<String, dynamic>.from(e)))
              .where((entry) => !entry.isEmpty)
              .toList() ??
          const [],
    );
  }

  MusicOwnedDetails copyWith({
    Object? storageDevice = _musicDetailsUnset,
    Object? storageSlot = _musicDetailsUnset,
    Object? signedBy = _musicDetailsUnset,
    Object? lastCleanedDate = _musicDetailsUnset,
    List<MusicMatrixRunout>? matrixRunouts,
    List<MusicDiscStorage>? discStorage,
  }) {
    return MusicOwnedDetails(
      storageDevice: identical(storageDevice, _musicDetailsUnset)
          ? this.storageDevice
          : storageDevice as String?,
      storageSlot: identical(storageSlot, _musicDetailsUnset)
          ? this.storageSlot
          : storageSlot as String?,
      signedBy: identical(signedBy, _musicDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      lastCleanedDate: identical(lastCleanedDate, _musicDetailsUnset)
          ? this.lastCleanedDate
          : lastCleanedDate as DateTime?,
      matrixRunouts: matrixRunouts ?? this.matrixRunouts,
      discStorage: discStorage ?? this.discStorage,
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
          listEquals(matrixRunouts, other.matrixRunouts) &&
          listEquals(discStorage, other.discStorage);

  @override
  int get hashCode => Object.hash(
        storageDevice,
        storageSlot,
        signedBy,
        lastCleanedDate,
        Object.hashAll(matrixRunouts),
        Object.hashAll(discStorage),
      );

  MusicDiscStorage? storageForMedium(int mediumIndex) {
    for (final entry in discStorage) {
      if (entry.mediumIndex == mediumIndex) return entry;
    }
    return null;
  }

  List<MusicMatrixRunout> matrixRunoutsForMedium(int mediumIndex) => [
        for (final runout in matrixRunouts)
          if (runout.mediumIndex == mediumIndex) runout,
      ];
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
