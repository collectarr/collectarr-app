import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/app_press_tap.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.fallbackCoverAspectRatio = 2 / 3,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    super.key,
  });

  final LibraryProjectionView item;
  final bool active;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onSelectionToggleTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onEditTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final double coverSize;
  final double fallbackCoverAspectRatio;
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
    final item = widget.item;
    final dto = item.dto;
    final presentation = libraryCardPresentationForEntry(item);
    final active = widget.active;
    final selected = widget.selected;
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final flat = uiPrefs.flatCovers;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
        ? libraryWorkspaceSelectionBackground(context)
        : widget.selectedColor;
    final resolvedSelectionColor = widget.selectionColor == kAppHighlight
        ? palette.utilityAction
        : widget.selectionColor;
    final showSelectionToggle = widget.selectionMode || selected || _hovered;
    final showEditButton = _hovered && widget.onEditTap != null;
    const selectedBorderWidth = 5.0;
    final targetCacheWidth = _targetCacheWidth(context);
    final badgeInset = switch (density) {
      LibraryDensity.comfortable => 5.0,
      LibraryDensity.compact => 4.0,
      LibraryDensity.dense => 3.0,
    };

    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected || active ? resolvedSelectedColor : null,
          border: selected || active
              ? Border.all(
                  color: palette.utilityAction,
                  width: selectedBorderWidth,
                )
              : null,
          // The reference draws covers bare, with only a 3 px black shadow.
          boxShadow: flat
              ? null
              : const [BoxShadow(color: Colors.black, blurRadius: 3)],
        ),
        child: AppPressTap(
            onTap: widget.onTap,
            builder: (context, onReleaseTap) => Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    onEnter: (_) => _setHovered(true),
                    onExit: (_) => _setHovered(false),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        InkWell(
                          mouseCursor: WidgetStateMouseCursor.clickable,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: onReleaseTap,
                          onDoubleTap: widget.onDoubleTap,
                          onSecondaryTapUp: widget.onSecondaryTapUp,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: LibraryInteractiveCover(
                                  title: dto.primaryLabel,
                                  itemNumber: presentation.itemNumber,
                                  imageUrl: dto.imageUrl,
                                  libraryEntryRef: item.source.libraryEntryRef,
                                  targetCacheWidth: targetCacheWidth,
                                  fallbackAspectRatio:
                                      widget.fallbackCoverAspectRatio,
                                  accentColor: widget.accentColor,
                                  fit: BoxFit.contain,
                                  enableFullscreen: false,
                                  enableSecondaryControl: false,
                                  showFrame: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showEditButton)
                          Positioned(
                            top: 4,
                            right: 5,
                            child: LibraryTileHoverActionButton(
                              icon: AppIcons.inlineEdit,
                              tooltip: 'Edit',
                              onTap: widget.onEditTap!,
                            ),
                          ),
                        // The status sits bottom left on the cover and the
                        // selection check top left, as on Vertical Cards.
                        Positioned(
                          left: 5,
                          bottom: badgeInset,
                          child: LibraryItemStatusBadge(
                            item: item,
                            selected: selected,
                            style: LibraryCollectionStatusMarkStyle.cover,
                          ),
                        ),
                        if (showSelectionToggle)
                          Positioned(
                            left: 5,
                            top: badgeInset,
                            child: LibraryTileSelectionToggleButton(
                              onTap: widget.onSelectionToggleTap,
                              child: LibraryTileSelectionToggle(
                                selected: selected,
                                accentColor: resolvedSelectionColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
      ),
    );
  }

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) {
      return;
    }
    setState(() => _hovered = value);
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

class LibraryTileSelectionToggle extends StatelessWidget {
  const LibraryTileSelectionToggle({
    super.key,
    required this.selected,
    required this.accentColor,
    this.integrated = false,
    this.highlighted = false,
  });

  final bool selected;
  final Color accentColor;
  final bool integrated;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
        width: integrated ? 30 : 24,
        height: 24,
        decoration: BoxDecoration(
          color:
              selected || highlighted ? accentColor : const Color(0xffdddddd),
          borderRadius:
              integrated ? BorderRadius.zero : BorderRadius.circular(4),
        ),
        child: Icon(selected ? AppIcons.check : Icons.check_box_outline_blank,
            size: 16,
            color: selected || highlighted
                ? Colors.white
                : const Color(0xff444444)),
      );
}

class LibraryTileSelectionToggleButton extends StatelessWidget {
  const LibraryTileSelectionToggleButton({
    super.key,
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
      child: Semantics(
        button: true,
        child: AppPressClaim(
            child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: child,
          ),
        )),
      ),
    );
  }
}

class LibraryTileHoverActionButton extends StatelessWidget {
  const LibraryTileHoverActionButton(
      {super.key,
      required this.icon,
      required this.tooltip,
      required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: AppClickTarget(
          onClick: onTap,
          builder: (context, hovered) => Container(
              width: 26,
              height: 24,
              decoration: BoxDecoration(
                  color: hovered
                      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.25),
                          const Color(0xffdddddd))
                      : const Color(0xffdddddd),
                  borderRadius: BorderRadius.circular(4)),
              child: Icon(icon, size: 14, color: const Color(0xff444444))),
        ),
      );
}
