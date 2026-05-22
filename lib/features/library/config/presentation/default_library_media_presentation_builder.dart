import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/seasons_section.dart';
import 'package:collectarr_app/features/library/volumes_section.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class DefaultLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const DefaultLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.showSeasonHierarchy = false,
    this.showVolumeHierarchy = false,
  });

  final bool showSummary;
  final bool showSeasonHierarchy;
  final bool showVolumeHierarchy;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryMediaFieldLabels labels,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final series = entry.series;
    final publishing = entry.publishing;
    final music = entry.music;
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
        if (hasVolume && !hasSeason)
          LibraryInspectorFactData(
            'Volume',
            series!.volumeName ?? 'Vol. ${series.volumeNumber}',
          ),
        if (hasSeason && hasEpisode)
          LibraryInspectorFactData(
            'Season / Episode',
            'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}',
          ),
        if (hasSeason && !hasEpisode)
          LibraryInspectorFactData('Season', 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryInspectorFactData('Episode', 'Ep. ${series!.episodeNumber}'),
        LibraryInspectorFactData(
          labels.number,
          genericLibraryDash(entry.itemNumber),
          onTap: tapFor(entry.itemNumber),
        ),
        LibraryInspectorFactData(
          labels.variant,
          genericLibraryDash(entry.variant),
          onTap: tapFor(entry.variant),
        ),
        LibraryInspectorFactData(
          labels.barcode,
          genericLibraryDash(entry.barcode),
        ),
      ],
      contextFacts: [
        LibraryInspectorFactData(
          labels.publisher,
          genericLibraryDash(entry.publisher),
          onTap: tapFor(entry.publisher),
        ),
        LibraryInspectorFactData(
          'Released',
          genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          ),
        ),
        if (publishing?.pageCount != null)
          LibraryInspectorFactData('Pages', publishing!.pageCount.toString()),
        if (music?.catalogNumber != null)
          LibraryInspectorFactData('Catalog No.', music!.catalogNumber!),
        if (publishing?.coverPriceCents != null)
          LibraryInspectorFactData(
            'Cover Price',
            formatPresentationMoney(
              publishing!.coverPriceCents,
              publishing.currency,
            ),
          ),
        if (publishing?.imprint != null)
          LibraryInspectorFactData(
            'Imprint',
            publishing!.imprint!,
            onTap: tapFor(publishing.imprint),
          ),
        if (publishing?.seriesGroup != null)
          LibraryInspectorFactData(
            'Series Group',
            publishing!.seriesGroup!,
            onTap: tapFor(publishing.seriesGroup),
          ),
        if (publishing?.subtitle != null)
          LibraryInspectorFactData('Subtitle', publishing!.subtitle!),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (music?.releaseStatus != null)
          LibraryInspectorFactData('Release Status', music!.releaseStatus!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
        if (entry.game?.platforms case final platforms? when platforms.isNotEmpty)
          LibraryInspectorFactData('Platforms', platforms.join(', ')),
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

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryWorkspaceEntry entry,
    required Color accent,
  }) {
    final sections = <Widget>[];
    if (showSeasonHierarchy) {
      sections.add(SeasonsSection(itemId: entry.id));
    } else if (showVolumeHierarchy) {
      sections.add(VolumesSection(itemId: entry.id));
    }
    if (showSummary && entry.synopsis != null && entry.synopsis!.trim().isNotEmpty) {
      sections.add(
        LibraryInspectorSection(
          title: 'Summary',
          accentColor: accent,
          children: [
            Text(
              entry.synopsis!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return sections;
  }
}