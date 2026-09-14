import 'package:flutter/foundation.dart';

@immutable
final class GradingDraft {
  const GradingDraft({
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
}
