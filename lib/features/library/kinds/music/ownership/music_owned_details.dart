import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const Object _musicDetailsUnset = Object();

@immutable
final class MusicMatrixRunout {
  const MusicMatrixRunout({
    required this.side,
    required this.runoutText,
  });

  final String side;
  final String runoutText;

  Map<String, dynamic> toJson() => {
        'side': side,
        'runout_text': runoutText,
      };

  factory MusicMatrixRunout.fromJson(Map<String, dynamic> json) {
    return MusicMatrixRunout(
      side: _text(json['side']) ?? '',
      runoutText: _text(json['runout_text']) ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicMatrixRunout &&
          runtimeType == other.runtimeType &&
          side == other.side &&
          runoutText == other.runoutText;

  @override
  int get hashCode => Object.hash(side, runoutText);
}

/// Physical details for one medium in an owned Music copy.
///
/// Storage and matrix/runout data intentionally live under the same medium
/// record. There is no parallel-array alignment invariant to maintain.
@immutable
final class MusicOwnedMediumDetails implements JsonEncodable {
  const MusicOwnedMediumDetails({
    required this.mediumIndex,
    this.mediaCondition,
    this.storageDevice,
    this.storageSlot,
    this.matrixRunouts = const [],
  });

  final int mediumIndex;
  final String? mediaCondition;
  final String? storageDevice;
  final String? storageSlot;
  final List<MusicMatrixRunout> matrixRunouts;

  bool get isEmpty =>
      (mediaCondition == null || mediaCondition!.trim().isEmpty) &&
      (storageDevice == null || storageDevice!.trim().isEmpty) &&
      (storageSlot == null || storageSlot!.trim().isEmpty) &&
      matrixRunouts.isEmpty;

  @override
  Map<String, dynamic> toJson() => {
        'medium_index': mediumIndex,
        if (mediaCondition?.trim().isNotEmpty == true)
          'media_condition': mediaCondition,
        if (storageDevice?.trim().isNotEmpty == true)
          'storage_device': storageDevice,
        if (storageSlot?.trim().isNotEmpty == true) 'storage_slot': storageSlot,
        if (matrixRunouts.isNotEmpty)
          'matrix_runouts': [
            for (final runout in matrixRunouts) runout.toJson(),
          ],
      };

  factory MusicOwnedMediumDetails.fromJson(Map<String, dynamic> json) {
    final rawRunouts = json['matrix_runouts'];
    return MusicOwnedMediumDetails(
      mediumIndex: _int(json['medium_index']) ?? 1,
      mediaCondition: _text(json['media_condition']),
      storageDevice: _text(json['storage_device']),
      storageSlot: _text(json['storage_slot']),
      matrixRunouts: rawRunouts is Iterable
          ? [
              for (final value in rawRunouts)
                if (value is Map)
                  MusicMatrixRunout.fromJson(Map<String, dynamic>.from(value)),
            ]
          : const <MusicMatrixRunout>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicOwnedMediumDetails &&
          mediumIndex == other.mediumIndex &&
          mediaCondition == other.mediaCondition &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot &&
          listEquals(matrixRunouts, other.matrixRunouts);

  @override
  int get hashCode => Object.hash(
        mediumIndex,
        mediaCondition,
        storageDevice,
        storageSlot,
        Object.hashAll(matrixRunouts),
      );
}

@immutable
final class MusicOwnedDetails implements JsonEncodable {
  const MusicOwnedDetails({
    this.media = const [],
    this.signedBy,
    this.lastCleanedDate,
  });

  final List<MusicOwnedMediumDetails> media;
  final String? signedBy;
  final DateTime? lastCleanedDate;

  @override
  Map<String, dynamic> toJson() => {
        if (media.any((entry) => !entry.isEmpty))
          'media': [
            for (final entry in media)
              if (!entry.isEmpty) entry.toJson(),
          ],
        if (signedBy != null) 'signed_by': signedBy,
        if (lastCleanedDate != null)
          'last_cleaned_date': lastCleanedDate!.toUtc().toIso8601String(),
      };

  factory MusicOwnedDetails.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    return MusicOwnedDetails(
      media: rawMedia is Iterable
          ? [
              for (final value in rawMedia)
                if (value is Map)
                  MusicOwnedMediumDetails.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
            ]
          : const <MusicOwnedMediumDetails>[],
      signedBy: _text(json['signed_by']),
      lastCleanedDate: _date(json['last_cleaned_date']),
    );
  }

  MusicOwnedDetails copyWith({
    List<MusicOwnedMediumDetails>? media,
    Object? signedBy = _musicDetailsUnset,
    Object? lastCleanedDate = _musicDetailsUnset,
  }) {
    return MusicOwnedDetails(
      media: media ?? this.media,
      signedBy: identical(signedBy, _musicDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      lastCleanedDate: identical(lastCleanedDate, _musicDetailsUnset)
          ? this.lastCleanedDate
          : lastCleanedDate as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicOwnedDetails &&
          listEquals(media, other.media) &&
          signedBy == other.signedBy &&
          lastCleanedDate == other.lastCleanedDate;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(media),
        signedBy,
        lastCleanedDate,
      );

  MusicOwnedMediumDetails? medium(int mediumIndex) {
    for (final entry in media) {
      if (entry.mediumIndex == mediumIndex) return entry;
    }
    return null;
  }

  List<MusicMatrixRunout> matrixRunoutsForMedium(int mediumIndex) => [
        ...?medium(mediumIndex)?.matrixRunouts,
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

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '')?.toUtc();
