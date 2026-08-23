import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/grading_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/signature_details.dart';

const Object _mangaDetailsUnset = Object();

@immutable
class MangaOwnedDetails extends OwnedItemDetails {
  const MangaOwnedDetails({
    this.grading = const GradingDetails(),
    this.signature = const SignatureDetails(),
    String? signedBy,
    String? gradingCompany,
    String? graderNotes,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.boxSetOuterCondition,
    this.insertsPresent = false,
    this.printing,
    this.localizedEdition,
  })  : _signedBy = signedBy,
        _gradingCompany = gradingCompany,
        _graderNotes = graderNotes;

  final GradingDetails grading;
  final SignatureDetails signature;

  final String? _signedBy;
  final String? _gradingCompany;
  final String? _graderNotes;

  /// Manga-specific: obi strip (belly band) present
  final bool obiStripPresent;

  /// Manga-specific: slipcover present (for box sets / deluxe editions)
  final bool slipcoverPresent;

  /// Manga-specific: dust jacket present (hardcover editions)
  final bool dustJacketPresent;

  /// Manga-specific: dust jacket condition description
  final String? dustJacketCondition;

  /// Manga-specific: outer box condition for box sets
  final String? boxSetOuterCondition;

  /// Manga-specific: bonus inserts / extras present
  final bool insertsPresent;

  /// Manga-specific: printing number / print run (e.g. "1st Print", "2nd Print")
  final String? printing;

  /// Manga-specific: localized edition label (e.g. "VIZ Media", "Yen Press")
  final String? localizedEdition;

  String? get signedBy => _signedBy ?? signature.signedBy;
  String? get gradingCompany => _gradingCompany ?? grading.gradingCompany;
  String? get graderNotes => _graderNotes ?? grading.graderNotes;

  @override
  Map<String, dynamic> toJson() => {
        if (signedBy != null) 'signed_by': signedBy,
        if (gradingCompany != null) 'grading_company': gradingCompany,
        if (graderNotes != null) 'grader_notes': graderNotes,
        if (obiStripPresent) 'obi_strip_present': true,
        if (slipcoverPresent) 'slipcover_present': true,
        if (dustJacketPresent) 'dust_jacket_present': true,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
        if (boxSetOuterCondition != null)
          'box_set_outer_condition': boxSetOuterCondition,
        if (insertsPresent) 'inserts_present': true,
        if (printing != null) 'printing': printing,
        if (localizedEdition != null) 'localized_edition': localizedEdition,
      };

  factory MangaOwnedDetails.fromJson(Map<String, dynamic> json) {
    final grading = GradingDetails.fromJson(json);
    final signature = SignatureDetails.fromJson(json);
    return MangaOwnedDetails(
      grading: grading,
      signature: signature,
      obiStripPresent: json['obi_strip_present'] as bool? ?? false,
      slipcoverPresent: json['slipcover_present'] as bool? ?? false,
      dustJacketPresent: json['dust_jacket_present'] as bool? ?? false,
      dustJacketCondition: json['dust_jacket_condition'] as String?,
      boxSetOuterCondition: json['box_set_outer_condition'] as String?,
      insertsPresent: json['inserts_present'] as bool? ?? false,
      printing: json['printing'] as String?,
      localizedEdition: json['localized_edition'] as String?,
    );
  }

  MangaOwnedDetails copyWith({
    Object? signedBy = _mangaDetailsUnset,
    Object? gradingCompany = _mangaDetailsUnset,
    Object? graderNotes = _mangaDetailsUnset,
    GradingDetails? grading,
    SignatureDetails? signature,
    bool? obiStripPresent,
    bool? slipcoverPresent,
    bool? dustJacketPresent,
    Object? dustJacketCondition = _mangaDetailsUnset,
    Object? boxSetOuterCondition = _mangaDetailsUnset,
    bool? insertsPresent,
    Object? printing = _mangaDetailsUnset,
    Object? localizedEdition = _mangaDetailsUnset,
  }) {
    return MangaOwnedDetails(
      grading: grading ?? this.grading,
      signature: signature ?? this.signature,
      signedBy: identical(signedBy, _mangaDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      gradingCompany: identical(gradingCompany, _mangaDetailsUnset)
          ? this.gradingCompany
          : gradingCompany as String?,
      graderNotes: identical(graderNotes, _mangaDetailsUnset)
          ? this.graderNotes
          : graderNotes as String?,
      obiStripPresent: obiStripPresent ?? this.obiStripPresent,
      slipcoverPresent: slipcoverPresent ?? this.slipcoverPresent,
      dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
      dustJacketCondition: identical(dustJacketCondition, _mangaDetailsUnset)
          ? this.dustJacketCondition
          : dustJacketCondition as String?,
      boxSetOuterCondition: identical(boxSetOuterCondition, _mangaDetailsUnset)
          ? this.boxSetOuterCondition
          : boxSetOuterCondition as String?,
      insertsPresent: insertsPresent ?? this.insertsPresent,
      printing: identical(printing, _mangaDetailsUnset)
          ? this.printing
          : printing as String?,
      localizedEdition: identical(localizedEdition, _mangaDetailsUnset)
          ? this.localizedEdition
          : localizedEdition as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaOwnedDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy &&
          gradingCompany == other.gradingCompany &&
          graderNotes == other.graderNotes &&
          obiStripPresent == other.obiStripPresent &&
          slipcoverPresent == other.slipcoverPresent &&
          dustJacketPresent == other.dustJacketPresent &&
          dustJacketCondition == other.dustJacketCondition &&
          boxSetOuterCondition == other.boxSetOuterCondition &&
          insertsPresent == other.insertsPresent &&
          printing == other.printing &&
          localizedEdition == other.localizedEdition;

  @override
  int get hashCode => Object.hash(
        signedBy,
        gradingCompany,
        graderNotes,
        obiStripPresent,
        slipcoverPresent,
        dustJacketPresent,
        dustJacketCondition,
        boxSetOuterCondition,
        insertsPresent,
        printing,
        localizedEdition,
      );
}
