import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// A consistently labelled Music disc text field used by Add and Edit.
final class MusicDiscTextField extends StatelessWidget {
  const MusicDiscTextField({
    super.key,
    required this.id,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  final String id;
  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: label,
        child: LibraryTextFormControl(
          key: ValueKey(id),
          initialValue: initialValue,
          decoration: const InputDecoration(isDense: true),
          onChanged: onChanged,
        ),
      );
}
