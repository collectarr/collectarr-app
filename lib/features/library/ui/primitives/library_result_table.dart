import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_result_row.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryResultCellBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

/// Typed semantic column definition for [LibraryResultTable].
class LibraryResultColumn<T> {
  const LibraryResultColumn({
    required this.id,
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.numeric = false,
  }) : assert(flex > 0);

  final String id;
  final String label;
  final LibraryResultCellBuilder<T> cellBuilder;
  final int flex;
  final bool numeric;
}

/// Shared result table chrome; kinds supply typed rows and semantic columns.
class LibraryResultTable<T> extends StatelessWidget {
  const LibraryResultTable({
    super.key,
    required this.rows,
    required this.columns,
    this.emptyState,
    this.accent,
    this.density,
  }) : assert(columns.length > 0);

  final List<LibraryResultRow<T>> rows;
  final List<LibraryResultColumn<T>> columns;
  final Widget? emptyState;
  final Color? accent;
  final LibraryDensity? density;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final metrics = (density ?? LibraryDensityScope.of(context)).metrics;
    final rowAccent = accent ?? palette.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          _buildHeader(context, metrics, palette),
          Expanded(
            child: rows.isEmpty
                ? Center(child: emptyState ?? const Text('No results'))
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final backgroundColor = row.isSelected
                          ? palette.selection
                          : index.isEven
                              ? palette.surface
                              : palette.surfaceSubtle;
                      return Material(
                        color: backgroundColor,
                        child: InkWell(
                          onTap: row.onTap,
                          onDoubleTap: row.onDoubleTap,
                          hoverColor: palette.surfaceSubtle,
                          child: Container(
                            key: row.key,
                            constraints: BoxConstraints(
                              minHeight: metrics.resultRowHeight,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: palette.divider),
                                left: row.isSelected
                                    ? BorderSide(color: rowAccent, width: 3)
                                    : BorderSide.none,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: metrics.panelPadding,
                              vertical: metrics.gapSm,
                            ),
                            child: _buildCells(context, row.item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LibraryMetrics metrics,
    AppThemePalette palette,
  ) {
    return Container(
      constraints: BoxConstraints(minHeight: metrics.panelHeaderHeight),
      padding: EdgeInsets.symmetric(horizontal: metrics.panelPadding),
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Align(
                alignment: column.numeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  column.label,
                  style: Theme.of(context).textTheme.tableHeader.copyWith(
                        color: palette.textPrimary,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCells(BuildContext context, T item) {
    return Row(
      children: [
        for (final column in columns)
          Expanded(
            flex: column.flex,
            child: Align(
              alignment:
                  column.numeric ? Alignment.centerRight : Alignment.centerLeft,
              child: column.cellBuilder(context, item),
            ),
          ),
      ],
    );
  }
}
