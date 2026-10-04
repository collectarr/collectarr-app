import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_notes_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_personal_fields_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared personal fields supported by the manual Add submission path.
final class LibraryAddManualPersonalTab extends StatelessWidget {
  const LibraryAddManualPersonalTab({
    super.key,
    required this.request,
  });

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final current = request.commonDraft ?? const LibraryAddCommonDraft();
    final condition = current.condition ?? request.defaultCondition;
    final locationId = current.clearLocation
        ? null
        : current.locationId ?? request.defaultLocationId;
    final date = current.purchaseDate ?? request.defaultPurchaseDate;
    final fields = <Widget>[
      if (request.conditions.isNotEmpty)
        LibraryDropdownPickField<String>(
          label: 'Condition',
          value: request.conditions.contains(condition)
              ? condition
              : request.conditions.first,
          options: [
            for (final value in request.conditions)
              LibraryFieldOption(value: value, label: value),
          ],
          onChanged: (value) {
            if (value != null) _updateCommon(condition: value);
          },
        )
      else
        LibraryFormField(
          label: 'Condition',
          child: TextFormField(
            key: const ValueKey('manual-condition'),
            initialValue: condition,
            decoration: const InputDecoration(
              constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
            ),
            onChanged: (value) => _updateCommon(condition: value),
          ),
        ),
      _locationField(locationId),
      _purchaseDateField(context, date),
      LibraryMoneyAmountField(
        key: const ValueKey('manual-price'),
        label: 'Purchase Price',
        amountMinorUnits: current.pricePaidCents,
        currency: current.currency ?? 'USD',
        controller: request.priceController,
        onChanged: (amount) => _updateCommon(pricePaidCents: amount),
      ),
      LibraryDropdownPickField<String>(
        label: 'Currency',
        value: (current.currency ?? 'USD').toUpperCase(),
        options: [
          for (final code in kLibraryCurrencyCodes)
            LibraryFieldOption(value: code, label: code),
        ],
        onChanged: (value) => _updateCommon(currency: value),
      ),
      LibraryDropdownPickField<String>(
        label: 'Purchase Store',
        value: request.purchaseStoreController.text.trim().isNotEmpty
            ? request.purchaseStoreController.text.trim()
            : current.purchaseStore,
        options: [
          for (final value in request.purchaseStoreOptions)
            LibraryFieldOption(value: value, label: value),
        ],
        allowCustomValue: true,
        onChanged: (value) {
          request.purchaseStoreController.text = value ?? '';
          _updateCommon(purchaseStore: value);
          request.onVocabularyValueChanged?.call(
            fieldId: 'purchase_store',
            listName: UniversalVocabularies.purchaseStore.key,
            value: value,
          );
        },
      ),
      LibraryDropdownPickField<String>(
        label: 'Owner',
        value: request.ownerLabelController.text.trim().isNotEmpty
            ? request.ownerLabelController.text.trim()
            : current.ownerLabel,
        options: [
          for (final value in request.ownerOptions)
            LibraryFieldOption(value: value, label: value),
        ],
        allowCustomValue: true,
        onChanged: (value) {
          request.ownerLabelController.text = value ?? '';
          _updateCommon(ownerLabel: value);
          request.onVocabularyValueChanged?.call(
            fieldId: 'owner_label',
            listName: UniversalVocabularies.owners.key,
            value: value,
          );
        },
      ),
      LibraryMultiValuePickField<String>(
        label: 'Tags',
        value: splitPickListValues(
          request.tagsController.text.trim().isNotEmpty
              ? request.tagsController.text
              : current.tags ?? request.defaultTags,
        ).toSet(),
        options: [
          for (final option in request.tagOptions)
            LibraryFieldOption<String>(value: option, label: option),
        ],
        allowCustomValueEntry: true,
        pickerSearchHint: 'Search tags',
        onOpenPicker: (
                {required label,
                required selectedValues,
                required options,
                searchHint,
                customValueHint}) =>
            showLibraryMultiValueOptionsDialog<String>(
          context: context,
          label: label,
          options: options,
          selectedValues: selectedValues,
          searchHint: searchHint ?? 'Search tags',
          customValueHint: customValueHint ?? 'Add value',
        ),
        onChanged: (selected) {
          final values = selected.toList(growable: false);
          final joined = joinPickListValues(values) ?? '';
          request.tagsController.text = joined;
          _updateCommon(tags: joined);
          request.onVocabularyValuesChanged?.call(
            fieldId: 'tags',
            listName: UniversalVocabularies.tags.key,
            values: values.toSet(),
          );
        },
      ),
      LibraryNotesField(
        label: 'Notes',
        controller: request.personalNotesController,
      ),
    ];

