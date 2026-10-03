import 'dart:async';

import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
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
  Widget build(BuildContext context) => LibraryFormField(
        label: 'Signed By',
        child: MultiSelectPickListField(
          label: 'Signed By',
          values: splitPickListValues(widget.draft.text('signed_by')),
          options: _options,
          pickerTitle: 'Signed By',
          pickerSearchHint: 'Search names',
          customValueHint: 'Add signer',
          onChanged: (values) {
            widget.draft.set('signed_by', joinPickListValues(values) ?? '');
            widget.draft.pendingChanges['vocabulary:music.signed_by'] =
                LibraryVocabularyEditChange([
              for (final value in values)
                (
                  listName: 'music.signed_by',
                  value: value,
                  mediaKind: 'music',
                ),
            ]);
          },
        ),
      );
}
