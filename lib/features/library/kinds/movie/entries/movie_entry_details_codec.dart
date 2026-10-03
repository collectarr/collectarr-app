import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';

final class MovieEntryDetailsCodec {
  const MovieEntryDetailsCodec();

  MovieEntryDetails fromJson(Map<String, dynamic> json) =>
      MovieEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(MovieEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MovieEntryDetails details) =>
      details.toJson();

  MovieEntryDetails defaultDetails() => const MovieEntryDetails();

  MovieEntryDetailsDraft draftFromDetails(MovieEntryDetails details) =>
      MovieEntryDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  MovieEntryDetailsDraft defaultDraft() => const MovieEntryDetailsDraft();
}
