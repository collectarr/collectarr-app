import 'package:flutter/material.dart';

class LibraryTableCellText extends StatelessWidget {
  const LibraryTableCellText(
    this.value, {
    this.emptyText = '-',
    this.fontSize = 12,
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: isEmpty
          ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
          : TextStyle(fontSize: fontSize),
    );
  }
}
