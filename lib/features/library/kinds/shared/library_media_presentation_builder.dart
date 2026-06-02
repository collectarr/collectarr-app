import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/seasons_section.dart';
import 'package:collectarr_app/features/library/volumes_section.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class SharedLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const SharedLibraryMediaPresentationBuilder({
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
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final metadata = entry.metadata;
    final series = entry.series;
    final publishing = entry.publishing;
    final music = entry.music;
    final referenceRelease = resolveLibraryEntryReferenceRelease(entry);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(entry);
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
          mediaFields.numberLabel,
          genericLibraryDash(entry.itemNumber),
          onTap: tapFor(entry.itemNumber),
        ),
        LibraryInspectorFactData(
          releaseFields.variantLabel,
          genericLibraryDash(entry.variant),
          onTap: tapFor(entry.variant),
        ),
        LibraryInspectorFactData(
          releaseFields.barcodeLabel,
          genericLibraryDash(entry.barcode),
        ),
      ],
      contextFacts: [
        LibraryInspectorFactData(
          mediaFields.publisherLabel,
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
        if (metadata.country != null)
          LibraryInspectorFactData('Country', metadata.country!),
        if (music?.releaseStatus != null)
          LibraryInspectorFactData('Release Status', music!.releaseStatus!),
        if (metadata.language != null)
          LibraryInspectorFactData('Language', metadata.language!),
        if (metadata.ageRating != null)
          LibraryInspectorFactData('Age Rating', metadata.ageRating!),
        if (metadata.audienceRating != null)
          LibraryInspectorFactData('Audience Rating', metadata.audienceRating!),
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryInspectorFactData('Variant Type', variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryInspectorFactData('SKU', sku.trim()),
        if (referencePlatforms.isNotEmpty)
          LibraryInspectorFactData(
            referencePlatforms.length == 1 ? 'Platform' : 'Platforms',
            referencePlatforms.join(', '),
          ),
        LibraryInspectorFactData(
          'Cover',
          entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: metadata.creators ?? const <Map<String, dynamic>>[],
      characters: metadata.characters ?? const <String>[],
      storyArcs: metadata.storyArcs ?? const <String>[],
      genres: metadata.genres ?? const <String>[],
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryWorkspaceEntry entry,
    required Color accent,
  }) {
    final sections = <Widget>[];
    final resolvedItemId = entry.titleItemId ?? entry.id;
    if (showSeasonHierarchy) {
      sections.add(SeasonsSection(itemId: resolvedItemId));
    } else if (showVolumeHierarchy) {
      sections.add(VolumesSection(itemId: resolvedItemId));
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