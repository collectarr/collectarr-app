import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Placement shared by searchable selectors and editable pick fields.
/// Bounds are in overlay coordinates; keyboard/safe-area space is excluded.
class AnchoredPopupGeometry {
  const AnchoredPopupGeometry._(
      this.anchor, this.overlaySize, this.bounds, this.opensAbove, this.gap);
  final Rect anchor;
  final Size overlaySize;
  final Rect bounds;
  final bool opensAbove;
  final double gap;

  factory AnchoredPopupGeometry.fromRect(
      {required Rect anchor,
      required Size overlaySize,
      EdgeInsets safeArea = EdgeInsets.zero,
      EdgeInsets viewInsets = EdgeInsets.zero,
      double maxHeight = 320,
      double gap = 4,
      double margin = 8,
      double minimumHeight = 44}) {
    final left = math.max(safeArea.left, viewInsets.left) + margin;
    final right =
        overlaySize.width - math.max(safeArea.right, viewInsets.right) - margin;
    final top = math.max(safeArea.top, viewInsets.top) + margin;
    final bottom = overlaySize.height -
        math.max(safeArea.bottom, viewInsets.bottom) -
        margin;
    final below = math.max(0.0, bottom - anchor.bottom - gap);
    final above = math.max(0.0, anchor.top - top - gap);
    final opensAbove = below < minimumHeight && above > below;
    final height = math.min(maxHeight, opensAbove ? above : below);
    final width = math.min(anchor.width, math.max(0.0, right - left));
    final x = anchor.left.clamp(left, math.max(left, right - width)).toDouble();
    final y = opensAbove ? anchor.top - gap - height : anchor.bottom + gap;
    return AnchoredPopupGeometry._(anchor, overlaySize,
        Rect.fromLTWH(x, y, width, height), opensAbove, gap);
  }

  static AnchoredPopupGeometry? measure(
      BuildContext context, GlobalKey anchorKey,
      {double maxHeight = 320, double gap = 4, bool rootOverlay = false}) {
    final anchor = anchorKey.currentContext?.findRenderObject();
    final overlay = Overlay.of(context, rootOverlay: rootOverlay)
        .context
        .findRenderObject();
    if (anchor is! RenderBox ||
        overlay is! RenderBox ||
        !anchor.hasSize ||
        !overlay.hasSize) {
      return null;
    }
    return AnchoredPopupGeometry.fromRect(
      anchor:
          anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size,
      overlaySize: overlay.size,
      safeArea: MediaQuery.paddingOf(context),
      viewInsets: MediaQuery.viewInsetsOf(context),
      maxHeight: maxHeight,
      gap: gap,
    );
  }

  RelativeRect get menuPosition => RelativeRect.fromRect(
      Rect.fromLTWH(bounds.left, bounds.top, bounds.width, 0),
      Offset.zero & overlaySize);
  Alignment get targetAnchor =>
      opensAbove ? Alignment.topLeft : Alignment.bottomLeft;
  Alignment get followerAnchor => Alignment.topLeft;
  Offset get followerOffset => Offset(
      bounds.left - anchor.left, opensAbove ? -bounds.height - gap : gap);
}
