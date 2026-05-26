import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
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
    required this.selectedAnchorId,
    required this.selectedIds,
    required this.accent,
    required this.emptyBuilder,
    required this.onApplySelection,
    required this.onActivateItem,
    required this.onToggleSelectionItem,
    required this.onOpenItem,
    this.onItemContextMenu,
  });

  final List<LibraryProjectionItem> items;
  final String? selectedId;
  final String? selectedAnchorId;
  final Set<String> selectedIds;
  final Color accent;
  final WidgetBuilder emptyBuilder;
  final void Function(Set<String> ids, String focusedId) onApplySelection;
  final ValueChanged<String> onActivateItem;
  final ValueChanged<String> onToggleSelectionItem;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
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
    if (nextIndex != _currentIndex && widget.selectedIds.isEmpty) {
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
        final activeItem = widget.items[_currentIndex.clamp(0, widget.items.length - 1)];
        final stageHeight = math.min(constraints.maxHeight * 0.72, 560.0);
        return Focus(
          autofocus: true,
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _focusNode.requestFocus,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A2233),
                    kAppGridCanvas,
                    Color(0xFF101620),
                  ],
                ),
              ),
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
                                  if (widget.selectedIds.isEmpty) {
                                    widget.onActivateItem(widget.items[index].entry.id);
                                  }
                                },
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  return AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      final page = _controller.hasClients
                                          ? (_controller.page ?? _currentIndex.toDouble())
                                          : _currentIndex.toDouble();
                                      final distance = (page - index).abs().clamp(0.0, 1.0);
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
                                        selected: widget.selectedIds.contains(item.entry.id),
                                        focused: index == _currentIndex,
                                        onTap: () => _handleTap(item, index),
                                        onDoubleTap: () => widget.onOpenItem(item),
                                        onSecondaryTapUp: widget.onItemContextMenu == null
                                            ? null
                                            : (details) => widget.onItemContextMenu!(item, details.globalPosition),
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
                                  onPressed: _currentIndex == 0 ? null : () => _animateToPage(_currentIndex - 1),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _FlowNavButton(
                                  key: const ValueKey('flow-carousel-next'),
                                  icon: Icons.chevron_right,
                                  onPressed: _currentIndex >= widget.items.length - 1
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
                                    key: ValueKey('flow-carousel-backdrop-${activeItem.entry.id}'),
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
                      onToggle: () => setState(() => _showAccentShelf = !_showAccentShelf),
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
    final index = widget.items.indexWhere((item) => item.entry.id == selectedId);
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
      if (_controller.hasClients && _controller.position.isScrollingNotifier.value) {
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
      if (_controller.hasClients && _controller.position.isScrollingNotifier.value) {
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
    final isRangeSelection = _isRangeSelectionModifierPressed();
    final isToggleSelection = _isToggleSelectionModifierPressed();
    if (isRangeSelection) {
      final anchorId = widget.selectedAnchorId ?? widget.selectedId ?? item.entry.id;
      final orderedIds = [for (final candidate in widget.items) candidate.entry.id];
      final rangeIds = selectionRangeItemIds(
        orderedIds,
        anchorId: anchorId,
        targetId: item.entry.id,
      );
      widget.onApplySelection(
        isToggleSelection ? {...widget.selectedIds, ...rangeIds} : rangeIds,
        item.entry.id,
      );
      return;
    }
    if (isToggleSelection) {
      widget.onToggleSelectionItem(item.entry.id);
      return;
    }
    widget.onActivateItem(item.entry.id);
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
    final entry = item.entry;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: kAppAnimNormal,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: Stack(
          key: ValueKey(entry.id),
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: 1.45,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Opacity(
                  opacity: 0.34,
                  child: LibraryCoverImage(
                    title: entry.resolvedTitle,
                    itemNumber: entry.itemNumber,
                    imageUrl: entry.displayCoverUrl,
                    ownedItemId: entry.ownedItemId,
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
                    const Color(0xF0101620),
                    accent.withValues(alpha: 0.12),
                    const Color(0xE6101620),
                    const Color(0xFF0D131C),
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
                    const Color(0xAA05080C),
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
    return Tooltip(
      message: active ? 'Hide shelf backdrop' : 'Show shelf backdrop',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: kAppAnimFast,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? accent.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: active ? accent : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowCarouselCard extends StatelessWidget {
  const _FlowCarouselCard({
    required this.item,
    required this.accent,
    required this.selected,
    required this.focused,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
  });

  final LibraryProjectionItem item;
  final Color accent;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final title = entry.resolvedTitle;
    final subtitle = [
      if (entry.itemNumber != null && entry.itemNumber!.trim().isNotEmpty)
        '#${entry.itemNumber}',
      if (entry.publisher != null && entry.publisher!.trim().isNotEmpty)
        entry.publisher,
      if (entry.releaseYear != null) entry.releaseYear.toString(),
    ].join('  ·  ');
    return SizedBox(
      width: 260,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: kAppRadiusLarge,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: AnimatedContainer(
            duration: kAppAnimFast,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: focused ? const Color(0xFF162033) : const Color(0xFF111923),
              borderRadius: kAppRadiusLarge,
              border: Border.all(
                color: selected
                    ? accent
                    : focused
                        ? accent.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.08),
                width: selected ? 2.2 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: focused ? 0.34 : 0.18),
                  blurRadius: focused ? 36 : 18,
                  offset: Offset(0, focused ? 18 : 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: LibraryInteractiveCover(
                            title: title,
                            itemNumber: entry.itemNumber,
                            imageUrl: entry.displayCoverUrl,
                            ownedItemId: entry.ownedItemId,
                            accentColor: accent,
                            enableFullscreen: false,
                            enableSecondaryControl: false,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: LibraryCoverBadges(
                          isOwned: entry.isOwned,
                          isTracked: entry.isTracked,
                          isWishlisted: entry.isWishlisted,
                          hasMissingCover: entry.hasMissingCover,
                          hasMissingMetadata: entry.hasMissingMetadata,
                        ),
                      ),
                      if (selected)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kAppTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowCarouselFooter extends StatefulWidget {
  const _FlowCarouselFooter({
    required this.item,
    required this.index,
    required this.total,
    required this.accent,
  });

  final LibraryProjectionItem item;
  final int index;
  final int total;
  final Color accent;

  @override
  State<_FlowCarouselFooter> createState() => _FlowCarouselFooterState();
}

class _FlowCarouselFooterState extends State<_FlowCarouselFooter> {
  bool _showReleases = false;

  @override
  void didUpdateWidget(covariant _FlowCarouselFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.entry.id != oldWidget.item.entry.id) {
      _showReleases = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.item.entry;
    final meta = [
      if (entry.series?.seriesTitle != null && entry.series!.seriesTitle!.trim().isNotEmpty)
        entry.series!.seriesTitle,
      if (entry.publisher != null && entry.publisher!.trim().isNotEmpty)
        entry.publisher,
      if (entry.releaseDate != null)
        '${entry.releaseDate!.year}-${entry.releaseDate!.month.toString().padLeft(2, '0')}-${entry.releaseDate!.day.toString().padLeft(2, '0')}'
      else if (entry.releaseYear != null)
        entry.releaseYear.toString(),
      if (entry.referenceFormatLabel != null) entry.referenceFormatLabel,
    ].whereType<String>().join('  ·  ');

    final editions = entry.editions;
    final hasReleases = editions.length > 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF131C28),
        borderRadius: kAppRadiusLarge,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.index + 1} / ${widget.total}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: widget.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.resolvedTitle,
                        key: const ValueKey('flow-carousel-footer-title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          meta,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kAppTextMuted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (entry.itemNumber != null && entry.itemNumber!.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: widget.accent.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '#${entry.itemNumber}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
              ],
            ),
            if (hasReleases) ...[
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _showReleases = !_showReleases),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showReleases
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18,
                        color: widget.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${editions.length} releases',
                        style: TextStyle(
                          color: widget.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showReleases) ...[
                const SizedBox(height: 6),
                for (final edition in editions)
                  _FlowCarouselReleaseRow(
                    edition: edition,
                    isOwned: edition.id == entry.referenceEditionId,
                    accent: widget.accent,
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _FlowCarouselReleaseRow extends StatelessWidget {
  const _FlowCarouselReleaseRow({
    required this.edition,
    required this.isOwned,
    required this.accent,
  });

  final CatalogEdition edition;
  final bool isOwned;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (isOwned)
            Icon(Icons.check_circle, size: 14, color: accent)
          else
            const Icon(Icons.circle_outlined, size: 14, color: kAppTextMuted),
          const SizedBox(width: 8),
          if (edition.physicalFormat != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FormatBadge.fromFormat(
                id: edition.physicalFormat!,
                label: edition.physicalFormatLabel ?? edition.physicalFormat!,
                compact: true,
              ),
            ),
          Expanded(
            child: Text(
              edition.title ?? edition.physicalFormatLabel ?? 'Release',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isOwned ? Colors.white : kAppTextMuted,
                fontSize: 12,
                fontWeight: isOwned ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (edition.variants.isNotEmpty)
            Text(
              '${edition.variants.length} variant${edition.variants.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: kAppTextMuted,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Material(
        color: const Color(0xB3111923),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
          iconSize: 28,
          tooltip: icon == Icons.chevron_left ? 'Previous item' : 'Next item',
        ),
      ),
    );
  }
}

bool _isRangeSelectionModifierPressed() {
  return HardwareKeyboard.instance.isShiftPressed;
}

bool _isToggleSelectionModifierPressed() {
  final keyboard = HardwareKeyboard.instance;
  return keyboard.isControlPressed || keyboard.isMetaPressed;
}