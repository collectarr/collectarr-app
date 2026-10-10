import 'package:flutter/material.dart';

class LibraryTableCellText extends StatelessWidget {
  const LibraryTableCellText(
    this.value, {
    this.emptyText = '-',
    this.fontSize = 14,
    super.key,
  });

  final String? value;
  final String emptyText;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.isEmpty;
    return Text(
      isEmpty ? emptyText : value!,
      maxLines: LibraryTableCellDisplayScope.wraps(context) ? 3 : 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            color:
                isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          ),
    );
  }
}

class LibraryTableCellDisplayScope extends InheritedWidget {
  const LibraryTableCellDisplayScope({
    super.key,
    required this.wrap,
    required super.child,
  });
  final bool wrap;
  static bool wraps(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LibraryTableCellDisplayScope>()
          ?.wrap ??
      false;
  @override
  bool updateShouldNotify(LibraryTableCellDisplayScope oldWidget) =>
      wrap != oldWidget.wrap;
}
