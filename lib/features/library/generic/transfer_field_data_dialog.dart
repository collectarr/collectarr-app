import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
/// [items] should be the currently visible (filtered) owned items.
Future<TransferFieldResult?> showTransferFieldDataDialog({
  required BuildContext context,
  required LocalDatabase db,
  required List<OwnedItem> items,
  required CollectionMutations mutations,
  required List<CustomFieldDefinition> customFieldDefinitions,
}) {
  return showDialog<TransferFieldResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TransferFieldDataDialog(
      db: db,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldDefinitions,
    ),
  );
}

class _TransferFieldDataDialog extends StatefulWidget {
  const _TransferFieldDataDialog({
    required this.db,
    required this.items,
    required this.mutations,
    required this.customFieldDefinitions,
  });

  final LocalDatabase db;
  final List<OwnedItem> items;
  final CollectionMutations mutations;
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

  @override
  void initState() {
    super.initState();
    _fields =
        TransferableField.withCustomFields(widget.customFieldDefinitions);
  }

  // ---------------------------------------------------------------------------
  // Preview calculation
  // ---------------------------------------------------------------------------

  int get _itemsWithSourceData {
    final src = _source;
    if (src == null) return 0;
    int count = 0;
    for (final item in widget.items) {
      final value = src.readFrom(item);
      if (value != null && value.isNotEmpty) count++;
    }
    return count;
  }

