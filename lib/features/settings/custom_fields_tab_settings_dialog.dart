import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

class CustomFieldsTabSettingsDialog extends StatefulWidget {
  const CustomFieldsTabSettingsDialog({super.key, required this.settings});
  final CustomFieldsDisplaySettings settings;

  @override
  State<CustomFieldsTabSettingsDialog> createState() =>
      _CustomFieldsTabSettingsDialogState();
}

class _CustomFieldsTabSettingsDialogState
    extends State<CustomFieldsTabSettingsDialog> {
  late final _name = TextEditingController(text: widget.settings.tabName);
  late bool _visible = widget.settings.showEditTab;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccentAlertDialog(
        title: const Text('Custom Fields'),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name')),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show tab in Edit screen'),
              value: _visible,
              onChanged: (value) => setState(() => _visible = value ?? true),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              Navigator.pop(
                  context,
                  CustomFieldsDisplaySettings(
                      tabName: _name.text.trim(), showEditTab: _visible));
            },
            child: const Text('Save'),
          ),
        ],
      );
}
