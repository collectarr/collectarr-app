import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/release_selection_helpers.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inline condition / grade dropdowns for any library type.
class InspectorCollectionFields extends StatelessWidget {
  const InspectorCollectionFields({
    super.key,
    required this.enabled,
    required this.condition,
    required this.grade,
    required this.conditions,
    required this.grades,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.accent,
  });

  final bool enabled;
  final String? condition;
  final String? grade;
  final List<String> conditions;
  final List<String> grades;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onGradeChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasConditions = conditions.isNotEmpty;
    final hasGrades = grades.isNotEmpty;
    if (!hasConditions && !hasGrades) return const SizedBox.shrink();
    return Row(
      children: [
        if (hasConditions)
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              dropdownColor: kAppPanelRaised,
              borderRadius: kAppMenuBorderRadius,
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
        if (hasConditions && hasGrades) const SizedBox(width: 10),
        if (hasGrades)
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              dropdownColor: kAppPanelRaised,
              borderRadius: kAppMenuBorderRadius,
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

/// Inline personal details editor (purchase date, price, notes)
/// for any library type.
class InspectorPersonalDetailsEditor extends ConsumerStatefulWidget {
  const InspectorPersonalDetailsEditor({
    super.key,
    required this.ownedItem,
    required this.accent,
  });

  final OwnedItem ownedItem;
  final Color accent;

  @override
  ConsumerState<InspectorPersonalDetailsEditor> createState() =>
      _InspectorPersonalDetailsEditorState();
}

class _InspectorPersonalDetailsEditorState
    extends ConsumerState<InspectorPersonalDetailsEditor> {
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  DateTime? _purchaseDate;
  String? _priceError;
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  bool _locationChanged = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _currencyController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromItem(widget.ownedItem);
    unawaited(_loadAvailableLocations());
  }

  @override
  void didUpdateWidget(covariant InspectorPersonalDetailsEditor oldWidget) {
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
    final accent = widget.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51C1F21),
        border: Border.all(color: accent.withValues(alpha: 0.33)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, size: 17, color: accent),
                const SizedBox(width: 7),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accent,
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
                    : 'Purchased ${_formatDate(_purchaseDate!)}',
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
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _pickLocation,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.place),
                ),
                child: Text(
                  _selectedLocationLabel ?? 'No location selected',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            _selectedLocationLabel == null ? kAppTextMuted : null,
                      ),
                ),
              ),
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
    _selectedLocationId = item.locationId;
    _locationChanged = false;
  }

  String? get _selectedLocationLabel {
    final locationLabel =
        locationPathForId(_availableLocations, _selectedLocationId);
    if (locationLabel != null) {
      return locationLabel;
    }
    if (_locationChanged) {
      return null;
    }
    final legacyLabel = widget.ownedItem.storageBox?.trim();
    if (legacyLabel == null || legacyLabel.isEmpty) {
      return null;
    }
    return legacyLabel;
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() => _availableLocations = locations);
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
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _locationChanged = true;
      _selectedLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
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
            storageBox: _locationChanged ? null : widget.ownedItem.storageBox,
            locationId:
              _locationChanged ? _selectedLocationId : widget.ownedItem.locationId,
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
    if (normalized.isEmpty) return null;
    final parsed = double.tryParse(normalized);
    if (parsed == null) return null;
    return (parsed * 100).round();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

class InspectorTrackingDetailsEditor extends ConsumerStatefulWidget {
  const InspectorTrackingDetailsEditor({
    super.key,
    required this.itemId,
    required this.trackingEntry,
    required this.profile,
    required this.accent,
    this.editions = const <CatalogEdition>[],
  });

  final String itemId;
  final TrackingEntry trackingEntry;
  final MediaTrackingProfile profile;
  final Color accent;
  final List<CatalogEdition> editions;

  @override
  ConsumerState<InspectorTrackingDetailsEditor> createState() =>
      _InspectorTrackingDetailsEditorState();
}

