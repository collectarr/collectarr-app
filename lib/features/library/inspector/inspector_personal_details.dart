import 'dart:async';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/tracking_editor_widgets.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kInspectorEditorLabelWidth = 92;

/// Inline collection-value dropdowns for any library type.
///
/// The host owns only the layout. The owning kind supplies the secondary
/// value label and vocabulary; the widget deliberately does not model a
/// domain-specific field.
class InspectorCollectionFields extends StatelessWidget {
  const InspectorCollectionFields({
    super.key,
    required this.enabled,
    required this.condition,
    required this.secondaryValue,
    required this.conditions,
    required this.secondaryOptions,
    required this.onConditionChanged,
    required this.onSecondaryChanged,
    required this.accent,
  });

  final bool enabled;
  final String? condition;
  final String? secondaryValue;
  final List<String> conditions;
  final List<String> secondaryOptions;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onSecondaryChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final hasConditions = conditions.isNotEmpty;
    final hasSecondaryOptions = secondaryOptions.isNotEmpty;
    if (!hasConditions && !hasSecondaryOptions) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasConditions)
          _InspectorEditorRow(
            label: 'Condition',
            child: CompactSearchDropdownFormField<String>(
              isExpanded: true,
              dropdownColor: palette.panelRaised,
              borderRadius: kAppMenuBorderRadius,
              initialValue: conditions.contains(condition) ? condition : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final option in conditions)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: enabled ? onConditionChanged : null,
            ),
          ),
        if (hasSecondaryOptions)
          _InspectorEditorRow(
            label: 'Collection value',
            child: CompactSearchDropdownFormField<String>(
              isExpanded: true,
              dropdownColor: palette.panelRaised,
              borderRadius: kAppMenuBorderRadius,
              initialValue: secondaryOptions.contains(secondaryValue)
                  ? secondaryValue
                  : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final option in secondaryOptions)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: enabled ? onSecondaryChanged : null,
            ),
          ),
        Text(
          'Collection values save immediately.',
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
    required this.libraryEntry,
    required this.accent,
  });

  final LibraryEntrySummary libraryEntry;
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
    _syncFromItem(widget.libraryEntry);
    unawaited(_loadAvailableLocations());
  }

  @override
  void didUpdateWidget(covariant InspectorPersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.libraryEntry.ref.id != widget.libraryEntry.ref.id ||
        oldWidget.libraryEntry.updatedAt != widget.libraryEntry.updatedAt) {
      _syncFromItem(widget.libraryEntry);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    _purchaseStoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final palette = appPalette(context);
    return LibraryDetailSection(
      title: 'Personal details',
      accentColor: accent,
      children: [
        const LibraryDetailFieldRow(
          field: LibraryDetailField(
            label: 'Mode',
            value: 'Draft edits. Apply changes to save.',
          ),
        ),
        _InspectorEditorRow(
          label: 'Purchased',
          child: LibraryDateFieldButton(
            label: 'Purchase date',
            value: _purchaseDate,
            onChanged: (value) => setState(() => _purchaseDate = value),
          ),
        ),
        _InspectorEditorRow(
          label: 'Price',
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(),
                    isDense: true,
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
                child: LibraryCurrencyField(
                  controller: _currencyController,
                  label: 'Currency',
                ),
              ),
            ],
          ),
        ),
        _InspectorEditorRow(
          label: 'Location',
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            borderRadius: BorderRadius.circular(8),
            onTap: _pickLocation,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.place),
                isDense: true,
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
        ),
        _InspectorEditorRow(
          label: 'Notes',
          alignTop: true,
          child: TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Personal notes',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        _InspectorEditorRow(
          label: 'Store',
          child: TextField(
            controller: _purchaseStoreController,
            decoration: const InputDecoration(
              hintText: 'Purchase store',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
              isDense: true,
            ),
          ),
        ),
        if (_priceError != null) ...[
          _InspectorEditorRow(
            label: 'Error',
            child: Text(
              _priceError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        _InspectorEditorRow(
          label: 'Actions',
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Apply personal changes'),
            ),
          ),
        ),
      ],
    );
  }

  void _syncFromItem(LibraryEntrySummary item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.notes ?? '';
    _purchaseStoreController.text = item.purchaseStore ?? '';
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

  Future<void> _save() async {
    final price = _parsePriceCents(_priceController.text);
    if (price == null && _priceController.text.trim().isNotEmpty) {
      setState(() {
        _priceError = 'Enter a valid price, for example 3.99';
      });
      return;
    }
    final currency = _currencyController.text.trim().toUpperCase();
    await ref.read(collectionCommandCoordinatorProvider).updateLibraryEntry(
          libraryEntryEditForKind(
            widget.libraryEntry.ref.kind,
          ).buildPersonalDetailsUpdateCommand(
            libraryEntryRef: widget.libraryEntry.ref,
            purchaseDate: _purchaseDate,
            pricePaidCents: price,
            currency: currency.isEmpty ? null : currency,
            personalNotes: _emptyToNull(_notesController.text),
            purchaseStore: _emptyToNull(_purchaseStoreController.text),
            locationChanged: _locationChanged,
            locationId: _selectedLocationId,
          ),
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
}

class InspectorTrackingDetailsEditor extends ConsumerStatefulWidget {
  const InspectorTrackingDetailsEditor({
    super.key,
    required this.trackingSummary,
    required this.profile,
    required this.accent,
    this.trackingEditor,
  });

  final TrackingSummary trackingSummary;
  final MediaTrackingProfile profile;
  final Color accent;
  final LibraryTrackingEditorCapability? trackingEditor;

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
  late final TextEditingController _trackingNotesController;
  TrackingStateEditMutation? _trackingEditorMutation;
  DateTime? _startedAt;
  DateTime? _finishedAt;

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController();
    _statusController = TextEditingController();
    _progressCurrentController = TextEditingController();
    _progressTotalController = TextEditingController();
    _timesCompletedController = TextEditingController();
    _trackingNotesController = TextEditingController();
    _syncFromSummary(widget.trackingSummary);
  }

  @override
  void didUpdateWidget(covariant InspectorTrackingDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackingSummary.ref != widget.trackingSummary.ref ||
        oldWidget.trackingSummary.updatedAt !=
            widget.trackingSummary.updatedAt) {
      _trackingEditorMutation = null;
      _syncFromSummary(widget.trackingSummary);
    }
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _statusController.dispose();
    _progressCurrentController.dispose();
    _progressTotalController.dispose();
    _timesCompletedController.dispose();
    _trackingNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return LibraryDetailSection(
      title: 'Tracking details',
      accentColor: accent,
      children: [
        const LibraryDetailFieldRow(
          field: LibraryDetailField(
            label: 'Mode',
            value:
                'Quick actions save immediately. Editor changes save when applied.',
          ),
        ),
        _InspectorEditorRow(
          label: 'My Rating',
          child: MediaRatingField(controller: _ratingController),
        ),
        _InspectorEditorRow(
          label: 'Status',
          child: MediaTrackingStatusField(
            profile: widget.profile,
            value: _statusController.text,
            label: 'Tracking status',
            onChanged: (value) {
              _statusController.text = value ?? '';
            },
          ),
        ),
        _InspectorEditorRow(
          label: 'Adjust',
          child: TrackingQuickAdjustments(
            accent: accent,
            progressCurrentController: _progressCurrentController,
            progressTotalController: _progressTotalController,
            onDecrementProgress: () => _bumpProgress(-1),
            onIncrementProgress: () => _bumpProgress(1),
          ),
        ),
        if (widget.trackingEditor != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: widget.trackingEditor!.build(
              context,
              summary: widget.trackingSummary,
              onChanged: (mutation) => setState(
                () => _trackingEditorMutation = mutation,
              ),
              accent: accent,
            ),
          ),
        _InspectorEditorRow(
          label: 'Progress',
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _progressCurrentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Current',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _progressTotalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Total',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        _InspectorEditorRow(
          label: 'Completed',
          child: TextField(
            controller: _timesCompletedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Times completed',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        _InspectorEditorRow(
          label: 'Notes',
          alignTop: true,
          child: TextField(
            controller: _trackingNotesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tracking notes',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        _InspectorEditorRow(
          label: 'Dates',
          child: Column(
            children: [
              _dateField(
                label: 'Started',
                value: _startedAt,
                onChanged: (value) => setState(() => _startedAt = value),
              ),
              const SizedBox(height: 10),
              _dateField(
                label: 'Finished',
                value: _finishedAt,
                onChanged: (value) => setState(() => _finishedAt = value),
              ),
            ],
          ),
        ),
        _InspectorEditorRow(
          label: 'Actions',
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
        ),
      ],
    );
  }

  void _syncFromSummary(TrackingSummary summary) {
    final progress = summary.progress;
    _ratingController.text = summary.rating?.toString() ?? '';
    _statusController.text = summary.statusStorageValue ?? '';
    _progressCurrentController.text = progress.current?.toString() ?? '';
    _progressTotalController.text = progress.total?.toString() ?? '';
    _timesCompletedController.text = progress.timesCompleted?.toString() ?? '';
    _trackingNotesController.text = summary.notes ?? '';
    _startedAt = summary.startedAt;
    _finishedAt = summary.completedAt;
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return LibraryDateFieldButton(
      label: label,
      value: value,
      onChanged: (value) {
        if (mounted) onChanged(value);
      },
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

  Future<void> _save() async {
    await ref.read(trackingMutationsProvider).upsertTrackingState(
          widget.trackingSummary.libraryEntryRef,
          sourceType: widget.trackingSummary.sourceType,
          status: mediaTrackingStatusFromValue(
              _emptyToNull(_statusController.text)),
          rating: _parseInt(_ratingController.text),
          startedAt: _startedAt,
          finishedAt: _finishedAt,
          progressCurrent: _parseInt(_progressCurrentController.text),
          progressTotal: _parseInt(_progressTotalController.text),
          timesCompleted: _parseInt(_timesCompletedController.text),
          notes: _emptyToNull(_trackingNotesController.text),
          kindPatch: _trackingEditorMutation,
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
      builder: (context) => AccentAlertDialog(
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
    await ref.read(trackingMutationsProvider).removeTrackingByRef(
          TrackingStateRef(
            kind: widget.trackingSummary.libraryEntryRef.kind,
            id: widget.trackingSummary.id,
          ),
        );
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
}

class _InspectorEditorRow extends StatelessWidget {
  const _InspectorEditorRow({
    required this.label,
    required this.child,
    this.alignTop = false,
  });

  final String label;
  final Widget child;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _kInspectorEditorLabelWidth,
            child: Padding(
              padding: EdgeInsets.only(top: alignTop ? 8 : 0),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
