import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class ComicLibraryKindProviderMapper extends CommonLibraryKindProviderMapper {
  const ComicLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return super.metadataItemFromPreview(preview).copyWith(
          itemNumber: preview.itemNumber,
          publisher: preview.publisher,
          editionTitle: preview.editionTitle,
          physicalFormat: preview.physicalFormat,
          physicalFormatLabel: preview.physicalFormatLabel,
          releaseYear:
              preview.releaseDate?.year ?? preview.series?.volumeStartYear,
          variant: preview.variantName,
          series: preview.series,
          publishing: preview.publishing,
          country: preview.country,
          language: preview.language,
          ageRating: preview.ageRating,
          audienceRating: preview.audienceRating,
          creators: [
            for (final creator in preview.creators)
              {
                'name': creator.name,
                if (creator.role != null) 'role': creator.role,
                if (creator.imageUrl != null) 'image_url': creator.imageUrl,
              },
          ],
          characters: preview.characters,
          storyArcs: preview.storyArcs,
          genres: preview.genres,
        );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) {
    final corrections = super.buildCorrections(
      preview: preview,
      edited: edited,
    );
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
    }
    if (edited.editionTitle != preview.editionTitle) {
      corrections['edition_title'] = edited.editionTitle;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
    }
    if (edited.physicalFormatLabel != preview.physicalFormatLabel) {
      corrections['physical_format_label'] = edited.physicalFormatLabel;
    }
    if (edited.variant != preview.variant) {
      corrections['variant_name'] = edited.variant;
    }
    if (edited.series?.seriesId != preview.series?.seriesId) {
      corrections['series_id'] = edited.series?.seriesId;
    }
    if (edited.series?.seriesTitle != preview.series?.seriesTitle) {
      corrections['series_title'] = edited.series?.seriesTitle;
    }
    if (edited.series?.volumeName != preview.series?.volumeName) {
      corrections['volume_name'] = edited.series?.volumeName;
    }
    if (edited.series?.volumeNumber != preview.series?.volumeNumber) {
      corrections['volume_number'] = edited.series?.volumeNumber;
    }
    if (edited.series?.volumeStartYear != preview.series?.volumeStartYear) {
      corrections['volume_start_year'] = edited.series?.volumeStartYear;
    }
    if (edited.series?.seasonNumber != preview.series?.seasonNumber) {
      corrections['season_number'] = edited.series?.seasonNumber;
    }
    if (edited.series?.episodeNumber != preview.series?.episodeNumber) {
      corrections['episode_number'] = edited.series?.episodeNumber;
    }
    if (!sameStringList(edited.series?.tags, preview.series?.tags)) {
      corrections['tags'] = edited.series?.tags;
    }
    if (edited.publishing?.pageCount != preview.publishing?.pageCount) {
      corrections['page_count'] = edited.publishing?.pageCount;
    }
    if (edited.publishing?.coverPriceCents !=
        preview.publishing?.coverPriceCents) {
      corrections['cover_price_cents'] = edited.publishing?.coverPriceCents;
    }
    if (edited.publishing?.currency != preview.publishing?.currency) {
      corrections['currency'] = edited.publishing?.currency;
    }
    if (edited.publishing?.imprint != preview.publishing?.imprint) {
      corrections['imprint'] = edited.publishing?.imprint;
    }
    if (edited.publishing?.subtitle != preview.publishing?.subtitle) {
      corrections['subtitle'] = edited.publishing?.subtitle;
    }
    if (edited.publishing?.seriesGroup != preview.publishing?.seriesGroup) {
      corrections['series_group'] = edited.publishing?.seriesGroup;
    }
    if (edited.country != preview.country) {
      corrections['country'] = edited.country;
    }
    if (edited.language != preview.language) {
      corrections['language'] = edited.language;
    }
    if (edited.ageRating != preview.ageRating) {
      corrections['age_rating'] = edited.ageRating;
    }
    if (edited.audienceRating != preview.audienceRating) {
      corrections['audience_rating'] = edited.audienceRating;
    }
    if (!sameCreators(edited.creators, preview.creators)) {
      corrections['creators'] = edited.creators;
    }
    if (!sameStringList(edited.characters, preview.characters)) {
      corrections['characters'] = edited.characters;
    }
    if (!sameStringList(edited.storyArcs, preview.storyArcs)) {
      corrections['story_arcs'] = edited.storyArcs;
    }
    if (!sameStringList(edited.genres, preview.genres)) {
      corrections['genres'] = edited.genres;
    }
    return corrections;
  }
}
