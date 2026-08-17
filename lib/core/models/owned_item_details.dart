import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

/// Sealed hierarchy of kind-specific details for an [OwnedItem].
@immutable
sealed class OwnedItemDetails {
  const OwnedItemDetails();

  Map<String, dynamic> toJson();

  static OwnedItemDetails parseForKind(
    CatalogMediaKind kind,
    Map<String, dynamic> json,
  ) {
    if (kind == CatalogMediaKind.unknown) {
      return const GenericOwnedDetails();
    }
    return libraryKindRuntimeForKind(kind).decodeOwnedDetails(json);
  }

  static OwnedItemDetails defaultForKind(CatalogMediaKind kind) {
    if (kind == CatalogMediaKind.unknown) {
      return const GenericOwnedDetails();
    }
    return libraryKindRuntimeForKind(kind).defaultOwnedDetails();
  }

  ComicOwnedDetails? get comic =>
      this is ComicOwnedDetails ? this as ComicOwnedDetails : null;
  VideoOwnedDetails? get video =>
      this is VideoOwnedDetails ? this as VideoOwnedDetails : null;
  GameOwnedDetails? get game =>
      this is GameOwnedDetails ? this as GameOwnedDetails : null;
  MusicOwnedDetails? get music =>
      this is MusicOwnedDetails ? this as MusicOwnedDetails : null;
  BookOwnedDetails? get book =>
      this is BookOwnedDetails ? this as BookOwnedDetails : null;
  BoardgameOwnedDetails? get boardgame =>
      this is BoardgameOwnedDetails ? this as BoardgameOwnedDetails : null;
}

const Object _detailsUnset = Object();

/// Kind-specific ownership details for books.
class BookOwnedDetails extends OwnedItemDetails {
  const BookOwnedDetails({
    this.signedBy,
  });

  final String? signedBy;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory BookOwnedDetails.fromJson(Map<String, dynamic> json) =>
      BookOwnedDetails(
        signedBy: json['signed_by'] as String?,
      );

  BookOwnedDetails copyWith({
    Object? signedBy = _detailsUnset,
  }) {
    return BookOwnedDetails(
      signedBy: identical(signedBy, _detailsUnset)
          ? this.signedBy
          : signedBy as String?,
    );
  }
}

/// Kind-specific ownership details for board games.
class BoardgameOwnedDetails extends OwnedItemDetails {
  const BoardgameOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  factory BoardgameOwnedDetails.fromJson(Map<String, dynamic> json) =>
      const BoardgameOwnedDetails();
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

  bool get isSlabbed =>
      rawOrSlabbed?.toLowerCase() == 'slabbed' || gradingCompany != null;

