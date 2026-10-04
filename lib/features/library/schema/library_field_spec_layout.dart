import 'dart:math' as math;

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:flutter/material.dart';

/// Shared responsive layout for fields described by [LibraryFieldSpec].
///
/// Add and Edit supply the same field definitions and differ only in how each
/// field is rendered and where its changes are saved.
class LibraryFieldSpecLayout<TDraft> extends StatelessWidget {
  const LibraryFieldSpecLayout({
    super.key,
    required this.fields,
    required this.draft,
    required this.buildField,
    required this.maxColumns,
    required this.fullWidthFieldIds,
    required this.fieldColumnSpans,
    required this.rightAlignedFieldIds,
  });

  final List<LibraryFieldSpec<TDraft>> fields;
  final TDraft draft;
  final Widget Function(LibraryFieldSpec<TDraft> field) buildField;
  final int maxColumns;
  final Set<String> fullWidthFieldIds;
  final Map<String, int> fieldColumnSpans;
  final Set<String> rightAlignedFieldIds;

  @override
  Widget build(BuildContext context) {
    final visibleFields =
        fields.where((field) => field.isVisible(draft)).toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableColumns = maxColumns < 1 ? 1 : maxColumns;
        final columns = (constraints.maxWidth >= 960
                ? availableColumns
                : constraints.maxWidth >= 680
                    ? math.min(availableColumns, 2)
                    : 1)
            .toInt();
        final columnWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 12 * (columns - 1)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in visibleFields)
              _fieldSlot(
                field,
                constraints: constraints,
                columns: columns,
                columnWidth: columnWidth,
              ),
          ],
        );
      },
    );
  }

  Widget _fieldSlot(
    LibraryFieldSpec<TDraft> field, {
    required BoxConstraints constraints,
    required int columns,
    required double columnWidth,
  }) {
    final fullWidth = fullWidthFieldIds.contains(field.id);
    final span = fieldColumnSpans[field.id] ?? 1;
    final resolvedSpan = fullWidth ? columns : span.clamp(1, columns).toInt();
    final fieldWidth = resolvedSpan * columnWidth + 12 * (resolvedSpan - 1);
    final child = buildField(field);

    if (rightAlignedFieldIds.contains(field.id) && columns > 1 && !fullWidth) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: fieldWidth, child: child),
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? constraints.maxWidth : fieldWidth,
      child: child,
    );
  }
}
