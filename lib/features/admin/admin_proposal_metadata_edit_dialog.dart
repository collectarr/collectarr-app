import 'dart:convert';

import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

class AdminProposalMetadataEditResult {
  const AdminProposalMetadataEditResult({
    required this.catalogItem,
    this.reviewNote,
  });

  final JsonMap catalogItem;
  final String? reviewNote;
}

class AdminProposalMetadataEditDialog extends StatefulWidget {
  const AdminProposalMetadataEditDialog({
    required this.proposal,
    super.key,
  });

  final AdminMetadataProposal proposal;

  @override
  State<AdminProposalMetadataEditDialog> createState() =>
      _AdminProposalMetadataEditDialogState();
}

class _AdminProposalMetadataEditDialogState
    extends State<AdminProposalMetadataEditDialog> {
  late final TextEditingController _itemController;
  late final TextEditingController _reviewNoteController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(
      text: const JsonEncoder.withIndent('  ')
          .convert(widget.proposal.catalogItem),
    );
    _reviewNoteController = TextEditingController(
      text: widget.proposal.reviewNote ?? '',
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _reviewNoteController.dispose();
    super.dispose();
  }

  void _save() {
    Object? decoded;
    try {
      decoded = jsonDecode(_itemController.text);
    } on FormatException {
      setState(
          () => _errorMessage = 'Catalog Item data contains invalid JSON.');
      return;
    }
    if (decoded is! Map) {
      setState(
          () => _errorMessage = 'Catalog Item data must be a JSON object.');
      return;
    }
    final item = JsonMap.from(decoded);
    final title = item['title'] ?? item['name'];
    if (title is! String || title.trim().isEmpty) {
      setState(() => _errorMessage = 'Catalog Item data needs a title.');
      return;
    }
    final note = _reviewNoteController.text.trim();
    Navigator.of(context).pop(
      AdminProposalMetadataEditResult(
        catalogItem: item,
        reviewNote: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text('Edit ${widget.proposal.kind} proposal'),
      content: SizedBox(
        width: 760,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit the same Catalog Item fields submitted from Add/Edit.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _itemController,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Catalog Item data (JSON)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewNoteController,
              maxLength: 2000,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Review note',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save changes'),
        ),
      ],
    );
  }
}
