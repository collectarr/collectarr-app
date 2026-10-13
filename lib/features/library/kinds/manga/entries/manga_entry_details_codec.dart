import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details_draft.dart';

final class MangaEntryDetailsCodec {
  const MangaEntryDetailsCodec();

  MangaEntryDetails fromJson(Map<String, dynamic> json) =>
      MangaEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(MangaEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MangaEntryDetails details) =>
      details.toJson();

  MangaEntryDetails defaultDetails() => const MangaEntryDetails();

  MangaEntryDetailsDraft draftFromDetails(MangaEntryDetails details) =>
      MangaEntryDetailsDraft(
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

  MangaEntryDetailsDraft defaultDraft() => const MangaEntryDetailsDraft();
}
