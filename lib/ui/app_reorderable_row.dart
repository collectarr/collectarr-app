import 'dart:math' as math;

import 'package:collectarr_app/ui/app_motion.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Decorates the dragged child; [lift] runs 0 → 1 as the drag starts and back
/// as it drops.
typedef AppReorderDragDecorator = Widget Function(
  Widget child,
  Animation<double> lift,
);

/// A horizontally scrolling row of keyed children that can be reordered by
/// dragging, such as tab strips.
///
/// The drag runs in the row's own coordinates instead of Flutter's
/// reorderable overlay. That overlay positions its proxy from global pointer
/// offsets mixed with local item offsets, so under the app zoom
/// (`AppZoomWrapper` scales the whole tree) the dragged item lands away from
/// the pointer and the drop targets drift:
/// https://github.com/flutter/flutter/issues/195303
///
/// Once that is fixed in the Flutter release we use, replace this widget with
/// `ReorderableListView.builder(scrollDirection: Axis.horizontal,
/// buildDefaultDragHandles: false, scrollController: controller,
/// proxyDecorator: ..., onReorderItem: ...)` whose items are wrapped in
/// `ReorderableDragStartListener`, and delete this file.
class AppReorderableRow extends StatefulWidget {
  const AppReorderableRow({
    super.key,
    required this.children,
    this.onReorderItem,
    this.controller,
    this.dragDecorator,
  });

  /// Children with distinct keys; a child without a key is keyed by identity.
  final List<Widget> children;

  /// Called with the dragged child's old index and its final index. Null
  /// disables dragging.
  final void Function(int oldIndex, int newIndex)? onReorderItem;
  final ScrollController? controller;
  final AppReorderDragDecorator? dragDecorator;

  @override
  State<AppReorderableRow> createState() => _AppReorderableRowState();
}

