import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/comic_preservation_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/grading_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/signature_details.dart';

const Object _mangaDetailsUnset = Object();

@immutable
class MangaOwnedDetails extends OwnedItemDetails {
  const MangaOwnedDetails({
    this.grading = const GradingDetails(),
    this.signature = const SignatureDetails(),
    this.preservation = const ComicPreservationDetails(),
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
  })  : _rawOrSlabbed = rawOrSlabbed,
        _gradingCompany = gradingCompany,
        _graderNotes = graderNotes,
        _signedBy = signedBy,
        _labelType = labelType,
        _customLabel = customLabel,
        _pageQuality = pageQuality,
        _certificationNumber = certificationNumber,
        _keyComic = keyComic,
        _keyReason = keyReason,
        _keyCategory = keyCategory,
        _keySeverity = keySeverity,
        _coverPriceCents = coverPriceCents,
        _lastBagBoardDate = lastBagBoardDate;

  final GradingDetails grading;
  final SignatureDetails signature;
  final ComicPreservationDetails preservation;

  final String? _rawOrSlabbed;
  final String? _gradingCompany;
  final String? _graderNotes;
  final String? _signedBy;
  final String? _labelType;
  final String? _customLabel;
  final String? _pageQuality;
  final String? _certificationNumber;
  final bool? _keyComic;
  final String? _keyReason;
  final String? _keyCategory;
  final String? _keySeverity;
  final int? _coverPriceCents;
  final DateTime? _lastBagBoardDate;

  String? get rawOrSlabbed => _rawOrSlabbed ?? grading.rawOrSlabbed;
  String? get gradingCompany => _gradingCompany ?? grading.gradingCompany;
  String? get graderNotes => _graderNotes ?? grading.graderNotes;
  String? get signedBy => _signedBy ?? signature.signedBy;
  String? get labelType => _labelType ?? grading.labelType;
  String? get customLabel => _customLabel ?? grading.customLabel;
  String? get pageQuality => _pageQuality ?? grading.pageQuality;
  String? get certificationNumber =>
      _certificationNumber ?? grading.certificationNumber;
  bool get keyComic => _keyComic ?? preservation.keyComic;
  String? get keyReason => _keyReason ?? preservation.keyReason;
  String? get keyCategory => _keyCategory ?? preservation.keyCategory;
  String? get keySeverity => _keySeverity ?? preservation.keySeverity;
  int? get coverPriceCents => _coverPriceCents ?? preservation.coverPriceCents;
  DateTime? get lastBagBoardDate =>
      _lastBagBoardDate ?? preservation.lastBagBoardDate;

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

  factory MangaOwnedDetails.fromJson(Map<String, dynamic> json) {
    final grading = GradingDetails.fromJson(json);
    final signature = SignatureDetails.fromJson(json);
    final preservation = ComicPreservationDetails.fromJson(json);
    return MangaOwnedDetails(
      grading: grading,
      signature: signature,
      preservation: preservation,
    );
  }

  MangaOwnedDetails copyWith({
    Object? rawOrSlabbed = _mangaDetailsUnset,
    Object? gradingCompany = _mangaDetailsUnset,
    Object? graderNotes = _mangaDetailsUnset,
    Object? signedBy = _mangaDetailsUnset,
    Object? labelType = _mangaDetailsUnset,
    Object? customLabel = _mangaDetailsUnset,
    Object? pageQuality = _mangaDetailsUnset,
    Object? certificationNumber = _mangaDetailsUnset,
    bool? keyComic,
    Object? keyReason = _mangaDetailsUnset,
    Object? keyCategory = _mangaDetailsUnset,
    Object? keySeverity = _mangaDetailsUnset,
    Object? coverPriceCents = _mangaDetailsUnset,
    Object? lastBagBoardDate = _mangaDetailsUnset,
    GradingDetails? grading,
    SignatureDetails? signature,
    ComicPreservationDetails? preservation,
  }) {
    return MangaOwnedDetails(
      rawOrSlabbed: identical(rawOrSlabbed, _mangaDetailsUnset)
          ? this.rawOrSlabbed
          : rawOrSlabbed as String?,
      gradingCompany: identical(gradingCompany, _mangaDetailsUnset)
          ? this.gradingCompany
          : gradingCompany as String?,
      graderNotes: identical(graderNotes, _mangaDetailsUnset)
          ? this.graderNotes
          : graderNotes as String?,
      signedBy: identical(signedBy, _mangaDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      labelType: identical(labelType, _mangaDetailsUnset)
          ? this.labelType
          : labelType as String?,
      customLabel: identical(customLabel, _mangaDetailsUnset)
          ? this.customLabel
          : customLabel as String?,
      pageQuality: identical(pageQuality, _mangaDetailsUnset)
          ? this.pageQuality
          : pageQuality as String?,
      certificationNumber: identical(certificationNumber, _mangaDetailsUnset)
          ? this.certificationNumber
          : certificationNumber as String?,
      keyComic: keyComic ?? this.keyComic,
      keyReason: identical(keyReason, _mangaDetailsUnset)
          ? this.keyReason
          : keyReason as String?,
      keyCategory: identical(keyCategory, _mangaDetailsUnset)
          ? this.keyCategory
          : keyCategory as String?,
      keySeverity: identical(keySeverity, _mangaDetailsUnset)
          ? this.keySeverity
          : keySeverity as String?,
      coverPriceCents: identical(coverPriceCents, _mangaDetailsUnset)
          ? this.coverPriceCents
          : coverPriceCents as int?,
      lastBagBoardDate: identical(lastBagBoardDate, _mangaDetailsUnset)
          ? this.lastBagBoardDate
          : lastBagBoardDate as DateTime?,
      grading: grading ?? this.grading,
      signature: signature ?? this.signature,
      preservation: preservation ?? this.preservation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaOwnedDetails &&
          runtimeType == other.runtimeType &&
          rawOrSlabbed == other.rawOrSlabbed &&
          gradingCompany == other.gradingCompany &&
          graderNotes == other.graderNotes &&
          signedBy == other.signedBy &&
          labelType == other.labelType &&
          customLabel == other.customLabel &&
          pageQuality == other.pageQuality &&
          certificationNumber == other.certificationNumber &&
          keyComic == other.keyComic &&
          keyReason == other.keyReason &&
          keyCategory == other.keyCategory &&
          keySeverity == other.keySeverity &&
          coverPriceCents == other.coverPriceCents &&
          lastBagBoardDate == other.lastBagBoardDate;

  @override
  int get hashCode => Object.hash(
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        signedBy,
        labelType,
        customLabel,
        pageQuality,
        certificationNumber,
        keyComic,
        keyReason,
        keyCategory,
        keySeverity,
        coverPriceCents,
        lastBagBoardDate,
      );
}
