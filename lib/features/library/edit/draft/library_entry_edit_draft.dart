import 'package:collectarr_app/features/library/edit/contracts/library_local_edit_change.dart';
import 'dart:convert';

import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

/// Shared personal form state belonging to the same record as catalog fields.
final class LibraryEntryEditDraft extends ChangeNotifier {
  LibraryEntryEditDraft(this.record)
      : values = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(record.personalData)) as Map,
        );

  final LibraryEntryRecord record;
  final Map<String, dynamic> values;
  bool used = false;
  final Map<Object, LibraryLocalEditChange> pendingChanges = {};

  Map<String, dynamic> get changes => {
    for (final entry in values.entries)
      if (jsonEncode(entry.value) != jsonEncode(record.personalData[entry.key])) entry.key: entry.value,
  };

  String text(String key) => values[key]?.toString() ?? '';
  int? number(String key) => (values[key] as num?)?.toInt();

  void set(String key, Object? value) {
    used = true;
    values[key] = value;
    notifyListeners();
  }
}

class LibraryEntryEditScope extends InheritedWidget {
  const LibraryEntryEditScope({super.key, required this.draft, this.onCommit, required super.child});
  final LibraryEntryEditDraft? draft;
  final Future<void> Function(LibraryEditSelection result)? onCommit;

  static LibraryEntryEditDraft? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LibraryEntryEditScope>()?.draft;

  @override
  bool updateShouldNotify(LibraryEntryEditScope oldWidget) => oldWidget.draft != draft;
}

Future<void> commitLibraryEdit(BuildContext context, LibraryEditSelection result) async {
  final scope = context.getInheritedWidgetOfExactType<LibraryEntryEditScope>();
  final draft = scope?.draft;
  final prepared = draft?.used == true
      ? result.copyWith(entryPersonalData: draft!.changes)
      : result;
  final complete = draft == null ? prepared : prepared.copyWith(localChanges: [...prepared.localChanges, ...draft.pendingChanges.values]);
  await scope?.onCommit?.call(complete);
  if (context.mounted) Navigator.of(context).pop(complete);
}
