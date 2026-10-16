import 'package:collectarr_app/ui/app_icons.dart';
import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:uuid/uuid.dart';

enum TransferItemScope { all, currentList, checkboxed }

/// Result returned when the transfer completes.
class TransferFieldResult {
  const TransferFieldResult({
    required this.transferred,
    required this.skipped,
    required this.total,
  });

  final int transferred;
  final int skipped;
  final int total;
}

/// Shows the Transfer Field Data dialog.
///
/// Counts and transfer previews follow the chosen collection scope.
Future<TransferFieldResult?> showTransferFieldDataDialog({
  required BuildContext context,
  required LocalDatabase db,
  required LibraryKindRegistration type,
  required List<TransferableLibraryEntry> allItems,
  required List<TransferableLibraryEntry> currentItems,
  required List<TransferableLibraryEntry> selectedItems,
  required TransferItemScope initialScope,
  required LibraryEntryMutations mutations,
  required List<CustomFieldDefinition> customFieldDefinitions,
}) {
  return showAppDialog<TransferFieldResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TransferFieldDataDialog(
      db: db,
      type: type,
      allItems: allItems,
      currentItems: currentItems,
      selectedItems: selectedItems,
      initialScope: initialScope,
      mutations: mutations,
      customFieldDefinitions: customFieldDefinitions,
    ),
  );
}

class _TransferFieldDataDialog extends StatefulWidget {
  const _TransferFieldDataDialog({
    required this.db,
    required this.type,
    required this.allItems,
    required this.currentItems,
    required this.selectedItems,
    required this.initialScope,
    required this.mutations,
    required this.customFieldDefinitions,
  });

  final LocalDatabase db;
  final LibraryKindRegistration type;
  final List<TransferableLibraryEntry> allItems;
  final List<TransferableLibraryEntry> currentItems;
  final List<TransferableLibraryEntry> selectedItems;
  final TransferItemScope initialScope;
  final LibraryEntryMutations mutations;
  final List<CustomFieldDefinition> customFieldDefinitions;

  @override
  State<_TransferFieldDataDialog> createState() =>
      _TransferFieldDataDialogState();
}

class _TransferFieldDataDialogState extends State<_TransferFieldDataDialog> {
  late final List<TransferableField> _fields;
  TransferableField? _source;
  TransferableField? _target;
  TransferMode _mode = TransferMode.copy;
  TransferConflict _conflict = TransferConflict.skip;
  bool _executing = false;
  late TransferItemScope _scope;
  Map<String, List<CustomFieldValue>> _customValues = {};
  String? _error;

  List<TransferableLibraryEntry> get _items => switch (_scope) {
        TransferItemScope.all => widget.allItems,
        TransferItemScope.currentList => widget.currentItems,
        TransferItemScope.checkboxed => widget.selectedItems,
      };

