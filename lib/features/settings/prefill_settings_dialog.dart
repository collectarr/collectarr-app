import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_field_layout.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/add/models/library_add_prefill_defaults.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';

class PrefillSettingsDialog extends ConsumerStatefulWidget {
  const PrefillSettingsDialog(
      {super.key, required this.accent, this.kind, this.confirmLabel});

  final Color accent;
  final CatalogMediaKind? kind;
  final String? confirmLabel;

  @override
  ConsumerState<PrefillSettingsDialog> createState() =>
      _PrefillSettingsDialogState();
}

class _PrefillSettingsDialogState extends ConsumerState<PrefillSettingsDialog> {
  final _tags = LibraryValuesController();
  List<String> _tagOptions = const [];
  final _conditionController = TextEditingController();
  bool _alwaysShow = true;
  bool _fillToday = false;
  bool _loaded = false;
  bool _showAdditionalFields = false;
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  LibraryEntryEditDraft? _personalDraft;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tags.dispose();
    _conditionController.dispose();
    _personalDraft?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final defaults = await PrefillDefaults.load(widget.kind);
    final locations = await ref.read(allLocationsProvider.future);
    final kind = widget.kind;
    final tagOptions = kind == null
        ? defaults.tags ?? const <String>[]
        : await loadTagPickListOptions(
            ref.read(localDatabaseProvider),
            mediaKind: kind.apiValue,
            selectedTags: defaults.tags ?? const [],
          );
    if (!mounted) return;
    setState(() {
      _tags.value = defaults.tags ?? const [];
      _tagOptions = tagOptions;
      _conditionController.text =
          defaults.personalValues['condition'] as String? ?? '';
      _alwaysShow = defaults.alwaysShow;
      _fillToday = defaults.fillPurchaseDateWithToday;
      _availableLocations = locations;
      _selectedLocationId = defaults.locationId;
      if (widget.kind case final kind?) {
        _personalDraft = LibraryEntryEditDraft(LibraryEntryRecord(
            id: 'prefill',
            kind: kind,
            catalogData: const {'title': 'Default values'},
            personalData: defaults.personalValues,
            updatedAt: DateTime.now().toUtc()));
      }
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appPalette(context).panel,
      alignment: const Alignment(0, -.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: widget.kind == null ? 440 : 800, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            if (!_loaded)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                  child: SingleChildScrollView(
                      child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  LibraryResponsiveFieldLayout(
                    maxColumns: 2,
                    columnBreakpoints: const {2: 600},
                    spacing: 30,
                    runSpacing: 15,
                    children: [
                      _locationField(),
                      if (_personalDraft case final draft?)
                        LibraryFormField(
                            label: 'Condition',
                            child: SingleValuePickField(
                                showInlineLabel: false,
                                controller: _conditionController,
                                options: libraryEditPresentationForKind(
                                        draft.record.kind)
                                    .conditions,
                                label: 'Condition',
                                onChanged: (value) =>
                                    draft.set('condition', value))),
                    ],
                  ),
                  if (_personalDraft case final draft?) ...[
                    const SizedBox(height: 15),
                    LibraryEntryPersonalSection(
                        draft: draft,
                        layoutBuilder: (fields, _) =>
                            LibraryResponsiveFieldLayout(
                              maxColumns: 2,
                              columnBreakpoints: const {2: 600},
                              spacing: 30,
                              runSpacing: 15,
                              children: [
                                if (fields['purchase_date'] case final field?)
                                  field,
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: SizedBox(
                                        height: 55,
                                        child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: _checkbox(
                                                'Fill purchase date with today',
                                                _fillToday,
                                                (value) => setState(() =>
                                                    _fillToday = value))))),
                                if (fields['purchase_store'] case final field?)
                                  field,
                                if (fields['price_paid_cents']
                                    case final field?)
                                  field,
                                if (_showAdditionalFields)
                                  if (fields['currency'] case final field?)
                                    field,
                              ],
                            )),
                  ],
                  if (_showAdditionalFields) ...[
                    const SizedBox(height: 15),
                    LibraryMultiVocabularyField(
                        label: 'Tags', options: _tagOptions, controller: _tags),
                  ],
                  const SizedBox(height: 25),
                  SizedBox(
                      width: double.infinity,
                      child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  tooltip: 'Additional Fields',
                                  onPressed: () => setState(() =>
                                      _showAdditionalFields =
                                          !_showAdditionalFields),
                                  icon: const Icon(Icons.settings, size: 18)),
                              _checkbox(
                                  'Always show this screen',
                                  _alwaysShow,
                                  (value) =>
                                      setState(() => _alwaysShow = value)),
                            ]),
                            TextButton(
                                onPressed: _clearAll,
                                child: const Text('Clear All')),
                          ])),
                ]),
              ))),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return AccentDialogHeader(
      title: 'Pre-fill Settings',
      accent: widget.accent,
      icon: Icons.auto_fix_high,
    );
  }

  void _clearAll() => setState(() {
        _selectedLocationId = null;
        _tags.value = const [];
        _personalDraft?.reset();
        _conditionController.clear();
        _fillToday = false;
      });

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
                value: value,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                })),
        const SizedBox(width: 5),
        Flexible(
            child: GestureDetector(
                onTap: () => onChanged(!value),
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400))))),
      ]);

  Widget _locationField() {
    final label = locationPathForId(_availableLocations, _selectedLocationId);
    return LibraryFormField(
        label: 'Location',
        child: SizedBox(
            height: 34,
            child: Row(children: [
              Expanded(
                  child: InkWell(
                onTap: _pickLocation,
                mouseCursor: SystemMouseCursors.click,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                      color: appPalette(context).field,
                      border: Border.all(color: appPalette(context).divider),
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(children: [
                    Expanded(
                        child: Text(label ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14))),
                    const Icon(Icons.arrow_drop_down, size: 18)
                  ]),
                ),
              )),
              IconButton(
                  tooltip: 'Manage Locations',
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.list, size: 18)),
              if (label != null)
                IconButton(
                    tooltip: 'Clear location',
                    onPressed: () => setState(() => _selectedLocationId = null),
                    icon: const Icon(Icons.clear, size: 16)),
            ])));
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _selectedLocationId,
    );
    if (result == null) {
      return;
    }
    ref.invalidate(allLocationsProvider);
    final locations = await ref.read(allLocationsProvider.future);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }

  Future<void> _save() async {
    final defaults = PrefillDefaults(
      alwaysShow: _alwaysShow,
      fillPurchaseDateWithToday: _fillToday,
      locationId: _selectedLocationId,
      tags: _tags.value.isEmpty ? null : _tags.value,
      personalValues: Map.of(_personalDraft?.values ?? const {}),
    );
    await defaults.save(widget.kind);
    if (mounted) Navigator.of(context).pop(defaults);
  }

  Widget _footer() => Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: appPalette(context).textPrimary),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          const SizedBox(width: 8),
          SizedBox(
              width: 150,
              height: 40,
              child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: appPalette(context).utilityAction,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                          fontFamily: appFontFamily,
                          fontFamilyFallback: kAppFontFamilyFallback,
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                  onPressed: _save,
                  child: Text(widget.confirmLabel ?? 'Save'))),
        ]),
      );
}

Future<PrefillDefaults?> showPrefillSettingsDialog({
  required BuildContext context,
  required Color accent,
  CatalogMediaKind? kind,
  String? confirmLabel,
}) {
  return showAppDialog<PrefillDefaults>(
    context: context,
    builder: (context) => Theme(
        data: editDialogTheme(
            seedColor: accent,
            palette: appPalette(context),
            compactDesktop: true),
        child: PrefillSettingsDialog(
            accent: accent, kind: kind, confirmLabel: confirmLabel)),
  );
}
