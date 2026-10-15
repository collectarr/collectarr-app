import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryCardLayout { vertical, horizontal }

class LibraryWorkspaceCard extends StatefulWidget {
  const LibraryWorkspaceCard({
    required this.item,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.mutedTextColor = kAppTextMuted,
    this.coverWidth = 72,
    this.cardLayout = LibraryCardLayout.horizontal,
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
  final GestureTapUpCallback? onSecondaryTapUp;
  final Color selectedColor;
  final Color accentColor;
  final Color mutedTextColor;
  final double coverWidth;
  final LibraryCardLayout cardLayout;
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
    // Resolve the kind-supplied card presentation (or fall back to default).
    final coverFocused = cardLayout == LibraryCardLayout.vertical;
    final presentation =
        libraryPresentationForKind(registration.kind).buildCardPresentation(
      item,
      coverFocused: coverFocused,
    );

    final coverCacheWidth = _targetCacheWidth(context);

    if (cardLayout == LibraryCardLayout.vertical) {
      return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: _buildStandardVerticalCard(
            context: context,
            selectedTitleColor: selectedTitleColor,
            mutedColor: resolvedMutedTextColor,
            coverCacheWidth: coverCacheWidth,
            presentation: presentation,
          ));
    }
    return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: _buildStandardHorizontalCard(
          context: context,
          selectedTitleColor: selectedTitleColor,
          mutedColor: resolvedMutedTextColor,
          coverCacheWidth: coverCacheWidth,
          presentation: presentation,
        ));
  }

  // ---------------------------------------------------------------------------
  // Standard horizontal card (default for most kinds).
  // ---------------------------------------------------------------------------

  Widget _buildStandardHorizontalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
  }) {
    final palette = appPalette(context);
    return RepaintBoundary(
        child: AnimatedContainer(
      duration: kAppAnimFast,
      color: selected
          ? (selectedColor == kAppSelection
              ? palette.utilityAction
              : selectedColor)
          : palette.panelRaised,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onSecondaryTapUp: onSecondaryTapUp,
          mouseCursor: SystemMouseCursors.click,
          hoverColor: palette.textPrimary.withValues(alpha: 0.06),
          child: Stack(children: [
            Padding(
                padding: const EdgeInsets.all(4),
                child: Row(children: [
                  SizedBox(
                      width: coverWidth,
                      child: _buildCover(
                          context: context,
                          coverCacheWidth: coverCacheWidth,
                          presentation: presentation,
                          fit: BoxFit.contain,
                          borderRadius: 0)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(item.dto.primaryLabel,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          height: 1.15,
                                          color: selected
                                              ? Colors.white
                                              : palette.link))),
                              if (presentation.compactBadges.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          for (final badge
                                              in presentation.compactBadges)
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(badge.icon,
                                                      size: 12,
                                                      color: Colors.white),
                                                  const SizedBox(width: 2),
                                                  Text(badge.label,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white)),
                                                ]),
                                        ])),
                            ]),
                        if (presentation.seriesTitle?.isNotEmpty == true)
                          Text(presentation.seriesTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        if (customFieldBadges.isNotEmpty)
                          Text(customFieldBadges.join(' | '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                        const Spacer(),
                        Text(
                            [
                              presentation.format,
                              presentation.releaseDate?.year.toString()
                            ].whereType<String>().join(' \u2013 '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ])),
                ])),
            if (_hovered || selectionMode || checked)
              Positioned(
                  left: 0,
                  bottom: 0,
                  child: LibraryTileSelectionToggleButton(
                      onTap: onSelectionToggleTap,
                      child: LibraryTileSelectionToggle(
                          selected: checked,
                          accentColor: palette.utilityAction,
                          integrated: true,
                          highlighted: selected))),
            if (_hovered && onEditTap != null)
              Positioned(
                  right: 5,
                  top: 5,
                  child: LibraryTileHoverActionButton(
                      icon: AppIcons.inlineEdit,
                      tooltip: 'Edit',
                      onTap: onEditTap!)),
          ]),
        ),
      ),
    ));
  }

  // ---------------------------------------------------------------------------
  // Standard vertical card (grid / card view).
  // ---------------------------------------------------------------------------

  Widget _buildStandardVerticalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
  }) {
    final palette = appPalette(context);
    final background = selected
        ? (selectedColor == kAppSelection
            ? libraryWorkspaceSelectionBackground(context)
            : selectedColor)
        : palette.panelRaised;
    final titleColor = kLibraryCardTitleColor;
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: selected ? palette.utilityAction : palette.cardBorder,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onSecondaryTapUp: onSecondaryTapUp,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.zero,
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
                            if (customFieldBadges.isNotEmpty)
                              Text(customFieldBadges.join(' | '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? Colors.white
                                          : mutedColor)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: SizedBox(
                            height: 57,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(item.dto.primaryLabel,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: titleColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4))),
                                Row(children: [
                                  Expanded(
                                      child: Text(
                                          presentation.seriesTitle ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: palette.textPrimary))),
                                  if (presentation.releaseDate != null)
                                    Text('${presentation.releaseDate!.year}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: palette.textPrimary)),
                                ]),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                if (_hovered || selectionMode || checked)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: LibraryTileSelectionToggleButton(
                      onTap: onSelectionToggleTap,
                      child: LibraryTileSelectionToggle(
                        selected: checked,
                        accentColor: palette.utilityAction,
                        integrated: true,
                        highlighted: selected,
                      ),
                    ),
                  ),
                if (_hovered && onEditTap != null)
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
      title: item.dto.primaryLabel,
      itemNumber: presentation.itemNumber,
      imageUrl: item.dto.imageUrl,
      libraryEntryRef: item.source.libraryEntryRef,
      targetCacheWidth: coverCacheWidth,
      fallbackAspectRatio: 1 /
          libraryViewProfileForKind(item.source.mediaKind)
              .coverGridHeightFactor,
      accentColor: accentColor,
      fit: fit,
      borderRadius: borderRadius,
      enableFullscreen: false,
      enableSecondaryControl: false,
    );
    final wrapOverlay = presentation.coverOverlayBuilder;
    return wrapOverlay != null ? wrapOverlay(cover) : cover;
  }

  int? _targetCacheWidth(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio <= 0) return null;
    final rawWidth = coverWidth * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}
