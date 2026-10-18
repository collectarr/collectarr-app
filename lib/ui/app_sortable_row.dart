import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// How long a dropped tab takes to settle into its slot, as in the reference.
const appSortableDropDuration = Duration(milliseconds: 250);

/// A horizontal row whose children are reordered by dragging, following the
/// reference's sortable lists: a plain copy of the child follows the pointer
/// along the row, the others jump into place the moment the pointer crosses
/// them (no sliding), and on release the copy eases into its slot.
///
/// Every child needs a key. The new order is kept locally from the drop until
/// the parent hands the children back in that order, so a slow save never
/// flashes the old order.
class AppSortableRow extends StatefulWidget {
  const AppSortableRow({
    super.key,
    required this.children,
    required this.onReorder,
    this.enabled = true,
    this.controller,
  });

  final List<Widget> children;

  /// Called on drop with the child's old index and its final index.
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool enabled;

  /// Scrolls the row when it is wider than its space.
  final ScrollController? controller;

  @override
  State<AppSortableRow> createState() => _AppSortableRowState();
}

class _AppSortableRowState extends State<AppSortableRow>
    with SingleTickerProviderStateMixin {
  final _slotKeys = <Key, GlobalKey>{};
  final _rowKey = GlobalKey();
  late final AnimationController _settle;

  /// Keys in the order shown while dragging and until the parent catches up.
  List<Key>? _order;
  Key? _dragging;
  OverlayEntry? _helper;
  double _grab = 0;
  double _helperLeft = 0;
  double _helperTop = 0;
  Size _helperSize = Size.zero;
  Tween<double>? _settleTween;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(vsync: this)
      ..addListener(() {
        final tween = _settleTween;
        if (tween == null) return;
        _helperLeft =
            tween.transform(Curves.easeInOut.transform(_settle.value));
        _helper?.markNeedsBuild();
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finishSettle();
      });
  }

  List<Key> get _parentKeys =>
      [for (final child in widget.children) child.key!];

  @override
  void didUpdateWidget(AppSortableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pending = _order;
    if (pending == null || _dragging != null) return;
    final keys = _parentKeys;
    // The parent shows the order we kept, or changed the children itself.
    if (listEquals(keys, pending) ||
        !listEquals(keys, [for (final c in oldWidget.children) c.key!])) {
      _order = null;
    }
  }

  @override
  void dispose() {
    _helper?.remove();
    _helper?.dispose();
    _settle.dispose();
    super.dispose();
  }

  GlobalKey _slotKey(Key key) => _slotKeys.putIfAbsent(key, GlobalKey.new);

  Rect? _rectOf(Key key) {
    final box = _slotKey(key).currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Rect? get _rowRect {
    final box = _rowKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _start(Key key, DragStartDetails details) {
    final rect = _rectOf(key);
    if (rect == null || _settle.isAnimating) return;
    _settle.stop();
    final keys = _order ?? _parentKeys;
    _order = [...keys];
    _dragging = key;
    _grab = details.globalPosition.dx - rect.left;
    _helperLeft = rect.left;
    _helperTop = rect.top;
    _helperSize = rect.size;
    final theme = InheritedTheme.capture(
        from: context, to: Overlay.of(context, rootOverlay: true).context);
    final child = widget.children.firstWhere((child) => child.key == key);
    _helper = OverlayEntry(
      builder: (_) => Positioned(
        left: _helperLeft,
        top: _helperTop,
        width: _helperSize.width,
        height: _helperSize.height,
        child: IgnorePointer(child: theme.wrap(child)),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_helper!);
    setState(() {});
  }

  void _update(Key key, DragUpdateDetails details) {
    if (_dragging != key) return;
    final row = _rowRect;
    final pointer = details.globalPosition.dx;
    if (row != null) {
      _helperLeft = (pointer - _grab)
          .clamp(row.left, math.max(row.left, row.right - _helperSize.width));
      _scrollNearEdge(row, pointer);
    } else {
      _helperLeft = pointer - _grab;
    }
    _helper?.markNeedsBuild();
    final order = _order!;
    final from = order.indexOf(key);
    for (final other in order) {
      if (other == key) continue;
      final rect = _rectOf(other);
      if (rect == null || pointer < rect.left || pointer >= rect.right) {
        continue;
      }
      final to = order.indexOf(other);
      if (to != from) {
        setState(() {
          order
            ..removeAt(from)
            ..insert(to, key);
        });
      }
      break;
    }
  }

  void _scrollNearEdge(Rect row, double pointer) {
    final controller = widget.controller;
    if (controller == null || !controller.hasClients) return;
    const edge = 20.0;
    const step = 12.0;
    final position = controller.position;
    if (pointer < row.left + edge) {
      controller
          .jumpTo(math.max(position.minScrollExtent, controller.offset - step));
    } else if (pointer > row.right - edge) {
      controller
          .jumpTo(math.min(position.maxScrollExtent, controller.offset + step));
    }
  }

  void _end(Key key) {
    if (_dragging != key) return;
    final order = _order!;
    final oldIndex = _parentKeys.indexOf(key);
    final newIndex = order.indexOf(key);
    final slot = _rectOf(key);
    final target = slot?.left ?? _helperLeft;
    if (oldIndex != newIndex) widget.onReorder(oldIndex, newIndex);
    final reduce = MediaQuery.disableAnimationsOf(context);
    _settleTween = Tween<double>(begin: _helperLeft, end: target);
    _settle
      ..duration = reduce ? Duration.zero : appSortableDropDuration
      ..forward(from: 0);
    if (reduce || _helperLeft == target) _finishSettle();
  }

  void _finishSettle() {
    _helper?.remove();
    _helper?.dispose();
    _helper = null;
    _settleTween = null;
    if (!mounted) return;
    setState(() {
      _dragging = null;
      if (listEquals(_parentKeys, _order)) _order = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final byKey = {for (final child in widget.children) child.key!: child};
    final keys = [
      for (final key in _order ?? _parentKeys)
        if (byKey.containsKey(key)) key,
    ];
    return SingleChildScrollView(
      controller: widget.controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        key: _rowKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final key in keys)
            KeyedSubtree(
              key: _slotKey(key),
              child: _Draggable(
                enabled: widget.enabled,
                onStart: (details) => _start(key, details),
                onUpdate: (details) => _update(key, details),
                onEnd: () => _end(key),
                child: Opacity(
                  opacity: _dragging == key ? 0 : 1,
                  child: byKey[key]!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Draggable extends StatelessWidget {
  const _Draggable({
    required this.enabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.child,
  });

  final bool enabled;
  final ValueChanged<DragStartDetails> onStart;
  final ValueChanged<DragUpdateDetails> onUpdate;
  final VoidCallback onEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
          (recognizer) => recognizer
            ..dragStartBehavior = DragStartBehavior.down
            ..onStart = onStart
            ..onUpdate = onUpdate
            ..onEnd = ((_) => onEnd())
            ..onCancel = onEnd,
        ),
      },
      child: child,
    );
  }
}
