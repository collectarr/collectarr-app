import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
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
  List<String> _tags = const [];
  List<String> _owners = const [];
  List<String> _purchaseStores = const [];
  bool _optionsLoaded = false;

  LibraryEntryEditDraft get _draft => widget.draft;
  String get _kind => _draft.record.kind.apiValue;

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController(
      text: _draft.text('rating'),
    )..addListener(_ratingChanged);
    unawaited(_loadOptions());
  }

  @override
  void didUpdateWidget(covariant LibraryEntryPersonalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) {
      _ratingController.removeListener(_ratingChanged);
      _ratingController.text = widget.draft.text('rating');
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
    final values = await Future.wait<Object>([
      loadTagPickListOptions(
        db,
        mediaKind: _kind,
        selectedTags: splitPickListValues(_draft.text('tags')),
      ),
      loadSingleValuePickListOptions(
        db,
        listName: UniversalVocabularies.owners.key,
        mediaKind: _kind,
        selectedValue: _draft.text('owner_label'),
      ),
      loadSingleValuePickListOptions(
        db,
        listName: UniversalVocabularies.purchaseStore.key,
        mediaKind: _kind,
        selectedValue: _draft.text('purchase_store'),
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _tags = values[0] as List<String>;
      _owners = values[1] as List<String>;
      _purchaseStores = values[2] as List<String>;
      _optionsLoaded = true;
    });
  }

  void _ratingChanged() {
    final parsed = int.tryParse(_ratingController.text);
    final rating = parsed == 0 ? null : parsed;
    if (_draft.number('rating') == rating) return;
    _draft.set('rating', rating);
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

  void _setTags(List<String> values) {
    _draft.set('tags', joinPickListValues(values) ?? '');
    _draft.pendingChanges['vocabulary:${UniversalVocabularies.tags.key}'] =
        LibraryVocabularyEditChange([
      for (final value in values)
        (
          listName: UniversalVocabularies.tags.key,
          value: value,
          mediaKind: _kind,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _draft,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720
                ? 4
                : constraints.maxWidth >= 480
                    ? 2
                    : 1;
            final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
            final fields = <Widget>[
              LibraryFormField(
                label: 'Purchase Date',
                child: LibraryPartialDateInput(
                  value: PartialDate.tryParse(
                    _draft.values['purchase_date_parts'] ??
                        _draft.values['purchase_date'],
                  ),
                  onChanged: (date) {
                    _draft.set('purchase_date_parts', date?.toJson());
                    _draft.set(
                      'purchase_date',
                      date?.asDateTime?.toIso8601String(),
                    );
                  },
                ),
              ),
              _money('Purchase Price', 'price_paid_cents'),
              if (_optionsLoaded)
                _singleVocabulary(
                  label: 'Purchase Store',
                  keyName: 'purchase_store',
                  listName: UniversalVocabularies.purchaseStore.key,
                  options: _purchaseStores,
                )
              else
                _text('Purchase Store', 'purchase_store'),
              _money('Current Value', 'market_value_cents'),
              if (_optionsLoaded)
                _singleVocabulary(
                  label: 'Owner',
                  keyName: 'owner_label',
                  listName: UniversalVocabularies.owners.key,
                  options: _owners,
                )
              else
                _text('Owner', 'owner_label'),
              LibraryFormField(
                label: 'Currency',
                child: LibraryDropdownPickField<String>(
                  label: 'Currency',
                  value: _draft.text('currency').trim().isEmpty
                      ? 'USD'
                      : _draft.text('currency').trim().toUpperCase(),
                  options: [
                    for (final code in kLibraryCurrencyCodes)
                      LibraryFieldOption(value: code, label: code),
                  ],
                  onChanged: (value) => _draft.set('currency', value),
                ),
              ),
              if (_optionsLoaded)
                LibraryFormField(
                  label: 'Tags',
                  child: MultiSelectPickListField(
                    label: 'Tags',
                    values: splitPickListValues(_draft.text('tags')),
                    options: _tags,
                    onChanged: _setTags,
                  ),
                )
              else
                _text('Tags', 'tags'),
              LibraryFormField(
                label: 'Last Cleaned Date',
                child: LibraryPartialDateInput(
                  value: PartialDate.tryParse(
                    _draft.values['last_cleaned_date_parts'] ??
                        _draft.values['last_cleaned_date'],
                  ),
                  onChanged: (date) {
                    _draft.set('last_cleaned_date_parts', date?.toJson());
                    _draft.set(
                      'last_cleaned_date',
                      date?.asDateTime?.toIso8601String(),
                    );
                  },
                ),
              ),
            ];
            fields.addAll(widget.kindSpecificFields);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    for (final field in fields)
                      SizedBox(width: width, child: field),
                  ],
                ),
                const SizedBox(height: 14),
                LibraryFormField(
                  label: 'My Rating (0–10)',
                  child: MediaRatingField(controller: _ratingController),
                ),
                const SizedBox(height: 12),
                LibraryFormField(
                  label: 'Notes',
                  child: TextFormField(
                    key: const ValueKey('library-entry-notes'),
                    initialValue: _draft.text('personal_notes'),
                    maxLines: 5,
                    onChanged: (value) {
                      _draft.set('personal_notes', value);
                      widget.onNotesChanged?.call(value);
                    },
                  ),
                ),
                if (widget.history != null) ...[
                  const SizedBox(height: 14),
                  widget.history!,
                ],
              ],
            );
          },
        ),
      );

  Widget _text(String label, String key) => LibraryFormField(
        label: label,
        child: TextFormField(
          key: ValueKey('library-entry-$key'),
          initialValue: _draft.text(key),
          onChanged: (value) => _draft.set(key, value),
        ),
      );

  Widget _money(String label, String key) => LibraryFormField(
        label: label,
        child: TextFormField(
          key: ValueKey('library-entry-$key'),
          initialValue: _draft.number(key) == null
              ? ''
              : (_draft.number(key)! / 100).toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText:
                '${_draft.text('currency').isEmpty ? 'USD' : _draft.text('currency')} ',
          ),
          validator: (value) => value == null ||
                  value.isEmpty ||
                  double.tryParse(value.replaceAll(',', '.')) != null
              ? null
              : 'Enter an amount',
          onChanged: (raw) {
            final amount = double.tryParse(raw.replaceAll(',', '.'));
            _draft.set(key, amount == null ? null : (amount * 100).round());
          },
        ),
      );

  Widget _singleVocabulary({
    required String label,
    required String keyName,
    required String listName,
    required List<String> options,
  }) {
    final current = _draft.text(keyName).trim();
    final db = ref.read(localDatabaseProvider);
    return LibraryDropdownPickField<String>(
      label: label,
      value: current.isEmpty ? null : current,
      options: [
        for (final option in options)
          LibraryFieldOption(value: option, label: option),
      ],
      allowCustomValue: true,
      onChanged: (value) => _setVocabulary(keyName, listName, value),
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
            final fields = <Widget>[
              LibraryFormField(
                label: 'Collection Status',
                child: DropdownButtonFormField<String>(
                  initialValue: _status(draft.text('collection_status')),
                  items: [
                    for (final status in _statuses)
                      DropdownMenuItem(value: status, child: Text(status)),
                  ],
                  onChanged: (status) => draft.set('collection_status', status),
                ),
              ),
              LibraryFormField(
                label: 'Index',
                child: TextFormField(
                  key: const ValueKey('entry-index'),
                  initialValue: draft.number('index_number')?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      draft.set('index_number', int.tryParse(value)),
                ),
              ),
              LibraryFormField(
                label: 'Quantity',
                child: TextFormField(
                  key: const ValueKey('entry-quantity'),
                  initialValue: (draft.number('quantity') ?? 1).toString(),
                  keyboardType: TextInputType.number,
                  validator: (raw) =>
                      (int.tryParse(raw ?? '') ?? 0) < 1 ? 'Minimum 1' : null,
                  onChanged: (value) =>
                      draft.set('quantity', int.tryParse(value) ?? 1),
                ),
              ),
              _locationField(draft),
            ];
            final wide = constraints.maxWidth >= 720;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(flex: [2, 1, 1, 4][i], child: fields[i]),
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

  Widget _locationField(LibraryEntryEditDraft draft) {
    final selectedId = draft.text('location_id');
    final db = ref.read(localDatabaseProvider);
    return LibraryDropdownPickField<String>(
      label: 'Location',
      value: selectedId.isEmpty ? null : selectedId,
      options: [
        for (final location in _locations)
          LibraryFieldOption(
            value: location.id,
            label: location.fullPath(_locations),
          ),
      ],
      clearOptionLabel: 'No location',
      onChanged: (value) => draft.set('location_id', value),
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

const _statuses = [
  'In Collection',
  'For Sale',
  'Wish List',
  'On Order',
  'Not in Collection',
  'Sold',
];

String _status(String value) =>
    _statuses.contains(value) ? value : 'In Collection';
