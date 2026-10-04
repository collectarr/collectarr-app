import 'dart:async';

import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class MusicSignedByPersonalField extends ConsumerStatefulWidget {
  const MusicSignedByPersonalField({
    super.key,
    required this.draft,
  });

  final LibraryEntryEditDraft draft;

  @override
  ConsumerState<MusicSignedByPersonalField> createState() =>
      _MusicSignedByPersonalFieldState();
}

final class _MusicSignedByPersonalFieldState
    extends ConsumerState<MusicSignedByPersonalField> {
  List<String> _options = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadOptions());
  }

  @override
  void didUpdateWidget(covariant MusicSignedByPersonalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) unawaited(_loadOptions());
  }

  Future<void> _loadOptions() async {
    final values = await loadSingleValuePickListOptions(
      ref.read(localDatabaseProvider),
      listName: 'music.signed_by',
      mediaKind: 'music',
      selectedValue: widget.draft.text('signed_by'),
    );
    if (!mounted) return;
    setState(() => _options = values);
  }

  @override
  Widget build(BuildContext context) => LibraryMultiValuePickField<String>(
        label: 'Signed By',
        value: splitPickListValues(widget.draft.text('signed_by')).toSet(),
        options: [
          for (final value in _options)
            LibraryFieldOption<String>(value: value, label: value),
        ],
        allowCustomValueEntry: true,
        hintText: 'Add signer',
        pickerSearchHint: 'Search names',
        customValueHint: 'Add signer',
        onOpenPicker: (
                {required label,
                required selectedValues,
                required options,
                searchHint,
                customValueHint}) =>
            showLibraryMultiValueOptionsDialog<String>(
          context: context,
          label: label,
          options: options,
          selectedValues: selectedValues,
          searchHint: searchHint ?? 'Search names',
          customValueHint: customValueHint ?? 'Add signer',
        ),
        onChanged: (values) {
          final selected = values.toList(growable: false);
          widget.draft.set('signed_by', joinPickListValues(selected) ?? '');
          widget.draft.pendingChanges['vocabulary:music.signed_by'] =
              LibraryVocabularyEditChange([
            for (final value in selected)
              (
                listName: 'music.signed_by',
                value: value,
                mediaKind: 'music',
              ),
          ]);
        },
      );
}
