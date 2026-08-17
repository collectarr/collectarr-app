import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryDateFormatter = String Function(DateTime value);
typedef LibraryMoneyFormatter = String Function(int? cents, String? currency);

enum LibraryCardLayout { vertical, horizontal }

class _LibraryWorkspaceCardDelegateImpl
    implements LibraryWorkspaceCardDelegate {
  _LibraryWorkspaceCardDelegateImpl({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTapUp,
    required this.selectedColor,
    required this.accentColor,
    required this.mutedTextColor,
    required this.coverWidth,
    required this.cardLayout,
    required this.selectionMode,
    required this.onSelectionToggleTap,
    required this.onEditTap,
    required this.customFieldBadges,
    required this.selectedTitleColor,
    required this.mutedColor,
    required this.coverCacheWidth,
    required this.metadataPresentation,
    required this.referenceHierarchy,
  });

  @override
  final LibraryProjectionRuntime item;
  @override
  final bool selected;
  @override
  final VoidCallback onTap;
  @override
  final VoidCallback? onDoubleTap;
  @override
  final GestureTapUpCallback? onSecondaryTapUp;
  @override
  final Color selectedColor;
  @override
  final Color accentColor;
  @override
  final Color mutedTextColor;
  @override
  final double coverWidth;
  final LibraryCardLayout cardLayout;
  @override
  final bool selectionMode;
  @override
  final VoidCallback? onSelectionToggleTap;
  @override
  final VoidCallback? onEditTap;
  @override
  final List<String> customFieldBadges;

  @override
  final Color selectedTitleColor;
  @override
  final Color mutedColor;
  @override
  final int? coverCacheWidth;
  @override
  final LibraryMetadataPresentation? metadataPresentation;
  @override
  final List<String> referenceHierarchy;
}

