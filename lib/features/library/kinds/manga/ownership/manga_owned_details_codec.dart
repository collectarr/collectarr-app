import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';

final class MangaOwnedDetailsCodec {
  const MangaOwnedDetailsCodec();

  MangaOwnedDetails fromJson(Map<String, dynamic> json) =>
      MangaOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(MangaOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MangaOwnedDetails details) =>
      details.toJson();

  MangaOwnedDetails defaultDetails() => const MangaOwnedDetails();

  MangaOwnedDetailsDraft draftFromDetails(MangaOwnedDetails details) =>
      MangaOwnedDetailsDraft(
        rawOrSlabbed: details.grading.rawOrSlabbed,
        signedBy: details.signedBy,
        gradingCompany: details.gradingCompany,
        graderNotes: details.graderNotes,
        labelType: details.grading.labelType,
        customLabel: details.grading.customLabel,
        pageQuality: details.grading.pageQuality,
        certificationNumber: details.grading.certificationNumber,
        obiStripPresent: details.obiStripPresent,
        slipcoverPresent: details.slipcoverPresent,
        dustJacketPresent: details.dustJacketPresent,
        dustJacketCondition: details.dustJacketCondition,
        boxSetOuterCondition: details.boxSetOuterCondition,
        insertsPresent: details.insertsPresent,
        printing: details.printing,
        localizedEdition: details.localizedEdition,
      );

  MangaOwnedDetailsDraft defaultDraft() => const MangaOwnedDetailsDraft();
}
