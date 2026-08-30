import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/_shared/add/grading_draft.dart';
import 'package:collectarr_app/features/library/kinds/_shared/add/signature_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_key_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicAddDraft extends LibraryAddKindDraft {
  const ComicAddDraft({
    this.grading = const GradingDraft(),
    this.signature = const SignatureDraft(),
    this.key = const ComicKeyDraft(),
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
    this.coverPriceCents,
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
        _keySeverity = keySeverity;

  final GradingDraft grading;
  final SignatureDraft signature;
  final ComicKeyDraft key;

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
  final int? coverPriceCents;

  String? get rawOrSlabbed => _rawOrSlabbed ?? grading.rawOrSlabbed;
  String? get gradingCompany => _gradingCompany ?? grading.gradingCompany;
  String? get graderNotes => _graderNotes ?? grading.graderNotes;
  String? get signedBy => _signedBy ?? signature.signedBy;
  String? get labelType => _labelType ?? grading.labelType;
  String? get customLabel => _customLabel ?? grading.customLabel;
  String? get pageQuality => _pageQuality ?? grading.pageQuality;
  String? get certificationNumber =>
      _certificationNumber ?? grading.certificationNumber;
  bool get keyComic => _keyComic ?? key.keyComic;
  String? get keyReason => _keyReason ?? key.keyReason;
  String? get keyCategory => _keyCategory ?? key.keyCategory;
  String? get keySeverity => _keySeverity ?? key.keySeverity;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => ComicOwnedDetailsDraft(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
      );
}
