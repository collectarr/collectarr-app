import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

/// API transport payload for the administrator catalog-correction endpoint.
///
/// This is deliberately kept at the API boundary. Library domain code must
/// not use it as a canonical catalog model; kind integrations translate the
/// transport payload into their concrete domain types.
final class AdminCatalogCorrection {
  const AdminCatalogCorrection({
    this.title,
    this.originalTitle,
    this.localizedTitle,
    this.sortKey,
    this.searchAliases,
    this.titleExtension,
    this.itemNumber,
    this.synopsis,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.genres,
    this.platforms,
    this.characters,
    this.storyArcs,
    this.creators,
    this.tracks,
    this.trailerUrls,
    this.externalLinks,
    this.editionTitle,
    this.pageCount,
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.publisher,
    this.releaseDate,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.catalogNumber,
    this.releaseStatus,
    this.physicalFormat,
    this.variantName,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.seriesTags,
  });

  final String? title;
  final String? originalTitle;
  final String? localizedTitle;
  final String? sortKey;
  final List<String>? searchAliases;
  final String? titleExtension;
  final String? itemNumber;
  final String? synopsis;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final List<String>? genres;
  final List<String>? platforms;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<JsonMap>? creators;
  final List<CatalogTrackDto>? tracks;
  final List<TrailerLinkDto>? trailerUrls;
  final List<TrailerLinkDto>? externalLinks;
  final String? editionTitle;
  final int? pageCount;
  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? publisher;
  final PartialDate? releaseDate;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? physicalFormat;
  final String? variantName;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String>? seriesTags;
}
