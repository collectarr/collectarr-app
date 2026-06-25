import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
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
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final String? grade;
  final String? locationId;
  final String? readStatus;
  final String? tags;

  static Future<PrefillDefaults> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefillDefaults(
      condition: prefs.getString('${_prefsPrefix}condition'),
      grade: prefs.getString('${_prefsPrefix}grade'),
      locationId: prefs.getString('${_prefsPrefix}location_id'),
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
    if (!mounted) return;
    setState(() {
      _conditionController.text = defaults.condition ?? '';
      _gradeController.text = defaults.grade ?? '';
      _tagsController.text = defaults.tags ?? '';
      _readStatus = defaults.readStatus;
      _availableLocations = locations;
      _selectedLocationId = defaults.locationId;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appPalette(context).panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Default values applied when adding new items to your collection.',
                        style: TextStyle(
                          fontSize: 12,
                          color: appPalette(context).textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _textField('Condition', _conditionController,
                        hint: 'e.g. Near Mint, Very Good'),
                    const SizedBox(height: 10),
                    _textField('Grade', _gradeController, hint: 'e.g. 9.6, A+'),
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
    return AccentDialogHeader(
      title: 'Pre-fill Settings',
      accent: widget.accent,
      icon: Icons.auto_fix_high,
      trailing: TextButton(
        onPressed: () {
          setState(() {
            _conditionController.clear();
            _gradeController.clear();
            _selectedLocationId = null;
            _tagsController.clear();
            _readStatus = null;
          });
        },
        child: const Text(
          'Clear all',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Widget _locationField() {
    final label = locationPathForId(_availableLocations, _selectedLocationId);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            'Location',
            style:
                TextStyle(fontSize: 13, color: appPalette(context).textMuted),
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
                color: appPalette(context).panelRaised,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: appPalette(context).divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.place,
                      size: 16, color: appPalette(context).textMuted),
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
      _availableLocations = locations;
    });
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
            style:
                TextStyle(fontSize: 13, color: appPalette(context).textMuted),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(
                fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(fontSize: 12, color: appPalette(context).textMuted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: appPalette(context).panelRaised,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: appPalette(context).divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: appPalette(context).divider),
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
        SizedBox(
          width: 100,
          child: Text(
            'Read Status',
            style:
                TextStyle(fontSize: 13, color: appPalette(context).textMuted),
          ),
        ),
        Expanded(
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: appPalette(context).panelRaised,
              borderRadius: kAppMenuBorderRadius,
              border: Border.all(color: appPalette(context).divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _readStatus,
                isExpanded: true,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
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
          top: BorderSide(color: appPalette(context).divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DialogActionButtons.cancel(
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          DialogActionButtons.save(
            accent: widget.accent,
            onPressed: () async {
              final defaults = PrefillDefaults(
                condition: _conditionController.text.isEmpty
                    ? null
                    : _conditionController.text,
                grade: _gradeController.text.isEmpty
                    ? null
                    : _gradeController.text,
                locationId: _selectedLocationId,
                readStatus: _readStatus,
                tags:
                    _tagsController.text.isEmpty ? null : _tagsController.text,
              );
              await defaults.save();
              if (mounted) Navigator.of(context).pop(defaults);
            },
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
