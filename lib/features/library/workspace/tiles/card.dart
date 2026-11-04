import 'card_footer.dart';
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

  /// A vertical card with the headline above the cover (see
  /// [LibraryCardPresentation.headline]).
  headlined,
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

  /// Whether a headlined card shows its headline; off when the chosen folder
  /// already names it.
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
    // Resolve the kind-supplied card presentation (or fall back to default).
    final headlined = cardLayout == LibraryCardLayout.headlined;
    final coverFocused = cardLayout == LibraryCardLayout.vertical || headlined;
    final presentation =
        libraryPresentationForKind(registration.kind).buildCardPresentation(
      item,
      coverFocused: coverFocused,
    );

    final coverCacheWidth = _targetCacheWidth(context);

    if (coverFocused) {
      return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: _buildStandardVerticalCard(
            context: context,
            selectedTitleColor: selectedTitleColor,
            mutedColor: resolvedMutedTextColor,
            coverCacheWidth: coverCacheWidth,
            presentation: presentation,
            headlined: headlined,
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
    final background = selected
        ? (selectedColor == kAppSelection
            ? palette.utilityAction
            : selectedColor)
        : checked
            ? kLibraryCheckedItemBackground
            : palette.panelRaised;
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
                        padding: const EdgeInsets.all(4),
                        child: Row(children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: coverWidth),
                              child: _buildCover(
                                  context: context,
                                  coverCacheWidth: coverCacheWidth,
                                  presentation: presentation,
                                  fit: BoxFit.contain,
                                  borderRadius: 0,
                                  intrinsicSize: true)),
                          const SizedBox(width: 5),
                          Expanded(
                              child: presentation.splitHorizontalMetadata
                                  ? _SplitMetadataHorizontalBody(
                                      item: item,
                                      presentation: presentation,
                                      selected: selected,
                                    )
                                  : Stack(children: [
                                      // Title, series and badges may exceed a short
                                      // card; they clip rather than overflow.
                                      Positioned.fill(
                                          bottom: 26,
                                          child: ClipRect(
                                              child: OverflowBox(
                                                  alignment: Alignment.topLeft,
                                                  maxHeight: double.infinity,
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                      item.dto
                                                                          .primaryLabel,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          height:
                                                                              1.15,
                                                                          color: selected
                                                                              ? Colors.white
                                                                              : palette.itemTitle))),
                                                              if (presentation
                                                                  .compactBadges
                                                                  .isNotEmpty)
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            6),
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          for (final badge
                                                                              in presentation.compactBadges)
                                                                            Row(mainAxisSize: MainAxisSize.min, children: [
                                                                              if (badge.icon != null) ...[
                                                                                Icon(badge.icon, size: 12, color: selected ? Colors.white : palette.textPrimary),
                                                                                const SizedBox(width: 2),
                                                                              ],
                                                                              Text(badge.label, style: TextStyle(fontSize: 12, fontWeight: badge.icon == null ? FontWeight.w400 : FontWeight.w700, color: selected ? Colors.white : palette.textPrimary)),
                                                                            ]),
                                                                        ])),
                                                            ]),
                                                        if (presentation
                                                                .detailLine
                                                                ?.isNotEmpty ==
                                                            true)
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 14),
                                                              child: Text(
                                                                  presentation
                                                                      .detailLine!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: selected
                                                                          ? Colors
                                                                              .white
                                                                          : palette
                                                                              .textMuted))),
                                                        if (presentation
                                                                .seriesTitle
                                                                ?.isNotEmpty ==
                                                            true)
                                                          Text(
                                                              presentation
                                                                  .seriesTitle!,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: selected
                                                                      ? Colors
                                                                          .white
                                                                      : palette
                                                                          .textPrimary)),
                                                        if (customFieldBadges
                                                            .isNotEmpty)
                                                          Text(
                                                              customFieldBadges
                                                                  .join(' | '),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: selected
                                                                      ? Colors
                                                                          .white
                                                                      : palette
                                                                          .textMuted)),
                                                      ])))),
                                      Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: LibraryCardFooter(
                                              label: [
                                                presentation.format,
                                                presentation.releaseDate?.year
                                                    .toString()
                                              ]
                                                  .whereType<String>()
                                                  .join(' \u2013 '),
                                              value: presentation.valueLabel,
                                              status: LibraryItemStatusBadge(
                                                  item: item,
                                                  selected: selected,
                                                  style:
                                                      LibraryCollectionStatusMarkStyle
                                                          .pill),
                                              selected: selected)),
                                    ])),
                        ])),
                    if (appPresentationPlatform.isNativeMobile && checked)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                              color:
                                  palette.utilityAction.withValues(alpha: .35)),
                        ),
                      ),
                    if (appPresentationPlatform.isNativeMobile &&
                        selectionMode &&
                        onSelectionToggleTap != null)
                      Positioned.fill(
                        child: AppPressClaim(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onSelectionToggleTap,
                          ),
                        ),
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
                                  integrated: true,
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

  Widget _buildStandardVerticalCard({
    required BuildContext context,
    required Color selectedTitleColor,
    required Color mutedColor,
    required int? coverCacheWidth,
    required LibraryCardPresentation presentation,
    required bool headlined,
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
    final isHeadlined = headlined;
    Widget buildCover({required Alignment alignment}) => _buildCover(
          context: context,
          coverCacheWidth: coverCacheWidth,
          presentation: presentation,
          fit: BoxFit.contain,
          alignment: alignment,
          borderRadius: 0,
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
                          child: isHeadlined
                              ? _HeadlinedVerticalCardBody(
                                  item: item,
                                  presentation: presentation,
                                  showHeadline: widget.showHeadline,
                                  selected: selected,
                                  titleColor: titleColor,
                                  detailColor: detailColor,
                                  mutedColor: mutedColor,
                                  customFieldBadges: customFieldBadges,
                                  buildCover: buildCover,
                                )
                              : _StandardVerticalCardBody(
                                  item: item,
                                  presentation: presentation,
                                  selected: selected,
                                  titleColor: titleColor,
                                  detailColor: detailColor,
                                  mutedColor: mutedColor,
                                  customFieldBadges: customFieldBadges,
                                  buildCover: buildCover,
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
                        if (appPresentationPlatform.isNativeMobile &&
                            selectionMode &&
                            onSelectionToggleTap != null)
                          Positioned.fill(
                            child: AppPressClaim(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: onSelectionToggleTap,
                              ),
                            ),
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
                                integrated: true,
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

  int? _targetCacheWidth(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio <= 0) return null;
    final rawWidth = coverWidth * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}

class _SplitMetadataHorizontalBody extends StatelessWidget {
  const _SplitMetadataHorizontalBody({
    required this.item,
    required this.presentation,
    required this.selected,
  });

  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = selected ? Colors.white : palette.textPrimary;
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 58,
        child: Text(presentation.headline ?? item.dto.primaryLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: selected ? Colors.white : palette.itemTitle,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
      if (presentation.numberLabel case final number?)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: palette.utilityAction,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      if (presentation.detailLine case final date?)
        Positioned(
          right: 0,
          top: 28,
          child: Text(date, style: TextStyle(color: foreground, fontSize: 12)),
        ),
      if (presentation.outlinedPill != null ||
          presentation.compactBadges.isNotEmpty)
        Positioned(
          bottom: 0,
          left: 0,
          right: 32,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (presentation.outlinedPill case final pill?)
              Flexible(
                  child: LibraryOutlinedPill(
                      pill: pill,
                      color: selected ? Colors.white : palette.utilityAction)),
            for (final badge in presentation.compactBadges)
              if (badge.icon case final icon?)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Tooltip(
                      message: badge.label,
                      child: Icon(icon, size: 16, color: foreground)),
                ),
          ]),
        ),
      Positioned(
        right: 0,
        bottom: 0,
        child: LibraryItemStatusBadge(
          item: item,
          selected: selected,
          style: LibraryCollectionStatusMarkStyle.pill,
        ),
      ),
    ]);
  }
}

