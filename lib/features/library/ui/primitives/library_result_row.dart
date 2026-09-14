import 'package:flutter/material.dart';

/// A typed row descriptor consumed by [LibraryResultTable].
class LibraryResultRow<T> {
  const LibraryResultRow({
    required this.item,
    this.key,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
  });

  final T item;
  final Key? key;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
}
