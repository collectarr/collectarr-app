import 'package:flutter/widgets.dart';

/// Descriptor for a single field in the kind-owned advanced search filter row.
class LibraryAddAdvancedFilterField {
  const LibraryAddAdvancedFilterField({
    required this.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.width,
    this.flex = 1,
    this.keyboardType,
  });

  final Key key;
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final double? width;
  final int flex;
  final TextInputType? keyboardType;
}
