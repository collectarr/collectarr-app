import 'package:collectarr_app/ui/app_icons.dart';
import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
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
  return showDialog<TransferFieldResult>(
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
  TransferMode _mode = TransferMode.move;
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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceCount = _itemsWithSourceData;
    final targetCount = _itemsWithTargetData;

    return AccentAlertDialog(
      title: const Row(
        children: [
          Icon(AppIcons.transferFieldData, size: 24),
          SizedBox(width: 8),
          Text('Transfer Field Data'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: _executing
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move or copy data from one field to another across '
                      '${_items.length} items.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(
                        '1. Which ${widget.type.identity.pluralLabel.toLowerCase()}',
                        style: theme.textTheme.titleSmall),
                    RadioGroup<TransferItemScope>(
                        groupValue: _scope,
                        onChanged: (value) {
                          if (value != null) setState(() => _scope = value);
                        },
                        child: Column(children: [
                          RadioListTile(
                              value: TransferItemScope.all,
                              title: Text('All (${widget.allItems.length})'),
                              dense: true),
                          RadioListTile(
                              value: TransferItemScope.currentList,
                              title: Text(
                                  'Current List (${widget.currentItems.length})'),
                              dense: true),
                          RadioListTile(
                              value: TransferItemScope.checkboxed,
                              title: Text(
                                  'Checkboxed (${widget.selectedItems.length})'),
                              dense: true),
                        ])),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    const SizedBox(height: 16),
                    // Source field
                    _FieldDropdown(
                      label: '2. Source field',
                      value: _source,
                      fields: _fields,
                      exclude: _target,
                      onChanged: (f) => setState(() => _source = f),
                    ),
                    if (_source != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$sourceCount item${sourceCount == 1 ? '' : 's'} '
                        '${sourceCount == 1 ? 'has' : 'have'} data in this field',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Target field
                    _FieldDropdown(
                      label: '3. Destination field',
                      value: _target,
                      fields: _fields,
                      exclude: _source,
                      onChanged: (f) => setState(() => _target = f),
                    ),
                    if (_target != null && targetCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$targetCount item${targetCount == 1 ? '' : 's'} '
                        'already have data in this field',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Mode
                    Text('Mode', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    RadioGroup<TransferMode>(
                      groupValue: _mode,
                      onChanged: (v) => setState(() {
                        if (v != null) _mode = v;
                      }),
                      child: Column(
                        children: TransferMode.values
                            .map((m) => RadioListTile<TransferMode>(
                                  title: Text(m.label),
                                  subtitle: Text(m.description),
                                  value: m,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Conflict
                    Text('When target already has data',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    RadioGroup<TransferConflict>(
                      groupValue: _conflict,
                      onChanged: (v) => setState(() {
                        if (v != null) _conflict = v;
                      }),
                      child: Column(
                        children: TransferConflict.values
                            .map((c) => RadioListTile<TransferConflict>(
                                  title: Text(c.label),
                                  subtitle: Text(c.description),
                                  value: c,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: _executing
          ? null
          : [
              TextButton(
                  onPressed: () => setState(() {
                        _scope = widget.initialScope;
                        _source = null;
                        _target = null;
                        _mode = TransferMode.move;
                        _conflict = TransferConflict.skip;
                        _error = null;
                      }),
                  child: const Text('Reset')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _canExecute ? _execute : null,
                child: Text(
                  _mode == TransferMode.move
                      ? 'Move ($sourceCount)'
                      : 'Copy ($sourceCount)',
                ),
              ),
            ],
    );
  }
}

class _FieldDropdown extends StatelessWidget {
  const _FieldDropdown({
    required this.label,
    required this.value,
    required this.fields,
    required this.onChanged,
    this.exclude,
  });

  final String label;
  final TransferableField? value;
  final List<TransferableField> fields;
  final TransferableField? exclude;
  final ValueChanged<TransferableField?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CompactSearchDropdownFormField<TransferableField>(
      key: ValueKey((label, value?.key)),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      initialValue: value,
      isExpanded: true,
      items: [
        for (final f in fields)
          if (exclude == null || f.key != exclude!.key)
            DropdownMenuItem(
              value: f,
              child: Row(
                children: [
                  Icon(f.icon, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (f.isCustomField)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'custom',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ],
      onChanged: onChanged,
    );
  }
}
