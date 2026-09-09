import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';

/// Structural option supplied by the owning kind to the override form.
final class MetadataOverrideFieldOption {
  const MetadataOverrideFieldOption({
    required this.id,
    required this.label,
  });

  final MetadataFieldId id;
  final String label;
}

final class MetadataOverrideFormResult {
  const MetadataOverrideFormResult({
    required this.fieldId,
    required this.overrideValue,
    this.originalValue,
  });

  final MetadataFieldId fieldId;
  final String overrideValue;
  final String? originalValue;
}

/// Generic override form mechanics. Field identity and labels are supplied by
/// the selected kind; this widget never invents metadata field paths.
final class MetadataOverrideFormDialog extends StatefulWidget {
  const MetadataOverrideFormDialog({
    super.key,
    required this.accent,
    required this.fields,
  });

  final Color accent;
  final List<MetadataOverrideFieldOption> fields;

  @override
  State<MetadataOverrideFormDialog> createState() =>
      _MetadataOverrideFormDialogState();
}

class _MetadataOverrideFormDialogState
    extends State<MetadataOverrideFormDialog> {
  MetadataFieldId? _selectedField;
  final _originalController = TextEditingController();
  final _overrideController = TextEditingController();

  bool get _isValid =>
      _selectedField != null && _overrideController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _originalController.dispose();
    _overrideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Add metadata correction',
        accent: widget.accent,
        icon: Icons.tune,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<MetadataFieldId>(
              initialValue: _selectedField,
              decoration: const InputDecoration(labelText: 'Field'),
              items: [
                for (final field in widget.fields)
                  DropdownMenuItem(
                    value: field.id,
                    child: Text(field.label),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedField = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _originalController,
              decoration: const InputDecoration(
                labelText: 'Original value (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _overrideController,
              decoration: const InputDecoration(
                labelText: 'Corrected value',
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        DialogActionButtons.cancel(
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButtons.save(
          onPressed: _isValid
              ? () => Navigator.pop(
                    context,
                    MetadataOverrideFormResult(
                      fieldId: _selectedField!,
                      overrideValue: _overrideController.text.trim(),
                      originalValue: _originalController.text.trim().isEmpty
                          ? null
                          : _originalController.text.trim(),
                    ),
                  )
              : null,
        ),
      ],
    );
  }
}