class _InspectorTrackingDetailsEditorState
    extends ConsumerState<InspectorTrackingDetailsEditor> {
  late final TextEditingController _ratingController;
  late final TextEditingController _statusController;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  String? _selectedEditionId;
  String? _selectedVariantId;

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController();
    _statusController = TextEditingController();
    _syncFromEntry(widget.trackingEntry);
  }

  @override
  void didUpdateWidget(covariant InspectorTrackingDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackingEntry.id != widget.trackingEntry.id ||
        oldWidget.trackingEntry.updatedAt != widget.trackingEntry.updatedAt) {
      _syncFromEntry(widget.trackingEntry);
    }
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51C1F21),
        border: Border.all(color: accent.withValues(alpha: 0.33)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.equalizer, size: 17, color: accent),
                const SizedBox(width: 7),
                Text(
                  'Tracking details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            if (widget.editions.isNotEmpty) ...[
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                isExpanded: true,
                dropdownColor: kAppPanelRaised,
                borderRadius: kEditMenuBorderRadius,
                initialValue: _selectedEditionId,
                decoration: const InputDecoration(
                  labelText: 'Tracked edition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Primary / unspecified edition'),
                  ),
                  for (final edition in widget.editions)
                    DropdownMenuItem<String>(
                      value: edition.id,
                      child: Text(edition.title),
                    ),
                ],
                onChanged: (value) {
                  final edition = resolveLibraryReleaseSelection(
                    widget.editions,
                    editionId: _emptyToNull(value ?? ''),
                  ).edition;
                  setState(() {
                    _selectedEditionId = edition?.id;
                    _selectedVariantId = resolveVariantForEdition(edition)?.id;
                  });
                },
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                isExpanded: true,
                dropdownColor: kAppPanelRaised,
                borderRadius: kEditMenuBorderRadius,
                initialValue: _selectedVariantId,
                decoration: const InputDecoration(
                  labelText: 'Tracked variant',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Primary / unspecified variant'),
                  ),
                  for (final variant in (_selectedEdition()?.variants ?? const <CatalogVariant>[]))
                    DropdownMenuItem<String>(
                      value: variant.id,
                      child: Text(variant.name),
                    ),
                ],
                onChanged: (_selectedEdition()?.variants.isEmpty ?? true)
                    ? null
                    : (value) =>
                        setState(() => _selectedVariantId = _emptyToNull(value ?? '')),
              ),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: MediaRatingField(controller: _ratingController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MediaTrackingStatusField(
                    profile: widget.profile,
                    value: _statusController.text,
                    label: 'Tracking status',
                    onChanged: (value) {
                      _statusController.text = value ?? '';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    context,
                    label: 'Started',
                    value: _startedAt,
                    onChanged: (value) => setState(() => _startedAt = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateField(
                    context,
                    label: 'Finished',
                    value: _finishedAt,
                    onChanged: (value) => setState(() => _finishedAt = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save tracking details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromEntry(TrackingEntry entry) {
    _ratingController.text = entry.rating?.toString() ?? '';
    _statusController.text = entry.status ?? '';
    _startedAt = entry.startedAt;
    _finishedAt = entry.finishedAt;
    final selection = resolveLibraryReleaseSelection(
      widget.editions,
      editionId: entry.editionId,
      variantId: entry.variantId,
    );
    _selectedEditionId = selection.edition?.id;
    _selectedVariantId = selection.variant?.id;
  }

  CatalogEdition? _selectedEdition() {
    final selectedId = _selectedEditionId;
    if (selectedId == null) {
      return null;
    }
    for (final edition in widget.editions) {
      if (edition.id == selectedId) {
        return edition;
      }
    }
    return null;
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 10),
        );
        if (picked != null && mounted) {
          onChanged(picked);
        }
      },
      onLongPress: value != null ? () => onChanged(null) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? _formatDate(value) : '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(collectionMutationsProvider).upsertTrackingEntry(
          widget.itemId,
          ownedItemId: widget.trackingEntry.ownedItemId,
          editionId: _selectedEditionId,
          variantId: _selectedVariantId,
          sourceType: widget.trackingEntry.sourceType,
          status: _emptyToNull(_statusController.text),
          rating: _parseInt(_ratingController.text),
          startedAt: _startedAt,
          finishedAt: _finishedAt,
          progressCurrent: widget.trackingEntry.progressCurrent,
          progressTotal: widget.trackingEntry.progressTotal,
          timesCompleted: widget.trackingEntry.timesCompleted,
          notes: widget.trackingEntry.notes,
          seasonNumber: widget.trackingEntry.seasonNumber,
          episodeNumber: widget.trackingEntry.episodeNumber,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracking details saved')),
      );
    }
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