  Future<void> _loadCustomValues() async {
    try {
      final values = await CustomFieldRepository(widget.db).listAllValues();
      if (mounted) setState(() => _customValues = values);
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not load custom fields: $error');
      }
    }
  }

  String? _read(TransferableField field, TransferableLibraryEntry item) =>
      field.isCustomField
          ? (_customValues[item.ref.key] ?? [])
              .where((value) => value.fieldDefinitionId == field.customFieldId)
              .firstOrNull
              ?.value
          : field.readFrom(item.value);

  @override
  void initState() {
    super.initState();
    _scope = widget.initialScope;
    unawaited(_loadCustomValues());
    _fields = libraryTransferForKind(widget.type.kind).fieldsWithCustomFields(
      widget.customFieldDefinitions,
    );
  }

  // ---------------------------------------------------------------------------
  // Preview calculation
  // ---------------------------------------------------------------------------

  int get _itemsWithSourceData {
    final src = _source;
    if (src == null) return 0;
    int count = 0;
    for (final item in _items) {
      final value = _read(src, item);
      if (value != null && value.isNotEmpty) count++;
    }
    return count;
  }

  int get _itemsWithTargetData {
    final tgt = _target;
    if (tgt == null) return 0;
    int count = 0;
    for (final item in _items) {
      final value = _read(tgt, item);
      if (value != null && value.isNotEmpty) count++;
    }
    return count;
  }

  bool get _canExecute =>
      _source != null &&
      _target != null &&
      _source!.key != _target!.key &&
      _itemsWithSourceData > 0 &&
      !_executing;

  // ---------------------------------------------------------------------------
  // Execute transfer
  // ---------------------------------------------------------------------------

  Future<void> _execute() async {
    final src = _source!;
    final tgt = _target!;
    setState(() {
      _executing = true;
      _error = null;
    });
    try {
      final cfRepo = CustomFieldRepository(widget.db);
      final now = DateTime.now().toUtc();
      int transferred = 0;
      int skipped = 0;

      // If custom fields are involved, pre-load values for all items.
      Map<String, List<CustomFieldValue>>? allCfValues;
      if (src.isCustomField || tgt.isCustomField) {
        allCfValues = await cfRepo.listAllValues();
      }

      await widget.mutations.mutationRunner.run(action: () async {
        for (int i = 0; i < _items.length; i++) {
          final item = _items[i];

          // Read source value (built-in or custom field).
          String? sourceValue;
          if (src.isCustomField) {
            final values = allCfValues?[item.ref.key] ?? [];
            sourceValue = values
                .where((v) => v.fieldDefinitionId == src.customFieldId)
                .map((v) => v.value)
                .where((v) => v != null && v.isNotEmpty)
                .firstOrNull;
          } else {
            sourceValue = _read(src, item);
          }

          if (sourceValue == null || sourceValue.isEmpty) {
            skipped++;
            continue;
          }

          // Read existing target value.
          String? existingTarget;
          if (tgt.isCustomField) {
            final values = allCfValues?[item.ref.key] ?? [];
            existingTarget = values
                .where((v) => v.fieldDefinitionId == tgt.customFieldId)
                .map((v) => v.value)
                .where((v) => v != null && v.isNotEmpty)
                .firstOrNull;
          } else {
            existingTarget = _read(tgt, item);
          }

          final hasExistingTarget =
              existingTarget != null && existingTarget.isNotEmpty;

          // Apply conflict strategy.
          String? newTargetValue;
          if (hasExistingTarget) {
            switch (_conflict) {
              case TransferConflict.skip:
                skipped++;
                continue;
              case TransferConflict.overwrite:
                newTargetValue = sourceValue;
              case TransferConflict.append:
                if (tgt.type == TransferableFieldType.text) {
                  newTargetValue = '$existingTarget; $sourceValue';
                } else {
                  newTargetValue = sourceValue;
                }
            }
          } else {
            newTargetValue = sourceValue;
          }

          final valid = switch (tgt.type) {
            TransferableFieldType.text => true,
            TransferableFieldType.integer =>
              int.tryParse(newTargetValue) != null,
            TransferableFieldType.date =>
              DateTime.tryParse(newTargetValue) != null,
            TransferableFieldType.boolean =>
              newTargetValue == 'true' || newTargetValue == 'false',
          };
          if (!valid) {
            throw FormatException(
                '${tgt.label} cannot accept "$newTargetValue".');
          }

          var updated = item.value;
          if (tgt.isCustomField) {
            final existing = (allCfValues?[item.ref.key] ?? [])
                .where((v) => v.fieldDefinitionId == tgt.customFieldId)
                .firstOrNull;
            await cfRepo.upsertValue(CustomFieldValue(
                id: existing?.id ?? const Uuid().v4(),
                targetId: item.ref.key,
                targetScope: CustomFieldTargetScope.libraryEntry,
                fieldDefinitionId: tgt.customFieldId!,
                value: newTargetValue,
                updatedAt: now));
          } else {
            updated = tgt.writeTo(updated, newTargetValue);
          }
          if (_mode == TransferMode.move) {
            if (src.isCustomField) {
              final existing = (allCfValues?[item.ref.key] ?? [])
                  .where((v) => v.fieldDefinitionId == src.customFieldId)
                  .firstOrNull;
              if (existing != null) {
                await cfRepo.upsertValue(CustomFieldValue(
                    id: existing.id,
                    targetId: item.ref.key,
                    targetScope: CustomFieldTargetScope.libraryEntry,
                    fieldDefinitionId: src.customFieldId!,
                    value: null,
                    updatedAt: now));
              }
            } else {
              updated = src.writeTo(updated, null);
            }
          }
          // Persist once, after attachments, so Sync sees the final moved values.
          await widget.mutations.updateLibraryEntry(
              libraryEntryEditForKind(widget.type.kind)
                  .buildTransferUpdateCommand(
                      libraryEntryRef: item.ref, updated: updated));

          transferred++;
        }
      });

      if (mounted) {
        Navigator.of(context).pop(TransferFieldResult(
          transferred: transferred,
          skipped: skipped,
          total: _items.length,
        ));
      }
    } catch (error) {
      if (mounted) {
        setState(
            () => _error = 'Transfer failed; no fields were changed: $error');
      }
    } finally {
      if (mounted) setState(() => _executing = false);
    }
  }

  void _reset() => setState(() {
        _scope = widget.initialScope;
        _source = null;
        _target = null;
        _mode = TransferMode.copy;
        _conflict = TransferConflict.skip;
        _error = null;
      });

  Future<void> _selectField({required bool source}) async {
    final field = await showAppDialog<TransferableField>(
        context: context,
        builder: (context) => _TransferFieldPicker(
              title: source
                  ? 'Select a source field'
                  : 'Select a destination field',
              fields: _fields
                  .where((f) => f.key != (source ? _target : _source)?.key)
                  .toList(),
            ));
    if (field == null || !mounted) return;
    setState(() {
      if (source) {
        _source = field;
      } else {
        _target = field;
        if (field.type != TransferableFieldType.text &&
            _conflict == TransferConflict.append) {
          _conflict = TransferConflict.skip;
        }
      }
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final sourceCount = _itemsWithSourceData;
    final targetCount = _itemsWithTargetData;
    const heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    Widget panel(Widget child) => Material(
        color: palette.isDark ? const Color(0xff383838) : palette.panelRaised,
        borderRadius: BorderRadius.circular(3),
        child: Padding(padding: const EdgeInsets.all(10), child: child));
    Widget fieldSection(bool source) {
      final field = source ? _source : _target;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(source ? '2. Source field' : '3. Destination field',
                style: heading),
            const SizedBox(height: 16),
            panel(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                      style: pickListButtonStyle(context).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.disabled)
                                  ? Color.alphaBlend(
                                      Colors.black.withValues(alpha: .35),
                                      palette.utilityAction)
                                  : palette.utilityAction)),
                      onPressed: _executing || (!source && _source == null)
                          ? null
                          : () => _selectField(source: source),
                      child: Text(field?.label ??
                          (source
                              ? 'Select source field'
                              : 'Select destination field'))),
                  if (field != null) ...[
                    const SizedBox(height: 8),
                    if (source) ...[
                      Text(
                          '$sourceCount item${sourceCount == 1 ? '' : 's'} ${sourceCount == 1 ? 'has' : 'have'} data in this field',
                          style: const TextStyle(fontSize: 12)),
                      CheckboxListTile(
                          activeColor: palette.utilityAction,
                          checkboxScaleFactor: .7,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Clear source field after transfer',
                              style: TextStyle(fontSize: 14)),
                          value: _mode == TransferMode.move,
                          onChanged: _executing
                              ? null
                              : (value) => setState(() => _mode = value!
                                  ? TransferMode.move
                                  : TransferMode.copy)),
                    ] else ...[
                      Text(
                          '$targetCount item${targetCount == 1 ? '' : 's'} already have data in this field',
                          style: const TextStyle(fontSize: 12)),
                      CheckboxListTile(
                          activeColor: palette.utilityAction,
                          checkboxScaleFactor: .7,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Replace existing data',
                              style: TextStyle(fontSize: 14)),
                          value: _conflict == TransferConflict.overwrite,
                          onChanged: _executing
                              ? null
                              : (value) => setState(() => _conflict = value!
                                  ? TransferConflict.overwrite
                                  : TransferConflict.skip)),
                      if (field.type == TransferableFieldType.text)
                        CheckboxListTile(
                            activeColor: palette.utilityAction,
                            checkboxScaleFactor: .7,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Append to existing text',
                                style: TextStyle(fontSize: 14)),
                            value: _conflict == TransferConflict.append,
                            onChanged: _executing
                                ? null
                                : (value) => setState(() => _conflict = value!
                                    ? TransferConflict.append
                                    : TransferConflict.skip)),
                    ],
                  ],
                ])),
          ]);
    }

    return PopScope(
        canPop: !_executing,
        child: Dialog(
          alignment: Alignment.topCenter,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          shape: appDialogShape,
          clipBehavior: Clip.antiAlias,
          backgroundColor: pickListSurface(context),
          child: SizedBox(
              width: 600,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AccentDialogHeader(
                    title: 'Transfer Field Data',
                    showCloseButton: !_executing,
                    icon: AppIcons.transferFieldData,
                    minHeight: 38,
                    onClose:
                        _executing ? null : () => Navigator.of(context).pop()),
                Flexible(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(15, 25, 15, 30),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 440;
                          final scope = Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    '1. Which ${widget.type.identity.pluralLabel.toLowerCase()}',
                                    style: heading),
                                const SizedBox(height: 16),
                                panel(RadioGroup<TransferItemScope>(
                                    groupValue: _scope,
                                    onChanged: (value) {
                                      if (!_executing && value != null) {
                                        setState(() => _scope = value);
                                      }
                                    },
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (final option in [
                                            (
                                              TransferItemScope.all,
                                              'All ${widget.type.identity.pluralLabel}',
                                              widget.allItems.length
                                            ),
                                            (
                                              TransferItemScope.currentList,
                                              'Current List',
                                              widget.currentItems.length
                                            ),
                                            (
                                              TransferItemScope.checkboxed,
                                              'Checkboxed',
                                              widget.selectedItems.length
                                            ),
                                          ])
                                            Material(
                                                color: _scope == option.$1
                                                    ? pickListToolbar(context)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: RadioListTile<
                                                        TransferItemScope>(
                                                    value: option.$1,
                                                    activeColor:
                                                        palette.utilityAction,
                                                    radioScaleFactor: .65,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    enabled: !_executing &&
                                                        option.$3 > 0,
                                                    dense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Row(children: [
                                                      Expanded(
                                                          child: Text(option.$2,
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700))),
                                                      Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          decoration: BoxDecoration(
                                                              color: palette
                                                                      .isDark
                                                                  ? const Color(
                                                                      0xff888888)
                                                                  : palette
                                                                      .surface,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3)),
                                                          child: Text(
                                                              '${option.$3}',
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700))),
                                                    ]))),
                                        ]))),
                              ]);
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                        width: narrow
                                            ? constraints.maxWidth
                                            : (constraints.maxWidth - 30) / 2,
                                        child: scope)),
                                const SizedBox(height: 25),
                                if (narrow) ...[
                                  fieldSection(true),
                                  const SizedBox(height: 25),
                                  fieldSection(false)
                                ] else
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: fieldSection(true)),
                                        const SizedBox(width: 30),
                                        Expanded(child: fieldSection(false))
                                      ]),
                                if (_source != null && _target != null)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Text(
                                          'For ${_items.length} item${_items.length == 1 ? '' : 's'}, data will be ${_mode == TransferMode.move ? 'moved' : 'copied'} from ${_source!.label} to ${_target!.label}. ${_conflict.description}.',
                                          style:
                                              const TextStyle(fontSize: 14))),
                                if (_error != null)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(_error!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error))),
                              ]);
                        }))),
                DialogActionFooter(
                    actions: [
                      DialogActionButton(
                          label: 'Reset',
                          onPressed: _executing ||
                                  (_source == null &&
                                      _target == null &&
                                      _scope == widget.initialScope)
                              ? null
                              : _reset),
                      DialogActionButton(
                          label: 'Transfer',
                          primary: true,
                          onPressed: _canExecute ? _execute : null),
                    ],
                    leading: _executing
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox.square(
                                dimension: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)))
                        : null),
              ])),
        ));
  }
}

