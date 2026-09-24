import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';

ComicMediaFormValues comicMediaFormValuesFrom(ComicMedia media) =>
    ComicMediaFormValues(
      seriesTitle:
          media.seriesTitle ?? media.series?.seriesTitle ?? media.title,
      seriesId: media.series?.seriesId,
      issueNumber: media.issueNumber ?? '',
      variant: media.variant ?? '',
      editionTitle: media.editionTitle ?? '',
      barcode: media.barcode ?? '',
      physicalFormatLabel: media.physicalFormatLabel ?? '',
      coverDate: media.coverDate,
      releaseDate: media.releaseDate,
      publisher: media.publisher ?? media.publishing?.originalPublisher ?? '',
      imprint: media.imprint ?? media.publishing?.imprint ?? '',
      seriesGroup: media.publishing?.seriesGroup ?? '',
      pageCount: media.pageCount ?? media.publishing?.pageCount,
      ageRating: media.ageRating ?? '',
      genres: List<String>.of(media.genres),
      language: media.language,
      country: media.country,
      crossover: media.crossover ?? '',
      storyArcs: List<String>.of(media.storyArcs),
      coverImageUrl: media.coverImageUrl ?? '',
    );

ComicMedia comicMediaFromFormValues({
  required ComicMedia original,
  required ComicMediaFormValues values,
}) {
  final seriesTitle = _nullable(values.seriesTitle);
  final oldSeries = original.series;
  final seriesId = _nullable(values.seriesId ?? '') ?? oldSeries?.seriesId;
  final series = oldSeries == null && seriesTitle == null && seriesId == null
      ? null
      : CatalogSeriesDetailsDto(
          seriesId: seriesId,
          seriesTitle: seriesTitle,
          volumeName: oldSeries?.volumeName,
          volumeNumber: oldSeries?.volumeNumber,
          volumeStartYear: oldSeries?.volumeStartYear,
          seasonNumber: oldSeries?.seasonNumber,
          episodeNumber: oldSeries?.episodeNumber,
          tags: oldSeries?.tags,
        );
  final oldPublishing = original.publishing;
  final publisher = _nullable(values.publisher);
  final imprint = _nullable(values.imprint);
  final seriesGroup = _nullable(values.seriesGroup);
  final publishing = oldPublishing == null &&
          publisher == null &&
          imprint == null &&
          seriesGroup == null &&
          values.pageCount == null
      ? null
      : CatalogPublishingDetailsDto(
          pageCount: values.pageCount,
          coverPriceCents: oldPublishing?.coverPriceCents,
          currency: oldPublishing?.currency,
          imprint: imprint,
          subtitle: oldPublishing?.subtitle,
          seriesGroup: seriesGroup,
          publicationPlace: oldPublishing?.publicationPlace,
          originalCountry: oldPublishing?.originalCountry,
          originalLanguage: oldPublishing?.originalLanguage,
          originalPublicationDate: oldPublishing?.originalPublicationDate,
          originalPublicationDateParts:
              oldPublishing?.originalPublicationDateParts,
          originalPublicationPlace: oldPublishing?.originalPublicationPlace,
          originalPublisher: publisher,
          paperType: oldPublishing?.paperType,
          printedBy: oldPublishing?.printedBy,
          subjects: oldPublishing?.subjects ?? const [],
          dustJacketCondition: oldPublishing?.dustJacketCondition,
          dustJacket: oldPublishing?.dustJacket,
          audiobookAbridged: oldPublishing?.audiobookAbridged,
          firstEdition: oldPublishing?.firstEdition,
          dewey: oldPublishing?.dewey,
        );

  return ComicMedia(
    id: original.id,
    title: seriesTitle ?? original.title,
    sortTitle: original.sortTitle,
    seriesTitle: seriesTitle,
    issueNumber: _nullable(values.issueNumber),
    publisher: publisher,
    imprint: imprint,
    releaseDate: values.releaseDate,
    coverDate: values.coverDate,
    pageCount: values.pageCount,
    country: _nullable(values.country) ?? original.country,
    language: _nullable(values.language) ?? original.language,
    ageRating: _nullable(values.ageRating),
    crossover: _nullable(values.crossover),
    genres: List<String>.unmodifiable(values.genres),
    searchAliases: original.searchAliases,
    synopsis: original.synopsis,
    writers: original.writers,
    artists: original.artists,
    inkers: original.inkers,
    colorists: original.colorists,
    letterers: original.letterers,
    editors: original.editors,
    coverArtists: original.coverArtists,
    creatorCredits: original.creatorCredits,
    characters: original.characters,
    characterDetails: original.characterDetails,
    creators: original.creators,
    storyArcs: List<String>.unmodifiable(values.storyArcs),
    keyEvents: original.keyEvents,
    isKeyComic: original.isKeyComic,
    keyReason: original.keyReason,
    variant: _nullable(values.variant),
    variantDescription: original.variantDescription,
    barcode: _nullable(values.barcode),
    series: series?.hasData == true ? series : null,
    publishing: publishing?.hasData == true ? publishing : null,
    editionTitle: _nullable(values.editionTitle),
    titleExtension: original.titleExtension,
    physicalFormat: original.physicalFormat,
    physicalFormatLabel: _nullable(values.physicalFormatLabel),
    links: original.links,
    releases: original.releases,
    rawPayload: {
      ..._withoutKeys(original.rawPayload, const {
        'title',
        'series_title',
        'issue_number',
        'item_number',
        'publisher',
        'imprint',
        'release_date',
        'cover_date',
        'page_count',
        'country',
        'language',
        'age_rating',
        'crossover',
        'genres',
        'story_arcs',
        'variant',
        'barcode',
        'series',
        'publishing',
        'series_group',
        'edition_title',
        'physical_format_label',
        'cover_image_url',
      }),
      'cover_image_url': _nullable(values.coverImageUrl),
    },
  );
}

ComicReleaseFormValues comicReleaseFormValuesFrom(ComicRelease release) =>
    ComicReleaseFormValues(
      id: release.id,
      title: release.title,
      publisher: release.publisher ?? '',
      imprint: release.imprint ?? '',
      isbn: release.isbn ?? '',
      upc: release.upc ?? '',
      releaseDate: release.releaseDate,
      coverImageUrl: release.coverImageUrl ?? '',
    );

ComicRelease comicReleaseFromFormValues({
  required ComicRelease original,
  required ComicReleaseFormValues values,
}) =>
    ComicRelease(
      id: original.id,
      title: values.title.trim(),
      publisher: _nullable(values.publisher),
      imprint: _nullable(values.imprint),
      isbn: _nullable(values.isbn),
      upc: _nullable(values.upc),
      releaseDate: values.releaseDate,
      coverImageUrl: _nullable(values.coverImageUrl),
      variants: List.unmodifiable(original.variants),
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> source,
  Set<String> keys,
) =>
    {
      for (final entry in source.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };
