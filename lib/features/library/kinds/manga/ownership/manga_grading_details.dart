import 'package:flutter/foundation.dart';

@immutable
final class MangaGradingDetails {
  const MangaGradingDetails({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;

  bool get isSlabbed =>
      rawOrSlabbed?.toLowerCase() == 'slabbed' || gradingCompany != null;

  Map<String, dynamic> toJson() => {
        if (rawOrSlabbed != null) 'raw_or_slabbed': rawOrSlabbed,
        if (gradingCompany != null) 'grading_company': gradingCompany,
        if (graderNotes != null) 'grader_notes': graderNotes,
        if (labelType != null) 'label_type': labelType,
        if (customLabel != null) 'custom_label': customLabel,
        if (pageQuality != null) 'page_quality': pageQuality,
        if (certificationNumber != null)
          'certification_number': certificationNumber,
      };

  factory MangaGradingDetails.fromJson(Map<String, dynamic> json) {
    return MangaGradingDetails(
      rawOrSlabbed: json['raw_or_slabbed'] as String?,
      gradingCompany: json['grading_company'] as String?,
      graderNotes: json['grader_notes'] as String?,
      labelType: json['label_type'] as String?,
      customLabel: json['custom_label'] as String?,
      pageQuality: json['page_quality'] as String?,
      certificationNumber: json['certification_number'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaGradingDetails &&
          rawOrSlabbed == other.rawOrSlabbed &&
          gradingCompany == other.gradingCompany &&
          graderNotes == other.graderNotes &&
          labelType == other.labelType &&
          customLabel == other.customLabel &&
          pageQuality == other.pageQuality &&
          certificationNumber == other.certificationNumber;

  @override
  int get hashCode => Object.hash(
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        labelType,
        customLabel,
        pageQuality,
        certificationNumber,
      );
}
