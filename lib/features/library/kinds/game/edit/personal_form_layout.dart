import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:flutter/material.dart';

/// Personal-tab state of one Game copy, from the editor or from Manual Add.
abstract interface class GamePersonalBindings {
  String? get storageDevice;
  String? get storageSlot;
  bool get completed;
  PartialDate? get completedDate;

  void setStorageDevice(String? value);
  void setStorageSlot(String? value);
  void setCompleted(bool value);
  void setCompletedDate(PartialDate? value);
}

/// Game controls of the reference Personal tab that the shared personal
/// section does not render.
Map<String, Widget> gamePersonalFields(GamePersonalBindings bindings) => {
      'game_storage_device': LibraryManagedVocabularyField(
        label: 'Storage Device',
        listName: GameVocabularyIds.storageDevice.value,
        mediaKind: 'game',
        value: bindings.storageDevice,
        onChanged: bindings.setStorageDevice,
      ),
      'game_storage_slot': LibraryFormField(
        label: 'Storage Slot',
        child: LibraryTextFormControl(
          key: const ValueKey('game-storage-slot'),
          initialValue: bindings.storageSlot ?? '',
          onChanged: (value) => bindings
              .setStorageSlot(value.trim().isEmpty ? null : value.trim()),
        ),
      ),
      'game_completed': LibrarySegmentedChoiceField<bool>(
        label: 'Completed',
        options: const [(false, 'No'), (true, 'Yes')],
        value: bindings.completed,
        onChanged: bindings.setCompleted,
      ),
      'game_completed_date_parts': LibraryPartialDateField(
        label: 'Completed Date',
        value: bindings.completedDate,
        onChanged: (date) => bindings.setCompletedDate(
            date == null || date.toJson().isEmpty ? null : date),
      ),
    };

/// Editor bindings over the entry's personal draft.
Map<String, Widget> gamePersonalAdditionalFields(LibraryEntryEditDraft draft) =>
    gamePersonalFields(_EntryDraftPersonalBindings(draft));

final class _EntryDraftPersonalBindings implements GamePersonalBindings {
  const _EntryDraftPersonalBindings(this.draft);

  final LibraryEntryEditDraft draft;

  String? _text(String key) =>
      draft.text(key).trim().isEmpty ? null : draft.text(key).trim();

  @override
  String? get storageDevice => _text('game_storage_device');
  @override
  String? get storageSlot => _text('game_storage_slot');
  @override
  bool get completed => draft.values['game_completed'] == true;
  @override
  PartialDate? get completedDate =>
      PartialDate.tryParse(draft.values['game_completed_date_parts']);

  @override
  void setStorageDevice(String? value) {
    draft.set('game_storage_device', value);
    draft.vocabularyEdits.replaceValue(
      fieldId: 'personal:game_storage_device',
      listName: GameVocabularyIds.storageDevice.value,
      value: value,
      mediaKind: 'game',
    );
  }

  @override
  void setStorageSlot(String? value) => draft.set('game_storage_slot', value);
  @override
  void setCompleted(bool value) => draft.set('game_completed', value);
  @override
  void setCompletedDate(PartialDate? value) =>
      draft.set('game_completed_date_parts', value?.toJson());
}

/// Reference Personal layout: owner, storage and notes on the left;
/// completion, rating and tags on the right.
Widget gamePersonalFormLayout(Map<String, Widget> fields, Widget? history) {
  Widget field(String key) => fields[key] ?? const SizedBox.shrink();
  Widget pair(String first, String second) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: field(first)),
          const SizedBox(width: 14),
          Expanded(child: field(second)),
        ]),
      );
  Widget stack(List<String> keys) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final key in keys)
            Padding(
                padding: const EdgeInsets.only(bottom: 12), child: field(key)),
        ],
      );
  return LayoutBuilder(builder: (context, constraints) {
    final left =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      pair('owner_label', 'game_storage_device'),
      pair('game_storage_slot', ''),
      stack(['personal_notes']),
    ]);
    final right =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      pair('game_completed', 'game_completed_date_parts'),
      stack(['rating', 'tags']),
      if (history != null) history,
    ]);
    if (constraints.maxWidth < 720) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, right]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: left),
      const SizedBox(width: 14),
      Expanded(child: right),
    ]);
  });
}
