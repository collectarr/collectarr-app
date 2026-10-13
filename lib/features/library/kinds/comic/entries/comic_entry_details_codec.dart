import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';

final class ComicEntryDetailsCodec {
  const ComicEntryDetailsCodec();

  ComicEntryDetails fromJson(Map<String, dynamic> json) =>
      ComicEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(ComicEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(ComicEntryDetails details) =>
      details.toJson();

  ComicEntryDetails defaultDetails() => const ComicEntryDetails();

  ComicEntryDetailsDraft draftFromDetails(ComicEntryDetails details) =>
      ComicEntryDetailsDraft(
        rawOrSlabbed: details.rawOrSlabbed,
        gradingCompany: details.gradingCompany,
        graderNotes: details.graderNotes,
        signedBy: details.signedBy,
        labelType: details.labelType,
        customLabel: details.customLabel,
        pageQuality: details.pageQuality,
        certificationNumber: details.certificationNumber,
        keyComic: details.keyComic,
        keyReason: details.keyReason,
        keyCategory: details.keyCategory,
        keySeverity: details.keySeverity,
        coverPriceCents: details.coverPriceCents,
        lastBagBoardDate: details.lastBagBoardDate,
      );

  ComicEntryDetailsDraft defaultDraft() => const ComicEntryDetailsDraft();
}
