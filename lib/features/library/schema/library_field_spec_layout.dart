import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_field_layout.dart';
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
    this.columns = const <LibraryFormColumnSpec>[],
  });

  final List<LibraryFieldSpec<TDraft>> fields;
  final TDraft draft;
  final Widget Function(LibraryFieldSpec<TDraft> field) buildField;
  final int maxColumns;
  final Set<String> fullWidthFieldIds;
  final Map<String, int> fieldColumnSpans;
  final Set<String> rightAlignedFieldIds;
  final List<LibraryFormColumnSpec> columns;

  @override
  Widget build(BuildContext context) {
    final visibleFields =
        fields.where((field) => field.isVisible(draft)).toList(growable: false);
    if (columns.isNotEmpty) {
      final fieldsById = {for (final field in fields) field.id: field};
      final assignedIds = <String>{};
      for (final column in columns) {
        for (final row in column.rows) {
          for (final id in row) {
            if (!fieldsById.containsKey(id) || !assignedIds.add(id)) {
              throw StateError('Invalid or repeated form column field: $id');
            }
          }
        }
      }
      if (assignedIds.length != fieldsById.length) {
        throw StateError('Every section field must belong to a form column.');
      }
      return LibraryResponsiveFieldLayout(
        maxColumns: columns.length,
        spacing: 14,
        columnBreakpoints: const {2: 680},
        children: [
          for (final column in columns)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in column.rows)
                  if (row.any((id) => fieldsById[id]!.isVisible(draft)))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LibraryResponsiveFieldLayout(
                        maxColumns: row.length,
                        spacing: 14,
                        columnBreakpoints: const {2: 300},
                        children: [
                          for (final id in row)
                            if (fieldsById[id]!.isVisible(draft))
                              buildField(fieldsById[id]!),
                        ],
                      ),
                    ),
              ],
            ),
        ],
      );
    }
    final fullWidthIndices = <int>{};
    final columnSpans = <int, int>{};
    final rightAlignedIndices = <int>{};
    for (var index = 0; index < visibleFields.length; index++) {
      final id = visibleFields[index].id;
      if (fullWidthFieldIds.contains(id)) fullWidthIndices.add(index);
      final span = fieldColumnSpans[id];
      if (span != null) columnSpans[index] = span;
      if (rightAlignedFieldIds.contains(id)) rightAlignedIndices.add(index);
    }

    return LibraryResponsiveFieldLayout(
      maxColumns: maxColumns,
      columnBreakpoints: {
        if (maxColumns >= 2) 2: 680,
        if (maxColumns > 2) maxColumns: 960,
      },
      spacing: 12,
      runSpacing: 12,
      fullWidthIndices: fullWidthIndices,
      columnSpans: columnSpans,
      rightAlignedIndices: rightAlignedIndices,
      children: [for (final field in visibleFields) buildField(field)],
    );
  }
}
