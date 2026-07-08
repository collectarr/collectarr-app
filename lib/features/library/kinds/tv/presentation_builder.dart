import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/shared/video_library_media_presentation_builder.dart';

const tvMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Series identity',
  contextSectionTitle: 'Broadcast context',
  creditsSectionTitle: 'Cast & Crew',
  creators: 'Cast & Crew',
);

class TvLibraryMediaPresentationBuilder
    extends VideoLibraryMediaPresentationBuilder {
  const TvLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: tvMetadataLabels,
        );
}
