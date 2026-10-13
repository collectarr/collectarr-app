import 'package:collectarr_app/features/settings/custom_field_select.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_field_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
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
  Widget build(BuildContext context) => CustomFieldDialog(
        title: 'Custom Fields',
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
              child: const Text('Save'))
        ],
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldDefinitionField(
                      label: 'Name',
                      labelStyle:
                          const TextStyle(fontSize: 13, height: 20 / 13),
                      child: LibraryTextFormControl(
                          controller: _name, autofocus: true)),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: LibraryBooleanButtonField(
                          label: 'Show tab in Edit screen',
                          value: _visible,
                          onChanged: (value) =>
                              setState(() => _visible = value))),
                ])),
      );
}
