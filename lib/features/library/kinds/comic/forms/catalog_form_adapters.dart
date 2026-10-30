import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_story_arc.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_values.dart';

ComicCatalogItemFormValues comicCatalogItemFormValuesFrom(
  ComicCatalogItem media,
) =>
    ComicCatalogItemFormValues(
      title: media.title,
      description: media.description ?? '',
      seriesTitle: media.seriesTitle ?? '',
      seriesId: media.seriesId,
      issueNumber: media.issueNumber ?? '',
      variant: media.variant ?? '',
      subtitle: media.subtitle ?? '',
      variantDescription: media.variantDescription ?? '',
      barcode: media.barcode ?? '',
      physicalFormatLabel: media.physicalFormat ?? '',
      coverDate: media.coverDate,
      coverDateParts: media.coverDateParts,
      releaseDate: media.releaseDate,
      releaseDateParts: media.releaseDateParts,
      publisher: media.publisher ?? '',
      imprint: media.imprint ?? '',
      seriesGroup: media.seriesGroup ?? '',
      pageCount: media.pageCount,
      publicationAge: media.publicationAge ?? '',
      genres: List<String>.of(media.genres),
      language: media.language,
      country: media.country,
      crossover: media.crossover ?? '',
      storyArc: _firstStoryArc(media.storyArcs) ?? '',
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
    title: values.title.trim(),
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
    releaseDateParts: values.releaseDateParts,
    pageCount: values.pageCount,
    country: values.country.trim(),
    language: values.language.trim(),
    ageRating: original.ageRating,
    publicationAge: _nullable(values.publicationAge),
    audienceRating: original.audienceRating,
    crossover: _nullable(values.crossover),
    genres: List<String>.unmodifiable(values.genres),
    searchAliases: original.searchAliases,
    synopsis: original.synopsis,
    description: _nullable(values.description),
    subtitle: _nullable(values.subtitle),
    localizedTitle: original.localizedTitle,
    originalTitle: original.originalTitle,
    plotDescription: original.plotDescription,
    plotSummary: original.plotSummary,
    releaseStatus: original.releaseStatus,
    characters: characters ?? original.characters,
    creators: creators ?? original.creators,
    storyArcs: _replaceComicStoryArc(original.storyArcs, values.storyArc),
    keyEvents: original.keyEvents,
    isKeyComic: original.isKeyComic,
    keyReason: original.keyReason,
    variant: _nullable(values.variant),
    variantDescription: _nullable(values.variantDescription),
    barcode: _nullable(values.barcode),
    catalogNumber: original.catalogNumber,
    coverPriceCents: original.coverPriceCents,
    currency: original.currency,
    coverImageUrl: _nullable(values.coverImageUrl),
    thumbnailImageUrl: original.thumbnailImageUrl,
    editionTitle: original.editionTitle,
    titleExtension: original.titleExtension,
    physicalFormat: _nullable(values.physicalFormatLabel),
    identifiers: original.identifiers,
    links: externalLinks ?? original.links,
  );
}

String? _firstStoryArc(List<ComicStoryArc> arcs) {
  for (final arc in arcs) {
    final name = arc.name?.trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return null;
}

/// CLZ edits one Story Arc; Core may list more, which an unchanged arc keeps.
List<ComicStoryArc> _replaceComicStoryArc(
  List<ComicStoryArc> original,
  String value,
) {
  final name = value.trim();
  if (name == (_firstStoryArc(original) ?? '')) return original;
  if (name.isEmpty) return const [];
  for (final arc in original) {
    if (arc.name?.trim().toLowerCase() == name.toLowerCase()) {
      return [arc.copyWith(name: name)];
    }
  }
  return [ComicStoryArc(name: name)];
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
