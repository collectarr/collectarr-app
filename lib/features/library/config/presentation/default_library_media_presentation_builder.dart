import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
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
        if (hasVolume && !hasSeason)
          LibraryInspectorFactData(
            'Volume',
            entry.volumeName ?? 'Vol. ${entry.volumeNumber}',
          ),
        if (hasSeason && hasEpisode)
          LibraryInspectorFactData(
            'Season / Episode',
            'Season ${entry.seasonNumber}, Ep. ${entry.episodeNumber}',
          ),
        if (hasSeason && !hasEpisode)
          LibraryInspectorFactData('Season', 'Season ${entry.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryInspectorFactData('Episode', 'Ep. ${entry.episodeNumber}'),
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
        if (entry.pageCount != null)
          LibraryInspectorFactData('Pages', entry.pageCount.toString()),
        if (entry.catalogNumber != null)
          LibraryInspectorFactData('Catalog No.', entry.catalogNumber!),
        if (entry.coverPriceCents != null)
          LibraryInspectorFactData(
            'Cover Price',
            formatPresentationMoney(entry.coverPriceCents, entry.catalogCurrency),
          ),
        if (entry.imprint != null)
          LibraryInspectorFactData(
            'Imprint',
            entry.imprint!,
            onTap: tapFor(entry.imprint),
          ),
        if (entry.seriesGroup != null)
          LibraryInspectorFactData(
            'Series Group',
            entry.seriesGroup!,
            onTap: tapFor(entry.seriesGroup),
          ),
        if (entry.subtitle != null)
          LibraryInspectorFactData('Subtitle', entry.subtitle!),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (entry.releaseStatus != null)
          LibraryInspectorFactData('Release Status', entry.releaseStatus!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
        if (entry.platforms != null && entry.platforms!.isNotEmpty)
          LibraryInspectorFactData('Platforms', entry.platforms!.join(', ')),
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