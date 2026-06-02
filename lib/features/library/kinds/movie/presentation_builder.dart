import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/shared/library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class VideoLibraryMediaPresentationBuilder
  extends SharedLibraryMediaPresentationBuilder {
  const VideoLibraryMediaPresentationBuilder({
    super.showSummary,
    super.showSeasonHierarchy,
    super.showVolumeHierarchy,
  });

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final series = entry.series;
    final publishing = entry.publishing;
    final video = entry.video;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (series?.seriesTitle != null)
          LibraryInspectorFactData(
            'Series',
            series!.seriesTitle!,
            onTap: tapFor(series.seriesTitle),
          ),
        if (hasSeason && hasEpisode)
          LibraryInspectorFactData(
            'Season / Episode',
            'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}',
          ),
        if (hasSeason && !hasEpisode)
          LibraryInspectorFactData('Season', 'Season ${series!.seasonNumber}'),
        if (!hasSeason && hasEpisode)
          LibraryInspectorFactData('Episode', 'Ep. ${series!.episodeNumber}'),
        if (hasVolume && !hasSeason)
          LibraryInspectorFactData(
            'Volume',
            series!.volumeName ?? 'Vol. ${series.volumeNumber}',
          ),
        if (entry.browseScope != LibraryBrowserScope.title &&
            entry.variant != null)
          LibraryInspectorFactData(
            releaseFields.variantLabel,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.browseScope != LibraryBrowserScope.title &&
            entry.barcode != null)
          LibraryInspectorFactData(releaseFields.barcodeLabel, entry.barcode!),
      ],
      contextFacts: [
        if (entry.publisher != null)
          LibraryInspectorFactData(
            mediaFields.publisherLabel,
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
        if (video?.runtimeMinutes != null)
          LibraryInspectorFactData('Runtime', '${video!.runtimeMinutes} min'),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
        if (entry.audienceRating != null)
          LibraryInspectorFactData('Audience Rating', entry.audienceRating!),
        if (publishing?.subtitle != null)
          LibraryInspectorFactData('Subtitle', publishing!.subtitle!),
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
