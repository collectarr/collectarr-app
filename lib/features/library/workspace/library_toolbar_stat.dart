import 'package:flutter/material.dart';

class LibraryToolbarStat extends StatelessWidget {
  const LibraryToolbarStat({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.labelSmall),
        Text(value.toString(), style: textTheme.titleMedium),
      ],
    );
  }
}
