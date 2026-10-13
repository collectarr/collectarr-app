import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Places form controls in a responsive grid with optional per-slot sizing.
///
/// Schema forms and custom kind editors use the same geometry while choosing
/// their own breakpoints, spans, and field content.
class LibraryResponsiveFieldLayout extends StatelessWidget {
  const LibraryResponsiveFieldLayout({
    super.key,
    required this.children,
    required this.maxColumns,
    this.columnBreakpoints = const {2: 680, 3: 960},
    this.spacing = 12,
    this.runSpacing = 12,
    this.fullWidthIndices = const {},
    this.columnSpans = const {},
    this.rightAlignedIndices = const {},
  });

  final List<Widget> children;
  final int maxColumns;
  final Map<int, double> columnBreakpoints;
  final double spacing;
  final double runSpacing;
  final Set<int> fullWidthIndices;
  final Map<int, int> columnSpans;
  final Set<int> rightAlignedIndices;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var columns = 1;
        for (final breakpoint in columnBreakpoints.entries.toList()
          ..sort((left, right) => left.key.compareTo(right.key))) {
          if (constraints.maxWidth >= breakpoint.value) {
            columns = math.max(columns, breakpoint.key);
          }
        }
        columns = math.min(columns, math.max(maxColumns, 1));
        final columnWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (var index = 0; index < children.length; index++)
              _slot(
                index,
                children[index],
                constraints: constraints,
                columns: columns,
                columnWidth: columnWidth,
              ),
          ],
        );
      },
    );
  }

  Widget _slot(
    int index,
    Widget child, {
    required BoxConstraints constraints,
    required int columns,
    required double columnWidth,
  }) {
    final fullWidth = fullWidthIndices.contains(index);
    final requestedSpan = columnSpans[index] ?? 1;
    final span = fullWidth ? columns : requestedSpan.clamp(1, columns).toInt();
    final width = span * columnWidth + spacing * (span - 1);

    if (rightAlignedIndices.contains(index) && columns > 1 && !fullWidth) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: width, child: child),
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? constraints.maxWidth : width,
      child: child,
    );
  }
}
