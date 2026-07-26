import 'package:flutter/foundation.dart';

/// Sealed hierarchy of kind-specific details for an [OwnedItem].
@immutable
sealed class OwnedItemDetails {
  const OwnedItemDetails();

  Map<String, dynamic> toJson();
}

/// Kind-specific ownership details for comics and manga.
class ComicOwnedDetails extends OwnedItemDetails {
  const ComicOwnedDetails({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
    this.coverPriceCents,
    this.lastBagBoardDate,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
  final int? coverPriceCents;
  final DateTime? lastBagBoardDate;

  bool get isSlabbed => rawOrSlabbed?.toLowerCase() == 'slabbed' || gradingCompany != null;

  @override
  Map<String, dynamic> toJson() => {
    if (rawOrSlabbed != null) 'raw_or_slabbed': rawOrSlabbed,
    if (gradingCompany != null) 'grading_company': gradingCompany,
    if (graderNotes != null) 'grader_notes': graderNotes,
    if (signedBy != null) 'signed_by': signedBy,
    if (labelType != null) 'label_type': labelType,
    if (customLabel != null) 'custom_label': customLabel,
    if (pageQuality != null) 'page_quality': pageQuality,
    if (certificationNumber != null) 'certification_number': certificationNumber,
    'key_comic': keyComic,
    if (keyReason != null) 'key_reason': keyReason,
    if (keyCategory != null) 'key_category': keyCategory,
    if (keySeverity != null) 'key_severity': keySeverity,
    if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
    if (lastBagBoardDate != null)
      'last_bag_board_date': lastBagBoardDate!.toUtc().toIso8601String(),
  };

  factory ComicOwnedDetails.fromJson(Map<String, dynamic> json) {
    return ComicOwnedDetails(
      rawOrSlabbed: json['raw_or_slabbed'] as String?,
      gradingCompany: json['grading_company'] as String?,
      graderNotes: json['grader_notes'] as String?,
      signedBy: json['signed_by'] as String?,
      labelType: json['label_type'] as String?,
      customLabel: json['custom_label'] as String?,
      pageQuality: json['page_quality'] as String?,
      certificationNumber: json['certification_number'] as String?,
      keyComic: json['key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      keyCategory: json['key_category'] as String?,
      keySeverity: json['key_severity'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      lastBagBoardDate: json['last_bag_board_date'] == null
          ? null
          : DateTime.parse(json['last_bag_board_date'] as String),
    );
  }

  ComicOwnedDetails copyWith({
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? customLabel,
    String? pageQuality,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
    int? coverPriceCents,
    DateTime? lastBagBoardDate,
  }) {
    return ComicOwnedDetails(
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      customLabel: customLabel ?? this.customLabel,
      pageQuality: pageQuality ?? this.pageQuality,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      lastBagBoardDate: lastBagBoardDate ?? this.lastBagBoardDate,
    );
  }
}

/// Kind-specific ownership details for movies, TV series, and anime.
class VideoOwnedDetails extends OwnedItemDetails {
  const VideoOwnedDetails({
    this.features,
    this.hdrFormats = const <String>[],
    this.boxSetId,
    this.boxSetName,
    this.region,
    this.packaging,
    this.distributor,
  });

  final String? features;
  final List<String> hdrFormats;
  final String? boxSetId;
  final String? boxSetName;
  final String? region;
  final String? packaging;
  final String? distributor;

  @override
  Map<String, dynamic> toJson() => {
    if (features != null) 'features': features,
    if (hdrFormats.isNotEmpty) 'hdr_formats': hdrFormats,
    if (boxSetId != null) 'box_set_id': boxSetId,
    if (boxSetName != null) 'box_set_name': boxSetName,
    if (region != null) 'region': region,
    if (packaging != null) 'packaging': packaging,
    if (distributor != null) 'distributor': distributor,
  };

  factory VideoOwnedDetails.fromJson(Map<String, dynamic> json) {
    return VideoOwnedDetails(
      features: json['features'] as String?,
      hdrFormats: (json['hdr_formats'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      boxSetId: json['box_set_id'] as String?,
      boxSetName: json['box_set_name'] as String?,
      region: json['region'] as String?,
      packaging: json['packaging'] as String?,
      distributor: json['distributor'] as String?,
    );
  }

  VideoOwnedDetails copyWith({
    String? features,
    List<String>? hdrFormats,
    String? boxSetId,
    String? boxSetName,
    String? region,
    String? packaging,
    String? distributor,
  }) {
    return VideoOwnedDetails(
      features: features ?? this.features,
      hdrFormats: hdrFormats ?? this.hdrFormats,
      boxSetId: boxSetId ?? this.boxSetId,
      boxSetName: boxSetName ?? this.boxSetName,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
    );
  }
}

/// Kind-specific ownership details for video games.
class GameOwnedDetails extends OwnedItemDetails {
  const GameOwnedDetails({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.coreRegion,
    this.valueIsLocked,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final String? coreRegion;
  final bool? valueIsLocked;

  @override
  Map<String, dynamic> toJson() => {
    if (completeness != null) 'game_completeness': completeness,
    if (hasBox != null) 'game_has_box': hasBox,
    if (hasManual != null) 'game_has_manual': hasManual,
    if (priceChartingId != null) 'game_pricecharting_id': priceChartingId,
    if (coreRegion != null) 'game_core_region': coreRegion,
    if (valueIsLocked != null) 'game_value_is_locked': valueIsLocked,
  };

  factory GameOwnedDetails.fromJson(Map<String, dynamic> json) {
    return GameOwnedDetails(
      completeness: json['game_completeness'] as String?,
      hasBox: json['game_has_box'] as bool?,
      hasManual: json['game_has_manual'] as bool?,
      priceChartingId: json['game_pricecharting_id'] as String?,
      coreRegion: json['game_core_region'] as String?,
      valueIsLocked: json['game_value_is_locked'] as bool?,
    );
  }

  GameOwnedDetails copyWith({
    String? completeness,
    bool? hasBox,
    bool? hasManual,
    String? priceChartingId,
    String? coreRegion,
    bool? valueIsLocked,
  }) {
    return GameOwnedDetails(
      completeness: completeness ?? this.completeness,
      hasBox: hasBox ?? this.hasBox,
      hasManual: hasManual ?? this.hasManual,
      priceChartingId: priceChartingId ?? this.priceChartingId,
      coreRegion: coreRegion ?? this.coreRegion,
      valueIsLocked: valueIsLocked ?? this.valueIsLocked,
    );
  }
}

/// Kind-specific ownership details for music releases.
class MusicOwnedDetails extends OwnedItemDetails {
  const MusicOwnedDetails({
    this.storageDevice,
    this.storageSlot,
  });

  final String? storageDevice;
  final String? storageSlot;

  @override
  Map<String, dynamic> toJson() => {
    if (storageDevice != null) 'storage_device': storageDevice,
    if (storageSlot != null) 'storage_slot': storageSlot,
  };

  factory MusicOwnedDetails.fromJson(Map<String, dynamic> json) {
    return MusicOwnedDetails(
      storageDevice: json['storage_device'] as String?,
      storageSlot: json['storage_slot'] as String?,
    );
  }

  MusicOwnedDetails copyWith({
    String? storageDevice,
    String? storageSlot,
  }) {
    return MusicOwnedDetails(
      storageDevice: storageDevice ?? this.storageDevice,
      storageSlot: storageSlot ?? this.storageSlot,
    );
  }
}

/// Generic fallback ownership details.
class GenericOwnedDetails extends OwnedItemDetails {
  const GenericOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};
}
