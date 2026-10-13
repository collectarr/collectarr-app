import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_draft.dart';

final class TvEntryDetailsCodec {
  const TvEntryDetailsCodec();

  TvEntryDetails fromJson(Map<String, dynamic> json) =>
      TvEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(TvEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(TvEntryDetails details) =>
      details.toJson();

  TvEntryDetails defaultDetails() => const TvEntryDetails();

  TvEntryDetailsDraft draftFromDetails(TvEntryDetails details) =>
      TvEntryDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  TvEntryDetailsDraft defaultDraft() => const TvEntryDetailsDraft();
}
