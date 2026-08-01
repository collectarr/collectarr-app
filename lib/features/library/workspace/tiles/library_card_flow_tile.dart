import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A tall card showing a large cover beside rich metadata, used in "card flow"
/// mode. Intended for a single- or two-column vertical feed layout.
class LibraryCardFlowTile extends StatelessWidget {
  const LibraryCardFlowTile({
    required this.item,
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

  final LibraryProjectionRuntime item;
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
    final dto = item.dto;
    final cat = item.source.catalogItem;
    final coverCacheWidth = _targetCacheWidth(context);
    final metadataPresentation = _metadataPresentationForEntry(item);
    final theme = Theme.of(context);
    final palette = appPalette(context);
    final resolvedSelectedColor = selectedColor == kAppSelection
        ? libraryWorkspaceSelectionBackground(
            context,
            accentColor: accentColor,
            baseColor: palette.cardBackground,
          )
        : selectedColor;
    final resolvedMutedTextColor =
        mutedTextColor == kAppTextMuted ? palette.textMuted : mutedTextColor;
    final selectedTitleColor = ThemeData.estimateBrightnessForColor(
              resolvedSelectedColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;
    final comic = cat?.comic;
    final strongSelection =
        selected && item.node.browseScope != LibraryBrowserScope.title;
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
          borderRadius: kAppRadiusMedium,
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
                            title: dto.title,
                            itemNumber: dto.itemNumber,
                            imageUrl: dto.coverImageUrl,
                            ownedItemId: item.source.ownedItem?.id,
                            targetCacheWidth: coverCacheWidth,
                            accentColor: accentColor,
                            enableFullscreen: false,
                            enableSecondaryControl: false,
                          ),
                        ),
                        Positioned(
                          left: 4,
                          top: 4,
                          child: LibraryCoverBadges(
                            isOwned: dto.isOwned,
                            isTracked: dto.isTracked,
                            isWishlisted: dto.isWishlisted,
                            hasMissingCover: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty,
                            hasMissingMetadata: dto.publisher == null || dto.publisher!.isEmpty,
                            hasFrontImage: item.source.itemImages.any((img) => img.imageType == 'front_cover'),
                            hasBackImage: item.source.itemImages.any((img) => img.imageType == 'back_cover'),
                            extraImageCount: item.source.itemImages.length,
                            contractDiagnosticLabel:
                                libraryHierarchyContractDiagnosticLabel(item),
                            keyLabel: libraryKeyMarkerLabel(
                              comic?.keyComic ?? false,
                              comic?.keyReason,
                            ),
                            slabLabel: librarySlabMarkerLabel(
                              comic?.rawOrSlabbed,
                              comic?.gradingCompany,
                            ),
                            notesLabel: libraryNotesMarkerLabel(dto.personalNotes),
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
                                dto.title,
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
                            if (dto.itemNumber != null) ...[
                              const SizedBox(width: 6),
                              _IssuePill(label: '#${dto.itemNumber}'),
                            ],
                          ],
                        ),
                        // Series / subtitle
                        if (_seriesSummary(metadataPresentation)
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
                            if (item.node.browseScope !=
                                    LibraryBrowserScope.title &&
                                dto.variant != null &&
                                dto.variant!.isNotEmpty)
                              dto.variant,
                            if (dto.releaseDate != null)
                              dateFormatter(dto.releaseDate!)
                            else if (dto.releaseDate?.year != null)
                              dto.releaseDate!.year.toString(),
                            if (dto.publisher != null &&
                                dto.publisher!.isNotEmpty)
                              dto.publisher,
                          ].whereType<String>().join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: resolvedMutedTextColor,
                            fontSize: 12,
                          ),
                        ),
                        if (dto.creator != null && dto.creator!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dto.creator!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: resolvedMutedTextColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Status pill + price/grade summary
                        Row(
                          children: [
                            _cardScopeBadge(context, item),
                            const Spacer(),
                            if (dto.condition != null && dto.condition!.isNotEmpty)
                              Text(
                                dto.condition!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: resolvedMutedTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _cardScopeBadge(BuildContext context, LibraryProjectionRuntime item) {
    final palette = appPalette(context);
    final scope = resolveLibraryCollectionStatusScope(item);
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

  static String? _seriesSummary(LibraryMetadataPresentation? presentation) {
    if (presentation == null) return null;
    for (final fact in presentation.identityFacts) {
      if (fact.label == 'Series') return fact.value;
    }
    return null;
  }

  static int _targetCacheWidth(BuildContext context) {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    final pixelRatio = devicePixelRatio ?? 1.0;
    if (pixelRatio <= 0.0) {
      return 256;
    }
    const coverWidth = 120.0;
    final rawWidth = coverWidth * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryProjectionRuntime item,
) {
  final kind = item.source.catalogItem?.kind ?? '';
  final type = collectarrLibraryTypes.byKind(kind);
  if (type == null) {
    return null;
  }
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    item: item,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}
