import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_details_form_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:flutter/material.dart';

class MusicAlbumDetailsPane extends StatelessWidget {
  const MusicAlbumDetailsPane({super.key, required this.draft});
  final MusicAlbumEditDraft draft;
  @override
  Widget build(BuildContext context) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    Widget content() => MusicDetailsFormPane<MusicAlbumEditDraft>(
          draft: draft,
          values: (draft) => draft.values,
          onVocabularyValueChanged: (
                  {required fieldId, required listName, required value}) =>
              _rememberValues(fieldId, listName, {if (value != null) value}),
          onVocabularyValuesChanged: (
                  {required fieldId, required listName, required values}) =>
              _rememberValues(fieldId, listName, values),
          packageCondition: _condition(
              entry,
              'Package/Sleeve Condition',
              'condition',
              MusicVocabularies.condition.key,
              MusicVocabularies.condition.builtIns),
          mediaCondition: _condition(
              entry,
              'Media Condition',
              'media_condition',
              MusicVocabularies.mediaCondition.key,
              MusicVocabularies.mediaCondition.builtIns),
        );
    return entry == null
        ? content()
        : ListenableBuilder(listenable: entry, builder: (_, __) => content());
  }

  void _rememberValues(String fieldId, String? listName, Set<String> values) {
    draft.pendingDetailVocabularyValues[fieldId] = [
      if (listName != null)
        for (final value in values)
          if (value.trim().isNotEmpty)
            (listName: listName, value: value.trim(), mediaKind: 'music'),
    ];
  }

  Widget _condition(LibraryEntryEditDraft? entry, String label, String key,
          String listName, List<String> builtIns) =>
      LibraryManagedVocabularyField(
          label: label,
          listName: listName,
          mediaKind: 'music',
          value: entry?.text(key).isNotEmpty == true ? entry!.text(key) : null,
          builtIns: builtIns,
          enabled: entry != null,
          onChanged: (value) {
            if (entry == null) return;
            entry.set(key, value);
            entry.pendingChanges['vocabulary:$listName'] =
                LibraryVocabularyEditChange([
              if (value?.trim().isNotEmpty == true)
                (listName: listName, value: value!.trim(), mediaKind: 'music'),
            ]);
          });
}