  @override
  Map<String, dynamic> toJson() => {
        if (rawOrSlabbed != null) 'raw_or_slabbed': rawOrSlabbed,
        if (gradingCompany != null) 'grading_company': gradingCompany,
        if (graderNotes != null) 'grader_notes': graderNotes,
        if (signedBy != null) 'signed_by': signedBy,
        if (labelType != null) 'label_type': labelType,
        if (customLabel != null) 'custom_label': customLabel,
        if (pageQuality != null) 'page_quality': pageQuality,
        if (certificationNumber != null)
          'certification_number': certificationNumber,
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
    Object? rawOrSlabbed = _detailsUnset,
    Object? gradingCompany = _detailsUnset,
    Object? graderNotes = _detailsUnset,
    Object? signedBy = _detailsUnset,
    Object? labelType = _detailsUnset,
    Object? customLabel = _detailsUnset,
    Object? pageQuality = _detailsUnset,
    Object? certificationNumber = _detailsUnset,
    bool? keyComic,
    Object? keyReason = _detailsUnset,
    Object? keyCategory = _detailsUnset,
    Object? keySeverity = _detailsUnset,
    Object? coverPriceCents = _detailsUnset,
    Object? lastBagBoardDate = _detailsUnset,
  }) {
    return ComicOwnedDetails(
      rawOrSlabbed: identical(rawOrSlabbed, _detailsUnset)
          ? this.rawOrSlabbed
          : rawOrSlabbed as String?,
      gradingCompany: identical(gradingCompany, _detailsUnset)
          ? this.gradingCompany
          : gradingCompany as String?,
      graderNotes: identical(graderNotes, _detailsUnset)
          ? this.graderNotes
          : graderNotes as String?,
      signedBy: identical(signedBy, _detailsUnset)
          ? this.signedBy
          : signedBy as String?,
      labelType: identical(labelType, _detailsUnset)
          ? this.labelType
          : labelType as String?,
      customLabel: identical(customLabel, _detailsUnset)
          ? this.customLabel
          : customLabel as String?,
      pageQuality: identical(pageQuality, _detailsUnset)
          ? this.pageQuality
          : pageQuality as String?,
      certificationNumber: identical(certificationNumber, _detailsUnset)
          ? this.certificationNumber
          : certificationNumber as String?,
      keyComic: keyComic ?? this.keyComic,
      keyReason: identical(keyReason, _detailsUnset)
          ? this.keyReason
          : keyReason as String?,
      keyCategory: identical(keyCategory, _detailsUnset)
          ? this.keyCategory
          : keyCategory as String?,
      keySeverity: identical(keySeverity, _detailsUnset)
          ? this.keySeverity
          : keySeverity as String?,
      coverPriceCents: identical(coverPriceCents, _detailsUnset)
          ? this.coverPriceCents
          : coverPriceCents as int?,
      lastBagBoardDate: identical(lastBagBoardDate, _detailsUnset)
          ? this.lastBagBoardDate
          : lastBagBoardDate as DateTime?,
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
    Object? features = _detailsUnset,
    List<String>? hdrFormats,
    Object? boxSetId = _detailsUnset,
    Object? boxSetName = _detailsUnset,
    Object? region = _detailsUnset,
    Object? packaging = _detailsUnset,
    Object? distributor = _detailsUnset,
  }) {
    return VideoOwnedDetails(
      features: identical(features, _detailsUnset)
          ? this.features
          : features as String?,
      hdrFormats: hdrFormats ?? this.hdrFormats,
      boxSetId: identical(boxSetId, _detailsUnset)
          ? this.boxSetId
          : boxSetId as String?,
      boxSetName: identical(boxSetName, _detailsUnset)
          ? this.boxSetName
          : boxSetName as String?,
      region:
          identical(region, _detailsUnset) ? this.region : region as String?,
      packaging: identical(packaging, _detailsUnset)
          ? this.packaging
          : packaging as String?,
      distributor: identical(distributor, _detailsUnset)
          ? this.distributor
          : distributor as String?,
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
    Object? completeness = _detailsUnset,
    Object? hasBox = _detailsUnset,
    Object? hasManual = _detailsUnset,
    Object? priceChartingId = _detailsUnset,
    Object? coreRegion = _detailsUnset,
    Object? valueIsLocked = _detailsUnset,
  }) {
    return GameOwnedDetails(
      completeness: identical(completeness, _detailsUnset)
          ? this.completeness
          : completeness as String?,
      hasBox: identical(hasBox, _detailsUnset) ? this.hasBox : hasBox as bool?,
      hasManual: identical(hasManual, _detailsUnset)
          ? this.hasManual
          : hasManual as bool?,
      priceChartingId: identical(priceChartingId, _detailsUnset)
          ? this.priceChartingId
          : priceChartingId as String?,
      coreRegion: identical(coreRegion, _detailsUnset)
          ? this.coreRegion
          : coreRegion as String?,
      valueIsLocked: identical(valueIsLocked, _detailsUnset)
          ? this.valueIsLocked
          : valueIsLocked as bool?,
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
    Object? storageDevice = _detailsUnset,
    Object? storageSlot = _detailsUnset,
  }) {
    return MusicOwnedDetails(
      storageDevice: identical(storageDevice, _detailsUnset)
          ? this.storageDevice
          : storageDevice as String?,
      storageSlot: identical(storageSlot, _detailsUnset)
          ? this.storageSlot
          : storageSlot as String?,
    );
  }
}

/// Generic fallback ownership details.
class GenericOwnedDetails extends OwnedItemDetails {
  const GenericOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};
}
