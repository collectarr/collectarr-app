import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsPrefix = 'collectarr.prefill.';

class PrefillDefaults {
  const PrefillDefaults({
    this.condition,
    this.grade,
    this.locationId,
    this.legacyStorageBox,
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final String? grade;
  final String? locationId;
  final String? legacyStorageBox;
  final String? readStatus;
  final String? tags;

  static Future<PrefillDefaults> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefillDefaults(
      condition: prefs.getString('${_prefsPrefix}condition'),
      grade: prefs.getString('${_prefsPrefix}grade'),
      locationId: prefs.getString('${_prefsPrefix}location_id'),
      legacyStorageBox: prefs.getString('${_prefsPrefix}storage_box'),
      readStatus: prefs.getString('${_prefsPrefix}read_status'),
      tags: prefs.getString('${_prefsPrefix}tags'),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> set(String key, String? value) async {
      if (value != null && value.isNotEmpty) {
        await prefs.setString('$_prefsPrefix$key', value);
      } else {
        await prefs.remove('$_prefsPrefix$key');
      }
    }

    await set('condition', condition);
    await set('grade', grade);
    await set('location_id', locationId);
    await set('storage_box', locationId == null ? legacyStorageBox : null);
    await set('read_status', readStatus);
    await set('tags', tags);
  }
}

class PrefillSettingsDialog extends ConsumerStatefulWidget {
  const PrefillSettingsDialog({super.key, required this.accent});

  final Color accent;

  @override
  ConsumerState<PrefillSettingsDialog> createState() =>
      _PrefillSettingsDialogState();
}

class _PrefillSettingsDialogState extends ConsumerState<PrefillSettingsDialog> {
  final _conditionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _readStatus;
  bool _loaded = false;
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String? _legacyLocationLabel;

  static const _readStatusOptions = [
    null,
    'unread',
    'reading',
    'read',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _gradeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final defaults = await PrefillDefaults.load();
    final locations = await ref.read(allLocationsProvider.future);
    final locationId = defaults.locationId ??
        _matchLegacyLocationId(defaults.legacyStorageBox, locations);
    if (!mounted) return;
    setState(() {
      _conditionController.text = defaults.condition ?? '';
      _gradeController.text = defaults.grade ?? '';
      _tagsController.text = defaults.tags ?? '';
      _readStatus = defaults.readStatus;
      _availableLocations = locations;
      _selectedLocationId = locationId;
      _legacyLocationLabel = locationId == null ? defaults.legacyStorageBox : null;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kAppPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: widget.accent.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Default values applied when adding new items to your collection.',
                        style: TextStyle(
                          fontSize: 12,
                          color: kAppTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _textField('Condition', _conditionController,
                        hint: 'e.g. Near Mint, Very Good'),
                    const SizedBox(height: 10),
                    _textField('Grade', _gradeController,
                        hint: 'e.g. 9.6, A+'),
                    const SizedBox(height: 10),
                    _locationField(),
                    const SizedBox(height: 10),
                    _readStatusField(),
                    const SizedBox(height: 10),
                    _textField('Tags', _tagsController,
                        hint: 'Comma-separated tags'),
                  ],
                ),
              ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kAppDivider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_fix_high, color: widget.accent, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Pre-fill Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _conditionController.clear();
                _gradeController.clear();
                _selectedLocationId = null;
                _legacyLocationLabel = null;
                _tagsController.clear();
                _readStatus = null;
              });
            },
            child: const Text('Clear all', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _locationField() {
    final label = locationPathForId(_availableLocations, _selectedLocationId) ??
        _legacyLocationLabel;
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Location',
            style: TextStyle(fontSize: 13, color: kAppTextMuted),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _pickLocation,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: kAppPanelRaised,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: kAppDivider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 16, color: kAppTextMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label ?? 'No location selected',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: label == null ? Colors.white38 : Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    label == null ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Clear location',
            onPressed: () {
              setState(() {
                _selectedLocationId = null;
                _legacyLocationLabel = null;
              });
            },
            icon: const Icon(Icons.clear, size: 16),
          ),
        ],
      ],
    );
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
      _legacyLocationLabel = null;
      _availableLocations = locations;
    });
  }

  String? _matchLegacyLocationId(
    String? legacyLabel,
    List<StorageLocation> locations,
  ) {
    final normalized = legacyLabel?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    final match = locations.cast<StorageLocation?>().firstWhere(
          (location) =>
              location != null &&
              (location.fullPath(locations) == normalized ||
                  location.name == normalized),
          orElse: () => null,
        );
    return match?.id;
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: kAppTextMuted),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: kAppTextMuted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: kAppPanelRaised,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: kAppDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: kAppDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: widget.accent),
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readStatusField() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Read Status',
            style: TextStyle(fontSize: 13, color: kAppTextMuted),
          ),
        ),
        Expanded(
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kAppPanelRaised,
              borderRadius: kAppMenuBorderRadius,
              border: Border.all(color: kAppDivider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _readStatus,
                isExpanded: true,
                dropdownColor: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                icon: const Icon(Icons.expand_more, size: 16),
                items: _readStatusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s ?? '(none)'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _readStatus = value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kAppDivider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final defaults = PrefillDefaults(
                condition: _conditionController.text.isEmpty
                    ? null
                    : _conditionController.text,
                grade: _gradeController.text.isEmpty
                    ? null
                    : _gradeController.text,
                locationId: _selectedLocationId,
                legacyStorageBox: _legacyLocationLabel,
                readStatus: _readStatus,
                tags: _tagsController.text.isEmpty
                    ? null
                    : _tagsController.text,
              );
              await defaults.save();
              if (mounted) Navigator.of(context).pop(defaults);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

Future<PrefillDefaults?> showPrefillSettingsDialog({
  required BuildContext context,
  required Color accent,
}) {
  return showDialog<PrefillDefaults>(
    context: context,
    builder: (context) => PrefillSettingsDialog(accent: accent),
  );
}
