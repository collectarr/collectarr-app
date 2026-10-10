import 'dart:convert';

import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/session/library_vocabulary_edit_accumulator.dart';
import 'package:flutter/widgets.dart';

/// Shared personal form state belonging to the same record as catalog fields.
final class LibraryEntryEditDraft extends ChangeNotifier {
  LibraryEntryEditDraft(this.record)
      : values = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(record.personalData)) as Map,
        );

  final LibraryEntryRecord record;
  final Map<String, dynamic> values;
  final vocabularyEdits = LibraryVocabularyEditAccumulator();
  bool used = false;

  Map<String, dynamic> get changes => {
        for (final entry in values.entries)
          if (jsonEncode(entry.value) !=
              jsonEncode(record.personalData[entry.key]))
            entry.key: entry.value,
      };

  String text(String key) => values[key]?.toString() ?? '';
  int? number(String key) => (values[key] as num?)?.toInt();

  void set(String key, Object? value) {
    used = true;
    values[key] = value;
    notifyListeners();
  }

  void reset() {
    values.clear();
    notifyListeners();
  }
}

class LibraryEntryEditScope extends InheritedWidget {
  const LibraryEntryEditScope(
      {super.key, required this.draft, this.onCommit, required super.child});
  final LibraryEntryEditDraft? draft;
  final Future<void> Function(LibraryEditSelection result)? onCommit;

  static LibraryEntryEditDraft? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LibraryEntryEditScope>()
      ?.draft;

  @override
  bool updateShouldNotify(LibraryEntryEditScope oldWidget) =>
      oldWidget.draft != draft;
}

Future<void> commitLibraryEdit(
    BuildContext context, LibraryEditSelection result) async {
  final scope = context.getInheritedWidgetOfExactType<LibraryEntryEditScope>();
  final draft = scope?.draft;
  final prepared = draft?.used == true
      ? result.copyWith(entryPersonalData: draft!.changes)
      : result;
  if (draft == null) {
    await scope?.onCommit?.call(prepared);
    if (context.mounted) Navigator.of(context).pop(prepared);
    return;
  }
  final vocabularyValues = [
    for (final change in prepared.localChanges)
      if (change is LibraryVocabularyEditChange) ...change.values,
    ...draft.vocabularyEdits
        .toEditChange(defaultMediaKind: draft.record.kind.apiValue)
        .values,
  ];
  final complete = prepared.copyWith(
    localChanges: [
      for (final change in prepared.localChanges)
        if (change is! LibraryVocabularyEditChange) change,
      if (vocabularyValues.isNotEmpty)
        LibraryVocabularyEditChange(vocabularyValues),
    ],
  );
  await scope?.onCommit?.call(complete);
  if (context.mounted) Navigator.of(context).pop(complete);
}
