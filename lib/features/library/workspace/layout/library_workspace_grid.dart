import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef LibraryGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

typedef LibraryGridItemId<T> = String Function(T item);

class LibraryWorkspaceGrid<T> extends StatefulWidget {
  const LibraryWorkspaceGrid({
    required this.items,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    this.initialCrossAxisCount,
    this.selectionEnabled = false,
    this.selectedIds = const {},
    this.itemIdOf,
    this.onSelectionChanged,
    this.shrinkWrap = false,
    this.scrollable = true,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.padding = const EdgeInsets.all(10),
    this.backgroundColor = kAppGridCanvas,
    super.key,
  });

  final List<T> items;
  final LibraryGridItemBuilder<T> itemBuilder;
  final WidgetBuilder emptyBuilder;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final int? initialCrossAxisCount;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final LibraryGridItemId<T>? itemIdOf;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final bool shrinkWrap;
  final bool scrollable;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  State<LibraryWorkspaceGrid<T>> createState() =>
      _LibraryWorkspaceGridState<T>();
}

class _LibraryWorkspaceGridState<T> extends State<LibraryWorkspaceGrid<T>> {
  final _scrollController = ScrollController();
  final _selectionRectNotifier = ValueNotifier<Rect?>(null);
  int? _stableCrossAxisCount;
  bool _freezeCrossAxisCount = false;
  Offset? _dragStart;
  Set<String> _dragBaseSelection = const {};

  @override
  void initState() {
    super.initState();
    _stableCrossAxisCount = widget.initialCrossAxisCount;
    _freezeCrossAxisCount = widget.initialCrossAxisCount != null;
  }

