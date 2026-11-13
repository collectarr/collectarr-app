import 'package:collectarr_app/features/library/ui/primitives/ordered_names_field.dart';
import 'package:flutter/material.dart';

/// The people who signed a copy: an ordered list of names added with the +
/// beside the label, as in the reference.
class BookSignedByField extends StatelessWidget {
  const BookSignedByField(
      {super.key, required this.names, required this.onChanged});

  final List<String> names;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) => LibraryOrderedNamesField(
        label: 'Signed by',
        values: [
          for (final (index, name) in names.indexed)
            LibraryNamedValue(id: 'signed-by-$index', name: name),
        ],
        onChanged: (values) => onChanged([
          for (final value in values)
            if (value.name.trim().isNotEmpty) value.name.trim(),
        ]),
      );
}
