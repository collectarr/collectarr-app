import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A tall card showing a large cover beside rich metadata, used in "card flow"
/// mode. Intended for a single- or two-column vertical feed layout.
class LibraryCardFlowTile extends StatelessWidget {
  const LibraryCardFlowTile({
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

  @override
  Widget build(BuildContext context) {
    final capabilities = collectarrLibraryTypes.capabilitiesForKind(
      entry.mediaType,
    );
    final metadataPresentation = _metadataPresentationForEntry(entry);
    final theme = Theme.of(context);
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
        : theme.colorScheme.onSurface;
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
        borderRadius: kAppRadiusMedium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Large cover ──
                SizedBox(
                  width: 120,
                  height: 184,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
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
                const SizedBox(width: 12),
                // ── Metadata ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + issue
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.resolvedTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? selectedTitleColor
                                    : kAppAccentLight,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (entry.itemNumber != null) ...[
                            const SizedBox(width: 6),
                            _IssuePill(label: '#${entry.itemNumber}'),
                          ],
                        ],
                      ),
                      // Series / subtitle
                      if (_seriesSummary(metadataPresentation, entry)
                          case final seriesTitle?) ...[
                        const SizedBox(height: 4),
                        Text(
                          seriesTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Variant | date | publisher
                      Text(
                        [
                          if (entry.browseScope != LibraryBrowserScope.title &&
                              entry.variant != null &&
                              entry.variant!.isNotEmpty)
                            entry.variant,
                          if (entry.releaseDate != null)
                            dateFormatter(entry.releaseDate!)
                          else if (entry.releaseYear != null)
                            entry.releaseYear.toString(),
                          if (entry.publisher != null &&
                              entry.publisher!.isNotEmpty)
                            entry.publisher,
                        ].whereType<String>().join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: resolvedMutedTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (referenceHierarchy.length > 1) ...[
                        Text(
                          referenceHierarchy.join('  ->  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentColor.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Meta pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (entry.referenceScopeLabel != null)
                            _MetaPill(
                              icon: Icons.link_outlined,
                              label: 'Scope: ${entry.referenceScopeLabel!}',
                              accentColor: accentColor,
                            ),
                          if (entry.referenceFormatLabel != null)
                            _MetaPill(
                              icon: Icons.album_outlined,
                              label: 'Format: ${entry.referenceFormatLabel!}',
                              accentColor: accentColor,
                            ),
                          if (entry.grade != null)
                            _MetaPill(
                              icon: Icons.workspace_premium,
                              label: entry.grade!,
                              accentColor: accentColor,
                            ),
                          if (entry.condition != null)
                            _MetaPill(
                              icon: Icons.fact_check_outlined,
                              label: entry.condition!,
                              accentColor: accentColor,
                            ),
                          if (_metadataFactValue(metadataPresentation, 'Runtime')
                              case final runtime?)
                            _MetaPill(
                              icon: Icons.schedule,
                              label: runtime,
                              accentColor: accentColor,
                            ),
                          if (comic?.keyComic == true)
                            _MetaPill(
                              icon: Icons.label_important,
                              label: comic?.keyReason ?? 'Key item',
                              accentColor: accentColor,
                            ),
                          if (comic?.rawOrSlabbed != null ||
                              comic?.gradingCompany != null)
                            _MetaPill(
                              icon: Icons.workspace_premium,
                              label: librarySlabMarkerLabel(
                                    comic?.rawOrSlabbed,
                                    comic?.gradingCompany,
                                  ) ??
                                  'Collector copy',
                              accentColor: accentColor,
                            ),
                          if (entry.locationPath != null)
                            _MetaPill(
                              icon: Icons.inventory_2_outlined,
                              label: entry.locationPath!,
                              accentColor: accentColor,
                            ),
                          if (entry.pricePaidCents != null)
                            _MetaPill(
                              icon: Icons.attach_money,
                              label: moneyFormatter(
                                entry.pricePaidCents,
                                entry.currency,
                              ),
                              accentColor: accentColor,
                            ),
                          if (entry.isWishlisted)
                            _MetaPill(
                              icon: Icons.star,
                              label: 'Wishlist',
                              accentColor: accentColor,
                            ),
                          if (capabilities.showsTrackData)
                            if (_metadataFactValue(metadataPresentation, 'Tracks')
                                case final trackCount)
                            _MetaPill(
                              icon: Icons.music_note,
                              label: '$trackCount tracks',
                              accentColor: accentColor,
                            ),
                          if (_metadataFactValue(
                                metadataPresentation,
                                'Release Status',
                              )
                              case final releaseStatus?)
                            _MetaPill(
                              icon: Icons.album,
                              label: releaseStatus,
                              accentColor: accentColor,
                            ),
                          if (_platformLabel(libraryReferencePlatforms(entry))
                              case final platformLabel?)
                            _MetaPill(
                              icon: Icons.sports_esports,
                              label: platformLabel,
                              accentColor: accentColor,
                            ),
                          if (_noteLabel(entry.notes) case final noteLabel?)
                            _MetaPill(
                              icon: Icons.sticky_note_2_outlined,
                              label: noteLabel,
                              accentColor: accentColor,
                            ),
                          if (_metadataFactValue(metadataPresentation, 'Pages')
                              case final pageCount?)
                            _MetaPill(
                              icon: Icons.menu_book,
                              label: '$pageCount pg',
                              accentColor: accentColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Synopsis snippet
                      if (capabilities.showsSynopsis &&
                          entry.synopsis != null &&
                          entry.synopsis!.isNotEmpty)
                        Text(
                          entry.synopsis!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: resolvedMutedTextColor.withValues(alpha: 0.7),
                            fontSize: 11,
                            height: 1.4,
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

String? _seriesSummary(
  LibraryMetadataPresentation? presentation,
  LibraryWorkspaceEntry entry,
) {
  final seriesTitle =
      _metadataFactValue(presentation, 'Series') ??
      _metadataFactValue(presentation, 'Artist');
  if (seriesTitle == null || seriesTitle == entry.title) {
    return null;
  }
  return seriesTitle;
}

String? _platformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final values = platforms
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  if (values.length == 1) {
    return values.single;
  }
  return '${values.first} +${values.length - 1}';
}

String? _noteLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= 28) {
    return trimmed;
  }
  return '${trimmed.substring(0, 27)}...';
}

// ─── Private helpers ────────────────────────────────────────────────────────

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });
  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
