import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class GameLibraryKindProviderMapper extends CommonLibraryKindProviderMapper {
  const GameLibraryKindProviderMapper();

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
          series: preview.series,
          publishing: preview.publishing,
          game: preview.game,
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
    if (!sameStringList(edited.game?.platforms, preview.game?.platforms)) {
      corrections['platforms'] = edited.game?.platforms;
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
    if (!sameStringList(edited.genres, preview.genres)) {
      corrections['genres'] = edited.genres;
    }
    return corrections;
  }
}
