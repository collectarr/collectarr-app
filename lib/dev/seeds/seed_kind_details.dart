import 'package:collectarr_app/core/models/partial_date.dart';

/// Seed-only values that keep development catalog fixtures readable.
///
/// These helpers are not application or transport models. Each value encodes
/// directly into the owning kind's root document.
final class SeedSeriesDetails {
  const SeedSeriesDetails({
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.seasonNumber,
    this.episodeNumber,
    this.tags,
  });

  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final String? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? tags;

  Map<String, dynamic> toJson() => {
        if (seriesId != null) 'series_id': seriesId,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (volumeName != null) 'volume_name': volumeName,
        if (volumeNumber != null) 'volume_number': volumeNumber,
        if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (tags != null) 'tags': tags,
      };
}

final class SeedVideoDetails {
  const SeedVideoDetails({
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.ageRating,
    this.audienceRating,
  });

  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? ageRating;
  final String? audienceRating;

  Map<String, dynamic> toJson() => {
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (color != null) 'color': color,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (layers != null) 'layers': layers,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
      };
}

final class SeedPublishingDetails {
  const SeedPublishingDetails({
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.publicationPlace,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublicationDateParts,
    this.originalPublicationPlace,
    this.originalPublisher,
    this.paperType,
    this.printedBy,
    this.subjects = const [],
    this.dustJacketCondition,
    this.dustJacket,
    this.audiobookAbridged,
    this.firstEdition,
    this.dewey,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? publicationPlace;
  final String? originalCountry;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final PartialDate? originalPublicationDateParts;
  final String? originalPublicationPlace;
  final String? originalPublisher;
  final String? paperType;
  final String? printedBy;
  final List<String> subjects;
  final String? dustJacketCondition;
  final bool? dustJacket;
  final bool? audiobookAbridged;
  final bool? firstEdition;
  final String? dewey;

  Map<String, dynamic> toJson() => {
        if (pageCount != null) 'page_count': pageCount,
        if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
        if (currency != null) 'currency': currency,
        if (imprint != null) 'imprint': imprint,
        if (subtitle != null) 'subtitle': subtitle,
        if (seriesGroup != null) 'series_group': seriesGroup,
        if (publicationPlace != null) 'publication_place': publicationPlace,
        if (originalCountry != null) 'original_country': originalCountry,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toUtc().toIso8601String(),
        if (originalPublicationDateParts != null)
          'original_publication_date_parts':
              originalPublicationDateParts!.toJson(),
        if (originalPublicationPlace != null)
          'original_publication_place': originalPublicationPlace,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (paperType != null) 'paper_type': paperType,
        if (printedBy != null) 'printed_by': printedBy,
        if (subjects.isNotEmpty) 'subjects': subjects,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
        if (dustJacket != null) 'dust_jacket': dustJacket,
        if (audiobookAbridged != null) 'audiobook_abridged': audiobookAbridged,
        if (firstEdition != null) 'first_edition': firstEdition,
        if (dewey != null) 'dewey': dewey,
      };
}