class _HeadlinedVerticalCardBody extends StatelessWidget {
  const _HeadlinedVerticalCardBody({
    required this.item,
    required this.presentation,
    required this.showHeadline,
    required this.selected,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.buildCover,
  });

  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool showHeadline;
  final bool selected;
  final Color titleColor;
  final Color detailColor;
  final Color mutedColor;
  final List<String> customFieldBadges;
  final Widget Function({required Alignment alignment}) buildCover;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeadline)
          _HeadlinedCardTitle(
            text: presentation.headline ?? item.dto.primaryLabel,
            color: titleColor,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildCover(alignment: Alignment.topCenter),
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: LibraryItemStatusBadge(
                    item: item,
                    selected: selected,
                    style: LibraryCollectionStatusMarkStyle.cover,
                    width: 29,
                    height: 27,
                  ),
                ),
                if (customFieldBadges.isNotEmpty)
                  Text(
                    customFieldBadges.join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : mutedColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _HeadlinedCardFooter(
          presentation: presentation,
          numberColor: titleColor,
          dateColor: detailColor,
          pillColor: selected ? Colors.white : palette.utilityAction,
        ),
      ],
    );
  }
}

class _StandardVerticalCardBody extends StatelessWidget {
  const _StandardVerticalCardBody({
    required this.item,
    required this.presentation,
    required this.selected,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.buildCover,
  });

  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;
  final Color titleColor;
  final Color detailColor;
  final Color mutedColor;
  final List<String> customFieldBadges;
  final Widget Function({required Alignment alignment}) buildCover;

