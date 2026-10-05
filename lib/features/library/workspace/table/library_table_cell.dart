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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            color:
                isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          ),
    );
  }
}
