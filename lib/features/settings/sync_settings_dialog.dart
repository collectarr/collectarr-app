import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncFieldPolicy {
  updateEmpty('Update empty fields only'),
  overwrite('Always overwrite'),
  leaveAsIs('Leave as is');

  const SyncFieldPolicy(this.label);
  final String label;
}

class SyncFieldSetting {
  const SyncFieldSetting(
    this.key,
    this.label, {
    this.group,
    this.legacyKey,
  });
  final String key;
  final String label;
  final String? group;
  final String? legacyKey;
}

const _syncFields = [
  SyncFieldSetting('front_cover', 'Front Cover', group: 'Images'),
  SyncFieldSetting('back_cover', 'Back Cover', group: 'Images'),
  SyncFieldSetting('series', 'Series', group: 'Catalog'),
  SyncFieldSetting('title', 'Title', group: 'Catalog'),
  SyncFieldSetting('item_number', 'Issue / Number', group: 'Catalog'),
  SyncFieldSetting('variant', 'Variant / Edition', group: 'Catalog'),
  SyncFieldSetting('synopsis', 'Synopsis / Plot', group: 'Catalog'),
  SyncFieldSetting('publisher', 'Publisher', group: 'Catalog'),
  SyncFieldSetting('release_date', 'Release Date', group: 'Catalog'),
  SyncFieldSetting('physical_format', 'Format', group: 'Catalog'),
  SyncFieldSetting('barcode', 'Barcode', group: 'Catalog'),
  SyncFieldSetting('condition', 'Condition', group: 'Personal'),
  SyncFieldSetting('grade', 'Grade', group: 'Personal'),
  SyncFieldSetting(
    'location_id',
    'Location',
    group: 'Personal',
    legacyKey: 'storage_box',
  ),
  SyncFieldSetting('tags', 'Tags', group: 'Personal'),
  SyncFieldSetting('rating', 'Rating', group: 'Personal'),
  SyncFieldSetting('read_status', 'Read Status', group: 'Personal'),
  SyncFieldSetting('personal_notes', 'Notes', group: 'Personal'),
  SyncFieldSetting('purchase_date', 'Date Purchased', group: 'Personal'),
  SyncFieldSetting('price_paid', 'Price Paid', group: 'Personal'),
];

const _prefsPrefix = 'collectarr.sync_field_policy.';

class SyncSettingsDialog extends StatefulWidget {
  const SyncSettingsDialog({super.key, required this.accent});

  final Color accent;

  @override
  State<SyncSettingsDialog> createState() => _SyncSettingsDialogState();
}

class _SyncSettingsDialogState extends State<SyncSettingsDialog> {
  final _policies = <String, SyncFieldPolicy>{};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <String, SyncFieldPolicy>{};
    for (final field in _syncFields) {
      final stored = prefs.getString('$_prefsPrefix${field.key}') ??
          (field.legacyKey == null
              ? null
              : prefs.getString('$_prefsPrefix${field.legacyKey}'));
      loaded[field.key] = SyncFieldPolicy.values.firstWhere(
        (p) => p.name == stored,
        orElse: () => SyncFieldPolicy.updateEmpty,
      );
    }
    if (mounted) {
      setState(() {
        _policies.addAll(loaded);
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _policies.entries) {
      await prefs.setString('$_prefsPrefix${entry.key}', entry.value.name);
    }
    for (final field in _syncFields) {
      if (field.legacyKey != null) {
        await prefs.remove('$_prefsPrefix${field.legacyKey}');
      }
    }
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _buildFieldRows(),
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
          Icon(Icons.sync, color: widget.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Sync Settings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                for (final field in _syncFields) {
                  _policies[field.key] = SyncFieldPolicy.updateEmpty;
                }
              });
            },
            child: const Text(
              'Reset all',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFieldRows() {
    final widgets = <Widget>[];
    String? lastGroup;
    for (final field in _syncFields) {
      if (field.group != lastGroup) {
        lastGroup = field.group;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            field.group ?? '',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kAppHighlight,
              letterSpacing: 0.5,
            ),
          ),
        ));
      }
      widgets.add(_SyncFieldRow(
        field: field,
        policy: _policies[field.key] ?? SyncFieldPolicy.updateEmpty,
        accent: widget.accent,
        onChanged: (policy) {
          setState(() => _policies[field.key] = policy);
        },
      ));
    }
    return widgets;
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _save();
              if (mounted) Navigator.of(context).pop(true);
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }
}

class _SyncFieldRow extends StatelessWidget {
  const _SyncFieldRow({
    required this.field,
    required this.policy,
    required this.accent,
    required this.onChanged,
  });

  final SyncFieldSetting field;
  final SyncFieldPolicy policy;
  final Color accent;
  final ValueChanged<SyncFieldPolicy> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              field.label,
              style: const TextStyle(
                fontSize: 13,
                color: kAppTextMuted,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                border: Border.all(color: kAppDivider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SyncFieldPolicy>(
                  value: policy,
                  isExpanded: true,
                  dropdownColor: kAppPanelRaised,
                  borderRadius: kAppMenuBorderRadius,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                  icon: const Icon(Icons.expand_more, size: 16),
                  items: SyncFieldPolicy.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onChanged(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showSyncSettingsDialog({
  required BuildContext context,
  required Color accent,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => SyncSettingsDialog(accent: accent),
  );
}
