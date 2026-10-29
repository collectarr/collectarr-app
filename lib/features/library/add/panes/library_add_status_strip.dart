import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_integer_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_field_layout.dart';
import 'package:flutter/material.dart';

/// Manual Add footer under every tab: Collection Status, Index, Quantity and
/// Location. The kind owns where Index and Quantity are kept.
class LibraryAddStatusStrip extends StatelessWidget {
  const LibraryAddStatusStrip({
    super.key,
    required this.request,
    required this.indexValue,
    required this.quantity,
    required this.onIndexChanged,
    required this.onQuantityChanged,
  });

  final LibraryAddManualPaneRequest request;
  final int? indexValue;
  final int quantity;
  final ValueChanged<int?> onIndexChanged;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
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
          child: LibraryIntegerField(
              initialValue: indexValue?.toString() ?? '',
              onChanged: (value) => onIndexChanged(int.tryParse(value)))),
      LibraryFormField(
          label: 'Quantity',
          child: LibraryIntegerField(
              initialValue: quantity.toString(),
              // An emptied Quantity saves as 0, as in the reference.
              onChanged: (value) =>
                  onQuantityChanged(int.tryParse(value) ?? 0))),
      LibraryDropdownPickField<String>(
          label: request.personalFields
                  .where((field) => field.key == 'location_id')
                  .firstOrNull
                  ?.label ??
              'Location',
          value: request.commonDraft?.clearLocation == true
              ? null
              : request.commonDraft?.locationId ?? request.defaultLocationId,
          options: [
            for (final location in request.locations)
              LibraryFieldOption(
                  value: location.id,
                  label: location.fullPath(request.locations))
          ],
          onChanged: (value) => request.onCommonDraftChanged?.call(request
              .commonDraft!
              .copyWith(locationId: value, clearLocation: value == null))),
    ]);
  }
}
