import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const Object _musicDetailsUnset = Object();

/// Physical details for one medium in an entry Music copy.
///
/// Personal media condition and storage details live here. Matrix/runout
/// identifiers describe the catalog medium and are stored on [MusicMedium].
@immutable
final class MusicEntryMediumDetails implements JsonEncodable {
  const MusicEntryMediumDetails({
    required this.mediumId,
    this.storageDevice,
    this.storageSlot,
  });

  final String mediumId;
  final String? storageDevice;
  final String? storageSlot;

  bool get isEmpty =>
      (storageDevice == null || storageDevice!.trim().isEmpty) &&
      (storageSlot == null || storageSlot!.trim().isEmpty);

  @override
  Map<String, dynamic> toJson() => {
        'medium_id': mediumId,
        if (storageDevice?.trim().isNotEmpty == true)
          'storage_device': storageDevice,
        if (storageSlot?.trim().isNotEmpty == true) 'storage_slot': storageSlot,
      };

  factory MusicEntryMediumDetails.fromJson(Map<String, dynamic> json) {
    final mediumId = json['medium_id'];
    if (mediumId is! String || mediumId.trim().isEmpty) {
      throw const FormatException(
        'Music entry medium details require a stable medium_id.',
      );
    }
    return MusicEntryMediumDetails(
      mediumId: mediumId,
      storageDevice: _text(json['storage_device']),
      storageSlot: _text(json['storage_slot']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicEntryMediumDetails &&
          mediumId == other.mediumId &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot;

  @override
  int get hashCode => Object.hash(
        mediumId,
        storageDevice,
        storageSlot,
      );
}

@immutable
final class MusicEntryDetails implements JsonEncodable {
  const MusicEntryDetails({
    this.media = const [],
    this.signedBy,
    this.lastCleanedDate,
  });

  final List<MusicEntryMediumDetails> media;
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

  factory MusicEntryDetails.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    return MusicEntryDetails(
      media: rawMedia is Iterable
          ? [
              for (final value in rawMedia)
                if (value is Map)
                  MusicEntryMediumDetails.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
            ]
          : const <MusicEntryMediumDetails>[],
      signedBy: _text(json['signed_by']),
      lastCleanedDate: _date(json['last_cleaned_date']),
    );
  }

  MusicEntryDetails copyWith({
    List<MusicEntryMediumDetails>? media,
    Object? signedBy = _musicDetailsUnset,
    Object? lastCleanedDate = _musicDetailsUnset,
  }) {
    return MusicEntryDetails(
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
      other is MusicEntryDetails &&
          listEquals(media, other.media) &&
          signedBy == other.signedBy &&
          lastCleanedDate == other.lastCleanedDate;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(media),
        signedBy,
        lastCleanedDate,
      );

  MusicEntryMediumDetails? medium(String mediumId) {
    for (final entry in media) {
      if (entry.mediumId == mediumId) return entry;
    }
    return null;
  }
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '')?.toUtc();
