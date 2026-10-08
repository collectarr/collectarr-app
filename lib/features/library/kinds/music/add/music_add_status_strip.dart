import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_field_layout.dart';
import 'package:flutter/material.dart';

class MusicAddStatusStrip extends StatelessWidget {
  const MusicAddStatusStrip({super.key, required this.request});
  final LibraryAddManualPaneRequest request;
  @override
  Widget build(BuildContext context) {
    final draft = (request.kindDraft is MusicAddDraft)
        ? request.kindDraft as MusicAddDraft
        : const MusicAddDraft();
    return LibraryResponsiveFieldLayout(maxColumns: 8, columnSpans: const {
      0: 2,
      3: 4
    }, columnBreakpoints: const {
      2: 480,
      8: 720
    }, children: [
      LibraryCollectionStatusField(
          value: request.commonDraft?.collectionStatus,
          onChanged: (value) => request.onCommonDraftChanged
              ?.call(request.commonDraft!.copyWith(collectionStatus: value))),
      LibraryFormField(
          label: 'Index',
          child: LibraryTextFormControl(
              initialValue: draft.indexNumber?.toString() ?? '',
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty || int.tryParse(value) != null
                      ? null
                      : 'Enter a whole number',
              onChanged: (value) => request.onKindDraftChanged
                  ?.call(draft.copyWith(indexNumber: int.tryParse(value))))),
      LibraryFormField(
          label: 'Quantity',
          child: LibraryTextFormControl(
              initialValue: draft.quantity.toString(),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (int.tryParse(value ?? '') ?? 0) < 1 ? 'Minimum 1' : null,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 1) {
                  request.onKindDraftChanged
                      ?.call(draft.copyWith(quantity: parsed));
                }
              })),
      LibraryDropdownPickField<String>(
          label: 'Location',
          value: request.commonDraft?.clearLocation == true
              ? null
              : request.commonDraft?.locationId ?? request.defaultLocationId,
          options: [
            for (final location in request.locations)
              LibraryFieldOption(
                  value: location.id,
                  label: location.fullPath(request.locations))
          ],
          clearOptionLabel: 'No location',
          onChanged: (value) => request.onCommonDraftChanged?.call(request
              .commonDraft!
              .copyWith(locationId: value, clearLocation: value == null))),
    ]);
  }
}