class _AppReorderableRowState extends State<AppReorderableRow>
    with TickerProviderStateMixin {
  final _viewportKey = GlobalKey();
  final _contentKey = GlobalKey();
  ScrollController? _ownScroll;
  late final _lift = AnimationController(
    vsync: this,
    duration: appReorderReturnDuration,
  );
  late final _settle = AnimationController(
    vsync: this,
    duration: appReorderReturnDuration,
  )..addListener(() => setState(() {}));

  int? _dragIndex;
  int _insertIndex = 0;
  List<double> _widths = const [];
  double _dragLeft = 0;
  double _grabDx = 0;
  double _settleFrom = 0;

  ScrollController get _scroll =>
      widget.controller ?? (_ownScroll ??= ScrollController());

  bool get _dragging => _dragIndex != null;

  @override
  void dispose() {
    _ownScroll?.dispose();
    _lift.dispose();
    _settle.dispose();
    super.dispose();
  }

  Duration _motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  double _contentX(Offset globalPosition) {
    final box = _contentKey.currentContext!.findRenderObject()! as RenderBox;
    return box.globalToLocal(globalPosition).dx;
  }

  void _startDrag(DragStartDetails details) {
    if (_dragging) return;
    final row = _contentKey.currentContext?.findRenderObject();
    if (row is! RenderFlex) return;
    final widths = <double>[];
    row.visitChildren(
        (RenderObject child) => widths.add((child as RenderBox).size.width));
    if (widths.isEmpty || widths.length != widget.children.length) return;
    final x = _contentX(details.globalPosition);
    var index = 0;
    var left = 0.0;
    while (index < widths.length - 1 && x >= left + widths[index]) {
      left += widths[index];
      index++;
    }
    setState(() {
      _widths = widths;
      _dragIndex = index;
      _insertIndex = index;
      _dragLeft = left;
      _grabDx = x - left;
    });
    _lift.duration = _motion(appReorderReturnDuration);
    _lift.forward(from: 0);
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_dragging || _settle.isAnimating) return;
    _autoScroll(details.globalPosition);
    final total = _widths.fold<double>(0, (sum, width) => sum + width);
    final width = _widths[_dragIndex!];
    final left = (_contentX(details.globalPosition) - _grabDx)
        .clamp(0.0, math.max(0.0, total - width))
        .toDouble();
    setState(() {
      _dragLeft = left;
      _insertIndex = _insertIndexFor(left);
    });
  }

  void _autoScroll(Offset globalPosition) {
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !_scroll.hasClients) return;
    final x = viewport.globalToLocal(globalPosition).dx;
    const edge = 24.0;
    final delta = x < edge
        ? -8.0
        : x > viewport.size.width - edge
            ? 8.0
            : 0.0;
    if (delta == 0) return;
    _scroll.jumpTo((_scroll.offset + delta)
        .clamp(0.0, _scroll.position.maxScrollExtent)
        .toDouble());
  }

  void _endDrag() {
    if (!_dragging || _settle.isAnimating) return;
    _settleFrom = _dragLeft;
    _lift.duration = _motion(appReorderReturnDuration);
    _lift.reverse();
    _settle.duration = _motion(appReorderReturnDuration);
    _settle.forward(from: 0).whenCompleteOrCancel(_finishDrag);
  }

  void _finishDrag() {
    if (!mounted || !_dragging) return;
    final from = _dragIndex!;
    final to = _insertIndex;
    setState(() {
      _dragIndex = null;
      _settle.value = 0;
    });
    if (from != to) widget.onReorderItem?.call(from, to);
  }

  /// The final index for the dragged child: its leading edge passing the
  /// middle of a neighbour in the original layout moves it past that one.
  int _insertIndexFor(double dragLeft) {
    final dragIndex = _dragIndex!;
    final dragRight = dragLeft + _widths[dragIndex];
    var insert = dragIndex;
    var left = 0.0;
    for (var index = 0; index < _widths.length; index++) {
      final middle = left + _widths[index] / 2;
      if (index < dragIndex && dragLeft < middle) {
        insert = math.min(insert, index);
      } else if (index > dragIndex && dragRight > middle) {
        insert = math.max(insert, index);
      }
      left += _widths[index];
    }
    return insert;
  }

  /// The key of the slot holding a child, distinct from the child's own key.
  Key _keyOf(int index) {
    final child = widget.children[index];
    return ValueKey<Key>(child.key ?? ObjectKey(child));
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    final canReorder = widget.onReorderItem != null;
    if (_dragging && (!canReorder || _widths.length != children.length)) {
      _dragIndex = null;
      _settle.value = 0;
    }

    final Widget content;
    if (_dragging) {
      content = _buildDragLayout();
    } else {
      content = Row(
        key: _contentKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++)
            KeyedSubtree(key: _keyOf(index), child: children[index]),
        ],
      );
    }

    return SingleChildScrollView(
      key: _viewportKey,
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      clipBehavior: _dragging ? Clip.none : Clip.hardEdge,
      // One recognizer above the content keeps the drag alive while the row
      // switches to the positioned drag layout underneath it.
      child: canReorder
          ? GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onHorizontalDragStart: _startDrag,
              onHorizontalDragUpdate: _updateDrag,
              onHorizontalDragEnd: (_) => _endDrag(),
              onHorizontalDragCancel: _endDrag,
              child: content,
            )
          : content,
    );
  }

  Widget _buildDragLayout() {
    final children = widget.children;
    final dragIndex = _dragIndex!;
    final order = [
      for (var index = 0; index < children.length; index++)
        if (index != dragIndex) index,
    ]..insert(_insertIndex, dragIndex);
    final shift = _motion(appReorderReturnDuration);
    final placed = <Widget>[];
    var left = 0.0;
    var dropLeft = 0.0;
    for (final index in order) {
      if (index == dragIndex) {
        dropLeft = left;
      } else {
        placed.add(AnimatedPositioned(
          key: _keyOf(index),
          duration: shift,
          left: left,
          top: 0,
          bottom: 0,
          width: _widths[index],
          child: children[index],
        ));
      }
      left += _widths[index];
    }
    final dragged = children[dragIndex];
    placed.add(Positioned(
      key: _keyOf(dragIndex),
      left: _settle.value > 0
          ? _settleFrom +
              (dropLeft - _settleFrom) * Curves.easeOut.transform(_settle.value)
          : _dragLeft,
      top: 0,
      bottom: 0,
      width: _widths[dragIndex],
      child: widget.dragDecorator?.call(dragged, _lift) ?? dragged,
    ));
    return SizedBox(
      key: _contentKey,
      width: left,
      child: Stack(clipBehavior: Clip.none, children: placed),
    );
  }
}
