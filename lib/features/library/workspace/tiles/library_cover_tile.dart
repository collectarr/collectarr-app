import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

LibraryCollectionStatusScope resolveLibraryCollectionStatusScope(
  LibraryProjectionRuntime item,
) {
  final dto = item.dto;
  final status = dto.collectionStatus?.trim().toLowerCase();
  return switch (status) {
    'sold' => LibraryCollectionStatusScope.sold,
    'for_sale' => LibraryCollectionStatusScope.forSale,
    'on_order' => LibraryCollectionStatusScope.onOrder,
    _ when dto.isOwned => LibraryCollectionStatusScope.inCollection,
    _ when dto.isWishlisted => LibraryCollectionStatusScope.wishList,
    _ => LibraryCollectionStatusScope.notInCollection,
  };
}

class LibraryCoverTile extends ConsumerStatefulWidget {
  const LibraryCoverTile({
    required this.item,
    required this.active,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    this.onSelectionToggleTap,
    this.onDoubleTap,
    this.onEditTap,
    this.onSecondaryTapUp,
    this.coverSize = 128,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    this.customFieldBadges = const <String>[],
    super.key,
  });

  final LibraryProjectionRuntime item;
  final bool active;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onSelectionToggleTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onEditTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final double coverSize;
  final Color selectedColor;
  final Color accentColor;
  final Color selectionColor;
  final Color mutedTextColor;
  final List<String> customFieldBadges;

  @override
  ConsumerState<LibraryCoverTile> createState() => _LibraryCoverTileState();
}

