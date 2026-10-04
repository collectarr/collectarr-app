import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_personal_field_registry.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/metadata/library_field_entries.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_notes_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_personal_fields_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_options_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryEntryPersonalSection extends ConsumerStatefulWidget {
  const LibraryEntryPersonalSection({
    super.key,
    required this.draft,
    this.kindSpecificFields = const <Widget>[],
    this.onRatingChanged,
    this.onNotesChanged,
    this.history,
  });

  final LibraryEntryEditDraft draft;
  final List<Widget> kindSpecificFields;
  final ValueChanged<int?>? onRatingChanged;
  final ValueChanged<String>? onNotesChanged;
  final Widget? history;

  @override
  ConsumerState<LibraryEntryPersonalSection> createState() =>
      _LibraryEntryPersonalSectionState();
}

class _LibraryEntryPersonalSectionState
    extends ConsumerState<LibraryEntryPersonalSection> {
  late final TextEditingController _ratingController;
  Map<String, List<String>> _vocabularyOptions = const {};
  bool _optionsLoaded = false;

  LibraryEntryEditDraft get _draft => widget.draft;
  String get _kind => _draft.record.kind.apiValue;
  String get _ratingKey =>
      _fieldFor(
        PersonalLibraryFieldArea.rating,
        PersonalLibraryFieldEditor.rating,
      )?.key ??
      (throw StateError('The kind has no rating field editor.'));

  PersonalLibraryFieldSpec? _fieldFor(
    PersonalLibraryFieldArea area,
    PersonalLibraryFieldEditor editor,
  ) {
    for (final field in _fieldsFor(area)) {
      if (field.editor == editor) return field;
    }
    return null;
  }

  List<PersonalLibraryFieldSpec> _fieldsFor(PersonalLibraryFieldArea area) =>
      personalFieldContributorFor(_draft.record.kind)
          .fields
          .where((field) => field.area == area)
          .toList()
        ..sort((left, right) =>
            (left.editOrder ?? 999).compareTo(right.editOrder ?? 999));

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController(
      text: _draft.text(_ratingKey),
    )..addListener(_ratingChanged);
    unawaited(_loadOptions());
  }

  @override
  void didUpdateWidget(covariant LibraryEntryPersonalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) {
      _ratingController.removeListener(_ratingChanged);
      _ratingController.text = widget.draft.text(_ratingKey);
      _ratingController.addListener(_ratingChanged);
      unawaited(_loadOptions());
    }
  }

  @override
  void dispose() {
    _ratingController.removeListener(_ratingChanged);
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final db = ref.read(localDatabaseProvider);
    final vocabularyFields = [
      for (final field in _fieldsFor(PersonalLibraryFieldArea.personalFields))
        if (field.editor == PersonalLibraryFieldEditor.singleVocabulary ||
            field.editor == PersonalLibraryFieldEditor.multiVocabulary)
          field,
    ];
    final values = await Future.wait([
      for (final field in vocabularyFields)
        if (field.editor == PersonalLibraryFieldEditor.multiVocabulary)
          loadMultiValuePickListOptions(
            db,
            listName: field.vocabularyListName!,
            mediaKind: _kind,
            selectedValues: splitPickListValues(_draft.text(field.key)),
          )
        else
          loadSingleValuePickListOptions(
            db,
            listName: field.vocabularyListName!,
            mediaKind: _kind,
            selectedValue: _draft.text(field.key),
          ),
    ]);
    if (!mounted) return;
    setState(() {
      _vocabularyOptions = {
        for (var index = 0; index < vocabularyFields.length; index++)
          vocabularyFields[index].key: values[index],
      };
      _optionsLoaded = true;
    });
  }

  void _ratingChanged() {
    final parsed = int.tryParse(_ratingController.text);
    final rating = parsed == 0 ? null : parsed;
    if (_draft.number(_ratingKey) == rating) return;
    _draft.set(_ratingKey, rating);
    widget.onRatingChanged?.call(rating);
  }

  void _setVocabulary(String key, String listName, String? value) {
    _draft.set(key, value);
    final normalized = value?.trim();
    final changeKey = 'vocabulary:$listName';
    if (normalized == null || normalized.isEmpty) {
      _draft.pendingChanges.remove(changeKey);
      return;
    }
    _draft.pendingChanges[changeKey] = LibraryVocabularyEditChange([
      (listName: listName, value: normalized, mediaKind: _kind),
    ]);
  }

  void _setMultiVocabulary(
    PersonalLibraryFieldSpec field,
    List<String> values,
  ) {
    final listName = field.vocabularyListName!;
    _draft.set(field.key, joinPickListValues(values) ?? '');
    _draft.pendingChanges['vocabulary:$listName'] =
        LibraryVocabularyEditChange([
      for (final value in values)
        (
          listName: listName,
          value: value,
          mediaKind: _kind,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _draft,
        builder: (context, _) {
          final fields = [
            for (final field
                in _fieldsFor(PersonalLibraryFieldArea.personalFields))
              _buildPersonalField(field),
          ];
          final ratingField = _fieldFor(
            PersonalLibraryFieldArea.rating,
            PersonalLibraryFieldEditor.rating,
          );
          final notesField = _fieldFor(
            PersonalLibraryFieldArea.notes,
            PersonalLibraryFieldEditor.notes,
          );
          fields.addAll(widget.kindSpecificFields);

          final fullWidthFields = <Widget>[
            if (ratingField != null)
              LibraryFormField(
                label: ratingField.label,
                child: MediaRatingField(controller: _ratingController),
              ),
            if (notesField != null)
              LibraryNotesField(
                fieldKey: ValueKey('library-entry-${notesField.key}'),
                label: notesField.label,
                value: _draft.text(notesField.key),
                onChanged: (value) {
                  _draft.set(notesField.key, value);
                  widget.onNotesChanged?.call(value);
                },
              ),
          ];
          return LibraryPersonalFieldsLayout(
            fields: fields,
            fullWidthFields: fullWidthFields,
            history: widget.history,
          );
        },
      );

  Widget _buildPersonalField(PersonalLibraryFieldSpec field) {
    switch (field.editor) {
      case PersonalLibraryFieldEditor.condition:
        return const SizedBox.shrink();
      case PersonalLibraryFieldEditor.partialDate:
        final partsKey = '${field.key}_parts';
        return LibraryFormField(
          label: field.label,
          child: LibraryPartialDateInput(
            value: PartialDate.tryParse(
              _draft.values[partsKey] ?? _draft.values[field.key],
            ),
            onChanged: (date) {
              _draft.set(partsKey, date?.toJson());
              _draft.set(field.key, date?.asDateTime?.toIso8601String());
            },
          ),
        );
      case PersonalLibraryFieldEditor.money:
        return _money(field);
      case PersonalLibraryFieldEditor.singleVocabulary:
        return _optionsLoaded
            ? _singleVocabulary(field)
            : _text(field.label, field.key);
      case PersonalLibraryFieldEditor.multiVocabulary:
        if (!_optionsLoaded) return _text(field.label, field.key);
        return LibraryMultiValuePickField<String>(
          label: field.label,
          value: splitPickListValues(_draft.text(field.key)).toSet(),
          options: [
            for (final option
                in _vocabularyOptions[field.key] ?? const <String>[])
              LibraryFieldOption<String>(value: option, label: option),
          ],
          allowCustomValueEntry: true,
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
            searchHint: searchHint,
            customValueHint: customValueHint ?? 'Add value',
          ),
          onChanged: (values) =>
              _setMultiVocabulary(field, values.toList(growable: false)),
        );
      case PersonalLibraryFieldEditor.currency:
        return LibraryDropdownPickField<String>(
          label: field.label,
          value: _draft.text(field.key).trim().isEmpty
              ? 'USD'
              : _draft.text(field.key).trim().toUpperCase(),
          options: [
            for (final code in kLibraryCurrencyCodes)
              LibraryFieldOption(value: code, label: code),
          ],
          onChanged: (value) => _draft.set(field.key, value),
        );
      case PersonalLibraryFieldEditor.rating:
      case PersonalLibraryFieldEditor.notes:
      case PersonalLibraryFieldEditor.collectionStatus:
      case PersonalLibraryFieldEditor.integer:
      case PersonalLibraryFieldEditor.location:
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _text(String label, String key) => LibraryFormField(
        label: label,
        child: LibraryTextFormControl(
          key: ValueKey('library-entry-$key'),
          initialValue: _draft.text(key),
          onChanged: (value) => _draft.set(key, value),
        ),
      );

  Widget _money(PersonalLibraryFieldSpec field) => LibraryMoneyAmountField(
        fieldKey: ValueKey('library-entry-${field.key}'),
        label: field.label,
        amountMinorUnits: _draft.number(field.key),
        currency: field.currencyFieldKey == null
            ? 'USD'
            : _draft.text(field.currencyFieldKey!).trim(),
        onChanged: (amount) => _draft.set(field.key, amount),
      );

  Widget _singleVocabulary(PersonalLibraryFieldSpec field) {
    final listName = field.vocabularyListName ?? field.key;
    final options = _vocabularyOptions[field.key] ?? const <String>[];
    final current = _draft.text(field.key).trim();
    final db = ref.read(localDatabaseProvider);
    return LibraryDropdownPickField<String>(
      label: field.label,
      value: current.isEmpty ? null : current,
      options: [
        for (final option in options)
          LibraryFieldOption(value: option, label: option),
      ],
      allowCustomValue: true,
      onChanged: (value) => _setVocabulary(field.key, listName, value),
      openPicker: (
              {required label, required selectedValue, required options}) =>
          showPickListSelectDialog(
        context: context,
        label: label,
        selectedValue: selectedValue,
        options: options,
        listName: listName,
        mediaKind: _kind,
        allowUserValues: true,
        db: db,
      ),
    );
  }
}

class LibraryEntryStatusStrip extends ConsumerStatefulWidget {
  const LibraryEntryStatusStrip({super.key, required this.draft});
  final LibraryEntryEditDraft draft;

  @override
  ConsumerState<LibraryEntryStatusStrip> createState() =>
      _LibraryEntryStatusStripState();
}

class _LibraryEntryStatusStripState
    extends ConsumerState<LibraryEntryStatusStrip> {
  List<StorageLocation> _locations = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocations());
  }

  Future<void> _loadLocations() async {
    final values = await LocationRepository(
      ref.read(localDatabaseProvider),
    ).getAll();
    if (mounted) setState(() => _locations = values);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.draft,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final draft = widget.draft;
            final specs = _fieldsFor(draft);
            final fields = [
              for (final spec in specs) _buildField(draft, spec),
            ];
            final wide = constraints.maxWidth >= 720;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(
                      flex: switch (specs[i].editor) {
                        PersonalLibraryFieldEditor.collectionStatus => 2,
                        PersonalLibraryFieldEditor.location => 4,
                        _ => 1,
                      },
                      child: fields[i],
                    ),
                  ],
                ],
              );
            }
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                for (final field in fields)
                  SizedBox(width: width, child: field),
              ],
            );
          },
        ),
      );

  List<PersonalLibraryFieldSpec> _fieldsFor(
    LibraryEntryEditDraft draft,
  ) =>
      personalFieldContributorFor(draft.record.kind)
          .fields
          .where((field) => field.area == PersonalLibraryFieldArea.statusStrip)
          .toList()
        ..sort((left, right) =>
            (left.editOrder ?? 999).compareTo(right.editOrder ?? 999));

  Widget _buildField(
    LibraryEntryEditDraft draft,
    PersonalLibraryFieldSpec field,
  ) {
    switch (field.editor) {
      case PersonalLibraryFieldEditor.condition:
        return const SizedBox.shrink();
      case PersonalLibraryFieldEditor.collectionStatus:
        final current = draft.text(field.key);
        final value = field.options.contains(current)
            ? current
            : field.options.firstOrNull;
        return LibraryFormField(
          label: field.label,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: [
              for (final option in field.options)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (status) => draft.set(field.key, status),
          ),
        );
      case PersonalLibraryFieldEditor.integer:
        return LibraryFormField(
          label: field.label,
          child: LibraryTextFormControl(
            key: ValueKey('entry-${field.key}'),
            initialValue: draft.number(field.key)?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) => draft.set(field.key, int.tryParse(value)),
          ),
        );
      case PersonalLibraryFieldEditor.location:
        return _locationField(draft, field);
      case PersonalLibraryFieldEditor.partialDate:
      case PersonalLibraryFieldEditor.money:
      case PersonalLibraryFieldEditor.singleVocabulary:
      case PersonalLibraryFieldEditor.multiVocabulary:
      case PersonalLibraryFieldEditor.currency:
      case PersonalLibraryFieldEditor.rating:
      case PersonalLibraryFieldEditor.notes:
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _locationField(
    LibraryEntryEditDraft draft,
    PersonalLibraryFieldSpec field,
  ) {
    final selectedId = draft.text(field.key);
    final db = ref.read(localDatabaseProvider);
    return LibraryDropdownPickField<String>(
      label: field.label,
      value: selectedId.isEmpty ? null : selectedId,
      options: [
        for (final location in _locations)
          LibraryFieldOption(
            value: location.id,
            label: location.fullPath(_locations),
          ),
      ],
      clearOptionLabel: 'No location',
      onChanged: (value) => draft.set(field.key, value),
      openPicker: (
          {required label, required selectedValue, required options}) async {
        final selected = await showLocationPickerDialog(
          context: context,
          db: db,
          currentLocationId: selectedValue,
        );
        if (selected == null) return null;
        await _loadLocations();
        return selected;
      },
    );
  }
}
