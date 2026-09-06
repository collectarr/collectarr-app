import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';

class MangaOwnedDetailsDraft extends OwnedDetailsDraft {
  const MangaOwnedDetailsDraft({
    this.rawOrSlabbed,
    this.signedBy,
    this.gradingCompany,
    this.graderNotes,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.boxSetOuterCondition,
    this.insertsPresent = false,
    this.printing,
    this.localizedEdition,
  });

  final String? rawOrSlabbed;
  final String? signedBy;
  final String? gradingCompany;
  final String? graderNotes;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool obiStripPresent;
  final bool slipcoverPresent;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final String? boxSetOuterCondition;
  final bool insertsPresent;
  final String? printing;
  final String? localizedEdition;

  @override
  MangaOwnedDetails toDetails() => MangaOwnedDetails(
        grading: MangaGradingDetails(
          rawOrSlabbed: rawOrSlabbed,
          gradingCompany: gradingCompany,
          graderNotes: graderNotes,
          labelType: labelType,
          customLabel: customLabel,
          pageQuality: pageQuality,
          certificationNumber: certificationNumber,
        ),
        signedBy: signedBy,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
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