class _LibraryCoverTileState extends ConsumerState<LibraryCoverTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final dto = item.dto;
    final cat = item.source.catalogItem;
    final active = widget.active;
    final selected = widget.selected;
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final flat = uiPrefs.flatCovers;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
        ? libraryWorkspaceSelectionBackground(
            context,
            accentColor: widget.accentColor,
            baseColor: palette.field,
          )
        : widget.selectedColor;
    final resolvedSelectionColor = widget.selectionColor == kAppHighlight
        ? widget.accentColor
        : widget.selectionColor;
    final showSelectionToggle = widget.selectionMode || selected || _hovered;
    final showEditButton = _hovered && widget.onEditTap != null;
    final scopeBadge = _scopeBadge(context, item);
    final comic = cat?.comic;
    final auxiliaryBadges = _auxiliaryBadges(item);
    final strongSelection =
        selected && item.node.browseScope != LibraryBrowserScope.title;
    final selectedBorderWidth =
        (widget.coverSize * 0.032).clamp(3.0, 6.0).toDouble();
    final activeBorderWidth =
        (widget.coverSize * 0.02).clamp(2.0, 3.5).toDouble();
    final targetCacheWidth = _targetCacheWidth(context);
    final tilePadding = switch (density) {
      LibraryDensity.comfortable => const EdgeInsets.all(2),
      LibraryDensity.compact => const EdgeInsets.all(1),
      LibraryDensity.dense => EdgeInsets.zero,
    };
    final badgeTop = switch (density) {
      LibraryDensity.comfortable => 6.0,
      LibraryDensity.compact => 5.0,
      LibraryDensity.dense => 4.0,
    };
    final badgeBottom = switch (density) {
      LibraryDensity.comfortable => 5.0,
      LibraryDensity.compact => 4.0,
      LibraryDensity.dense => 3.0,
    };

    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: flat ? EdgeInsets.zero : tilePadding,
        decoration: BoxDecoration(
          color: selected
              ? resolvedSelectedColor
              : (flat ? Colors.transparent : palette.field),
          borderRadius: flat ? BorderRadius.zero : kAppRadiusSmall,
          border: flat
              ? (selected || active
                  ? Border.all(
                      color: selected
                          ? widget.accentColor
                          : widget.accentColor.withValues(alpha: 0.82),
                      width: selected
                          ? (strongSelection
                              ? selectedBorderWidth + 1
                              : selectedBorderWidth)
                          : activeBorderWidth,
                    )
                  : null)
              : Border.all(
                  color: selected
                      ? widget.accentColor
                      : active
                          ? widget.accentColor.withValues(alpha: 0.82)
                          : palette.cardBorder,
                  width: selected
                      ? (strongSelection
                          ? selectedBorderWidth + 1
                          : selectedBorderWidth)
                      : active
                          ? activeBorderWidth
                          : 1,
                ),
          boxShadow: flat
              ? null
              : [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(
                          alpha: palette.isDark ? 0.6 : 0.18,
                        ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                  if (strongSelection)
                    BoxShadow(
                      color: widget.accentColor.withValues(
                        alpha: palette.isDark ? 0.38 : 0.28,
                      ),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InkWell(
                onTap: widget.onTap,
                onDoubleTap: widget.onDoubleTap,
                onSecondaryTapUp: widget.onSecondaryTapUp,
                onHover: (value) {
                  if (_hovered == value) {
                    return;
                  }
                  setState(() => _hovered = value);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SlabFrameOverlay.maybeWrap(
                        rawOrSlabbed: comic?.rawOrSlabbed,
                        gradingCompany: comic?.gradingCompany,
                        grade: dto.grade,
                        labelType: comic?.labelType,
                        child: LibraryInteractiveCover(
                          title: dto.title,
                          itemNumber: dto.itemNumber,
                          imageUrl: dto.coverImageUrl,
                          ownedItemId: item.source.ownedItem?.id,
                          targetCacheWidth: targetCacheWidth,
                          accentColor: widget.accentColor,
                          fit: BoxFit.cover,
                          enableFullscreen: false,
                          enableSecondaryControl: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (auxiliaryBadges.isNotEmpty)
                Positioned(
                  top: showEditButton ? 34 : badgeTop,
                  right: 6,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: auxiliaryBadges,
                  ),
                ),
              if (showEditButton)
                Positioned(
                  top: 6,
                  right: 6,
                  child: LibraryTileHoverActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit item',
                    onTap: widget.onEditTap!,
                  ),
                ),
              if (showSelectionToggle)
                Positioned(
                  left: 5,
                  bottom: badgeBottom,
                  child: LibraryTileSelectionToggleButton(
                    onTap: widget.onSelectionToggleTap,
                    child: LibraryTileSelectionToggle(
                      selected: selected,
                      accentColor: resolvedSelectionColor,
                      coverSize: widget.coverSize,
                    ),
                  ),
                ),
              if (scopeBadge != null)
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: scopeBadge,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _auxiliaryBadges(LibraryProjectionRuntime item) {
    final dto = item.dto;
    final comic = item.source.catalogItem?.comic;
    return [
      if (dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty)
        const LibraryCoverBadge(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing cover',
        ),
      if (dto.publisher == null || dto.publisher!.isEmpty)
        const LibraryCoverBadge(
          icon: Icons.manage_search,
          label: 'Missing metadata',
        ),
      if (libraryKeyMarkerLabel(comic?.keyComic ?? false, comic?.keyReason)
          case final label?)
        LibraryCoverBadge(
          icon: Icons.label_important,
          label: label,
        ),
      if (dto.grade?.trim().isNotEmpty == true)
        LibraryCoverBadge(
          icon: Icons.star_rate,
          label: 'Grade ${dto.grade!.trim()}',
        ),
      if (librarySlabMarkerLabel(comic?.rawOrSlabbed, comic?.gradingCompany)
          case final label?)
        LibraryCoverBadge(
          icon: Icons.workspace_premium,
          label: label,
        ),
      if (libraryHierarchyContractDiagnosticLabel(item) case final label?)
        LibraryCoverBadge(
          icon: Icons.rule_outlined,
          label: label,
        ),
      for (final badge in widget.customFieldBadges)
        LibraryCoverBadge(
          icon: Icons.tune,
          label: badge,
        ),
    ];
  }

  Widget? _scopeBadge(BuildContext context, LibraryProjectionRuntime item) {
    final palette = appPalette(context);
    final scope = resolveLibraryCollectionStatusScope(item);
    final iconColor = libraryCollectionStatusScopeColor(
      scope,
      widget.accentColor,
      palette.textMuted,
    );
    return LibraryTileScopePill(
      icon: scope.icon,
      label: scope.label,
      color: iconColor,
    );
  }

  int _targetCacheWidth(BuildContext context) {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    final pixelRatio = devicePixelRatio ?? 1.0;
    if (pixelRatio <= 0.0) {
      return (widget.coverSize * 2).round().clamp(128, 768);
    }
    final rawWidth = widget.coverSize * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}
