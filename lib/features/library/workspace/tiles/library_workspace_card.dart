import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryDateFormatter = String Function(DateTime value);
typedef LibraryMoneyFormatter = String Function(int? cents, String? currency);

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

  @override
  Widget build(BuildContext context) {
    final metadataPresentation = _metadataPresentationForEntry(entry);
    final palette = appPalette(context);
    final resolvedSelectedColor = selectedColor == kAppSelection
        ? palette.selection
        : selectedColor;
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
    return RepaintBoundary(
      child: AnimatedContainer(
      duration: kAppAnimFast,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? resolvedSelectedColor : palette.cardBackground,
        border: Border.all(
          color: selected ? accentColor : palette.cardBorder,
          width: selected ? 2 : 1,
        ),
        borderRadius: kAppRadiusSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Padding(
            padding: const EdgeInsets.all(8),
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
                          notesLabel: libraryNotesMarkerLabel(entry.notes),
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
                            _LibraryIssuePill(label: '#${entry.itemNumber}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (entry.browseScope != LibraryBrowserScope.title &&
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: resolvedMutedTextColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (referenceHierarchy.length > 1) ...[
                        Text(
                          referenceHierarchy.join('  ->  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: accentColor.withValues(alpha: 0.88),
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
                              label: 'Scope: ${entry.referenceScopeLabel!}',
                              accentColor: accentColor,
                            ),
                          if (entry.browseScope != LibraryBrowserScope.title &&
                              entry.referenceFormatLabel != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.album_outlined,
                              label: 'Format: ${entry.referenceFormatLabel!}',
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
                          if (_metadataFactValue(metadataPresentation, 'Runtime')
                              case final runtime?)
                            _LibraryCompactMetaPill(
                              icon: Icons.schedule,
                              label: runtime,
                              accentColor: accentColor,
                            ),
                          if (_metadataFactValue(metadataPresentation, 'Tracks')
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: appPalette(context).textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
