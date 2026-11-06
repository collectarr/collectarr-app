import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef LibraryFlowItemContextMenuCallback = void Function(
  LibraryProjectionItem item,
  Offset globalPosition,
);

class LibraryFlowCarousel extends StatefulWidget {
  const LibraryFlowCarousel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.accent,
    required this.emptyBuilder,
    this.coverAspectRatio = 2 / 3,
    required this.onActivateItem,
    required this.onOpenItem,
    this.onEditItem,
    this.onItemContextMenu,
  });

  final List<LibraryProjectionItem> items;
  final String? selectedId;
  final Color accent;
  final WidgetBuilder emptyBuilder;

  /// Cover width / height of the kind, kept by every card.
  final double coverAspectRatio;
  final ValueChanged<String> onActivateItem;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
  final ValueChanged<LibraryProjectionItem>? onEditItem;
  final LibraryFlowItemContextMenuCallback? onItemContextMenu;

  @override
  State<LibraryFlowCarousel> createState() => _LibraryFlowCarouselState();
}

class _LibraryFlowCarouselState extends State<LibraryFlowCarousel> {
  late PageController _controller;
  final _focusNode = FocusNode(debugLabel: 'LibraryFlowCarousel');
  int _currentIndex = 0;
  double _viewportFraction = 0.34;
  double? _pendingViewportFraction;
  bool _showAccentShelf = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = _resolvedIndex();
    _controller = PageController(
      initialPage: _currentIndex,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void didUpdateWidget(covariant LibraryFlowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _resolvedIndex();
    if (nextIndex != _currentIndex) {
      _currentIndex = nextIndex;
      if (_controller.hasClients) {
        _controller.animateToPage(
          nextIndex,
          duration: kAppAnimNormal,
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyBuilder(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        _syncViewportFraction(constraints.maxWidth);
        final activeItem =
            widget.items[_currentIndex.clamp(0, widget.items.length - 1)];
        final stageHeight = math.min(constraints.maxHeight * 0.72, 560.0);
        return Focus(
          autofocus: true,
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _focusNode.requestFocus,
            child: DecoratedBox(
              decoration:
                  BoxDecoration(color: libraryViewBackgroundColor(context)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: stageHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: widget.items.length,
                                padEnds: true,
                                onPageChanged: (index) {
                                  setState(() => _currentIndex = index);
                                  widget.onActivateItem(
                                      widget.items[index].target.id);
                                },
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  return AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      final page = _controller.hasClients
                                          ? (_controller.page ??
                                              _currentIndex.toDouble())
                                          : _currentIndex.toDouble();
                                      final distance =
                                          (page - index).abs().clamp(0.0, 1.0);
                                      final focus = 1.0 - distance;
                                      final scale = 0.82 + (0.18 * focus);
                                      final verticalOffset = 34 * (1 - focus);
                                      return Transform.translate(
                                        offset: Offset(0, verticalOffset),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Opacity(
                                            opacity: 0.42 + (0.58 * focus),
                                            child: child,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: _FlowCarouselCard(
                                        item: item,
                                        accent: widget.accent,
                                        coverAspectRatio:
                                            widget.coverAspectRatio,
                                        focused: index == _currentIndex,
                                        onTap: () => _handleTap(item, index),
                                        onDoubleTap: () =>
                                            widget.onOpenItem(item),
                                        onEditTap: widget.onEditItem == null
                                            ? null
                                            : () => widget.onEditItem!(item),
                                        onSecondaryTapUp:
                                            widget.onItemContextMenu == null
                                                ? null
                                                : (details) =>
                                                    widget.onItemContextMenu!(
                                                        item,
                                                        details.globalPosition),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (widget.items.length > 1) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _FlowNavButton(
                                  key: const ValueKey('flow-carousel-prev'),
                                  icon: Icons.chevron_left,
                                  onPressed: _currentIndex == 0
                                      ? null
                                      : () => _animateToPage(_currentIndex - 1),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _FlowNavButton(
                                  key: const ValueKey('flow-carousel-next'),
                                  icon: Icons.chevron_right,
                                  onPressed: _currentIndex >=
                                          widget.items.length - 1
                                      ? null
                                      : () => _animateToPage(_currentIndex + 1),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            if (_showAccentShelf)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: kAppRadiusLarge,
                                  child: _FlowBackdrop(
                                    key: ValueKey(
                                        'flow-carousel-backdrop-${activeItem.target.id}'),
                                    item: activeItem,
                                    accent: widget.accent,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                              child: _FlowCarouselFooter(
                                item: activeItem,
                                index: _currentIndex,
                                total: widget.items.length,
                                accent: widget.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _FlowShelfToggle(
                      active: _showAccentShelf,
                      accent: widget.accent,
                      onToggle: () =>
                          setState(() => _showAccentShelf = !_showAccentShelf),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_currentIndex > 0) {
        _animateToPage(_currentIndex - 1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_currentIndex < widget.items.length - 1) {
        _animateToPage(_currentIndex + 1);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  int _resolvedIndex() {
    if (widget.items.isEmpty) {
      return 0;
    }
    final selectedId = widget.selectedId;
    if (selectedId == null) {
      return _currentIndex.clamp(0, widget.items.length - 1);
    }
    final index =
        widget.items.indexWhere((item) => item.target.id == selectedId);
    return index >= 0 ? index : 0;
  }

  void _syncViewportFraction(double width) {
    final nextFraction = width >= 1500
        ? 0.22
        : width >= 1200
            ? 0.26
            : width >= 900
                ? 0.34
                : 0.54;
    if ((_viewportFraction - nextFraction).abs() < 0.001 ||
        (_pendingViewportFraction != null &&
            (_pendingViewportFraction! - nextFraction).abs() < 0.001)) {
      return;
    }
    _pendingViewportFraction = nextFraction;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final pendingFraction = _pendingViewportFraction;
      if (pendingFraction == null ||
          (_viewportFraction - pendingFraction).abs() < 0.001) {
        return;
      }
      if (_controller.hasClients &&
          _controller.position.isScrollingNotifier.value) {
        _syncViewportFractionForPendingFrame();
        return;
      }
      _applyViewportFraction(pendingFraction);
    });
  }

  void _syncViewportFractionForPendingFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final pendingFraction = _pendingViewportFraction;
      if (pendingFraction == null) {
        return;
      }
      if (_controller.hasClients &&
          _controller.position.isScrollingNotifier.value) {
        _syncViewportFractionForPendingFrame();
        return;
      }
      if ((_viewportFraction - pendingFraction).abs() < 0.001) {
        _pendingViewportFraction = null;
        return;
      }
      _applyViewportFraction(pendingFraction);
    });
  }

  void _applyViewportFraction(double viewportFraction) {
    final previous = _controller;
    final targetPage = previous.hasClients
        ? (previous.page ?? _currentIndex.toDouble()).round()
        : _currentIndex;
    _viewportFraction = viewportFraction;
    _pendingViewportFraction = null;
    _controller = PageController(
      initialPage: targetPage,
      viewportFraction: viewportFraction,
    );
    if (mounted) {
      setState(() {
        _currentIndex = targetPage.clamp(0, widget.items.length - 1);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  void _handleTap(LibraryProjectionItem item, int index) {
    _focusNode.requestFocus();
    if (appPresentationPlatform.isNativeMobile) {
      if (index != _currentIndex) {
        _animateToPage(index);
      } else {
        widget.onOpenItem(item);
      }
      return;
    }
    widget.onActivateItem(item.target.id);
    if (index != _currentIndex) {
      _animateToPage(index);
    }
  }

  void _animateToPage(int index) {
    _focusNode.requestFocus();
    if (!_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }
        _animateToPage(index);
      });
      return;
    }
    _controller.animateToPage(
      index,
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
    );
  }
}

class _FlowBackdrop extends StatelessWidget {
  const _FlowBackdrop({
    super.key,
    required this.item,
    required this.accent,
  });

  final LibraryProjectionItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: kAppAnimNormal,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: Stack(
          key: ValueKey(item.target.id),
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: 1.45,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Opacity(
                  opacity: 0.34,
                  child: LibraryCoverImage(
                    title: item.dto.primaryLabel,
                    mediaKind: item.source.mediaKind,
                    itemNumber:
                        libraryCardPresentationForEntry(item).itemNumber,
                    imageUrl: item.dto.imageUrl,
                    libraryEntryRef: item.source.libraryEntryRef,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.surface.withValues(alpha: 0.94),
                    accent.withValues(alpha: 0.12),
                    palette.surfaceSubtle.withValues(alpha: 0.92),
                    palette.surface.withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.08,
                  colors: [
                    accent.withValues(alpha: 0.18),
                    Colors.transparent,
                    palette.surface.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowShelfToggle extends StatelessWidget {
  const _FlowShelfToggle({
    required this.active,
    required this.accent,
    required this.onToggle,
  });

  final bool active;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Tooltip(
      message: active ? 'Hide shelf backdrop' : 'Show shelf backdrop',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onToggle,
          child: AnimatedContainer(
            duration: kAppAnimFast,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? accent.withValues(alpha: 0.22)
                  : palette.surfaceSubtle.withValues(alpha: 0.82),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.5)
                    : palette.divider.withValues(alpha: 0.72),
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: active ? accent : palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// Flow card metrics: the widest cover, and the card's padding and the title
// and subtitle beneath the cover.
const _kFlowCoverMaxWidth = 232.0;
const _kFlowCardHorizontalPadding = 28.0;
const _kFlowCardChromeHeight = 104.0;

class _FlowCarouselCard extends StatefulWidget {
  const _FlowCarouselCard({
    required this.item,
    required this.accent,
    required this.coverAspectRatio,
    required this.focused,
    required this.onTap,
    this.onEditTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
  });

  final LibraryProjectionItem item;
  final Color accent;
  final double coverAspectRatio;
  final bool focused;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;

  @override
  State<_FlowCarouselCard> createState() => _FlowCarouselCardState();
}

class _FlowCarouselCardState extends State<_FlowCarouselCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dto = widget.item.dto;
    final presentation = libraryCardPresentationForEntry(widget.item);
    final palette = appPalette(context);
    final title = dto.primaryLabel;
    final itemNumber = presentation.itemNumber;
    final cardColor = widget.focused
        ? Color.alphaBlend(
            widget.accent.withValues(alpha: 0.12),
            palette.cardBackground,
          )
        : palette.panel;
    final showEditButton = _hovered && widget.onEditTap != null;
    final wrapCover =
        presentation.coverOverlayBuilder ?? (Widget cover) => cover;
    // The card hugs the cover at its own shape, so the cover never gets bars.
    // Covers share one height, that of a cover of the kind's aspect ratio as
    // tall as the stage allows beneath it the title and subtitle; only one too
    // wide for its page is smaller.
    Widget card(
      BoxConstraints constraints,
      double aspectRatio,
      ValueChanged<double> onAspectRatio,
    ) {
      final coverHeight = math.min(
          _kFlowCoverMaxWidth / widget.coverAspectRatio,
          math.max(0.0, constraints.maxHeight - _kFlowCardChromeHeight));
      final coverWidth = math.min(coverHeight * aspectRatio,
          math.max(0.0, constraints.maxWidth - _kFlowCardHorizontalPadding));
      return SizedBox(
        width: coverWidth + _kFlowCardHorizontalPadding,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            borderRadius: kAppRadiusLarge,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onSecondaryTapUp: widget.onSecondaryTapUp,
            onHover: (value) {
              if (_hovered == value) {
                return;
              }
              setState(() => _hovered = value);
            },
            child: AnimatedContainer(
              duration: kAppAnimFast,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: kAppRadiusLarge,
                border: Border.all(
                  color: widget.focused
                      ? widget.accent.withValues(alpha: 0.55)
                      : palette.cardBorder,
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: widget.focused ? 0.34 : 0.18),
                    blurRadius: widget.focused ? 36 : 18,
                    offset: Offset(0, widget.focused ? 18 : 10),
                  ),
                ],
              ),
              child: LibraryItemContent(
                view: LibraryItemContentView.flow,
                data: LibraryCardBodyData(
                  item: widget.item,
                  presentation: presentation,
                  selected: false,
                  active: widget.focused,
                  showHeadline: true,
                  titleColor: palette.itemTitle,
                  detailColor: palette.textMuted,
                  mutedColor: palette.textMuted,
                  customFieldBadges: widget.item.customFieldBadges,
                  coverWidth: constraints.maxWidth,
                  pillStatus: const SizedBox.shrink(),
                  coverStatus: const SizedBox.shrink(),
                  buildCover: ({required alignment}) => AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: wrapCover(LibraryInteractiveCover(
                              title: title,
                              mediaKind: widget.item.source.mediaKind,
                              itemNumber: itemNumber,
                              imageUrl: dto.imageUrl,
                              libraryEntryRef:
                                  widget.item.source.libraryEntryRef,
                              accentColor: widget.accent,
                              enableFullscreen: false,
                              alignment: alignment,
                              enableSecondaryControl: false,
                              enableHoverCue: false,
                              fallbackAspectRatio: widget.coverAspectRatio,
                              onAspectRatio: onAspectRatio,
                            )),
                          ),
                        ),
                        if (showEditButton)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: LibraryTileHoverActionButton(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit item',
                              onTap: widget.onEditTap!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LibraryCoverShape(
      imageUrl: dto.imageUrl,
      libraryEntryRef: widget.item.source.libraryEntryRef,
      fallbackAspectRatio: widget.coverAspectRatio,
      followsImage: presentation.coverOverlayBuilder == null,
      builder: (context, aspectRatio, onAspectRatio) => LayoutBuilder(
        builder: (context, constraints) =>
            card(constraints, aspectRatio, onAspectRatio),
      ),
    );
  }
}

class _FlowCarouselFooter extends StatelessWidget {
  const _FlowCarouselFooter(
      {required this.item,
      required this.index,
      required this.total,
      required this.accent});
  final LibraryProjectionItem item;
  final int index;
  final int total;
  final Color accent;
  @override
  Widget build(BuildContext context) =>
      libraryCardPresentationForEntry(item).flowFooterBuilder(context,
          LibraryFlowFooterData(index: index, total: total, accent: accent));
}

class _FlowNavButton extends StatelessWidget {
  const _FlowNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Material(
        color: palette.surface.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: palette.textPrimary,
          iconSize: 28,
          tooltip: icon == Icons.chevron_left ? 'Previous item' : 'Next item',
        ),
      ),
    );
  }
}