class LibraryWorkspaceCard extends StatelessWidget {
  const LibraryWorkspaceCard({
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
    this.coverWidth = 72,
    this.cardLayout = LibraryCardLayout.horizontal,
    this.selectionMode = false,
    this.onSelectionToggleTap,
    this.onEditTap,
    this.customFieldBadges = const <String>[],
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
  final double coverWidth;
  final LibraryCardLayout cardLayout;
  final bool selectionMode;
  final VoidCallback? onSelectionToggleTap;
  final VoidCallback? onEditTap;
  final List<String> customFieldBadges;

  @override
  Widget build(BuildContext context) {
    final metadataPresentation = _metadataPresentationForEntry(item);
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
        : Theme.of(context).colorScheme.onSurface;
    final referenceHierarchy = libraryReferenceHierarchySegments(
      mediaType: item.source.catalogItem?.kind ?? '',
      editions: item.source.catalogItem?.editions ?? const [],
      editionId: item.source.ownedItem?.editionId,
      variantId: item.source.ownedItem?.variantId,
      bundleReleaseId: item.source.ownedItem?.bundleReleaseId,
    );

    // Resolve the kind-supplied card presentation (or fall back to default).
    final kind = catalogMediaKindFromValue(item.source.catalogItem?.kind);
    final module = libraryKindRuntimeForKind(kind);
    final musicVertical = cardLayout == LibraryCardLayout.vertical;
    final presentation = module.buildCard(
      item,
      musicVertical: musicVertical,
    );

    final strongSelection = selected && item.node is! LibraryTitleNodeRef;
    final coverCacheWidth = _targetCacheWidth(context);

    final delegate = _LibraryWorkspaceCardDelegateImpl(
      item: item,
      selected: selected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapUp: onSecondaryTapUp,
      selectedColor: selectedColor,
      accentColor: accentColor,
      mutedTextColor: mutedTextColor,
      coverWidth: coverWidth,
      cardLayout: cardLayout,
      selectionMode: selectionMode,
      onSelectionToggleTap: onSelectionToggleTap,
      onEditTap: onEditTap,
      customFieldBadges: customFieldBadges,
      selectedTitleColor: selectedTitleColor,
      mutedColor: resolvedMutedTextColor,
      coverCacheWidth: coverCacheWidth,
      metadataPresentation: metadataPresentation,
      referenceHierarchy: referenceHierarchy,
    );

    if (presentation.customCardBuilder != null) {
      return presentation.customCardBuilder!(context, delegate);
    }

    if (cardLayout == LibraryCardLayout.vertical) {
      return _buildStandardVerticalCard(
        context: context,
        selectedTitleColor: selectedTitleColor,
        mutedColor: resolvedMutedTextColor,
        strongSelection: strongSelection,
        coverCacheWidth: coverCacheWidth,
        presentation: presentation,
      );
    }
    return _buildStandardHorizontalCard(
      context: context,
      selectedTitleColor: selectedTitleColor,
      mutedColor: resolvedMutedTextColor,
      strongSelection: strongSelection,
      coverCacheWidth: coverCacheWidth,
      metadataPresentation: metadataPresentation,
      presentation: presentation,
      referenceHierarchy: referenceHierarchy,
    );
  }

  // ---------------------------------------------------------------------------
  // Standard horizontal card (default for most kinds).
  // ---------------------------------------------------------------------------

  Widget _buildStandardHorizontalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required bool strongSelection,
    required int? coverCacheWidth,
    required LibraryMetadataPresentation? metadataPresentation,
    required LibraryCardPresentation presentation,
    required List<String> referenceHierarchy,
  }) {
    final palette = appPalette(context);
    final gradeLabel = item.source.grade?.trim();
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? libraryWorkspaceSelectionBackground(
                  context,
                  accentColor: accentColor,
                  baseColor: palette.cardBackground,
                )
              : palette.cardBackground,
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
                            _buildCover(
                              context: context,
                              coverCacheWidth: coverCacheWidth,
                              presentation: presentation,
                              fit: BoxFit.contain,
                              borderRadius: 2,
                            ),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: LibraryCoverBadges(
                                isOwned: item.source.isOwned,
                                isTracked: item.source.isTracked,
                                isWishlisted: item.source.isWishlisted,
                                hasMissingCover:
                                    item.dto.coverImageUrl == null ||
                                        item.dto.coverImageUrl!.isEmpty,
                                hasMissingMetadata:
                                    item.dto.publisher == null ||
                                        item.dto.publisher!.isEmpty,
                                contractDiagnosticLabel:
                                    libraryHierarchyContractDiagnosticLabel(
                                  item,
                                ),
                                keyLabel: _coverKeyLabel(presentation),
                                gradeLabel:
                                    gradeLabel == null || gradeLabel.isEmpty
                                        ? null
                                        : 'Grade $gradeLabel',
                                slabLabel: _coverSlabLabel(presentation),
                                notesLabel: libraryNotesMarkerLabel(
                                    item.source.personalNotes),
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
                                    item.dto.title,
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
                                if (item.dto.itemNumber != null)
                                  _LibraryIssuePill(
                                      label: '#${item.dto.itemNumber}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (item.node is! LibraryTitleNodeRef &&
                                    item.dto.variant != null &&
                                    item.dto.variant!.isNotEmpty)
                                  item.dto.variant,
                                if (item.dto.releaseDate != null)
                                  dateFormatter(item.dto.releaseDate!),
                                if (item.dto.publisher != null &&
                                    item.dto.publisher!.isNotEmpty)
                                  item.dto.publisher,
                              ].whereType<String>().join('  |  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: mutedColor,
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
                                if (item.dto.format != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.album_outlined,
                                    label: 'Format: ${item.dto.format!}',
                                    accentColor: accentColor,
                                  ),
                                if (item.source.grade != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.workspace_premium,
                                    label: item.source.grade!,
                                    accentColor: accentColor,
                                  ),
                                if (item.source.condition != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.fact_check_outlined,
                                    label: item.source.condition!,
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
                                for (final badge in presentation.compactBadges)
                                  _LibraryCompactMetaPill(
                                    icon: badge.icon,
                                    label: badge.label,
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
                                if (_compactNotesLabel(
                                        item.source.personalNotes)
                                    case final noteLabel?)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.sticky_note_2_outlined,
                                    label: noteLabel,
                                    accentColor: accentColor,
                                  ),
                                for (final badge in customFieldBadges)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.tune,
                                    label: badge,
                                    accentColor: accentColor,
                                  ),
                                if (item.source.locationPath != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.inventory_2_outlined,
                                    label: item.source.locationPath!,
                                    accentColor: accentColor,
                                  ),
                                if (item.source.pricePaidCents != null)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.attach_money,
                                    label: moneyFormatter(
                                      item.source.pricePaidCents,
                                      item.source.currency,
                                    ),
                                    accentColor: accentColor,
                                  ),
                                if (item.source.isWishlisted)
                                  _LibraryCompactMetaPill(
                                    icon: Icons.star,
                                    label: 'Wishlist',
                                    accentColor: accentColor,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            if (item.node is! LibraryTitleNodeRef)
                              Text(
                                item.dto.barcode == null ||
                                        item.dto.barcode!.isEmpty
                                    ? 'No barcode'
                                    : item.dto.barcode!,
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
                if (onEditTap != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: LibraryTileHoverActionButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit item',
                      onTap: onEditTap!,
                    ),
                  ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: _scopeBadge(context, item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Standard vertical card (grid / card view).
  // ---------------------------------------------------------------------------

  Widget _buildStandardVerticalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required bool strongSelection,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
  }) {
    final palette = appPalette(context);
    final background = selected
        ? libraryWorkspaceSelectionBackground(
            context,
            accentColor: accentColor,
            baseColor: palette.cardBackground,
          )
        : palette.cardBackground;
    final titleColor = selected
        ? selectedTitleColor
        : (palette.isDark ? kAppAccentLight : accentColor);
    final subtitle = [
      if (item.node is! LibraryTitleNodeRef &&
          item.dto.variant != null &&
          item.dto.variant!.isNotEmpty)
        item.dto.variant,
      if (item.dto.releaseDate != null) dateFormatter(item.dto.releaseDate!),
      if (item.dto.publisher != null && item.dto.publisher!.isNotEmpty)
        item.dto.publisher,
    ].whereType<String>().join('  |  ');
    final support = [
      if (item.source.grade != null) item.source.grade!,
      if (_metadataFactValue(_metadataPresentationForEntry(item), 'Runtime')
          case final runtime?)
        runtime,
    ].whereType<String>().join('  ·  ');
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background,
          borderRadius: kAppRadiusSmall,
          border: Border.all(
            color: selected ? accentColor : palette.cardBorder,
            width: selected ? (strongSelection ? 3 : 2) : 1,
          ),
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
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildCover(
                              context: context,
                              coverCacheWidth: coverCacheWidth,
                              presentation: presentation,
                              fit: BoxFit.cover,
                              borderRadius: 0,
                            ),
                            Positioned(
                              left: 6,
                              top: 6,
                              child: LibraryCoverBadges(
                                isOwned: item.source.isOwned,
                                isTracked: item.source.isTracked,
                                isWishlisted: item.source.isWishlisted,
                                hasMissingCover:
                                    item.dto.coverImageUrl == null ||
                                        item.dto.coverImageUrl!.isEmpty,
                                hasMissingMetadata:
                                    item.dto.publisher == null ||
                                        item.dto.publisher!.isEmpty,
                                contractDiagnosticLabel:
                                    libraryHierarchyContractDiagnosticLabel(
                                  item,
                                ),
                                keyLabel: _coverKeyLabel(presentation),
                                slabLabel: _coverSlabLabel(presentation),
                                notesLabel: libraryNotesMarkerLabel(
                                    item.source.personalNotes),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.dto.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: mutedColor,
                                    ),
                              ),
                            ],
                            if (support.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                support,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: mutedColor.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
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
                if (onEditTap != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: LibraryTileHoverActionButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit item',
                      onTap: onEditTap!,
                    ),
                  ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: _scopeBadge(context, item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers.
  // ---------------------------------------------------------------------------

  /// Builds the cover image, optionally wrapped in a kind-supplied overlay
  /// (e.g. slab frame for comics).
  Widget _buildCover({
    required BuildContext context,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
    required BoxFit fit,
    required double borderRadius,
  }) {
    final cover = LibraryInteractiveCover(
      title: item.dto.title,
      itemNumber: item.dto.itemNumber,
      imageUrl: item.dto.coverImageUrl,
      ownedItemId: item.source.ownedItem?.id,
      targetCacheWidth: coverCacheWidth,
      accentColor: accentColor,
      fit: fit,
      borderRadius: borderRadius,
      enableFullscreen: false,
      enableSecondaryControl: false,
    );
    final wrapOverlay = presentation.coverOverlayBuilder;
    return wrapOverlay != null ? wrapOverlay(cover) : cover;
  }

  Widget _scopeBadge(BuildContext context, LibraryProjectionRuntime item) {
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

  int? _targetCacheWidth(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio <= 0) return null;
    final rawWidth = coverWidth * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}

// ---------------------------------------------------------------------------
// Helpers for extracting cover-badge labels from the presentation.
// These read the first badge of the expected icon type.  Kinds can inject
// badges via LibraryCardPresentation.compactBadges; the cover badges come from
// kind-specific labels exposed via comic_card_presentation helpers.
// ---------------------------------------------------------------------------

String? _coverKeyLabel(LibraryCardPresentation presentation) {
  for (final b in presentation.compactBadges) {
    if (b.icon == Icons.label_important) return b.label;
  }
  return null;
}

String? _coverSlabLabel(LibraryCardPresentation presentation) {
  for (final b in presentation.compactBadges) {
    if (b.icon == Icons.workspace_premium) return b.label;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Module-level helpers (previously in the file-level scope).
// ---------------------------------------------------------------------------

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryProjectionRuntime item,
) {
  final kind = item.source.catalogItem?.kind ?? '';
  final type = collectarrLibraryTypes.byKind(catalogMediaKindFromValue(kind));
  if (type == null) return null;
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    item: item,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation? presentation,
  String label,
) {
  if (presentation == null) return null;
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

String? _compactNotesLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.length <= 28) return trimmed;
  return '${trimmed.substring(0, 27)}...';
}

// ---------------------------------------------------------------------------
// Private widget helpers.
// ---------------------------------------------------------------------------

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
