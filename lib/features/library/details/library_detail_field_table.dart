import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minCellWidth).floor().clamp(1, 3);
        final gap = 12.0;
        final cellWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return KeyedSubtree(
          key: ValueKey('library-detail-field-table-$columns'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.72),
                  border: Border(
                    bottom: BorderSide(color: palette.divider),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Field',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Value',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
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
            ],
          ),
        );
      },
    );
  }
}
