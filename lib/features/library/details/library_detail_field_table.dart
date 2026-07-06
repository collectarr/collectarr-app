import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:flutter/material.dart';

class LibraryDetailFieldTable extends StatelessWidget {
  const LibraryDetailFieldTable({
    super.key,
    required this.fields,
    this.minCellWidth = 220,
    this.labelWidth = 92,
  });

  final List<LibraryDetailField> fields;
  final double minCellWidth;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final ordered = [...fields]..sort((a, b) => a.priority.compareTo(b.priority));
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minCellWidth).floor().clamp(1, 3);
        final gap = 12.0;
        final cellWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return KeyedSubtree(
          key: ValueKey('library-detail-field-table-$columns'),
          child: Wrap(
            spacing: gap,
            runSpacing: 2,
            children: [
              for (final field in ordered)
                SizedBox(
                  width: cellWidth,
                  child: LibraryDetailFieldRow(
                    field: field,
                    labelWidth: labelWidth,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
