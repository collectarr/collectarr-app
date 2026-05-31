import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/tracking_editor_widgets.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/state/api_provider.dart';
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
    final palette = appPalette(context);
    final hasConditions = conditions.isNotEmpty;
    final hasGrades = grades.isNotEmpty;
    if (!hasConditions && !hasGrades) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (hasConditions)
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  dropdownColor: palette.panelRaised,
                  borderRadius: kAppMenuBorderRadius,
                  initialValue:
                      conditions.contains(condition) ? condition : null,
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
                  dropdownColor: palette.panelRaised,
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
        ),
        const SizedBox(height: 6),
        Text(
          'Condition and grade save immediately.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
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
  late final TextEditingController _purchaseStoreController;
  late final TextEditingController _boxSetNameController;
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
    _purchaseStoreController = TextEditingController();
    _boxSetNameController = TextEditingController();
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
    _purchaseStoreController.dispose();
    _boxSetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final palette = appPalette(context);
    return LibraryInspectorSection(
      title: 'Personal details',
      accentColor: accent,
      children: [
        Text(
          'This panel uses draft editing. Apply changes when you are ready to save.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
                    color: _selectedLocationLabel == null
                        ? palette.textMuted
                        : null,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Personal notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _purchaseStoreController,
          decoration: const InputDecoration(
            labelText: 'Purchase store',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.store),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _boxSetNameController,
          decoration: const InputDecoration(
            labelText: 'Box set name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.inventory_2_outlined),
          ),
        ),
        if (_priceError != null) ...[
          const SizedBox(height: 10),
          Text(
            _priceError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Apply personal changes'),
          ),
        ),
      ],
    );
  }

  void _syncFromItem(OwnedItem item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.personalNotes ?? '';
    _purchaseStoreController.text = item.purchaseStore ?? '';
    _boxSetNameController.text = item.boxSetName ?? '';
    _selectedLocationId = item.locationId;
    _locationChanged = false;
  }

  String? get _selectedLocationLabel {
    final locationLabel =
        locationPathForId(_availableLocations, _selectedLocationId);
    if (locationLabel != null) {
      return locationLabel;
    }
    return null;
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
          purchaseStore: _emptyToNull(_purchaseStoreController.text),
          boxSetName: _emptyToNull(_boxSetNameController.text),
          quantity: widget.ownedItem.quantity,
          locationId:
              _locationChanged ? _selectedLocationId : widget.ownedItem.locationId,
          indexNumber: widget.ownedItem.indexNumber,
          coverPriceCents: widget.ownedItem.coverPriceCents,
          rawOrSlabbed: widget.ownedItem.rawOrSlabbed,
          gradingCompany: widget.ownedItem.gradingCompany,
          graderNotes: widget.ownedItem.graderNotes,
          signedBy: widget.ownedItem.signedBy,
          labelType: widget.ownedItem.labelType,
          certificationNumber: widget.ownedItem.certificationNumber,
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
  late final TextEditingController _progressCurrentController;
  late final TextEditingController _progressTotalController;
  late final TextEditingController _timesCompletedController;
  late final TextEditingController _seasonNumberController;
  late final TextEditingController _episodeNumberController;
  late final TextEditingController _trackingNotesController;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  String? _selectedEditionId;
  String? _selectedVariantId;

  bool get _showsEpisodeFields {
    return widget.profile.name == videoTrackingProfile.name ||
        _seasonNumberController.text.trim().isNotEmpty ||
        _episodeNumberController.text.trim().isNotEmpty ||
        widget.trackingEntry.seasonNumber != null ||
        widget.trackingEntry.episodeNumber != null;
  }

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController();
    _statusController = TextEditingController();
    _progressCurrentController = TextEditingController();
    _progressTotalController = TextEditingController();
    _timesCompletedController = TextEditingController();
    _seasonNumberController = TextEditingController();
    _episodeNumberController = TextEditingController();
    _trackingNotesController = TextEditingController();
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
    _progressCurrentController.dispose();
    _progressTotalController.dispose();
    _timesCompletedController.dispose();
    _seasonNumberController.dispose();
    _episodeNumberController.dispose();
    _trackingNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final palette = appPalette(context);
    return LibraryInspectorSection(
      title: 'Tracking details',
      accentColor: accent,
      children: [
        Text(
          'Tracking quick actions save immediately; this editor uses draft changes until you apply them.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
        ),
        if (widget.editions.isNotEmpty) ...[
          const SizedBox(height: 10),
          _TrackingEditionBrowser(
            editions: widget.editions,
            selectedEditionId: _selectedEditionId,
            selectedVariantId: _selectedVariantId,
            accent: accent,
            onEditionSelected: (editionId) {
              final edition = resolveLibraryEditionSelection(
                widget.editions,
                editionId: editionId,
              ).edition;
              setState(() {
                _selectedEditionId = edition?.id;
                _selectedVariantId = resolveVariantForEdition(edition)?.id;
              });
            },
            onVariantSelected: (variantId) {
              setState(() => _selectedVariantId = variantId);
            },
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _createEdition,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add edition'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        TrackingQuickAdjustments(
          accent: accent,
          progressCurrentController: _progressCurrentController,
          progressTotalController: _progressTotalController,
          seasonNumberController: _seasonNumberController,
          episodeNumberController: _episodeNumberController,
          showsEpisodeFields: _showsEpisodeFields,
          onDecrementProgress: () => _bumpProgress(-1),
          onIncrementProgress: () => _bumpProgress(1),
          onDecrementEpisode: () => _bumpEpisode(-1),
          onIncrementEpisode: () => _bumpEpisode(1),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _progressCurrentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Progress current',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _progressTotalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Progress total',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _timesCompletedController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Times completed',
            border: OutlineInputBorder(),
          ),
        ),
        if (_showsEpisodeFields) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _seasonNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Season',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _episodeNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Episode',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: _trackingNotesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Tracking notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _stopTracking,
                icon: const Icon(Icons.playlist_remove, size: 18),
                label: const Text('Stop tracking'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Apply tracking changes'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _syncFromEntry(TrackingEntry entry) {
    _ratingController.text = entry.rating?.toString() ?? '';
    _statusController.text = entry.statusStorageValue ?? '';
    _progressCurrentController.text = entry.progressCurrent?.toString() ?? '';
    _progressTotalController.text = entry.progressTotal?.toString() ?? '';
    _timesCompletedController.text = entry.timesCompleted?.toString() ?? '';
    _seasonNumberController.text = entry.seasonNumber?.toString() ?? '';
    _episodeNumberController.text = entry.episodeNumber?.toString() ?? '';
    _trackingNotesController.text = entry.notes ?? '';
    _startedAt = entry.startedAt;
    _finishedAt = entry.finishedAt;
    final selection = resolveLibraryEditionSelection(
      widget.editions,
      editionId: entry.editionId,
      variantId: entry.variantId,
    );
    _selectedEditionId = selection.edition?.id;
    _selectedVariantId = selection.variant?.id;
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
                  tooltip: 'Clear date',
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

  void _bumpProgress(int delta) {
    final current = parseTrackingInt(_progressCurrentController.text) ?? 0;
    final total = parseTrackingInt(_progressTotalController.text);
    final bounded = clampTrackingProgress(
      current: current,
      delta: delta,
      progressTotal: total,
    );
    setState(() {
      _progressCurrentController.text = '$bounded';
    });
  }

  void _bumpEpisode(int delta) {
    final current = parseTrackingInt(_episodeNumberController.text) ?? 1;
    final bounded = clampTrackingEpisode(current: current, delta: delta);
    setState(() {
      _episodeNumberController.text = '$bounded';
    });
  }

  Future<void> _createEdition() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appPalette(context).panel,
        title: const Text('New edition'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Edition title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty || !mounted) return;
    try {
      final api = ref.read(apiClientProvider);
      final edition = await api.createEdition(widget.itemId, title: title);
      if (!mounted) return;
      setState(() => _selectedEditionId = edition.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edition "$title" created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create edition: $e')),
      );
    }
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
          progressCurrent: _parseInt(_progressCurrentController.text),
          progressTotal: _parseInt(_progressTotalController.text),
          timesCompleted: _parseInt(_timesCompletedController.text),
          notes: _emptyToNull(_trackingNotesController.text),
          seasonNumber: _parseInt(_seasonNumberController.text),
          episodeNumber: _parseInt(_episodeNumberController.text),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracking details saved')),
      );
    }
  }

  Future<void> _stopTracking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appPalette(context).panel,
        title: const Text('Stop tracking'),
        content: const Text(
          'This will remove all tracking details for this item. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Stop tracking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(collectionMutationsProvider)
        .removeTrackingEntry(widget.trackingEntry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracking removed')),
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

/// Visual edition & variant browser for tracked items.
///
/// Shows each edition as a selectable card. When an edition with variants is
/// selected, variant tiles with cover thumbnails appear below.
class _TrackingEditionBrowser extends StatelessWidget {
  const _TrackingEditionBrowser({
    required this.editions,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.accent,
    required this.onEditionSelected,
    required this.onVariantSelected,
  });

  final List<CatalogEdition> editions;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final Color accent;
  final ValueChanged<String?> onEditionSelected;
  final ValueChanged<String?> onVariantSelected;

  CatalogEdition? get _activeEdition {
    if (selectedEditionId == null) return null;
    for (final e in editions) {
      if (e.id == selectedEditionId) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final activeEdition = _activeEdition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Releases',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: editions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _EditionCard(
                  title: 'Primary',
                  subtitle: 'Default',
                  isSelected: selectedEditionId == null,
                  accent: accent,
                  onTap: () => onEditionSelected(null),
                );
              }
              final edition = editions[index - 1];
              final coverUrl = edition.variants
                  .where((v) => v.coverImageUrl != null)
                  .map((v) => v.thumbnailImageUrl ?? v.coverImageUrl)
                  .firstOrNull;
              return _EditionCard(
                title: edition.title,
                subtitle: [
                  if (edition.physicalFormatLabel != null)
                    edition.physicalFormatLabel!,
                  if (edition.publisher != null) edition.publisher!,
                ].join(' · '),
                coverUrl: coverUrl,
                isSelected: selectedEditionId == edition.id,
                accent: accent,
                onTap: () => onEditionSelected(edition.id),
              );
            },
          ),
        ),
        if (activeEdition != null && activeEdition.variants.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Variants',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activeEdition.variants.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final variant = activeEdition.variants[index];
                return _VariantCard(
                  variant: variant,
                  isSelected: selectedVariantId == variant.id,
                  accent: accent,
                  onTap: () => onVariantSelected(variant.id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

@visibleForTesting
Widget buildTrackingEditionBrowserForTesting({
  required List<CatalogEdition> editions,
  required String? selectedEditionId,
  required String? selectedVariantId,
  required Color accent,
  required ValueChanged<String?> onEditionSelected,
  required ValueChanged<String?> onVariantSelected,
}) {
  return _TrackingEditionBrowser(
    editions: editions,
    selectedEditionId: selectedEditionId,
    selectedVariantId: selectedVariantId,
    accent: accent,
    onEditionSelected: onEditionSelected,
    onVariantSelected: onVariantSelected,
  );
}

class _EditionCard extends StatelessWidget {
  const _EditionCard({
    required this.title,
    required this.isSelected,
    required this.accent,
    required this.onTap,
    this.subtitle = '',
    this.coverUrl,
  });

  final String title;
  final String subtitle;
  final String? coverUrl;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return _TrackingBrowserCardFrame(
      width: 98,
      isSelected: isSelected,
      accent: accent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              child: coverUrl != null
                  ? Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _placeholderIcon(context, Icons.album),
                    )
                  : _placeholderIcon(context, Icons.album),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
            child: Column(
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? accent : onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final CatalogVariant variant;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return _TrackingBrowserCardFrame(
      width: 90,
      isSelected: isSelected,
      accent: accent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              child: variant.coverImageUrl != null
                  ? Image.network(
                      variant.thumbnailImageUrl ?? variant.coverImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _placeholderIcon(context, Icons.image_outlined),
                    )
                  : _placeholderIcon(context, Icons.image_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
            child: Column(
              children: [
                Text(
                  variant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? accent : onSurface,
                  ),
                ),
                if (variant.physicalFormatLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    variant.physicalFormatLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingBrowserCardFrame extends StatelessWidget {
  const _TrackingBrowserCardFrame({
    required this.width,
    required this.isSelected,
    required this.accent,
    required this.onTap,
    required this.child,
  });

  final double width;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: width,
          decoration: BoxDecoration(
            color: isSelected
                ? Color.alphaBlend(
                    accent.withValues(alpha: 0.16),
                    colorScheme.surfaceContainerHigh,
                  )
                : palette.surfaceSubtle.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.85)
                  : palette.divider,
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget _placeholderIcon(BuildContext context, IconData icon) {
  final palette = appPalette(context);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: palette.surfaceSubtle.withValues(alpha: 0.96),
    ),
    child: Center(
      child: Icon(icon, size: 22, color: palette.textMuted),
    ),
  );
}