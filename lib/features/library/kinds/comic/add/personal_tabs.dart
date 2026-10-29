import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import '../edit/entry/entry_draft.dart';
import '../edit/personal_form.dart';
import 'draft.dart';
import 'package:flutter/material.dart';

class ComicAddPersonalTab extends StatelessWidget {
  const ComicAddPersonalTab(
      {super.key,
      required this.request,
      required this.entry,
      required this.valueTab});
  final LibraryAddManualPaneRequest request;
  final ComicEntryEditDraft entry;
  final bool valueTab;

  @override
  Widget build(BuildContext context) {
    final draft = request.kindDraft is ComicAddDraft
        ? request.kindDraft as ComicAddDraft
        : const ComicAddDraft();
    return LibraryAddManualPersonalTab(
      request: request,
      layoutBuilder: (fields, _) => ComicPersonalForm(
        personal: draft.personal,
        entry: entry,
        valueTab: valueTab,
        currency: request.commonDraft?.currency ?? AppFormats.current.currency,
        commonFields: fields,
        update: (value) =>
            request.onKindDraftChanged?.call(draft.copyWith(personal: value)),
      ),
    );
  }
}
