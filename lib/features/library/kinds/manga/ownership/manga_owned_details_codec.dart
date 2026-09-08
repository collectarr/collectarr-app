import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';

class MangaOwnedDetailsCodec
    extends OwnedDetailsCodec<MangaOwnedDetails, MangaOwnedDetailsDraft> {
  const MangaOwnedDetailsCodec();

  @override
  MangaOwnedDetails fromJson(Map<String, dynamic> json) =>
      MangaOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(MangaOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(MangaOwnedDetails details) =>
      details.toJson();

  @override
  MangaOwnedDetails defaultDetails() => const MangaOwnedDetails();

  @override
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

  @override
  MangaOwnedDetailsDraft defaultDraft() => const MangaOwnedDetailsDraft();
}
