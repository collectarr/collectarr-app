import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';

class AdminReleaseMappingRuleFormResult {
  const AdminReleaseMappingRuleFormResult({
    required this.provider,
    required this.releaseType,
    required this.targetKind,
    required this.priority,
    required this.isActive,
    this.notes,
  });

  final String? provider;
  final String releaseType;
  final String targetKind;
  final int priority;
  final bool isActive;
  final String? notes;
}

class AdminReleaseMappingRuleDialog extends StatefulWidget {
  const AdminReleaseMappingRuleDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialProvider,
    this.initialReleaseType,
    this.initialTargetKind,
    this.initialPriority = 100,
    this.initialIsActive = true,
    this.initialNotes,
  });

  final List<String> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialProvider;
  final String? initialReleaseType;
  final String? initialTargetKind;
  final int initialPriority;
  final bool initialIsActive;
  final String? initialNotes;

  @override
  State<AdminReleaseMappingRuleDialog> createState() =>
      _AdminReleaseMappingRuleDialogState();
}

class _AdminReleaseMappingRuleDialogState
    extends State<AdminReleaseMappingRuleDialog> {
  late final TextEditingController _releaseTypeController;
  late final TextEditingController _priorityController;
  late final TextEditingController _notesController;
  String? _provider;
  String? _targetKind;
  late bool _isActive;
  String? _error;

  @override
  void initState() {
    super.initState();
    _releaseTypeController = TextEditingController(
      text: widget.initialReleaseType ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.initialPriority.toString(),
    );
    _notesController = TextEditingController(
      text: widget.initialNotes ?? '',
    );
    _provider = widget.initialProvider;
    _targetKind = widget.initialTargetKind ??
        (widget.kinds.contains('comic')
            ? 'comic'
            : (widget.kinds.isNotEmpty ? widget.kinds.first : null));
    _isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    _releaseTypeController.dispose();
    _priorityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      shape: adminDialogShape,
      title: const Text('Release mapping rule'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompactSearchDropdownFormField<String?>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Provider scope',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All providers'),
                ),
                for (final provider in widget.providers)
                  DropdownMenuItem<String?>(
                    value: provider,
                    child: Text(provider),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _provider = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _releaseTypeController,
              decoration: const InputDecoration(
                labelText: 'Release type',
                hintText: 'issue, variant, season, episode...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CompactSearchDropdownFormField<String>(
              initialValue: _targetKind,
              decoration: const InputDecoration(
                labelText: 'Target media kind',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final kind in widget.kinds)
                  DropdownMenuItem<String>(
                    value: kind,
                    child: Text(widget.kindLabels[kind] ?? kind),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _targetKind = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Priority (lower wins)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value ?? true;
                });
              },
              title: const Text('Rule is active'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AdminMessageRow(message: _error!, isError: true),
              ),
          ],
        ),
      ),
      actions: [
        DialogActionButtons.cancel(
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogActionButtons.save(
          onPressed: _submit,
        ),
      ],
    );
  }

  void _submit() {
    final releaseType = _releaseTypeController.text.trim().toLowerCase();
    if (releaseType.isEmpty) {
      setState(() {
        _error = 'Release type is required.';
      });
      return;
    }
    final targetKind = _targetKind?.trim();
    if (targetKind == null || targetKind.isEmpty) {
      setState(() {
        _error = 'Select a target media kind.';
      });
      return;
    }
    final parsedPriority = int.tryParse(_priorityController.text.trim());
    if (parsedPriority == null || parsedPriority < 0) {
      setState(() {
        _error = 'Priority must be a positive number.';
      });
      return;
    }
    Navigator.of(context).pop(
      AdminReleaseMappingRuleFormResult(
        provider:
            _provider?.trim().isNotEmpty == true ? _provider!.trim() : null,
        releaseType: releaseType,
        targetKind: targetKind,
        priority: parsedPriority,
        isActive: _isActive,
        notes: _notesController.text.trim(),
      ),
    );
  }
}
