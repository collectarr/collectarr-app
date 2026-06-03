import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class GenericLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GenericLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

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
    final music = entry.music;
    final referenceRelease = resolveLibraryEntryReferenceRelease(entry);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(entry);
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
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
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (music?.releaseStatus != null)
          LibraryInspectorFactData('Release Status', music!.releaseStatus!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
        if (entry.audienceRating != null)
          LibraryInspectorFactData('Audience Rating', entry.audienceRating!),
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
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }
}