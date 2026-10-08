import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/metadata/library_field_entries.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_notes_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_personal_fields_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter/material.dart';

/// Shared personal fields supported by the manual Add submission path.
final class LibraryAddManualPersonalTab extends StatelessWidget {
  const LibraryAddManualPersonalTab({
    super.key,
    required this.request,
    this.kindSpecificFields = const [],
    this.fieldOverrides = const {},
    this.layoutBuilder,
  });

  final LibraryAddManualPaneRequest request;
  final List<Widget> kindSpecificFields;
  final Map<String, Widget> fieldOverrides;
  final LibraryPersonalLayoutBuilder? layoutBuilder;

  @override
  Widget build(BuildContext context) {
    final current = request.commonDraft ?? const LibraryAddCommonDraft();
    final specs = request.personalFields
        .where((field) => field.manualAddOrder != null)
        .toList()
      ..sort((left, right) =>
          left.manualAddOrder!.compareTo(right.manualAddOrder!));
    final fields = [
      for (final field in specs)
        fieldOverrides[field.key] ?? _buildField(context, field, current),
    ];
    if (layoutBuilder != null) {
      return layoutBuilder!({
        for (var index = 0; index < specs.length; index++)
          specs[index].key: fields[index],
        ...fieldOverrides,
      }, null);
    }
    final notesIndex = specs.indexWhere(
      (field) => field.editor == PersonalLibraryFieldEditor.notes,
    );
    fields.insertAll(
      notesIndex < 0 ? fields.length : notesIndex,
      kindSpecificFields,
    );
    final fullWidthStart = fields.length > 2 ? fields.length - 2 : 0;
    final gridFields = fields.take(fullWidthStart).toList(growable: false);
    final fullWidthFields = fields.skip(fullWidthStart).toList(growable: false);
    return EditSection(
      title: 'Personal',
      accent: request.accent,
      child: LibraryPersonalFieldsLayout(
        fields: gridFields,
        fullWidthFields: fullWidthFields,
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    PersonalLibraryFieldSpec field,
    LibraryAddCommonDraft current,
  ) {
    switch (field.editor) {
      case PersonalLibraryFieldEditor.condition:
        _expectFieldKey(field, 'condition');
        return _conditionField(field, current);
      case PersonalLibraryFieldEditor.location:
        _expectFieldKey(field, 'location_id');
        final selectedId = current.clearLocation
            ? null
            : current.locationId ?? request.defaultLocationId;
        return _locationField(field.label, selectedId);
      case PersonalLibraryFieldEditor.partialDate:
        _expectFieldKey(field, 'purchase_date');
        return _purchaseDateField(
          field.label,
          current.purchaseDate ?? request.defaultPurchaseDate,
        );
      case PersonalLibraryFieldEditor.money:
        _expectFieldKey(field, 'price_paid_cents');
        return LibraryMoneyAmountField(
          key: ValueKey('manual-${field.key}'),
          label: field.label,
          amountMinorUnits: current.pricePaidCents,
          currency: current.currency ?? 'USD',
          controller: request.priceController,
          onChanged: (amount) => _updateCommon(pricePaidCents: amount),
        );
      case PersonalLibraryFieldEditor.singleVocabulary:
        return _singleVocabularyField(field, current);
      case PersonalLibraryFieldEditor.multiVocabulary:
        return _multiVocabularyField(context, field, current);
      case PersonalLibraryFieldEditor.currency:
        _expectFieldKey(field, 'currency');
        return LibraryDropdownPickField<String>(
          label: field.label,
          value: (current.currency ?? 'USD').toUpperCase(),
          options: [
            for (final code in kLibraryCurrencyCodes)
              LibraryFieldOption(value: code, label: code),
          ],
          onChanged: (value) => _updateCommon(currency: value),
        );
      case PersonalLibraryFieldEditor.notes:
        _expectFieldKey(field, 'personal_notes');
        return LibraryNotesField(
          label: field.label,
          controller: request.personalNotesController,
        );
      case PersonalLibraryFieldEditor.rating:
      case PersonalLibraryFieldEditor.collectionStatus:
      case PersonalLibraryFieldEditor.integer:
        throw StateError(
          'Manual Add does not support ${field.editor} for ${field.key}.',
        );
      case null:
        throw StateError(
          'Manual Add field ${field.key} requires an explicit editor.',
        );
    }
  }

  Widget _conditionField(
    PersonalLibraryFieldSpec field,
    LibraryAddCommonDraft current,
  ) {
    final condition = current.condition ?? request.defaultCondition;
    if (request.conditions.isEmpty) {
      return LibraryFormField(
        label: field.label,
        child: LibraryTextFormControl(
          key: ValueKey('manual-${field.key}'),
          initialValue: condition,
          onChanged: (value) => _updateCommon(condition: value),
        ),
      );
    }
    return LibraryDropdownPickField<String>(
      label: field.label,
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
    );
  }

  Widget _singleVocabularyField(
    PersonalLibraryFieldSpec field,
    LibraryAddCommonDraft current,
  ) {
    final isPurchaseStore = field.key == 'purchase_store';
    if (!isPurchaseStore && field.key != 'owner_label') {
      throw StateError(
        'Manual Add has no single-vocabulary binding for ${field.key}.',
      );
    }
    final controller = isPurchaseStore
        ? request.purchaseStoreController
        : request.ownerLabelController;
    final value = controller.text.trim().isNotEmpty
        ? controller.text.trim()
        : isPurchaseStore
            ? current.purchaseStore
            : current.ownerLabel;
    final options =
        isPurchaseStore ? request.purchaseStoreOptions : request.ownerOptions;
    return LibraryDropdownPickField<String>(
      label: field.label,
      value: value,
      options: [
        for (final option in options)
          LibraryFieldOption(value: option, label: option),
      ],
      allowCustomValue: true,
      onChanged: (selected) {
        controller.text = selected ?? '';
        if (isPurchaseStore) {
          _updateCommon(purchaseStore: selected);
        } else {
          _updateCommon(ownerLabel: selected);
        }
        request.onVocabularyValueChanged?.call(
          fieldId: field.key,
          listName: field.vocabularyListName,
          value: selected,
        );
      },
    );
  }

  Widget _multiVocabularyField(
    BuildContext context,
    PersonalLibraryFieldSpec field,
    LibraryAddCommonDraft current,
  ) {
    _expectFieldKey(field, 'tags');
    final rawValues = switch (field.key) {
      'tags' => request.tagsController.text.trim().isNotEmpty
          ? request.tagsController.text
          : current.tags ?? request.defaultTags,
      _ => '',
    };
    return LibraryMultiValuePickField<String>(
      label: field.label,
      value: splitPickListValues(rawValues).toSet(),
      options: [
        for (final option in request.tagOptions)
          LibraryFieldOption<String>(value: option, label: option),
      ],
      allowCustomValueEntry: true,
      pickerSearchHint: 'Search ${field.label.toLowerCase()}',
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
        searchHint: searchHint ?? 'Search ${field.label.toLowerCase()}',
        customValueHint: customValueHint ?? 'Add value',
      ),
      onChanged: (selected) {
        final values = selected.toList(growable: false);
        final joined = joinPickListValues(values) ?? '';
        request.tagsController.text = joined;
        _updateCommon(tags: joined);
        request.onVocabularyValuesChanged?.call(
          fieldId: field.key,
          listName: field.vocabularyListName,
          values: values.toSet(),
        );
      },
    );
  }

  void _expectFieldKey(PersonalLibraryFieldSpec field, String expectedKey) {
    if (field.key != expectedKey) {
      throw StateError(
        'Manual Add ${field.editor} editor expects "$expectedKey", '
        'received "${field.key}".',
      );
    }
  }

  Widget _locationField(String label, String? selectedId) {
    if (request.locations.isEmpty) {
      return LibraryFormField(
        label: label,
        child: LibraryTextFormControl(
          key: ValueKey('manual-location-${request.defaultLocationLabel}'),
          initialValue: request.defaultLocationLabel ?? '',
          readOnly: true,
        ),
      );
    }
    final selected =
        request.locations.any((location) => location.id == selectedId)
            ? selectedId
            : null;
    return LibraryDropdownPickField<String>(
      label: label,
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

  Widget _purchaseDateField(String label, DateTime? currentDate) =>
      LibraryDateFieldButton(
        label: label,
        value: currentDate,
        onChanged: (selected) {
          request.purchaseDateController.text =
              selected == null ? '' : _dateText(selected);
          _updateCommon(purchaseDate: selected);
        },
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
