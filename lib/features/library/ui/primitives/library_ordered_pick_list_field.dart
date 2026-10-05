import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Managed choices with an independently ordered selection in the item draft.
/// Creating a dictionary value is explicit; cancelling selection adds no row.
class LibraryOrderedPickListField extends ConsumerWidget {
  const LibraryOrderedPickListField(
      {super.key,
      required this.label,
      required this.listName,
      required this.mediaKind,
      required this.values,
      required this.onChanged,
      this.options = const [],
      this.loadOptions,
      this.rowTrailingBuilder});

  final String label;
  final String listName;
  final String mediaKind;
  final List<LibraryNamedValue> values;
  final List<String> options;
  final Future<List<String>> Function(LocalDatabase db)? loadOptions;
  final ValueChanged<List<LibraryNamedValue>> onChanged;
  final Widget Function(LibraryNamedValue value)? rowTrailingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LibraryOrderedNamesField(
        label: label,
        values: values,
        onChanged: onChanged,
        rowTrailingBuilder: rowTrailingBuilder,
        pickValue: () async {
          final db = ref.read(localDatabaseProvider);
          final choices = await loadOptions?.call(db) ?? const <String>[];
          if (!context.mounted) return null;
          return showPickListSelectDialog(
              context: context,
              label: label,
              options: [
                ...options,
                ...choices,
                for (final value in values) value.name
              ],
              listName: listName,
              mediaKind: mediaKind,
              allowUserValues: true,
              db: db);
        },
      );
}
