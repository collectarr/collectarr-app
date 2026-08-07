import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/video/release/video_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';

class VideoLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const VideoLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final catalogItem = item.source.catalogItem;
    final series = catalogItem?.series;
    final video = catalogItem?.video;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ??
                  libraryVolumeLabel(series.volumeNumber != null
                      ? double.tryParse(series.volumeNumber!)
                      : null)),
        if (hasSeason && hasEpisode)
          LibraryDetailField(
              label: 'Season / Episode',
              value:
                  'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}'),
        if (hasSeason && !hasEpisode)
          LibraryDetailField(
              label: 'Season', value: 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryDetailField(
              label: 'Episode', value: 'Ep. ${series!.episodeNumber}'),
        LibraryDetailField(
            label: mediaFields.numberLabel,
            value: genericLibraryDash(dto.itemNumber),
            onTap: tapFor(dto.itemNumber)),
        LibraryDetailField(
            label: releaseFields.variantLabel,
            value: genericLibraryDash(dto.variant),
            onTap: tapFor(dto.variant)),
        LibraryDetailField(
            label: releaseFields.barcodeLabel,
            value: genericLibraryDash(dto.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: mediaFields.publisherLabel,
            value: genericLibraryDash(dto.publisher),
            onTap: tapFor(dto.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(dto.releaseDate) ??
                  dto.releaseDate?.year.toString(),
            )),
        if (video?.runtimeMinutes != null)
          LibraryDetailField(
              label: 'Runtime', value: '${video!.runtimeMinutes} min'),
        if (video?.screenRatio != null)
          LibraryDetailField(label: 'Aspect Ratio', value: video!.screenRatio!),
        if (video?.audioTracks != null)
          LibraryDetailField(label: 'Audio', value: video!.audioTracks!),
        if (video?.subtitles != null)
          LibraryDetailField(label: 'Subtitles', value: video!.subtitles!),
        if (dto.country != null)
          LibraryDetailField(
              label: 'Country',
              value: dto.country!,
              onTap: tapFor(dto.country)),
        if (dto.language != null)
          LibraryDetailField(
              label: 'Language',
              value: dto.language!,
              onTap: tapFor(dto.language)),
        if (catalogItem?.ageRating != null)
          LibraryDetailField(
              label: 'Age Rating',
              value: catalogItem!.ageRating!,
              onTap: tapFor(catalogItem.ageRating)),
        if (catalogItem?.audienceRating != null)
          LibraryDetailField(
              label: 'Audience Rating',
              value: catalogItem!.audienceRating!,
              onTap: tapFor(catalogItem.audienceRating)),
        LibraryDetailField(
            label: 'Cover',
            value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value: dto.publisher == null || dto.publisher!.isEmpty
                ? 'Missing'
                : 'Ready'),
      ],
      creators: catalogItem?.creators ?? const <Map<String, dynamic>>[],
      characters: catalogItem?.characters ?? const <String>[],
      storyArcs: catalogItem?.storyArcs ?? const <String>[],
      genres: catalogItem?.genres ?? const <String>[],
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final synopsis = item.source.catalogItem?.synopsis;
    if (!showSummary || synopsis == null || synopsis.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          Text(
            synopsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ];
  }

  @override
  bool canOpenKindDrilldown(LibraryProjectionRuntime item) {
    return canOpenVideoShelfDrilldown(null, item);
  }

  @override
  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionRuntime selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> ownedCopies,
    required List<WishlistItem> wishlistItems,
    required String? selectedReleaseId,
    required void Function(String releaseId) onSelectRelease,
    required LibraryWorkspaceProjector projector,
  }) {
    final drilldownItems = buildVideoShelfReleaseItems(
      titleItem: selectedItem,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
      projector: projector,
    );
    return VideoShelfReleaseDrilldown(
      titleItem: selectedItem,
      items: drilldownItems,
      selectedReleaseId: selectedReleaseId,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
      onSelectRelease: onSelectRelease,
    );
  }
}