  @override
  void dispose() {
    _selectionRectNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LibraryWorkspaceGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxCrossAxisExtent != widget.maxCrossAxisExtent ||
        oldWidget.crossAxisSpacing != widget.crossAxisSpacing ||
        oldWidget.mainAxisExtent != widget.mainAxisExtent ||
        oldWidget.padding != widget.padding) {
      _stableCrossAxisCount = null;
    }
    if (oldWidget.initialCrossAxisCount != widget.initialCrossAxisCount) {
      if (widget.initialCrossAxisCount != null) {
        _stableCrossAxisCount = widget.initialCrossAxisCount;
        _freezeCrossAxisCount = true;
      } else if (oldWidget.initialCrossAxisCount != null) {
        _freezeCrossAxisCount = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyBuilder(context);
    }
    final backgroundColor = widget.backgroundColor == kAppGridCanvas
        ? appPalette(context).gridCanvas
        : widget.backgroundColor;
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = widget.padding.resolve(Directionality.of(context));
        final gridWidth =
            math.max(0.0, constraints.maxWidth - padding.left - padding.right);
        final crossAxisCount = _resolveStableCrossAxisCount(gridWidth);
        final tileWidth = widget.maxCrossAxisExtent;
        final crossAxisSpacing = widget.crossAxisSpacing;
        final usedGridWidth = (crossAxisCount * tileWidth) +
            ((crossAxisCount - 1) * crossAxisSpacing);
        final extraRightPadding = math.max(0.0, gridWidth - usedGridWidth);
        final effectivePadding = padding.copyWith(
          right: padding.right + extraRightPadding,
        );
        final rowCount = (widget.items.length / crossAxisCount).ceil();
        final nestedGridHeight = widget.shrinkWrap && !widget.scrollable
            ? effectivePadding.top +
                effectivePadding.bottom +
                (rowCount * widget.mainAxisExtent) +
                ((rowCount - 1) * widget.mainAxisSpacing)
            : null;
        final grid = GridView.builder(
          controller: widget.scrollable ? _scrollController : null,
          shrinkWrap: widget.shrinkWrap,
          physics:
              widget.scrollable ? null : const NeverScrollableScrollPhysics(),
          padding: effectivePadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: widget.mainAxisExtent,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) => widget.itemBuilder(
            context,
            widget.items[index],
          ),
        );
        final boundedGrid = nestedGridHeight == null
            ? grid
            : SizedBox(height: nestedGridHeight, child: grid);
        if (!widget.selectionEnabled ||
            widget.itemIdOf == null ||
            widget.onSelectionChanged == null) {
          return ColoredBox(color: backgroundColor, child: boundedGrid);
        }
        final selectionLayer = Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (event.kind != PointerDeviceKind.mouse) {
              return;
            }
            if ((event.buttons & kPrimaryMouseButton) == 0) {
              return;
            }
            _dragStart = event.localPosition;
            _dragBaseSelection = _selectionIsAdditive
                ? Set<String>.from(widget.selectedIds)
                : const {};
            _selectionRectNotifier.value = Rect.fromPoints(
              event.localPosition,
              event.localPosition,
            );
          },
          onPointerMove: (event) {
            final start = _dragStart;
            if (start == null) {
              return;
            }
            final rect = Rect.fromPoints(start, event.localPosition);
            final rectSelection = _selectedIdsForRect(
              rect,
              padding: effectivePadding,
              crossAxisCount: crossAxisCount,
              tileWidth: tileWidth,
              crossAxisSpacing: crossAxisSpacing,
            );
            _selectionRectNotifier.value = rect;
            widget.onSelectionChanged!(
              _selectionIsAdditive
                  ? {..._dragBaseSelection, ...rectSelection}
                  : rectSelection,
            );
          },
          onPointerUp: (_) {
            _dragStart = null;
            _dragBaseSelection = const {};
            _selectionRectNotifier.value = null;
          },
          onPointerCancel: (_) {
            _dragStart = null;
            _dragBaseSelection = const {};
            _selectionRectNotifier.value = null;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              boundedGrid,
              ValueListenableBuilder<Rect?>(
                valueListenable: _selectionRectNotifier,
                builder: (context, rect, _) {
                  if (rect == null) return const SizedBox.shrink();
                  return IgnorePointer(
                    child: CustomPaint(
                      painter: _SelectionRectPainter(rect),
                    ),
                  );
                },
              ),
            ],
          ),
        );
        return ColoredBox(
          color: backgroundColor,
          child: nestedGridHeight == null
              ? selectionLayer
              : SizedBox(height: nestedGridHeight, child: selectionLayer),
        );
      },
    );
  }

  int _resolveStableCrossAxisCount(double gridWidth) {
    if (_freezeCrossAxisCount && _stableCrossAxisCount != null) {
      return _stableCrossAxisCount!;
    }
    final spacing = widget.crossAxisSpacing;
    final cellAndGap = widget.maxCrossAxisExtent + spacing;
    final computed = math.max(1, ((gridWidth + spacing) / cellAndGap).floor());
    final previous = _stableCrossAxisCount;
    if (previous == null) {
      _stableCrossAxisCount = computed;
      return computed;
    }

    // Keep a wider dead-zone for larger covers to avoid resize oscillation.
    final hysteresis =
        (widget.maxCrossAxisExtent * 0.14).clamp(18.0, 54.0).toDouble();
    final growThreshold = ((previous + 1) * cellAndGap) - spacing + hysteresis;
    final shrinkThreshold = (previous * cellAndGap) - spacing;

    var next = previous;
    if (computed > previous && gridWidth >= growThreshold) {
      next = computed;
    } else if (computed < previous && gridWidth <= shrinkThreshold) {
      next = computed;
    }
    if (next < 1) {
      next = 1;
    }
    _stableCrossAxisCount = next;
    return next;
  }

  bool get _selectionIsAdditive {
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isControlPressed || keyboard.isMetaPressed;
  }

  Set<String> _selectedIdsForRect(
    Rect rect, {
    required EdgeInsets padding,
    required int crossAxisCount,
    required double tileWidth,
    required double crossAxisSpacing,
  }) {
    final selected = <String>{};
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    for (var index = 0; index < widget.items.length; index++) {
      final row = index ~/ crossAxisCount;
      final column = index % crossAxisCount;
      final left = padding.left + (column * (tileWidth + crossAxisSpacing));
      final top = padding.top +
          (row * (widget.mainAxisExtent + widget.mainAxisSpacing)) -
          scrollOffset;
      final tileRect = Rect.fromLTWH(
        left,
        top,
        tileWidth,
        widget.mainAxisExtent,
      );
      if (tileRect.overlaps(rect)) {
        selected.add(widget.itemIdOf!(widget.items[index]));
      }
    }
    return selected;
  }
}

class _SelectionRectPainter extends CustomPainter {
  const _SelectionRectPainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final normalized = Rect.fromLTRB(
      rect.left.clamp(0, size.width),
      rect.top.clamp(0, size.height),
      rect.right.clamp(0, size.width),
      rect.bottom.clamp(0, size.height),
    );
    final fill = Paint()..color = kAppAccent.withValues(alpha: 0.2);
    final stroke = Paint()
      ..color = kAppAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(normalized, fill);
    canvas.drawRect(normalized, stroke);
  }

  @override
  bool shouldRepaint(covariant _SelectionRectPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
