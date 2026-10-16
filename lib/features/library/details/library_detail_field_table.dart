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
    this.showHeader = true,
  });

  final List<LibraryDetailField> fields;
  final double minCellWidth;
  final double labelWidth;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final ordered = [...fields]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    final palette = appPalette(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minCellWidth).floor().clamp(1, 3);
        final gap = 12.0;
        final cellWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        final fittedLabelWidth = _fittedLabelWidth(context, ordered);
        return KeyedSubtree(
          key: ValueKey('library-detail-field-table-$columns'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader)
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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
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
              if (showHeader) const SizedBox(height: 8),
              Wrap(
                spacing: gap,
                children: [
                  for (var index = 0; index < ordered.length; index++)
                    SizedBox(
                      width: cellWidth,
                      // Ruled rows with alternate tint, as in the reference
                      // detail tables.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: (index ~/ columns).isOdd
                              ? palette.detailStripe
                              : null,
                          border: Border(
                            top: BorderSide(color: palette.detailRule),
                            bottom: index + columns >= ordered.length
                                ? BorderSide(color: palette.detailRule)
                                : BorderSide.none,
                          ),
                        ),
                        child: Padding(
                          // The extra top pixel clears the row rule.
                          padding: const EdgeInsets.fromLTRB(5, 2, 5, 1),
                          child: LibraryDetailFieldRow(
                            field: ordered[index],
                            labelWidth: fittedLabelWidth,
                          ),
                        ),
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

  /// The label column fits its longest label, up to [labelWidth].
  double _fittedLabelWidth(
    BuildContext context,
    List<LibraryDetailField> fields,
  ) {
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );
    var widest = 0.0;
    for (final field in fields) {
      painter.text = TextSpan(
        text: field.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
      );
      painter.layout();
      if (painter.width > widest) widest = painter.width;
    }
    painter.dispose();
    return (widest + 2).ceilToDouble().clamp(0, labelWidth).toDouble();
  }
}
