import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCoverTile extends ConsumerStatefulWidget {
  const LibraryCoverTile({
    required this.entry,
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
    super.key,
  });

  final LibraryWorkspaceEntry entry;
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

  @override
  ConsumerState<LibraryCoverTile> createState() => _LibraryCoverTileState();
}

class _LibraryCoverTileState extends ConsumerState<LibraryCoverTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final active = widget.active;
    final selected = widget.selected;
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final flat = uiPrefs.flatCovers;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
        ? palette.selection
        : widget.selectedColor;
    final resolvedSelectionColor = widget.selectionColor == kAppHighlight
        ? widget.accentColor
        : widget.selectionColor;
    final showSelectionToggle = widget.selectionMode || selected || _hovered;
    final showEditButton = _hovered && widget.onEditTap != null;
    final scopeBadge = _scopeBadge(context, entry);
    final comic = entry.comic;
    final auxiliaryBadges = _auxiliaryBadges(entry);
    final strongSelection =
        selected && entry.browseScope != LibraryBrowserScope.title;
    final selectedBorderWidth =
        (widget.coverSize * 0.032).clamp(3.0, 6.0).toDouble();
    final activeBorderWidth =
        (widget.coverSize * 0.02).clamp(2.0, 3.5).toDouble();

    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: flat ? EdgeInsets.zero : const EdgeInsets.all(2),
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
          child: InkWell(
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
                          accentColor: widget.accentColor,
                          enableFullscreen: false,
                          enableSecondaryControl: false,
                        ),
                      ),
                      if (auxiliaryBadges.isNotEmpty)
                        Positioned(
                          top: showEditButton ? 34 : 6,
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
                          child: _LibraryTileHoverActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit item',
                            onTap: widget.onEditTap!,
                          ),
                        ),
                      if (showSelectionToggle)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: _LibraryTileSelectionToggleButton(
                            onTap: widget.onSelectionToggleTap,
                            child: _LibraryTileSelectionToggle(
                              selected: selected,
                              accentColor: resolvedSelectionColor,
                              coverSize: widget.coverSize,
                            ),
                          ),
                        ),
                      if (scopeBadge != null)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: scopeBadge,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _auxiliaryBadges(LibraryWorkspaceEntry entry) {
    final comic = entry.comic;
    return [
      if (entry.hasMissingCover)
        const LibraryCoverBadge(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing cover',
        ),
      if (entry.hasMissingMetadata)
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
      if (librarySlabMarkerLabel(comic?.rawOrSlabbed, comic?.gradingCompany)
          case final label?)
        LibraryCoverBadge(
          icon: Icons.workspace_premium,
          label: label,
        ),
      if (libraryNotesMarkerLabel(entry.notes) case final label?)
        LibraryCoverBadge(
          icon: Icons.sticky_note_2_outlined,
          label: label,
        ),
    ];
  }

  Widget? _scopeBadge(BuildContext context, LibraryWorkspaceEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = entry.collectionStatus?.trim().toLowerCase();
    if (status == 'sold') {
      return _LibraryTileScopePill(
        icon: Icons.sell,
        label: 'Sold',
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      );
    }
    if (status == 'for_sale') {
      return _LibraryTileScopePill(
        icon: Icons.sell_outlined,
        label: 'For sale',
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      );
    }
    if (status == 'on_order') {
      return _LibraryTileScopePill(
        icon: Icons.local_shipping_outlined,
        label: 'On order',
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      );
    }
    if (entry.isOwned) {
      return _LibraryTileScopePill(
        icon: Icons.check_circle,
        label: 'In collection',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      );
    }
    if (entry.isWishlisted) {
      return _LibraryTileScopePill(
        icon: Icons.star,
        label: 'Wishlist',
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
      );
    }
    if (entry.isTracked) {
      return _LibraryTileScopePill(
        icon: Icons.equalizer,
        label: 'Tracked',
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      );
    }
    return _LibraryTileScopePill(
      icon: Icons.add_box_outlined,
      label: 'Catalog only',
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurfaceVariant,
    );
  }
}

class _LibraryTileSelectionToggle extends StatelessWidget {
  const _LibraryTileSelectionToggle({
    required this.selected,
    required this.accentColor,
    required this.coverSize,
  });

  final bool selected;
  final Color accentColor;
  final double coverSize;

  @override
  Widget build(BuildContext context) {
    final iconSize = (coverSize * 0.11).clamp(14.0, 20.0).toDouble();
    final padding = (coverSize * 0.015).clamp(2.0, 4.0).toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? accentColor : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? accentColor : Colors.black.withValues(alpha: 0.18),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(
          selected ? Icons.check : Icons.check_box_outline_blank,
          size: iconSize,
          color: selected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}

class _LibraryTileSelectionToggleButton extends StatelessWidget {
  const _LibraryTileSelectionToggleButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: child,
      ),
    );
  }
}

class _LibraryTileHoverActionButton extends StatelessWidget {
  const _LibraryTileHoverActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.surfaceBright.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: kAppHighlight.withValues(alpha: 0.25),
          highlightColor: kAppHighlight.withValues(alpha: 0.18),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: 15, color: palette.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _LibraryTileScopePill extends StatelessWidget {
  const _LibraryTileScopePill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x29000000),
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: foregroundColor),
        ),
      ),
    );
  }
}
