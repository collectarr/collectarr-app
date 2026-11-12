import 'package:collectarr_app/features/library/ui/primitives/collection_status_icon.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_press_tap.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/workspace/tiles/item_status_badge.dart';
import 'package:flutter/material.dart';

enum LibraryCardLayout {
  vertical,
  horizontal,
}

class LibraryWorkspaceCard extends StatefulWidget {
  const LibraryWorkspaceCard({
    required this.item,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTapUp,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.mutedTextColor = kAppTextMuted,
    this.coverWidth = 92,
    this.cardLayout = LibraryCardLayout.horizontal,
    this.showHeadline = true,
    this.selectionMode = false,
    this.checked = false,
    this.onSelectionToggleTap,
    this.onEditTap,
    this.customFieldBadges = const <String>[],
    super.key,
  });

  final LibraryProjectionView item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final GestureTapUpCallback? onSecondaryTapUp;
  final Color selectedColor;
  final Color accentColor;
  final Color mutedTextColor;
  final double coverWidth;
  final LibraryCardLayout cardLayout;

  /// Whether a kind-owned card body shows its optional heading.
  final bool showHeadline;
  final bool selectionMode;
  final bool checked;
  final VoidCallback? onSelectionToggleTap;
  final VoidCallback? onEditTap;
  final List<String> customFieldBadges;

  @override
  State<LibraryWorkspaceCard> createState() => _LibraryWorkspaceCardState();
}

class _LibraryWorkspaceCardState extends State<LibraryWorkspaceCard> {
  bool _hovered = false;
  LibraryProjectionView get item => widget.item;
  bool get selected => widget.selected;
  VoidCallback get onTap => widget.onTap;
  VoidCallback? get onDoubleTap => widget.onDoubleTap;
  GestureTapUpCallback? get onSecondaryTapUp => widget.onSecondaryTapUp;
  Color get selectedColor => widget.selectedColor;
  Color get accentColor => widget.accentColor;
  Color get mutedTextColor => widget.mutedTextColor;
  double get coverWidth => widget.coverWidth;
  LibraryCardLayout get cardLayout => widget.cardLayout;
  bool get selectionMode => widget.selectionMode;
  bool get checked => widget.checked;
  bool get showSelectionToggle => appPresentationPlatform.isNativeMobile
      ? selectionMode
      : _hovered || checked || libraryShowsUntickedBoxes(selectionMode);
  bool get showEditButton =>
      !appPresentationPlatform.isNativeMobile && _hovered && onEditTap != null;
  VoidCallback? get onSelectionToggleTap => widget.onSelectionToggleTap;
  VoidCallback? get onEditTap => widget.onEditTap;
  List<String> get customFieldBadges => widget.customFieldBadges;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedMutedTextColor =
        mutedTextColor == kAppTextMuted ? palette.textMuted : mutedTextColor;
    const selectedTitleColor = Colors.white;
    final kind = item.source.mediaKind;
    final registration = libraryKindRegistrationForKind(kind);
    // Resolve the displayed item?s kind-owned composition.
    final coverFocused = cardLayout == LibraryCardLayout.vertical;
    final presentation =
        libraryPresentationForKind(registration.kind).buildCardPresentation(
      item,
      coverFocused: coverFocused,
    );

