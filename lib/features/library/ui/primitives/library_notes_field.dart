import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Shared multiline notes input used by Add and Edit personal forms.
final class LibraryNotesField extends StatelessWidget {
  const LibraryNotesField({
    super.key,
    required this.label,
    this.value = '',
    this.controller,
    this.fieldKey,
    this.onChanged,
    this.minLines = 2,
    this.maxLines = 5,
  });

  final String label;
  final String value;
  final TextEditingController? controller;
  final Key? fieldKey;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: label,
        child: TextFormField(
          key: fieldKey,
          controller: controller,
          initialValue: controller == null ? value : null,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
        ),
      );
}
