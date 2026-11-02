import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/features/library/edit/fields/dialog_widgets.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/responsive_field_layout.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/add/models/prefill_defaults.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/selection_fields.dart';
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

  String get _title {
    if (widget.kind case final kind?) {
      final identity = defaultLibraryKindRegistry.tryGet(kind)?.identity;
      if (identity != null) {
        return 'Pre-fill ${identity.singularLabel} Details';
      }
    }
    return 'Pre-fill Settings';
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);

    if (appPresentationPlatform.isNativeMobile) {
      final viewport = MediaQuery.sizeOf(context);
      final isPhone = viewport.width < 600 || viewport.height < 480;

      final mobilePage = MobilePage(
        title: _title,
        headerColor: widget.accent,
        backgroundColor: palette.panel,
        onBack: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            tooltip: widget.confirmLabel ?? 'Save',
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_kindFields(_personalDraft) case final kindFields?)
                        _kindPrefillFields(_personalDraft!, kindFields)
                      else
                        _buildDefaultFields(),
                    ],
                  ),
                ),
              ),
        footer: _buildMobileFooter(palette),
      );

      if (!isPhone) {
        return Scaffold(
          backgroundColor: Colors.black54,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: 600,
                  child: mobilePage,
                ),
              ),
            ),
          ),
        );
      }
      return mobilePage;
    }

    return Dialog(
      backgroundColor: palette.panel,
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
                  if (_kindFields(_personalDraft) case final kindFields?)
                    _kindPrefillFields(_personalDraft!, kindFields)
                  else
                    _buildDefaultFields(),
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

  Widget _buildDefaultFields() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        if (fields['owner_label'] case final field?)
                          field,
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
                        if (fields['purchase_store']
                            case final field?)
                          field,
                        if (fields['price_paid_cents']
                            case final field?)
                          field,
                      ],
                    )),
          ],
          if (_showAdditionalFields ||
              appPresentationPlatform.isNativeMobile) ...[
            const SizedBox(height: 15),
            LibraryMultiVocabularyField(
                label: 'Tags',
                options: _tagOptions,
                controller: _tags),
          ],
        ],
      );

  Widget _buildMobileFooter(AppThemePalette palette) {
    final actionLabel = widget.confirmLabel ?? 'Save';
    return Container(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          top: BorderSide(color: palette.divider.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _alwaysShow,
                  onChanged: (value) => setState(() => _alwaysShow = value),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _alwaysShow = !_alwaysShow),
                  child: Text(
                    'Always show',
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.utilityAction,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(80, 44),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: _save,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> Function(LibraryEntryEditDraft)? _kindFields(
          LibraryEntryEditDraft? draft) =>
      draft == null
          ? null
          : libraryEditPresentationForKind(draft.record.kind).prefillFields;

  /// Reference Games pre-fill: the kind's completeness controls, Location
  /// and Owner, purchase facts, Quantity and Tags; no Condition.
  Widget _kindPrefillFields(LibraryEntryEditDraft draft,
          List<Widget> Function(LibraryEntryEditDraft) kindFields) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ListenableBuilder(
            listenable: draft,
            builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final field in kindFields(draft)) ...[
                        field,
                        const SizedBox(height: 12),
                      ],
                    ])),
        LibraryEntryPersonalSection(
            draft: draft,
            layoutBuilder: (fields, _) => LibraryResponsiveFieldLayout(
                  maxColumns: 2,
                  columnBreakpoints: const {2: 600},
                  spacing: 30,
                  runSpacing: 15,
                  children: [
                    _locationField(),
                    fields['owner_label'] ?? const SizedBox.shrink(),
                    if (fields['purchase_date'] case final field?) field,
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                            height: 55,
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: _checkbox(
                                    'Fill with today',
                                    _fillToday,
                                    (value) =>
                                        setState(() => _fillToday = value))))),
                    if (fields['purchase_store'] case final field?) field,
                    if (fields['price_paid_cents'] case final field?) field,
                    LibraryFormField(
                        label: 'Quantity',
                        child: LibraryTextFormControl(
                            key: const ValueKey('prefill-quantity'),
                            initialValue: '${draft.number('quantity') ?? 1}',
                            onChanged: (text) {
                              final quantity = int.tryParse(text.trim());
                              draft.set(
                                  'quantity',
                                  quantity == null || quantity < 1
                                      ? null
                                      : quantity);
                            })),
                  ],
                )),
        const SizedBox(height: 15),
        LibraryMultiVocabularyField(
            label: 'Tags', options: _tagOptions, controller: _tags),
      ]);

  Widget _header() {
    return AccentDialogHeader(
      title: _title,
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

  Widget _locationField() => LibraryDropdownPickField<String>(
      label: 'Location',
      value: _selectedLocationId,
      options: [
        for (final location in _availableLocations)
          LibraryFieldOption(
              value: location.id, label: location.fullPath(_availableLocations))
      ],
      onManage: _pickLocation,
      manageTooltip: 'Manage Locations',
      onChanged: (value) => setState(() => _selectedLocationId = value));

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
      // A pre-fill never sets the value: completeness controls may recompute
      // it, and a new entry keeps the value from its catalog item.
      personalValues: Map.of(_personalDraft?.values ?? const {})
        ..remove('market_value_cents'),
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
  final content = Theme(
    data: editDialogTheme(
      seedColor: accent,
      palette: appPalette(context),
      compactDesktop: !appPresentationPlatform.isNativeMobile,
    ),
    child: PrefillSettingsDialog(
      accent: accent,
      kind: kind,
      confirmLabel: confirmLabel,
    ),
  );
  if (appPresentationPlatform.isNativeMobile) {
    return Navigator.of(context, rootNavigator: true).push<PrefillDefaults>(
      MaterialPageRoute<PrefillDefaults>(
        fullscreenDialog: true,
        builder: (_) => content,
      ),
    );
  }
  return showAppDialog<PrefillDefaults>(
    context: context,
    builder: (_) => content,
  );
}
