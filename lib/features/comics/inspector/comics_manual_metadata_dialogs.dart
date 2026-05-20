import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:flutter/material.dart';

class ManualComicDialog extends StatefulWidget {
  const ManualComicDialog({super.key});

  @override
  State<ManualComicDialog> createState() => _ManualComicDialogState();
}

class _ManualComicDialogState extends State<ManualComicDialog> {
  final _titleController = TextEditingController();
  final _issueController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _variantController = TextEditingController();
  final _synopsisController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add manual comic'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DialogTextField(
                width: 320,
                controller: _titleController,
                label: 'Series / title',
              ),
              _DialogTextField(
                width: 110,
                controller: _issueController,
                label: 'Issue #',
              ),
              _DialogTextField(
                width: 220,
                controller: _publisherController,
                label: 'Publisher',
              ),
              _DialogTextField(
                width: 100,
                controller: _yearController,
                label: 'Year',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 260,
                controller: _barcodeController,
                label: 'Barcode / UPC',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 220,
                controller: _variantController,
                label: 'Variant',
              ),
              _DialogTextField(
                width: 500,
                controller: _synopsisController,
                label: 'Plot / notes',
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CatalogItem(
                id: 'manual-comic-${DateTime.now().microsecondsSinceEpoch}',
                kind: comicsLibraryConfig.workspace.kind,
                title: title,
                itemNumber: _emptyToNull(_issueController.text),
                synopsis: _emptyToNull(_synopsisController.text),
                publisher: _emptyToNull(_publisherController.text),
                releaseYear: int.tryParse(_yearController.text.trim()),
                barcode: _emptyToNull(_barcodeController.text),
                variant: _emptyToNull(_variantController.text),
              ),
            );
          },
          child: const Text('Add to results'),
        ),
      ],
    );
  }
}

class ManualProposalDialog extends StatefulWidget {
  const ManualProposalDialog({super.key});

  @override
  State<ManualProposalDialog> createState() => _ManualProposalDialogState();
}

class _ManualProposalDialogState extends State<ManualProposalDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Propose manual metadata'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comic title / issue',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Source notes',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              ManualProposalDraft(
                title: title,
                notes: _emptyToNull(_notesController.text),
              ),
            );
          },
          child: const Text('Send proposal'),
        ),
      ],
    );
  }
}

class ManualProposalDraft {
  const ManualProposalDraft({required this.title, required this.notes});

  final String title;
  final String? notes;
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.width,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
