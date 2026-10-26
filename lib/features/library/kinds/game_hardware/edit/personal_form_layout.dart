import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:flutter/material.dart';

Map<String, Widget> gameHardwarePersonalAdditionalFields(
        LibraryEntryEditDraft draft) =>
    const {};
Widget gameHardwarePersonalFormLayout(
        Map<String, Widget> fields, Widget? history) =>
    LayoutBuilder(builder: (context, constraints) {
      Widget column(List<String> ids) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final id in ids)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: fields[id] ?? const SizedBox.shrink())
          ]);
      final left = column(['owner_label', 'personal_notes']);
      final right = column(['rating', 'tags']);
      return constraints.maxWidth < 720
          ? Column(children: [left, right])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: left),
              const SizedBox(width: 14),
              Expanded(child: right)
            ]);
    });
