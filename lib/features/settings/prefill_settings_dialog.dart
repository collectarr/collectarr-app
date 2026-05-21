import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsPrefix = 'collectarr.prefill.';

class PrefillDefaults {
  const PrefillDefaults({
    this.condition,
    this.grade,
    this.storageBox,
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final String? grade;
  final String? storageBox;
  final String? readStatus;
  final String? tags;

  static Future<PrefillDefaults> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefillDefaults(
      condition: prefs.getString('${_prefsPrefix}condition'),
      grade: prefs.getString('${_prefsPrefix}grade'),
      storageBox: prefs.getString('${_prefsPrefix}storage_box'),
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
    await set('storage_box', storageBox);
    await set('read_status', readStatus);
    await set('tags', tags);
  }
}

class PrefillSettingsDialog extends StatefulWidget {
  const PrefillSettingsDialog({super.key, required this.accent});

  final Color accent;

  @override
  State<PrefillSettingsDialog> createState() => _PrefillSettingsDialogState();
}

class _PrefillSettingsDialogState extends State<PrefillSettingsDialog> {
  final _conditionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _storageBoxController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _readStatus;
  bool _loaded = false;

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
    _storageBoxController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) return;
    setState(() {
      _conditionController.text = defaults.condition ?? '';
      _gradeController.text = defaults.grade ?? '';
      _storageBoxController.text = defaults.storageBox ?? '';
      _tagsController.text = defaults.tags ?? '';
      _readStatus = defaults.readStatus;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
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
                          color: Colors.white54,
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
                    _textField('Storage Box', _storageBoxController,
                        hint: 'e.g. Box A, Shelf 3'),
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
          bottom: BorderSide(color: kClzDivider),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high, color: widget.accent, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Pre-fill Settings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _conditionController.clear();
                _gradeController.clear();
                _storageBoxController.clear();
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
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.white24),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFF404040)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFF404040)),
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
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        Expanded(
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF404040)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _readStatus,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(fontSize: 13, color: Colors.white),
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
          top: BorderSide(color: kClzDivider),
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
                storageBox: _storageBoxController.text.isEmpty
                    ? null
                    : _storageBoxController.text,
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
