import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class VideoLibraryMediaPresentationBuilder
    extends DefaultLibraryMediaPresentationBuilder {
  const VideoLibraryMediaPresentationBuilder({
    super.showSummary,
    super.showSeasonHierarchy,
    super.showVolumeHierarchy,
  });

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryMediaFieldLabels labels,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final hasVolume = entry.volumeName != null || entry.volumeNumber != null;
    final hasSeason = entry.seasonNumber != null;
    final hasEpisode = entry.episodeNumber != null;
    return LibraryMetadataPresentation(
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (entry.seriesTitle != null)
          LibraryInspectorFactData(
            'Series',
            entry.seriesTitle!,
            onTap: tapFor(entry.seriesTitle),
          ),
        if (hasSeason && hasEpisode)
          LibraryInspectorFactData(
            'Season / Episode',
            'Season ${entry.seasonNumber}, Ep. ${entry.episodeNumber}',
          ),
        if (hasSeason && !hasEpisode)
          LibraryInspectorFactData('Season', 'Season ${entry.seasonNumber}'),
        if (!hasSeason && hasEpisode)
          LibraryInspectorFactData('Episode', 'Ep. ${entry.episodeNumber}'),
        if (hasVolume && !hasSeason)
          LibraryInspectorFactData(
            'Volume',
            entry.volumeName ?? 'Vol. ${entry.volumeNumber}',
          ),
        if (entry.variant != null)
          LibraryInspectorFactData(
            labels.variant,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.barcode != null)
          LibraryInspectorFactData(labels.barcode, entry.barcode!),
      ],
      contextFacts: [
        if (entry.publisher != null)
          LibraryInspectorFactData(
            labels.publisher,
            entry.publisher!,
            onTap: tapFor(entry.publisher),
          ),
        LibraryInspectorFactData(
          'Released',
          genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          ),
        ),
        if (entry.runtimeMinutes != null)
          LibraryInspectorFactData('Runtime', '${entry.runtimeMinutes} min'),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
        if (entry.subtitle != null)
          LibraryInspectorFactData('Subtitle', entry.subtitle!),
        LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }
}