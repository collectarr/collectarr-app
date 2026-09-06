import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/grading_draft.dart';
import 'package:collectarr_app/features/library/add/models/signature_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MangaAddDraft extends LibraryAddKindDraft {
  const MangaAddDraft({
    this.grading = const GradingDraft(),
    this.signature = const SignatureDraft(),
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

  final GradingDraft grading;
  final SignatureDraft signature;

  final String? _signedBy;
  final String? _gradingCompany;
  final String? _graderNotes;

  final bool obiStripPresent;
  final bool slipcoverPresent;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final String? boxSetOuterCondition;
  final bool insertsPresent;
  final String? printing;
  final String? localizedEdition;

  String? get signedBy => _signedBy ?? signature.signedBy;
  String? get gradingCompany => _gradingCompany ?? grading.gradingCompany;
  String? get graderNotes => _graderNotes ?? grading.graderNotes;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => MangaOwnedDetailsDraft(
        rawOrSlabbed: grading.rawOrSlabbed,
        signedBy: signedBy,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        labelType: grading.labelType,
        customLabel: grading.customLabel,
        pageQuality: grading.pageQuality,
        certificationNumber: grading.certificationNumber,
        obiStripPresent: obiStripPresent,
        slipcoverPresent: slipcoverPresent,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        boxSetOuterCondition: boxSetOuterCondition,
        insertsPresent: insertsPresent,
        printing: printing,
        localizedEdition: localizedEdition,
      );
}
