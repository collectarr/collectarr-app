import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_listening_edit_draft.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_grade_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_personal_form_layout.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_signed_by_personal_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter/material.dart';

class MusicAddPersonalPane extends StatefulWidget {
  const MusicAddPersonalPane({super.key, required this.request});
  final LibraryAddManualPaneRequest request;
  @override
  State<MusicAddPersonalPane> createState() => _MusicAddPersonalPaneState();
}

class _MusicAddPersonalPaneState extends State<MusicAddPersonalPane> {
  late final TextEditingController _rating;
  late final MusicListeningEditDraft _listening;
  MusicAddDraft get draft => widget.request.kindDraft as MusicAddDraft;
  void update(MusicAddDraft value) => widget.request.onKindDraftChanged!(value);
  @override
  void initState() {
    super.initState();
    _listening = MusicListeningEditDraft(
        const LibraryEntryRef(
            kind: CatalogMediaKind.music, id: LibraryEntryId('manual-music')),
        draft.initialListens)
      ..addListener(_listensChanged);
    _rating = TextEditingController(text: draft.rating?.toString() ?? '')
      ..addListener(_ratingChanged);
  }

  void _listensChanged() =>
      update(draft.copyWith(initialListens: _listening.history));
  void _ratingChanged() =>
      update(draft.copyWith(rating: int.tryParse(_rating.text)));
  @override
  void dispose() {
    _rating.dispose();
    _listening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return LibraryAddManualPersonalTab(
        request: request,
        layoutBuilder: (fields, _) => musicPersonalFormLayout(
            fields, MusicListeningDraftSection(draft: _listening)),
        fieldOverrides: {
          'purchase_date': LibraryFormField(
              label: 'Purchase Date',
              child: LibraryPartialDateInput(
                  value: draft.purchaseDateParts ??
                      (request.commonDraft?.purchaseDate == null
                          ? null
                          : PartialDate.fromDateTime(
                              request.commonDraft!.purchaseDate!)),
                  onChanged: (date) {
                    update(draft.copyWith(purchaseDateParts: date));
                    request.purchaseDateController.text =
                        date?.asDateTime?.toIso8601String() ?? '';
                    final common = request.commonDraft;
                    if (common != null) {
                      request.onCommonDraftChanged?.call(
                          common.copyWith(purchaseDate: date?.asDateTime));
                    }
                  })),
          'market_value_cents': LibraryMoneyAmountField(
              label: 'Current Value',
              amountMinorUnits: draft.marketValueCents,
              currency: request.commonDraft?.currency ?? 'USD',
              onChanged: (value) =>
                  update(draft.copyWith(marketValueCents: value))),
          'last_cleaned_date': LibraryFormField(
              label: 'Last Cleaned Date',
              child: LibraryPartialDateInput(
                  value: draft.lastCleanedDateParts,
                  onChanged: (value) =>
                      update(draft.copyWith(lastCleanedDateParts: value)))),
          'rating': LibraryFormField(
              label: 'My Rating',
              child: MediaRatingField(
                  controller: _rating, showLabel: false, compact: true)),
          'grade': MusicGradeField(
              value: draft.grade,
              onChanged: (value) {
                update(draft.copyWith(grade: value));
                request.onVocabularyValueChanged?.call(
                    fieldId: 'grade',
                    listName: MusicVocabularies.grade.key,
                    value: value == 'Ungraded' ? null : value);
              }),
          'signed_by': MusicSignedByPersonalField(
              value: draft.signedBy,
              onChanged: (value) {
                update(draft.copyWith(signedBy: value));
                request.onVocabularyValuesChanged?.call(
                    fieldId: 'signed_by',
                    listName: 'music.signed_by',
                    values: splitPickListValues(value ?? '').toSet());
              }),
        });
  }
}
