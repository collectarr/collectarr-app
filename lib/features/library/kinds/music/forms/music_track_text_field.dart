import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// A consistently sized Music track text control used by Add and Edit.
final class MusicTrackTextField extends StatelessWidget {
  const MusicTrackTextField({
    super.key,
    required this.id,
    required this.initialValue,
    required this.onChanged,
    this.label,
    this.hint,
    this.keyboardType,
    this.style,
    this.maxLines = 1,
  });

  final String id;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => LibraryTextFormControl(
        key: ValueKey(id),
        initialValue: initialValue,
        keyboardType: keyboardType,
        style: style,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
        ),
        onChanged: onChanged,
      );
}
