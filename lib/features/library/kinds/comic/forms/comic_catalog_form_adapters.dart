import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';

ComicCatalogItemFormValues comicCatalogItemFormValuesFrom(
  ComicCatalogItem media,
) =>
    ComicCatalogItemFormValues(
      title: media.title,
      seriesTitle: media.seriesTitle ?? '',
      seriesId: media.seriesId,
      issueNumber: media.issueNumber ?? '',
      variant: media.variant ?? '',
      editionTitle: media.editionTitle ?? '',
      barcode: media.barcode ?? '',
      isbn: media.isbn ?? '',
      upc: media.upc ?? '',
      physicalFormatLabel: media.physicalFormat ?? '',
      coverDate: media.coverDate,
      coverDateParts: media.coverDateParts,
      releaseDate: media.releaseDate,
      publisher: media.publisher ?? '',
      imprint: media.imprint ?? '',
      seriesGroup: media.seriesGroup ?? '',
      pageCount: media.pageCount,
      ageRating: media.ageRating ?? '',
      genres: List<String>.of(media.genres),
      language: media.language,
      country: media.country,
      crossover: media.crossover ?? '',
      storyArcs: [
        for (final arc in media.storyArcs)
          if (arc.name?.trim().isNotEmpty == true) arc.name!.trim(),
      ],
      coverImageUrl: media.coverImageUrl ?? '',
    );

ComicCatalogItem comicCatalogItemFromFormValues({
  required ComicCatalogItem original,
  required ComicCatalogItemFormValues values,
  List<ComicLink>? externalLinks,
  List<ComicCreator>? creators,
  List<ComicCharacter>? characters,
}) {
  final seriesTitle = _nullable(values.seriesTitle);
  final publisher = _nullable(values.publisher);
  final imprint = _nullable(values.imprint);
  final seriesGroup = _nullable(values.seriesGroup);

  return ComicCatalogItem(
    id: original.id,
    title: _nullable(values.title) ?? original.title,
    sortTitle: original.sortTitle,
    seriesTitle: seriesTitle,
    seriesId: _nullable(values.seriesId ?? ''),
    seriesGroup: seriesGroup,
    seriesTags: original.seriesTags,
    volumeName: original.volumeName,
    volumeNumber: original.volumeNumber,
    volumeStartYear: original.volumeStartYear,
    issueNumber: _nullable(values.issueNumber),
    publisher: publisher,
    imprint: imprint,
    releaseDate: values.releaseDate,
    coverDate: values.coverDate,
    coverDateParts: values.coverDateParts,
    releaseDateParts: original.releaseDateParts,
    pageCount: values.pageCount,
    country: _nullable(values.country) ?? original.country,
    language: _nullable(values.language) ?? original.language,
    ageRating: _nullable(values.ageRating),
    audienceRating: original.audienceRating,
    crossover: _nullable(values.crossover),
    genres: List<String>.unmodifiable(values.genres),
    searchAliases: original.searchAliases,
    synopsis: original.synopsis,
    description: original.description,
    subtitle: original.subtitle,
    localizedTitle: original.localizedTitle,
    originalTitle: original.originalTitle,
    plotDescription: original.plotDescription,
    plotSummary: original.plotSummary,
    releaseStatus: original.releaseStatus,
    contributors: original.contributors,
    characters: characters ?? original.characters,
    characterDetails: characters ?? original.characterDetails,
    creators: creators ?? original.creators,
    storyArcs: _replaceComicStoryArcs(original.storyArcs, values.storyArcs),
    keyEvents: original.keyEvents,
    isKeyComic: original.isKeyComic,
    keyReason: original.keyReason,
    variant: _nullable(values.variant),
    variantDescription: original.variantDescription,
    barcode: _nullable(values.barcode),
    catalogNumber: original.catalogNumber,
    coverPriceCents: original.coverPriceCents,
    currency: original.currency,
    coverImageUrl: _nullable(values.coverImageUrl),
    thumbnailImageUrl: original.thumbnailImageUrl,
    editionTitle: _nullable(values.editionTitle),
    titleExtension: original.titleExtension,
    physicalFormat: _nullable(values.physicalFormatLabel),
    identifiers: _replaceComicIdentifiers(
      original.identifiers,
      isbn: _nullable(values.isbn),
      upc: _nullable(values.upc),
    ),
    links: externalLinks ?? original.links,
  );
}

List<ComicIdentifier> _replaceComicIdentifiers(
  List<ComicIdentifier> original, {
  required String? isbn,
  required String? upc,
}) =>
    [
      for (final identifier in original)
        if (!{'isbn', 'upc'}.contains(identifier.identifierType.toLowerCase()))
          identifier,
      if (isbn != null) ComicIdentifier(identifierType: 'isbn', value: isbn),
      if (upc != null) ComicIdentifier(identifierType: 'upc', value: upc),
    ];

List<ComicStoryArc> _replaceComicStoryArcs(
  List<ComicStoryArc> original,
  List<String> values,
) {
  final existing = {
    for (final arc in original)
      if (arc.name?.trim().isNotEmpty == true)
        arc.name!.trim().toLowerCase(): arc,
  };
  return [
    for (final value in values)
      if (value.trim().isNotEmpty)
        (existing[value.trim().toLowerCase()] ?? const ComicStoryArc())
            .copyWith(name: value.trim()),
  ];
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
