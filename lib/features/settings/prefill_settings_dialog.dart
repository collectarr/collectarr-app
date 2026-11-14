import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/library/add/models/prefill_defaults.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_personal_field_registry.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/responsive_field_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/selection_fields.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/settings/prefill_fields_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared fields Pre-fill Settings draws itself rather than through the
/// personal section.
const _ownFields = {
  'location_id',
  'condition',
  'purchase_date',
  'quantity',
  'tags',
  'market_value_cents',
};

class PrefillSettingsDialog extends ConsumerStatefulWidget {
  const PrefillSettingsDialog(
      {super.key, required this.accent, required this.kind, this.confirmLabel});

  final Color accent;
  final CatalogMediaKind kind;
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
  bool _fillPriceFromCover = false;
  int _coverDiscountPercent = 0;
  int _coverDiscountResets = 0;
  bool _loaded = false;
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  late final LibraryEntryEditDraft _draft;

  /// The fields shown, in order, as chosen in Pre-fill fields.
  List<String> _fields = const [];

  LibraryEditPresentationCapability get _presentation =>
      libraryEditPresentationForKind(widget.kind);

  late final Map<String, PersonalLibraryFieldSpec> _specs = {
    for (final field in personalFieldContributorFor(widget.kind).fields)
      field.key: field,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tags.dispose();
    _conditionController.dispose();
    if (_loaded) _draft.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final defaults = await PrefillDefaults.load(widget.kind);
    final locations = await ref.read(allLocationsProvider.future);
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.kind.apiValue,
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
      _fillPriceFromCover = defaults.fillPriceWithCoverPrice;
      _coverDiscountPercent = defaults.coverPriceDiscountPercent;
      _availableLocations = locations;
      _selectedLocationId = defaults.locationId;
      _draft = LibraryEntryEditDraft(LibraryEntryRecord(
          id: 'prefill',
          kind: widget.kind,
          catalogData: const {'title': 'Default values'},
          personalData: defaults.personalValues,
          updatedAt: DateTime.now().toUtc()));
      final available = {for (final choice in _choices()) choice.id};
      _fields = [
        for (final id in defaults.fields ?? _defaultFields())
          if (available.contains(id)) id,
      ];
      _loaded = true;
    });
  }

  List<LibraryPrefillField> _kindFields() =>
      _presentation.prefillFields?.call(_draft) ?? const [];

  String _label(String key, String fallback) => _specs[key]?.label ?? fallback;

  /// Every field Pre-fill fields offers, under the reference's groups.
  List<PrefillFieldChoice> _choices() => [
        for (final field in _kindFields())
          (id: field.id, label: field.label, group: 'Value'),
        if (_presentation.conditions.isNotEmpty &&
            !_kindFields().any((field) => field.id == 'condition'))
          (
            id: 'condition',
            label: _label('condition', 'Condition'),
            group: 'Value'
          ),
        for (final key in [
          'purchase_date',
          'purchase_store',
          'price_paid_cents'
        ])
          if (_specs[key] case final spec?)
            (id: key, label: spec.label, group: 'Value'),
        (
          id: 'location_id',
          label: _label('location_id', 'Location'),
          group: 'Personal'
        ),
        if (_specs['owner_label'] case final spec?)
          (id: 'owner_label', label: spec.label, group: 'Personal'),
        if (_specs.containsKey('quantity') ||
            _presentation.prefillFields != null)
          (
            id: 'quantity',
            label: _label('quantity', 'Quantity'),
            group: 'Personal'
          ),
        for (final spec in _specs.values)
          if (spec.area == PersonalLibraryFieldArea.rating ||
              spec.area == PersonalLibraryFieldArea.notes ||
              (spec.area == PersonalLibraryFieldArea.personalFields &&
                  !_ownFields.contains(spec.key) &&
                  !{'owner_label', 'purchase_store', 'price_paid_cents'}
                      .contains(spec.key)))
            (id: spec.key, label: spec.label, group: 'Personal'),
        (id: 'tags', label: _label('tags', 'Tags'), group: 'Personal'),
      ];

  /// The reference's fields before any are chosen: a kind's own controls
  /// replace Condition and add Quantity.
  List<String> _defaultFields() {
    final kindFields = _kindFields();
    return [
      for (final field in kindFields)
        if (field.shownByDefault) field.id,
      'location_id',
      if (kindFields.isEmpty) 'condition',
      'owner_label',
      'purchase_date',
      'purchase_store',
      'price_paid_cents',
      if (kindFields.isNotEmpty) 'quantity',
      'tags',
    ];
  }

  /// The draft values a field sets.
  List<String> _keysOf(String id) {
    for (final field in _kindFields()) {
      if (field.id == id) return field.keys;
    }
    return switch (id) {
      'purchase_date' => const ['purchase_date', 'purchase_date_parts'],
      'price_paid_cents' => const ['price_paid_cents', 'currency'],
      _ => [id],
    };
  }

  String get _title {
    final identity = defaultLibraryKindRegistry.tryGet(widget.kind)?.identity;
    return identity == null
        ? 'Pre-fill Settings'
        : 'Pre-fill ${identity.singularLabel} Details';
  }

  Future<void> _chooseFields() async {
    final chosen = await showPrefillFieldsDialog(
      context: context,
      accent: widget.accent,
      choices: _choices(),
      selected: _fields,
    );
    if (chosen != null && mounted) setState(() => _fields = chosen);
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
            tooltip: 'Pre-fill fields',
            icon: const Icon(AppIcons.settings),
            onPressed: _loaded ? _chooseFields : null,
          ),
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
                  child: _form(),
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
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccentDialogHeader(title: _title, accent: widget.accent),
            if (!_loaded)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else ...[
              Flexible(
                  child: SingleChildScrollView(
                      child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
                child: _form(),
              ))),
              _optionBar(palette),
              _footer(palette),
            ],
          ],
        ),
      ),
    );
  }

  /// The chosen fields in two columns, a kind's controls, Tags, Rating and
  /// Notes across both; Fill with today follows Purchase Date and the cover
  /// price fill follows Purchase Price.
  Widget _form() => LibraryEntryPersonalSection(
        draft: _draft,
        layoutBuilder: (fields, _) {
          final kindFields = {
            for (final field in _kindFields()) field.id: field
          };
          final cells = <Widget>[];
          final fullWidth = <int>{};
          void add(Widget? cell, {bool wide = false}) {
            if (cell == null) return;
            if (wide) fullWidth.add(cells.length);
            cells.add(cell);
          }

          for (final id in _fields) {
            switch (id) {
              case _ when kindFields.containsKey(id):
                add(kindFields[id]!.field, wide: kindFields[id]!.fullWidth);
              case 'location_id':
                add(_locationField());
              case 'condition':
                add(_conditionField());
              case 'purchase_date':
                add(_purchaseDateField());
                add(_fillTodayCheckbox());
              case 'price_paid_cents':
                add(fields[id]);
                if (_presentation.prefillPriceFromCover) add(_coverPriceFill());
              case 'quantity':
                add(_quantityField());
              case 'tags':
                add(
                    LibraryMultiVocabularyField(
                        label: _label('tags', 'Tags'),
                        options: _tagOptions,
                        controller: _tags),
                    wide: true);
              case _
                  when _specs[id]?.area == PersonalLibraryFieldArea.rating ||
                      _specs[id]?.area == PersonalLibraryFieldArea.notes:
                add(fields[id], wide: true);
              default:
                add(fields[id]);
            }
          }
          return LibraryResponsiveFieldLayout(
            maxColumns: 2,
            columnBreakpoints: const {2: 600},
            spacing: 30,
            runSpacing: 15,
            fullWidthIndices: fullWidth,
            children: cells,
          );
        },
      );

  Widget _conditionField() => LibraryFormField(
      label: _label('condition', 'Condition'),
      child: SingleValuePickField(
          showInlineLabel: false,
          controller: _conditionController,
          options: _presentation.conditions,
          label: _label('condition', 'Condition'),
          onChanged: (value) => _draft.set('condition', value)));

  /// Shows today, read-only, while Fill with today is ticked.
  Widget _purchaseDateField() => LibraryPartialDateField(
        label: _label('purchase_date', 'Purchase Date'),
        enabled: !_fillToday,
        value: _fillToday
            ? PartialDate.fromDateTime(DateTime.now())
            : PartialDate.tryParse(_draft.values['purchase_date_parts'] ??
                _draft.values['purchase_date']),
        onChanged: (date) {
          _draft.set('purchase_date_parts', date?.toJson());
          _draft.set('purchase_date', date?.asDateTime?.toIso8601String());
        },
      );

  Widget _fillTodayCheckbox() => Align(
      alignment: Alignment.bottomLeft,
      child: SizedBox(
          height: 55,
          child: Align(
              alignment: Alignment.bottomLeft,
              child: _checkbox('Fill with today', _fillToday,
                  (value) => setState(() => _fillToday = value)))));

  Widget _quantityField() => LibraryFormField(
      label: _label('quantity', 'Quantity'),
      child: LibraryTextFormControl(
          key: const ValueKey('prefill-quantity'),
          initialValue: '${_draft.number('quantity') ?? 1}',
          onChanged: (text) {
            final quantity = int.tryParse(text.trim());
            _draft.set(
                'quantity', quantity == null || quantity < 1 ? null : quantity);
          }));

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

  /// Beside Purchase Price: each new item's cover price, less a discount.
  Widget _coverPriceFill() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: SizedBox(
                  height: 55,
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: _checkbox(
                          'Fill with Cover Price',
                          _fillPriceFromCover,
                          (value) =>
                              setState(() => _fillPriceFromCover = value))))),
          const SizedBox(width: 12),
          SizedBox(
              width: 100,
              child: LibraryFormField(
                  label: 'Discount %',
                  child: LibraryTextFormControl(
                      key: ValueKey(
                          'prefill-cover-discount-$_coverDiscountResets'),
                      enabled: _fillPriceFromCover,
                      keyboardType: TextInputType.number,
                      initialValue: _coverDiscountPercent == 0
                          ? ''
                          : '$_coverDiscountPercent',
                      onChanged: (text) => _coverDiscountPercent =
                          (int.tryParse(text.trim()) ?? 0).clamp(0, 100)))),
        ],
      );

  void _clearAll() => setState(() {
        _selectedLocationId = null;
        _tags.value = const [];
        _draft.reset();
        _conditionController.clear();
        _fillToday = false;
        _fillPriceFromCover = false;
        _coverDiscountPercent = 0;
        _coverDiscountResets++;
      });

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged,
          {bool bold = false}) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 24,
            height: 24,
            child: AppCheckbox(value: value, onChanged: onChanged)),
        const SizedBox(width: 5),
        Flexible(
            child: GestureDetector(
                onTap: () => onChanged(!value),
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight:
                                bold ? FontWeight.w700 : FontWeight.w400))))),
      ]);

  Widget _locationField() => LibraryDropdownPickField<String>(
      label: _label('location_id', 'Location'),
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

  /// Saves only the shown fields' values, so a field taken out of Pre-fill
  /// fields no longer fills new items.
  Future<void> _save() async {
    final shown = _fields.toSet();
    final values = Map.of(_draft.values)
      // A pre-fill never sets the value: completeness controls may recompute
      // it, and a new entry keeps the value from its catalog item.
      ..remove('market_value_cents');
    for (final choice in _choices()) {
      if (!shown.contains(choice.id)) _keysOf(choice.id).forEach(values.remove);
    }
    final fillToday = _fillToday && shown.contains('purchase_date');
    if (fillToday) _keysOf('purchase_date').forEach(values.remove);
    final defaults = PrefillDefaults(
      alwaysShow: _alwaysShow,
      fillPurchaseDateWithToday: fillToday,
      fillPriceWithCoverPrice:
          _fillPriceFromCover && shown.contains('price_paid_cents'),
      coverPriceDiscountPercent: _coverDiscountPercent,
      locationId: shown.contains('location_id') ? _selectedLocationId : null,
      tags:
          shown.contains('tags') && _tags.value.isNotEmpty ? _tags.value : null,
      fields: _fields,
      personalValues: values,
    );
    await defaults.save(widget.kind);
    if (mounted) Navigator.of(context).pop(defaults);
  }

  /// The reference's grey bar under the fields: Pre-fill fields, Always show
  /// this screen and Clear All.
  Widget _optionBar(AppThemePalette palette) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        color: palette.isDark ? const Color(0xff666666) : palette.panelRaised,
        child: Row(children: [
          _BarButton(
            tooltip: 'Pre-fill fields',
            color: palette.utilityAction,
            width: 30,
            onPressed: _chooseFields,
            child: const Icon(AppIcons.settings, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _checkbox('Always show this screen', _alwaysShow,
                  (value) => setState(() => _alwaysShow = value),
                  bold: true),
            ),
          ),
          _BarButton(
            color: palette.isDark ? const Color(0xff494949) : palette.field,
            onPressed: _clearAll,
            child: Text('Clear All',
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
          ),
        ]),
      );

  /// Save alone, as in the reference: the header's close button cancels.
  Widget _footer(AppThemePalette palette) => Padding(
        padding: const EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
              width: 150,
              height: 40,
              child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.utilityAction,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      textStyle: TextStyle(
                          fontFamily: appFontFamily,
                          fontFamilyFallback: kAppFontFamilyFallback,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  onPressed: _save,
                  child: Text(widget.confirmLabel ?? 'Save'))),
        ),
      );
}

/// A 32 px button of the option bar.
class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.color,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.width,
  });

  final Color color;
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: color,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: width,
          height: 32,
          alignment: Alignment.center,
          padding: width == null
              ? const EdgeInsets.symmetric(horizontal: 8)
              : EdgeInsets.zero,
          child: child,
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

Future<PrefillDefaults?> showPrefillSettingsDialog({
  required BuildContext context,
  required Color accent,
  required CatalogMediaKind kind,
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