  @override
  Widget build(BuildContext context) {
    final subtitle = presentation.format ??
        item.dto.secondaryLabel ??
        presentation.seriesTitle ??
        (presentation.contextFacts.isNotEmpty
            ? presentation.contextFacts.first
            : null);
    final releaseYear = presentation.releaseDate != null
        ? '${presentation.releaseDate!.year}'
        : presentation.suggestionDetail;
    final trailingText = presentation.valueLabel ?? releaseYear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildCover(alignment: Alignment.topCenter),
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: LibraryItemStatusBadge(
                    item: item,
                    selected: selected,
                    style: LibraryCollectionStatusMarkStyle.cover,
                    width: 29,
                    height: 27,
                  ),
                ),
                if (customFieldBadges.isNotEmpty)
                  Text(
                    customFieldBadges.join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : mutedColor,
                    ),
                  ),
              ],
            ),
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
                  child: Text(
                    item.dto.primaryLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (subtitle != null && subtitle.isNotEmpty)
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: presentation.format != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: detailColor,
                          ),
                        ),
                      ),
                    if (trailingText != null && trailingText.isNotEmpty)
                      Text(
                        trailingText,
                        style: TextStyle(
                          fontSize: 12,
                          color: detailColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadlinedCardTitle extends StatelessWidget {
  const _HeadlinedCardTitle({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: 22, maxHeight: kLibraryHeadlinedCardTitleHeight),
      child: SizedBox(
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
              child: Text(text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 18.5714 / 13)))));
}

/// A large number with the date at the right, then an outlined pill row.
class _HeadlinedCardFooter extends StatelessWidget {
  const _HeadlinedCardFooter(
      {required this.presentation,
      required this.numberColor,
      required this.dateColor,
      required this.pillColor});
  final LibraryCardPresentation presentation;
  final Color numberColor;
  final Color dateColor;
  final Color pillColor;

  @override
  Widget build(BuildContext context) {
    final pill = presentation.outlinedPill;
    return SizedBox(
        height: kLibraryHeadlinedCardFooterHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  height: 24,
                  child: Row(children: [
                    Expanded(
                        child: Text(presentation.numberLabel ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: numberColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 24 / 18))),
                    if (presentation.detailLine case final date?)
                      Text(date,
                          style: TextStyle(
                              color: dateColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                  ])),
              if (pill != null)
                Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LibraryOutlinedPill(pill: pill, color: pillColor)),
            ])));
  }
}

/// A [LibraryCardPill] outlined in [color]: the lead segment, on its own
/// fill when it has one, then the value.
class LibraryOutlinedPill extends StatelessWidget {
  const LibraryOutlinedPill(
      {required this.pill, required this.color, super.key});
  final LibraryCardPill pill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget segment(String text, IconData? icon, Color color) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14))),
        ]);
    final lead = pill.lead;
    final value = pill.value;
    final leadBackground = pill.leadBackground;
    return Container(
        height: 22,
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (lead != null)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: leadBackground == null
                    ? null
                    : BoxDecoration(
                        gradient: leadBackground,
                        borderRadius: value == null
                            ? BorderRadius.circular(4)
                            : const BorderRadius.horizontal(
                                left: Radius.circular(4))),
                alignment: Alignment.center,
                child: segment(
                    lead,
                    pill.leadIcon,
                    leadBackground == null
                        ? color
                        : Colors.black.withValues(alpha: .7))),
          if (value != null)
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: segment(value, pill.valueIcon, color))),
        ]));
  }
}
