import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_inspector_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzAccent = Color(0xFF10A8D8);

class ComicCollectionFields extends StatelessWidget {
  const ComicCollectionFields({
    super.key,
    required this.enabled,
    required this.condition,
    required this.grade,
    required this.conditions,
    required this.grades,
    required this.onConditionChanged,
    required this.onGradeChanged,
  });

  final bool enabled;
  final String? condition;
  final String? grade;
  final List<String> conditions;
  final List<String> grades;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onGradeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: conditions.contains(condition) ? condition : null,
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in conditions)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onConditionChanged : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: grades.contains(grade) ? grade : null,
            decoration: const InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in grades)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onGradeChanged : null,
          ),
        ),
      ],
    );
  }
}

class ComicPersonalDetailsEditor extends ConsumerStatefulWidget {
  const ComicPersonalDetailsEditor({
    super.key,
    required this.ownedItem,
  });

  final OwnedItem ownedItem;

  @override
  ConsumerState<ComicPersonalDetailsEditor> createState() =>
      _ComicPersonalDetailsEditorState();
}

class _ComicPersonalDetailsEditorState
    extends ConsumerState<ComicPersonalDetailsEditor> {
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  DateTime? _purchaseDate;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _currencyController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromItem(widget.ownedItem);
  }

  @override
  void didUpdateWidget(covariant ComicPersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownedItem.id != widget.ownedItem.id ||
        oldWidget.ownedItem.updatedAt != widget.ownedItem.updatedAt) {
      _syncFromItem(widget.ownedItem);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51C1F21),
        border: Border.all(color: const Color(0x554DBBD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 17, color: _kClzAccent),
                const SizedBox(width: 7),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _kClzAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: _pickPurchaseDate,
              icon: const Icon(Icons.event),
              label: Text(
                _purchaseDate == null
                    ? 'Set purchase date'
                    : 'Purchased ${formatComicInspectorDate(_purchaseDate!)}',
              ),
            ),
            if (_purchaseDate != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _purchaseDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear purchase date'),
                ),
              ),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price paid',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_priceError != null) {
                        setState(() => _priceError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 9),
            if (_priceError != null) ...[
              Text(
                _priceError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 9),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save personal details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromItem(OwnedItem item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.personalNotes ?? '';
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    final price = _parsePriceCents(_priceController.text);
    if (price == null && _priceController.text.trim().isNotEmpty) {
      setState(() {
        _priceError = 'Enter a valid price, for example 3.99';
      });
      return;
    }
    final currency = _currencyController.text.trim().toUpperCase();
    await ref.read(collectionMutationsProvider).updateItem(
          widget.ownedItem,
          condition: widget.ownedItem.condition,
          grade: widget.ownedItem.grade,
          purchaseDate: _purchaseDate,
          pricePaidCents: price,
          currency: currency.isEmpty ? null : currency,
          personalNotes: _emptyToNull(_notesController.text),
          quantity: widget.ownedItem.quantity,
          storageBox: widget.ownedItem.storageBox,
          indexNumber: widget.ownedItem.indexNumber,
          coverPriceCents: widget.ownedItem.coverPriceCents,
          rawOrSlabbed: widget.ownedItem.rawOrSlabbed,
          gradingCompany: widget.ownedItem.gradingCompany,
          graderNotes: widget.ownedItem.graderNotes,
          signedBy: widget.ownedItem.signedBy,
          keyComic: widget.ownedItem.keyComic,
          keyReason: widget.ownedItem.keyReason,
          rating: widget.ownedItem.rating,
          readStatus: widget.ownedItem.readStatus,
          tags: widget.ownedItem.tags,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved')),
      );
    }
  }

  int? _parsePriceCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }
    return (parsed * 100).round();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