    final gridFields = fields.take(fields.length - 2).toList(growable: false);
    final fullWidthFields =
        fields.skip(fields.length - 2).toList(growable: false);
    return EditSection(
      title: 'Personal',
      accent: request.accent,
      child: LibraryPersonalFieldsLayout(
        fields: gridFields,
        fullWidthFields: fullWidthFields,
      ),
    );
  }

  Widget _locationField(String? selectedId) {
    if (request.locations.isEmpty) {
      return LibraryFormField(
        label: 'Location',
        child: TextFormField(
          key: ValueKey('manual-location-${request.defaultLocationLabel}'),
          initialValue: request.defaultLocationLabel ?? '',
          readOnly: true,
          decoration: const InputDecoration(
            constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
          ),
        ),
      );
    }
    final selected =
        request.locations.any((location) => location.id == selectedId)
            ? selectedId
            : null;
    return LibraryDropdownPickField<String>(
      label: 'Location',
      value: selected,
      options: [
        for (final location in request.locations)
          LibraryFieldOption(
            value: location.id,
            label: location.fullPath(request.locations),
          ),
      ],
      clearOptionLabel: 'No location',
      onChanged: (value) => _updateCommon(locationId: value),
    );
  }

  Widget _purchaseDateField(BuildContext context, DateTime? currentDate) =>
      LibraryFormField(
        label: 'Purchase Date',
        child: InkWell(
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime(1),
              lastDate: DateTime(9999),
            );
            if (selected == null) return;
            request.purchaseDateController.text = _dateText(selected);
            _updateCommon(purchaseDate: selected);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_month_outlined),
              constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
            ),
            child: Text(
              currentDate == null ? 'Select a date' : _dateText(currentDate),
              style: TextStyle(
                color: currentDate == null
                    ? appPalette(context).textMuted
                    : appPalette(context).textPrimary,
              ),
            ),
          ),
        ),
      );

  void _updateCommon({
    String? condition,
    Object? tags = _unchanged,
    Object? purchaseDate = _unchanged,
    Object? pricePaidCents = _unchanged,
    Object? currency = _unchanged,
    Object? purchaseStore = _unchanged,
    Object? ownerLabel = _unchanged,
    Object? locationId = _unchanged,
  }) {
    final current = request.commonDraft ?? const LibraryAddCommonDraft();
    request.onCommonDraftChanged?.call(
      LibraryAddCommonDraft(
        condition: condition ?? current.condition,
        purchaseDate: identical(purchaseDate, _unchanged)
            ? current.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _unchanged)
            ? current.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _unchanged)
            ? current.currency
            : currency as String?,
        personalNotes: current.personalNotes,
        tags: identical(tags, _unchanged) ? current.tags : tags as String?,
        locationId: identical(locationId, _unchanged)
            ? current.locationId
            : locationId as String?,
        clearLocation: identical(locationId, _unchanged)
            ? current.clearLocation
            : locationId == null,
        purchaseStore: identical(purchaseStore, _unchanged)
            ? current.purchaseStore
            : purchaseStore as String?,
        ownerLabel: identical(ownerLabel, _unchanged)
            ? current.ownerLabel
            : ownerLabel as String?,
        collectionStatus: current.collectionStatus,
        isDigital: current.isDigital,
      ),
    );
  }

  static String _dateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

const Object _unchanged = Object();
