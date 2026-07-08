import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class MovieLibraryKindProviderMapper extends CommonLibraryKindProviderMapper {
  const MovieLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return super.metadataItemFromPreview(preview).copyWith(
          video: preview.video,
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
    if (edited.video?.runtimeMinutes != preview.video?.runtimeMinutes) {
      corrections['runtime_minutes'] = edited.video?.runtimeMinutes;
    }
    if (edited.video?.color != preview.video?.color) {
      corrections['color'] = edited.video?.color;
    }
    if (edited.video?.nrDiscs != preview.video?.nrDiscs) {
      corrections['nr_discs'] = edited.video?.nrDiscs;
    }
    if (edited.video?.screenRatio != preview.video?.screenRatio) {
      corrections['screen_ratio'] = edited.video?.screenRatio;
    }
    if (edited.video?.audioTracks != preview.video?.audioTracks) {
      corrections['audio_tracks'] = edited.video?.audioTracks;
    }
    if (edited.video?.subtitles != preview.video?.subtitles) {
      corrections['subtitles'] = edited.video?.subtitles;
    }
    if (edited.video?.layers != preview.video?.layers) {
      corrections['layers'] = edited.video?.layers;
    }
    if (edited.video?.ageRating != preview.video?.ageRating) {
      corrections['age_rating'] = edited.video?.ageRating;
    }
    if (edited.video?.audienceRating != preview.video?.audienceRating) {
      corrections['audience_rating'] = edited.video?.audienceRating;
    }
    return corrections;
  }
}
