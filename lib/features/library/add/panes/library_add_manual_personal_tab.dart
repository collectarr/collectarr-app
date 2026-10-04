import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
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
    final locationId = current.locationId ?? request.defaultLocationId;
    final date = current.purchaseDate ?? request.defaultPurchaseDate;
    final fields = <Widget>[
      if (request.conditions.isNotEmpty)
        LibraryFormField(
          label: 'Condition',
          child: DropdownButtonFormField<String>(
            key: ValueKey('manual-condition-$condition'),
            initialValue: request.conditions.contains(condition)
                ? condition
                : request.conditions.first,
            decoration: const InputDecoration(
              constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
            ),
            items: [
              for (final value in request.conditions)
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: (value) {
              if (value != null) _updateCommon(condition: value);
            },
          ),
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
      LibraryFormField(
        label: 'Purchase Price',
        child: TextFormField(
          key: const ValueKey('manual-price'),
          controller: request.priceController,
          decoration: const InputDecoration(
            constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            final text = value.trim();
            if (text.isEmpty) {
              _updateCommon(pricePaidCents: null);
              return;
            }
            final amount = double.tryParse(text.replaceAll(',', '.'));
            if (amount != null && amount.isFinite && amount >= 0) {
              _updateCommon(pricePaidCents: (amount * 100).round());
            }
          },
        ),
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
      MultiSelectPickListField(
        label: 'Tags',
        values: splitPickListValues(
          request.tagsController.text.trim().isNotEmpty
              ? request.tagsController.text
              : current.tags ?? request.defaultTags,
        ),
        options: request.tagOptions,
        onChanged: (values) {
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
      LibraryFormField(
        label: 'Notes',
        child: TextField(
          controller: request.personalNotesController,
          decoration: const InputDecoration(
            constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
          ),
          minLines: 2,
          maxLines: 4,
        ),
      ),
    ];

    return EditSection(
      title: 'Personal',
      accent: request.accent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 680
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var index = 0; index < fields.length; index++)
                SizedBox(
                  width:
                      index >= fields.length - 2 ? constraints.maxWidth : width,
                  child: fields[index],
                ),
            ],
          );
        },
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
    return LibraryFormField(
      label: 'Location',
      child: DropdownButtonFormField<String>(
        key: ValueKey('manual-location-$selected'),
        initialValue: selected,
        decoration: const InputDecoration(
          constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
        ),
        items: [
          for (final location in request.locations)
            DropdownMenuItem(
              value: location.id,
              child: Text(location.fullPath(request.locations)),
            ),
        ],
        onChanged: (value) {
          if (value != null) _updateCommon(locationId: value);
        },
      ),
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
    String? locationId,
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
        locationId: locationId ?? current.locationId,
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