  int get _itemsWithTargetData {
    final tgt = _target;
    if (tgt == null) return 0;
    int count = 0;
    for (final item in widget.items) {
      final value = tgt.readFrom(item);
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
    setState(() => _executing = true);

    final cfRepo = CustomFieldRepository(widget.db);
    final now = DateTime.now().toUtc();
    int transferred = 0;
    int skipped = 0;

    // If custom fields are involved, pre-load values for all items.
    Map<String, List<CustomFieldValue>>? allCfValues;
    if (src.isCustomField || tgt.isCustomField) {
      allCfValues = await cfRepo.listAllValues();
    }

    await widget.db.transaction(() async {
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isLast = i == widget.items.length - 1;

      // Read source value (built-in or custom field).
      String? sourceValue;
      if (src.isCustomField) {
        final values = allCfValues?[item.id] ?? [];
        sourceValue = values
            .where((v) => v.fieldDefinitionId == src.customFieldId)
            .map((v) => v.value)
            .where((v) => v != null && v.isNotEmpty)
            .firstOrNull;
      } else {
        sourceValue = src.readFrom(item);
      }

      if (sourceValue == null || sourceValue.isEmpty) {
        skipped++;
        continue;
      }

      // Read existing target value.
      String? existingTarget;
      if (tgt.isCustomField) {
        final values = allCfValues?[item.id] ?? [];
        existingTarget = values
            .where((v) => v.fieldDefinitionId == tgt.customFieldId)
            .map((v) => v.value)
            .where((v) => v != null && v.isNotEmpty)
            .firstOrNull;
      } else {
        existingTarget = tgt.readFrom(item);
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

      // Write target.
      if (tgt.isCustomField) {
        final existing = (allCfValues?[item.id] ?? [])
            .where((v) => v.fieldDefinitionId == tgt.customFieldId)
            .firstOrNull;
        await cfRepo.upsertValue(CustomFieldValue(
          id: existing?.id ?? const Uuid().v4(),
          ownedItemId: item.id,
          fieldDefinitionId: tgt.customFieldId!,
          value: newTargetValue,
          updatedAt: now,
        ));
      } else {
        var updated = tgt.writeTo(item, newTargetValue);
        // When moving between built-in fields, clear the source inline.
        // OwnedItem.copyWith uses ?? so writeTo(item, null) can't null out
        // a field — we pass null directly to updateItem instead.
        final clearSrc = _mode == TransferMode.move && !src.isCustomField;
        T? clr<T>(String key, T? value) =>
            clearSrc && src.key == key ? null : value;
        await widget.mutations.updateItem(
          item,
          condition: clr('condition', updated.condition),
          grade: clr('grade', updated.grade),
          personalNotes: clr('personalNotes', updated.personalNotes),
          storageBox: clr('storageBox', updated.storageBox),
          tags: clr('tags', updated.tags),
          currency: clr('currency', updated.currency),
          rawOrSlabbed: clr('rawOrSlabbed', updated.rawOrSlabbed),
          gradingCompany: clr('gradingCompany', updated.gradingCompany),
          graderNotes: clr('graderNotes', updated.graderNotes),
          signedBy: clr('signedBy', updated.signedBy),
          keyReason: clr('keyReason', updated.keyReason),
          readStatus: clr('readStatus', updated.readStatus),
          soldTo: clr('soldTo', updated.soldTo),
          features: clr('features', updated.features),
          pricePaidCents: clr('pricePaidCents', updated.pricePaidCents),
          coverPriceCents: clr('coverPriceCents', updated.coverPriceCents),
          sellPriceCents: clr('sellPriceCents', updated.sellPriceCents),
          quantity: clr('quantity', updated.quantity),
          indexNumber: clr('indexNumber', updated.indexNumber),
          rating: clr('rating', updated.rating),
          purchaseDate: clr('purchaseDate', updated.purchaseDate),
          startedAt: clr('startedAt', updated.startedAt),
          finishedAt: clr('finishedAt', updated.finishedAt),
          soldAt: clr('soldAt', updated.soldAt),
          keyComic: clr('keyComic', updated.keyComic),
          purchaseStore: clr('purchaseStore', updated.purchaseStore),
          boxSetName: clr('boxSetName', updated.boxSetName),
          notify: isLast,
        );
        // Clear source custom field when moving from custom → built-in.
        if (_mode == TransferMode.move && src.isCustomField) {
          final existing = (allCfValues?[item.id] ?? [])
              .where((v) => v.fieldDefinitionId == src.customFieldId)
              .firstOrNull;
          if (existing != null) {
            await cfRepo.upsertValue(CustomFieldValue(
              id: existing.id,
              ownedItemId: item.id,
              fieldDefinitionId: src.customFieldId!,
              value: null,
              updatedAt: now,
            ));
          }
        }
        transferred++;
        continue;
      }

      // Clear source for custom fields when mode is Move.
      if (_mode == TransferMode.move) {
        if (src.isCustomField) {
          final existing = (allCfValues?[item.id] ?? [])
              .where((v) => v.fieldDefinitionId == src.customFieldId)
              .firstOrNull;
          if (existing != null) {
            await cfRepo.upsertValue(CustomFieldValue(
              id: existing.id,
              ownedItemId: item.id,
              fieldDefinitionId: src.customFieldId!,
              value: null,
              updatedAt: now,
            ));
          }
        } else {
          await widget.mutations.updateItem(
            item,
            condition: src.key == 'condition' ? null : item.condition,
            grade: src.key == 'grade' ? null : item.grade,
            personalNotes:
                src.key == 'personalNotes' ? null : item.personalNotes,
            storageBox: src.key == 'storageBox' ? null : item.storageBox,
            tags: src.key == 'tags' ? null : item.tags,
            currency: src.key == 'currency' ? null : item.currency,
            rawOrSlabbed: src.key == 'rawOrSlabbed' ? null : item.rawOrSlabbed,
            gradingCompany:
                src.key == 'gradingCompany' ? null : item.gradingCompany,
            graderNotes: src.key == 'graderNotes' ? null : item.graderNotes,
            signedBy: src.key == 'signedBy' ? null : item.signedBy,
            keyReason: src.key == 'keyReason' ? null : item.keyReason,
            readStatus: src.key == 'readStatus' ? null : item.readStatus,
            soldTo: src.key == 'soldTo' ? null : item.soldTo,
            features: src.key == 'features' ? null : item.features,
            notify: isLast,
          );
        }
      }

      transferred++;
    }
    });

    if (mounted) {
      Navigator.of(context).pop(TransferFieldResult(
        transferred: transferred,
        skipped: skipped,
        total: widget.items.length,
      ));
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

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.swap_horiz, size: 24),
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
                      '${widget.items.length} items.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    // Source field
                    _FieldDropdown(
                      label: 'Source field',
                      value: _source,
                      fields: _fields,
                      exclude: _target,
                      onChanged: (f) => setState(() => _source = f),
                    ),
                    if (_source != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$sourceCount item${sourceCount == 1 ? '' : 's'} '
                        'have data in this field',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Target field
                    _FieldDropdown(
                      label: 'Target field',
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
                      onChanged: (v) =>
                          setState(() => _mode = v ?? _mode),
                      child: Column(
                        children: TransferMode.values.map((m) => RadioListTile<TransferMode>(
                              title: Text(m.label),
                              subtitle: Text(m.description),
                              value: m,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            )).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Conflict
                    Text('When target already has data',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    RadioGroup<TransferConflict>(
                      groupValue: _conflict,
                      onChanged: (v) =>
                          setState(() => _conflict = v ?? _conflict),
                      child: Column(
                        children: TransferConflict.values.map(
                            (c) => RadioListTile<TransferConflict>(
                                  title: Text(c.label),
                                  subtitle: Text(c.description),
                                  value: c,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                )).toList(),
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
    return DropdownButtonFormField<TransferableField>(
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
                          fontSize: 11,
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
