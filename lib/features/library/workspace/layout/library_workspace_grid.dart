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
  State<LibraryWorkspaceGrid<T>> createState() => _LibraryWorkspaceGridState<T>();
}

class _LibraryWorkspaceGridState<T> extends State<LibraryWorkspaceGrid<T>> {
  final _scrollController = ScrollController();
  final _selectionRectNotifier = ValueNotifier<Rect?>(null);
  Offset? _dragStart;
  Set<String> _dragBaseSelection = const {};

  @override
  void dispose() {
    _selectionRectNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
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
        final gridWidth = constraints.maxWidth - padding.left - padding.right;
        final crossAxisCount = math.max(
          1,
          ((gridWidth + widget.crossAxisSpacing) /
                  (widget.maxCrossAxisExtent + widget.crossAxisSpacing))
              .ceil(),
        );
        final tileWidth =
            (gridWidth - ((crossAxisCount - 1) * widget.crossAxisSpacing)) /
                crossAxisCount;
        final rowCount = (widget.items.length / crossAxisCount).ceil();
        final nestedGridHeight = widget.shrinkWrap && !widget.scrollable
          ? padding.top +
            padding.bottom +
            (rowCount * widget.mainAxisExtent) +
            ((rowCount - 1) * widget.mainAxisSpacing)
          : null;
        final grid = GridView.builder(
          controller: widget.scrollable ? _scrollController : null,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.scrollable
              ? null
              : const NeverScrollableScrollPhysics(),
          padding: widget.padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: widget.mainAxisExtent,
            crossAxisSpacing: widget.crossAxisSpacing,
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
              padding: padding,
              crossAxisCount: crossAxisCount,
              tileWidth: tileWidth,
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

  bool get _selectionIsAdditive {
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isControlPressed || keyboard.isMetaPressed;
  }

  Set<String> _selectedIdsForRect(
    Rect rect, {
    required EdgeInsets padding,
    required int crossAxisCount,
    required double tileWidth,
  }) {
    final selected = <String>{};
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    for (var index = 0; index < widget.items.length; index++) {
      final row = index ~/ crossAxisCount;
      final column = index % crossAxisCount;
      final left = padding.left +
          (column * (tileWidth + widget.crossAxisSpacing));
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
