import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';

final class AnimeEntryDetailsCodec {
  const AnimeEntryDetailsCodec();

  AnimeEntryDetails fromJson(Map<String, dynamic> json) =>
      AnimeEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(AnimeEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(AnimeEntryDetails details) =>
      details.toJson();

  AnimeEntryDetails defaultDetails() => const AnimeEntryDetails();

  AnimeEntryDetailsDraft draftFromDetails(AnimeEntryDetails details) =>
      AnimeEntryDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  AnimeEntryDetailsDraft defaultDraft() => const AnimeEntryDetailsDraft();
}