    if (coverFocused) {
      return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: _buildVerticalCardHost(
            context: context,
            selectedTitleColor: selectedTitleColor,
            mutedColor: resolvedMutedTextColor,
            presentation: presentation,
          ));
    }
    return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: _buildHorizontalCardHost(
          context: context,
          selectedTitleColor: selectedTitleColor,
          mutedColor: resolvedMutedTextColor,
          coverCacheWidth: _targetCacheWidth(context, coverWidth),
          presentation: presentation,
        ));
  }

  // ---------------------------------------------------------------------------
  // Shared horizontal card interaction host.
  // ---------------------------------------------------------------------------

  Widget _statusBadge(LibraryCollectionStatusMarkStyle style) =>
      LibraryItemStatusBadge(
        item: item,
        selected: selected,
        style: style,
        width: style == LibraryCollectionStatusMarkStyle.cover ? 29 : 25,
        height: style == LibraryCollectionStatusMarkStyle.cover ? 27 : 23,
      );

  Widget _buildHorizontalCardHost({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
  }) {
    final palette = appPalette(context);
    final background = selected
        ? (selectedColor == kAppSelection
            ? palette.utilityAction
            : selectedColor)
        : checked
            ? kLibraryCheckedItemBackground
            : palette.panelRaised;
    final body = LibraryItemContent(
      view: LibraryItemContentView.horizontalCard,
      data: LibraryCardBodyData(
        pillStatus: _statusBadge(LibraryCollectionStatusMarkStyle.pill),
        coverStatus: _statusBadge(LibraryCollectionStatusMarkStyle.cover),
        item: item,
        presentation: presentation,
        selected: selected,
        active: selected,
        showHeadline: widget.showHeadline,
        titleColor: selected ? selectedTitleColor : palette.itemTitle,
        detailColor: selected ? Colors.white : palette.textMuted,
        mutedColor: mutedColor,
        customFieldBadges: customFieldBadges,
        coverWidth: coverWidth,
        buildCover: ({required alignment}) => _buildCover(
          context: context,
          coverCacheWidth: coverCacheWidth,
          presentation: presentation,
          fit: BoxFit.contain,
          borderRadius: 0,
          alignment: alignment,
          intrinsicSize: true,
        ),
      ),
    );
    return RepaintBoundary(
        child: AnimatedContainer(
      duration: kAppAnimFast,
      color: background,
      child: AppPressTap(
          onTap: onTap,
          builder: (context, onReleaseTap) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onReleaseTap,
                  onDoubleTap: onDoubleTap,
                  onLongPress: widget.onLongPress,
                  onSecondaryTapUp: onSecondaryTapUp,
                  mouseCursor: SystemMouseCursors.click,
                  // A hover highlight keeps the alpha it appeared with, so
                  // turning it transparent on selection paints opaque black;
                  // a selected card repaints its own fill instead.
                  hoverColor:
                      selected || checked ? background : palette.surfaceBright,
                  highlightColor: Colors.transparent,
                  child: Stack(children: [
                    Padding(
                        padding: kLibraryHorizontalCardPadding, child: body),
                    if (appPresentationPlatform.isNativeMobile && checked)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                              color:
                                  palette.utilityAction.withValues(alpha: .35)),
                        ),
                      ),
                    if (selectionMode && onSelectionToggleTap != null)
                      Positioned.fill(
                        child: LibraryTileSelectionTapArea(
                            onTap: appPresentationPlatform.isNativeMobile
                                ? onSelectionToggleTap!
                                : onTap,
                            child: const SizedBox.expand()),
                      ),
                    if (showSelectionToggle)
                      Positioned(
                          left: 0,
                          bottom: 0,
                          child: LibraryTileSelectionToggleButton(
                              onTap: onSelectionToggleTap,
                              child: LibraryTileSelectionToggle(
                                  selected: checked,
                                  accentColor: palette.utilityAction,
                                  surface: LibraryTileSelectionSurface
                                      .horizontalCard,
                                  backgroundColor: background,
                                  highlighted: selected))),
                    if (showEditButton)
                      Positioned(
                          right: 5,
                          top: 5,
                          child: LibraryTileHoverActionButton(
                              icon: AppIcons.inlineEdit,
                              tooltip: 'Edit',
                              onTap: onEditTap!)),
                  ]),
                ),
              )),
    ));
  }

  // ---------------------------------------------------------------------------
  // Standard vertical card (grid / card view).
  // ---------------------------------------------------------------------------

  Widget _buildVerticalCardHost({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required LibraryCardPresentation presentation,
  }) {
    final palette = appPalette(context);
    final background = selected
        ? (selectedColor == kAppSelection
            ? libraryWorkspaceSelectionBackground(context)
            : selectedColor)
        : checked
            ? kLibraryCheckedItemBackground
            : palette.panelRaised;
    final titleColor = selected
        ? kLibraryCardTitleColor
        : palette.isDark
            ? kLibraryCardTitleIdle
            : palette.textPrimary;
    final detailColor = selected
        ? Colors.white
        : palette.isDark
            ? kLibraryCardDetailIdle
            : palette.textMuted;
    // The cover fills the card, which can be far wider than [coverWidth], so
    // it decodes for the width it is laid out at. Like cover tiles it keeps
    // twice that, for fine cover text and for app zoom.
    Widget buildCover({required Alignment alignment}) => LayoutBuilder(
          builder: (context, constraints) => _buildCover(
            context: context,
            coverCacheWidth: _targetCacheWidth(
                context,
                constraints.hasBoundedWidth
                    ? constraints.maxWidth * 2
                    : coverWidth * 2),
            presentation: presentation,
            fit: BoxFit.contain,
            alignment: alignment,
            borderRadius: 0,
          ),
        );

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background,
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
        child: AppPressTap(
            onTap: onTap,
            builder: (context, onReleaseTap) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: WidgetStateMouseCursor.clickable,
                    hoverColor: selected || checked
                        ? background
                        : palette.surfaceBright,
                    highlightColor: Colors.transparent,
                    onTap: onReleaseTap,
                    onDoubleTap: onDoubleTap,
                    onLongPress: widget.onLongPress,
                    onSecondaryTapUp: onSecondaryTapUp,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.zero,
                          child: LibraryItemContent(
                            view: LibraryItemContentView.verticalCard,
                            data: LibraryCardBodyData(
                              pillStatus: _statusBadge(
                                  LibraryCollectionStatusMarkStyle.pill),
                              coverStatus: _statusBadge(
                                  LibraryCollectionStatusMarkStyle.cover),
                              item: item,
                              presentation: presentation,
                              showHeadline: widget.showHeadline,
                              selected: selected,
                              active: selected,
                              titleColor: titleColor,
                              detailColor: detailColor,
                              mutedColor: mutedColor,
                              customFieldBadges: customFieldBadges,
                              coverWidth: coverWidth,
                              buildCover: buildCover,
                            ),
                          ),
                        ),
                        if (appPresentationPlatform.isNativeMobile && checked)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ColoredBox(
                                  color: palette.utilityAction
                                      .withValues(alpha: .35)),
                            ),
                          ),
                        if (selectionMode && onSelectionToggleTap != null)
                          Positioned.fill(
                            child: LibraryTileSelectionTapArea(
                                onTap: appPresentationPlatform.isNativeMobile
                                    ? onSelectionToggleTap!
                                    : onTap,
                                child: const SizedBox.expand()),
                          ),
                        if (showSelectionToggle)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: LibraryTileSelectionToggleButton(
                              onTap: onSelectionToggleTap,
                              child: LibraryTileSelectionToggle(
                                selected: checked,
                                accentColor: palette.utilityAction,
                                surface:
                                    LibraryTileSelectionSurface.verticalCard,
                                backgroundColor: background,
                                highlighted: selected,
                              ),
                            ),
                          ),
                        if (showEditButton)
                          Positioned(
                            top: 4,
                            right: 5,
                            child: LibraryTileHoverActionButton(
                              icon: AppIcons.inlineEdit,
                              tooltip: 'Edit',
                              onTap: onEditTap!,
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
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
    Alignment alignment = Alignment.center,
    bool intrinsicSize = false,
  }) {
    // Intrinsic covers size to the image's own aspect ratio within the
    // incoming constraints, so no empty bands remain beside or below it.
    final Widget cover = intrinsicSize
        ? LibraryCoverImage(
            title: item.dto.primaryLabel,
            mediaKind: item.source.mediaKind,
            itemNumber: presentation.itemNumber,
            imageUrl: item.dto.imageUrl,
            libraryEntryRef: item.source.libraryEntryRef,
            targetCacheWidth: coverCacheWidth,
            fallbackAspectRatio: 1 /
                libraryViewProfileForKind(item.source.mediaKind)
                    .coverGridHeightFactor,
            fit: fit,
            alignment: alignment,
            borderRadius: borderRadius,
          )
        : LibraryInteractiveCover(
            title: item.dto.primaryLabel,
            mediaKind: item.source.mediaKind,
            itemNumber: presentation.itemNumber,
            imageUrl: item.dto.imageUrl,
            libraryEntryRef: item.source.libraryEntryRef,
            targetCacheWidth: coverCacheWidth,
            fallbackAspectRatio: 1 /
                libraryViewProfileForKind(item.source.mediaKind)
                    .coverGridHeightFactor,
            accentColor: accentColor,
            fit: fit,
            alignment: alignment,
            borderRadius: borderRadius,
            enableFullscreen: false,
            enableSecondaryControl: false,
            showFrame: false,
          );
    final wrapOverlay = presentation.coverOverlayBuilder;
    return wrapOverlay != null ? wrapOverlay(cover) : cover;
  }

  int? _targetCacheWidth(BuildContext context, double width) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio <= 0) return null;
    final rawWidth = width * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}
