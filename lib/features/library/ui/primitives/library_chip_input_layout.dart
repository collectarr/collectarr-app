import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Wraps chips and lets the last child (the editor) fill the remaining row.
/// Uses the actual chip sizes, including text scaling and delete controls.
class LibraryChipInputLayout extends MultiChildRenderObjectWidget {
  const LibraryChipInputLayout({
    super.key,
    required super.children,
    required this.hasEditor,
    required this.minimumEditorWidth,
  });
  final bool hasEditor;
  final double minimumEditorWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderLibraryChipInputLayout(
          hasEditor, minimumEditorWidth, Directionality.of(context));

  @override
  void updateRenderObject(
      BuildContext context, RenderLibraryChipInputLayout renderObject) {
    renderObject.update(
        hasEditor, minimumEditorWidth, Directionality.of(context));
  }
}

class RenderLibraryChipInputLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  RenderLibraryChipInputLayout(
      this._hasEditor, this._minimumEditorWidth, this._direction);
  bool _hasEditor;
  double _minimumEditorWidth;
  TextDirection _direction;
  static const _spacing = 3.0;

  void update(bool hasEditor, double width, TextDirection direction) {
    if (_hasEditor == hasEditor &&
        _minimumEditorWidth == width &&
        _direction == direction) {
      return;
    }
    _hasEditor = hasEditor;
    _minimumEditorWidth = width;
    _direction = direction;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _ChipInputParentData();
    }
  }

  Size _arrange(BoxConstraints constraints, {required bool dry}) {
    assert(constraints.hasBoundedWidth);
    final width = constraints.maxWidth;
    var x = 0.0;
    var y = 0.0;
    var rowHeight = 0.0;
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as ContainerBoxParentData<RenderBox>;
      final editor = _hasEditor && child == lastChild;
      if (editor && x > 0 && width - x < math.min(width, _minimumEditorWidth)) {
        y += rowHeight + _spacing;
        x = 0;
        rowHeight = 0;
      }
      final childConstraints = editor
          ? BoxConstraints.tightFor(width: math.max(0, width - x))
          : BoxConstraints(maxWidth: width);
      final Size childSize;
      if (dry) {
        childSize = child.getDryLayout(childConstraints);
      } else {
        child.layout(childConstraints, parentUsesSize: true);
        childSize = child.size;
      }
      if (!editor && x > 0 && x + childSize.width > width) {
        y += rowHeight + _spacing;
        x = 0;
        rowHeight = 0;
      }
      if (!dry) {
        data.offset = Offset(
            _direction == TextDirection.ltr ? x : width - x - childSize.width,
            y);
      }
      x += childSize.width + _spacing;
      rowHeight = math.max(rowHeight, childSize.height);
      child = data.nextSibling;
    }
    return constraints.constrain(Size(width, y + rowHeight));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _arrange(constraints, dry: true);

  @override
  void performLayout() => size = _arrange(constraints, dry: false);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

class _ChipInputParentData extends ContainerBoxParentData<RenderBox> {}
