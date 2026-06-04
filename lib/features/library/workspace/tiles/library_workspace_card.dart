import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryDateFormatter = String Function(DateTime value);
typedef LibraryMoneyFormatter = String Function(int? cents, String? currency);

enum LibraryMusicCardLayout { vertical, horizontal }

class LibraryWorkspaceCard extends StatelessWidget {
  const LibraryWorkspaceCard({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.dateFormatter,
    required this.moneyFormatter,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.mutedTextColor = kAppTextMuted,
    this.coverWidth = 72,
    this.musicLayout = LibraryMusicCardLayout.vertical,
    this.selectionMode = false,
    this.onSelectionToggleTap,
    super.key,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final LibraryDateFormatter dateFormatter;
  final LibraryMoneyFormatter moneyFormatter;
  final Color selectedColor;
  final Color accentColor;
  final Color mutedTextColor;
  final double coverWidth;
  final LibraryMusicCardLayout musicLayout;
  final bool selectionMode;
  final VoidCallback? onSelectionToggleTap;

  @override
  Widget build(BuildContext context) {
    final metadataPresentation = _metadataPresentationForEntry(entry);
    final palette = appPalette(context);
    final resolvedSelectedColor =
        selectedColor == kAppSelection ? palette.selection : selectedColor;
    final resolvedMutedTextColor =
        mutedTextColor == kAppTextMuted ? palette.textMuted : mutedTextColor;
    final selectedTitleColor = ThemeData.estimateBrightnessForColor(
              resolvedSelectedColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final referenceHierarchy = libraryReferenceHierarchySegments(
      mediaType: entry.mediaType,
      editions: entry.editions,
      editionId: entry.referenceEditionId,
      variantId: entry.referenceVariantId,
      bundleReleaseId: entry.referenceBundleReleaseId,
    );
    final comic = entry.comic;
    final strongSelection =
        selected && entry.browseScope != LibraryBrowserScope.title;
    if (entry.mediaType == 'music') {
      return _buildMusicCard(
        context: context,
        selectedTitleColor: selectedTitleColor,
        mutedColor: resolvedMutedTextColor,
      );
    }
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected ? resolvedSelectedColor : palette.cardBackground,
          border: Border.all(
            color: selected ? accentColor : palette.cardBorder,
            width: selected ? (strongSelection ? 3 : 2) : 1,
          ),
          borderRadius: kAppRadiusSmall,
          boxShadow: strongSelection
              ? [
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: palette.isDark ? 0.34 : 0.26,
                    ),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onSecondaryTapUp: onSecondaryTapUp,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
                  child: Row(
                    children: [
                      SizedBox(
                        width: coverWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SlabFrameOverlay.maybeWrap(
                              rawOrSlabbed: comic?.rawOrSlabbed,
                              gradingCompany: comic?.gradingCompany,
                              grade: entry.grade,
                              labelType: comic?.labelType,
                              child: LibraryInteractiveCover(
                                title: entry.resolvedTitle,
                                itemNumber: entry.itemNumber,
                                imageUrl: entry.displayCoverUrl,
                                ownedItemId: entry.ownedItemId,
                                accentColor: accentColor,
                                enableFullscreen: false,
                                enableSecondaryControl: false,
                              ),
                            ),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: LibraryCoverBadges(
                                isOwned: entry.isOwned,
                                isTracked: entry.isTracked,
                                isWishlisted: entry.isWishlisted,
                                hasMissingCover: entry.hasMissingCover,
                                hasMissingMetadata: entry.hasMissingMetadata,
                                keyLabel: libraryKeyMarkerLabel(
                                  comic?.keyComic ?? false,
                                  comic?.keyReason,
                                ),
                                slabLabel: librarySlabMarkerLabel(
                                  comic?.rawOrSlabbed,
                                  comic?.gradingCompany,
                                ),
                                notesLabel:
                                    libraryNotesMarkerLabel(entry.notes),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.resolvedTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: selected
                                              ? selectedTitleColor
                                              : (palette.isDark
                                                  ? kAppAccentLight
                                                  : accentColor),
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                if (entry.itemNumber != null)
                                  _LibraryIssuePill(
                                      label: '#${entry.itemNumber}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (entry.browseScope !=
                                        LibraryBrowserScope.title &&
                                    entry.variant != null &&
                                    entry.variant!.isNotEmpty)
                                  entry.variant,
                                if (entry.releaseDate != null)
                                  dateFormatter(entry.releaseDate!),
                                if (entry.publisher != null &&
                                    entry.publisher!.isNotEmpty)
                                  entry.publisher,
                              ].whereType<String>().join('  |  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: resolvedMutedTextColor,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (referenceHierarchy.length > 1) ...[
                              Text(
                                referenceHierarchy.join('  ->  '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          accentColor.withValues(alpha: 0.88),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (entry.referenceScopeLabel != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.link_outlined,
                                    label:
                                        'Scope: ${entry.referenceScopeLabel!}',
                                    accentColor: accentColor,
                                  ),
                                if (entry.browseScope !=
                                        LibraryBrowserScope.title &&
                                    entry.referenceFormatLabel != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.album_outlined,
                                    label:
                                        'Format: ${entry.referenceFormatLabel!}',
                                    accentColor: accentColor,
                                  ),
                                if (entry.grade != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.workspace_premium,
                                    label: entry.grade!,
                                    accentColor: accentColor,
                                  ),
                                if (entry.condition != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.fact_check_outlined,
                                    label: entry.condition!,
                                    accentColor: accentColor,
                                  ),
                                if (_metadataFactValue(
                                        metadataPresentation, 'Runtime')
                                    case final runtime?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.schedule,
                                    label: runtime,
                                    accentColor: accentColor,
                                  ),
                                if (_metadataFactValue(
                                        metadataPresentation, 'Tracks')
                                    case final trackCount?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.music_note,
                                    label: '$trackCount tracks',
                                    accentColor: accentColor,
                                  ),
                                if (_metadataFactValue(
                                  metadataPresentation,
                                  'Release Status',
                                )
                                    case final releaseStatus?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.album,
                                    label: releaseStatus,
                                    accentColor: accentColor,
                                  ),
                                if (_compactPlatformLabel(
                                  libraryReferencePlatforms(entry),
                                )
                                    case final platformLabel?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.sports_esports,
                                    label: platformLabel,
                                    accentColor: accentColor,
                                  ),
                                if (_compactNotesLabel(entry.notes)
                                    case final noteLabel?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.sticky_note_2_outlined,
                                    label: noteLabel,
                                    accentColor: accentColor,
                                  ),
                                if (comic?.keyComic == true)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.label_important,
                                    label: comic?.keyReason ?? 'Key item',
                                    accentColor: accentColor,
                                  ),
                                if (comic?.rawOrSlabbed != null ||
                                    comic?.gradingCompany != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.workspace_premium,
                                    label: librarySlabMarkerLabel(
                                          comic?.rawOrSlabbed,
                                          comic?.gradingCompany,
                                        ) ??
                                        'Collector copy',
                                    accentColor: accentColor,
                                  ),
                                if (entry.locationPath != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.inventory_2_outlined,
                                    label: entry.locationPath!,
                                    accentColor: accentColor,
                                  ),
                                if (entry.pricePaidCents != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.attach_money,
                                    label: moneyFormatter(
                                      entry.pricePaidCents,
                                      entry.currency,
                                    ),
                                    accentColor: accentColor,
                                  ),
                                if (entry.isWishlisted)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.star,
                                    label: 'Wishlist',
                                    accentColor: accentColor,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            if (entry.browseScope != LibraryBrowserScope.title)
                              Text(
                                entry.barcode == null || entry.barcode!.isEmpty
                                    ? 'No barcode'
                                    : entry.barcode!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: appPalette(context).textSecondary,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectionMode || selected)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: LibraryTileSelectionToggleButton(
                      onTap: onSelectionToggleTap,
                      child: LibraryTileSelectionToggle(
                        selected: selected,
                        accentColor: accentColor,
                        coverSize: coverWidth,
                      ),
                    ),
                  ),
                if (_scopeBadge(context, entry) case final badge?)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: badge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
  }) {
    return switch (musicLayout) {
      LibraryMusicCardLayout.horizontal => _buildMusicHorizontalCard(
          context: context,
          selectedTitleColor: selectedTitleColor,
          mutedColor: mutedColor,
        ),
      LibraryMusicCardLayout.vertical => _buildMusicVerticalCard(
          context: context,
          selectedTitleColor: selectedTitleColor,
          mutedColor: mutedColor,
        ),
    };
  }

  Widget _buildMusicHorizontalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
  }) {
    final palette = appPalette(context);
    final background = selected ? palette.selection : palette.cardBackground;
    final titleColor = selected ? selectedTitleColor : palette.textPrimary;
    final subtitleColor =
        selected ? selectedTitleColor.withValues(alpha: 0.9) : mutedColor;
    final supportColor = selected
        ? selectedTitleColor.withValues(alpha: 0.82)
        : palette.textSecondary;
    final artist = _musicArtist(entry);
    final year = entry.releaseYear?.toString() ?? '';
    final format = entry.referenceFormatLabel?.trim();
    final tracks = entry.music?.trackCount ??
        int.tryParse(_metadataFactValue(
                _metadataPresentationForEntry(entry), 'Tracks') ??
            '');
    final duration = _musicDuration(entry);
    final metaLine = [
      if (format != null && format.isNotEmpty) format,
      if (year.isNotEmpty) year
    ].join(' \u2013 ');
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        decoration: BoxDecoration(
          color: background,
          borderRadius: kAppRadiusSmall,
          border: Border.all(
            color: selected ? accentColor : palette.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.24),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onSecondaryTapUp: onSecondaryTapUp,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: coverWidth,
                        child: LibraryInteractiveCover(
                          title: entry.resolvedTitle,
                          itemNumber: entry.itemNumber,
                          imageUrl: entry.displayCoverUrl,
                          ownedItemId: entry.ownedItemId,
                          accentColor: accentColor,
                          fit: BoxFit.cover,
                          borderRadius: 2,
                          enableFullscreen: false,
                          enableSecondaryControl: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.resolvedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            if (artist != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                            const Spacer(),
                            if (metaLine.isNotEmpty)
                              Text(
                                metaLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: subtitleColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (tracks != null || duration != null) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (tracks != null)
                              Text(
                                '\u266b$tracks',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: supportColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            if (duration != null)
                              Text(
                                duration,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: supportColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (selectionMode || selected)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: LibraryTileSelectionToggleButton(
                      onTap: onSelectionToggleTap,
                      child: LibraryTileSelectionToggle(
                        selected: selected,
                        accentColor: accentColor,
                        coverSize: coverWidth,
                      ),
                    ),
                  ),
                if (_scopeBadge(context, entry) case final badge?)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: badge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicVerticalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
  }) {
    final palette = appPalette(context);
    final background = selected ? palette.selection : palette.cardBackground;
    final titleColor = selected ? selectedTitleColor : palette.textPrimary;
    final subtitleColor =
        selected ? selectedTitleColor.withValues(alpha: 0.9) : mutedColor;
    final artist = _musicArtist(entry);
    final year = entry.releaseYear?.toString() ?? '';
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background,
          borderRadius: kAppRadiusSmall,
          border: Border.all(
            color: selected ? accentColor : palette.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onSecondaryTapUp: onSecondaryTapUp,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LibraryInteractiveCover(
                          title: entry.resolvedTitle,
                          itemNumber: entry.itemNumber,
                          imageUrl: entry.displayCoverUrl,
                          ownedItemId: entry.ownedItemId,
                          accentColor: accentColor,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                          enableFullscreen: false,
                          enableSecondaryControl: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.resolvedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    artist ?? entry.resolvedTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: subtitleColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                if (year.isNotEmpty)
                                  Text(
                                    year,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: subtitleColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectionMode || selected)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: LibraryTileSelectionToggleButton(
                      onTap: onSelectionToggleTap,
                      child: LibraryTileSelectionToggle(
                        selected: selected,
                        accentColor: accentColor,
                        coverSize: coverWidth,
                      ),
                    ),
                  ),
                if (_scopeBadge(context, entry) case final badge?)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: badge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _musicArtist(LibraryWorkspaceEntry entry) {
    final creators = entry.creators ?? const <Map<String, dynamic>>[];
    String? fallbackName;
    for (final creator in creators) {
      final rawName =
          (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
      if (rawName.isEmpty) {
        continue;
      }
      fallbackName ??= rawName;
      final role =
          (creator['role'] ?? creator['type'] ?? '').toString().toLowerCase();
      if (role.contains('artist') ||
          role.contains('performer') ||
          role.contains('musician') ||
          role.contains('band')) {
        return rawName;
      }
    }
    final publisher = entry.publisher?.trim();
    if (publisher != null && publisher.isNotEmpty) {
      return publisher;
    }
    return fallbackName;
  }

  String? _musicDuration(LibraryWorkspaceEntry entry) {
    final runtimeFact =
        _metadataFactValue(_metadataPresentationForEntry(entry), 'Runtime');
    if (runtimeFact != null && runtimeFact.isNotEmpty) {
      return runtimeFact;
    }
    final totalSeconds = entry.music?.tracks.fold<int>(
      0,
      (sum, track) => sum + (track.durationSeconds ?? 0),
    );
    if (totalSeconds == null || totalSeconds <= 0) {
      return null;
    }
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _scopeBadge(BuildContext context, LibraryWorkspaceEntry entry) {
    final palette = appPalette(context);
    final scope = resolveLibraryCollectionStatusScope(entry);
    return LibraryTileScopePill(
      icon: scope.icon,
      label: scope.label,
      color: libraryCollectionStatusScopeColor(
        scope,
        accentColor,
        palette.textMuted,
      ),
    );
  }
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryWorkspaceEntry entry,
) {
  final type = collectarrLibraryTypes.byKind(entry.mediaType);
  if (type == null) {
    return null;
  }
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation? presentation,
  String label,
) {
  if (presentation == null) {
    return null;
  }
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}

String? _compactPlatformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final first = platforms.first.trim();
  if (first.isEmpty) {
    return null;
  }
  final extra =
      platforms.skip(1).where((value) => value.trim().isNotEmpty).length;
  return extra == 0 ? first : '$first +$extra';
}

String? _compactNotesLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= 28) {
    return trimmed;
  }
  return '${trimmed.substring(0, 27)}...';
}

class _LibraryIssuePill extends StatelessWidget {
  const _LibraryIssuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppHighlight,
        borderRadius: kAppRadiusSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            color: appPalette(context).textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LibraryCompactMetaPill extends StatelessWidget {
  const _LibraryCompactMetaPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.tableBottomBorder,
        borderRadius: kAppRadiusSmall,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: accentColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