class _TransferFieldPicker extends StatefulWidget {
  const _TransferFieldPicker({required this.title, required this.fields});
  final String title;
  final List<TransferableField> fields;
  @override
  State<_TransferFieldPicker> createState() => _TransferFieldPickerState();
}

class _TransferFieldPickerState extends State<_TransferFieldPicker> {
  String _query = '';
  final Map<bool, bool> _expanded = {false: true, true: true};
  @override
  Widget build(BuildContext context) => AccentAlertDialog(
      headerIcon: AppIcons.transferFieldData,
      title: Text(widget.title),
      headerOnClose: () => Navigator.of(context).pop(),
      contentPadding: const EdgeInsets.all(15),
      content: SizedBox(
          width: 370,
          height: (MediaQuery.sizeOf(context).height - 220).clamp(150, 540),
          child: Column(children: [
            LibraryFieldSelectionSearch(
                onChanged: (query) =>
                    setState(() => _query = query.toLowerCase())),
            const SizedBox(height: 10),
            Expanded(
                child: ListView(children: [
              for (final custom in [false, true])
                if (widget.fields.any((f) =>
                    f.isCustomField == custom &&
                    f.label.toLowerCase().contains(_query)))
                  LibraryFieldSelectionCategory(
                      title: custom ? 'Custom Fields' : 'Personal',
                      expanded: _query.isNotEmpty || _expanded[custom]!,
                      onToggle: () => setState(
                          () => _expanded[custom] = !_expanded[custom]!),
                      children: [
                        for (final field in widget.fields)
                          if (field.isCustomField == custom &&
                              field.label.toLowerCase().contains(_query))
                            ListTile(
                                dense: true,
                                title: Text(field.label,
                                    style: librarySelectionFieldStyle),
                                onTap: () => Navigator.of(context).pop(field)),
                      ]),
            ])),
          ])));
}
