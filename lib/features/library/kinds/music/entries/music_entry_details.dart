import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const Object _musicDetailsUnset = Object();

/// Physical details for one disc in an entry Music copy.
///
/// Personal media condition and storage details live here. Matrix/runout
/// identifiers describe the catalog disc and are stored on [MusicDisc].
@immutable
final class MusicEntryDiscDetails implements JsonEncodable {
  const MusicEntryDiscDetails({
    required this.discId,
    this.storageDevice,
    this.storageSlot,
  });

  final String discId;
  final String? storageDevice;
  final String? storageSlot;

  bool get isEmpty =>
      (storageDevice == null || storageDevice!.trim().isEmpty) &&
      (storageSlot == null || storageSlot!.trim().isEmpty);

  @override
  Map<String, dynamic> toJson() => {
        'disc_id': discId,
        if (storageDevice?.trim().isNotEmpty == true)
          'storage_device': storageDevice,
        if (storageSlot?.trim().isNotEmpty == true) 'storage_slot': storageSlot,
      };

  factory MusicEntryDiscDetails.fromJson(Map<String, dynamic> json) {
    final discId = json['disc_id'];
    if (discId is! String || discId.trim().isEmpty) {
      throw const FormatException(
        'Music entry disc details require a stable disc_id.',
      );
    }
    return MusicEntryDiscDetails(
      discId: discId,
      storageDevice: _text(json['storage_device']),
      storageSlot: _text(json['storage_slot']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicEntryDiscDetails &&
          discId == other.discId &&
          storageDevice == other.storageDevice &&
          storageSlot == other.storageSlot;

  @override
  int get hashCode => Object.hash(
        discId,
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
    this.lastCleanedDateParts,
  });

  final List<MusicEntryDiscDetails> media;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final PartialDate? lastCleanedDateParts;

  @override
  Map<String, dynamic> toJson() => {
        if (media.any((entry) => !entry.isEmpty))
          'media': [
            for (final entry in media)
              if (!entry.isEmpty) entry.toJson(),
          ],
        if (signedBy != null) 'signed_by': signedBy,
        if (lastCleanedDateParts != null)
          'last_cleaned_date_parts': lastCleanedDateParts!.toJson(),
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
                  MusicEntryDiscDetails.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
            ]
          : const <MusicEntryDiscDetails>[],
      signedBy: _text(json['signed_by']),
      lastCleanedDate: _date(json['last_cleaned_date']),
      lastCleanedDateParts: PartialDate.tryParse(
          json['last_cleaned_date_parts'] ?? json['last_cleaned_date']),
    );
  }

  MusicEntryDetails copyWith({
    List<MusicEntryDiscDetails>? media,
    Object? signedBy = _musicDetailsUnset,
    Object? lastCleanedDate = _musicDetailsUnset,
    Object? lastCleanedDateParts = _musicDetailsUnset,
  }) {
    return MusicEntryDetails(
      media: media ?? this.media,
      signedBy: identical(signedBy, _musicDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      lastCleanedDateParts: identical(lastCleanedDateParts, _musicDetailsUnset)
          ? this.lastCleanedDateParts
          : lastCleanedDateParts as PartialDate?,
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
          lastCleanedDate == other.lastCleanedDate &&
          lastCleanedDateParts == other.lastCleanedDateParts;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(media),
        signedBy,
        lastCleanedDate,
        lastCleanedDateParts,
      );

  MusicEntryDiscDetails? disc(String discId) {
    for (final entry in media) {
      if (entry.discId == discId) return entry;
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
