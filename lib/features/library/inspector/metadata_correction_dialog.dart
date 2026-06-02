import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a dialog to propose metadata corrections for any media type.
Future<void> showMetadataCorrectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required CatalogItem item,
  required LibraryTypeConfig type,
}) async {
  final draft = await showDialog<_MetadataCorrectionDraft>(
    context: context,
    builder: (context) => _MetadataCorrectionDialog(item: item),
  );
  if (draft == null || !context.mounted) return;

  try {
    final resolvedType = ref.read(resolvedLibraryTypeProvider(type));
    final query = draft.queryFor(item);
    final title = draft.title.trim().isEmpty ? item.title : draft.title.trim();
    final response = await createLibraryMetadataProposal(
      api: ref.read(apiClientProvider),
      type: resolvedType,
      query: query,
      title: title,
      summary: draft.summaryFor(item),
    );
    await recordLibraryMetadataProposalResponse(
      response: response,
      type: resolvedType,
      query: query,
      title: title,
      source: 'Metadata correction',
    );
    if (!context.mounted) return;
    showAppToast(
      context,
      'Metadata correction sent for review.',
      tone: AppToastTone.success,
    );
  } catch (error) {
    if (!context.mounted) return;
    showAppToast(
      context,
      _describeMetadataCorrectionError(error),
      tone: AppToastTone.error,
    );
  }
}

String _describeMetadataCorrectionError(Object error) {
  if (error case DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    if (statusCode != null) {
      return 'Couldn\'t send the metadata correction. Server responded with $statusCode.';
    }
    if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.receiveTimeout ||
        dioError.type == DioExceptionType.sendTimeout) {
      return 'Couldn\'t send the metadata correction. The request timed out.';
    }
    return 'Couldn\'t send the metadata correction right now. Try again.';
  }
  final text = error.toString().trim();
  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }
  return 'Couldn\'t send the metadata correction. $text';
}

class _MetadataCorrectionDialog extends StatefulWidget {
  const _MetadataCorrectionDialog({required this.item});

  final CatalogItem item;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final _titleController = TextEditingController(text: widget.item.title);
  late final _issueController =
      TextEditingController(text: widget.item.itemNumber ?? '');
  late final _publisherController =
      TextEditingController(text: widget.item.publisher ?? '');
  late final _yearController =
      TextEditingController(text: widget.item.releaseYear?.toString() ?? '');
  late final _barcodeController =
      TextEditingController(text: widget.item.barcode ?? '');
  late final _variantController =
      TextEditingController(text: widget.item.variant ?? '');
  final _notesController = TextEditingController();
  final _sourceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _notesController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: const AccentDialogHeader(
        title: 'Correct metadata',
        icon: Icons.edit_note,
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CorrectionField(
                width: 340,
                controller: _titleController,
                label: 'Series / title',
              ),
              _CorrectionField(
                width: 120,
                controller: _issueController,
                label: 'Issue #',
              ),
              _CorrectionField(
                width: 220,
                controller: _publisherController,
                label: 'Publisher',
              ),
              _CorrectionField(
                width: 100,
                controller: _yearController,
                label: 'Year',
                keyboardType: TextInputType.number,
              ),
              _CorrectionField(
                width: 220,
                controller: _barcodeController,
                label: 'Barcode / UPC',
                keyboardType: TextInputType.number,
              ),
              _CorrectionField(
                width: 220,
                controller: _variantController,
                label: 'Variant',
              ),
              _CorrectionField(
                width: 540,
                controller: _sourceController,
                label: 'Source URL',
              ),
              _CorrectionField(
                width: 540,
                controller: _notesController,
                label: 'What should change?',
                maxLines: 5,
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
            Navigator.of(context).pop(
              _MetadataCorrectionDraft(
                title: _titleController.text,
                issueNumber: _issueController.text,
                publisher: _publisherController.text,
                releaseYear: _yearController.text,
                barcode: _barcodeController.text,
                variant: _variantController.text,
                sourceUrl: _sourceController.text,
                notes: _notesController.text,
              ),
            );
          },
          child: const Text('Send correction'),
        ),
      ],
    );
  }
}

class _CorrectionField extends StatelessWidget {
  const _CorrectionField({
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
      child: MetadataCorrectionTextField(
        controller: controller,
        label: label,
        keyboardType: keyboardType,
        maxLines: maxLines,
        isDense: true,
      ),
    );
  }
}

class _MetadataCorrectionDraft {
  const _MetadataCorrectionDraft({
    required this.title,
    required this.issueNumber,
    required this.publisher,
    required this.releaseYear,
    required this.barcode,
    required this.variant,
    required this.sourceUrl,
    required this.notes,
  });

  final String title;
  final String issueNumber;
  final String publisher;
  final String releaseYear;
  final String barcode;
  final String variant;
  final String sourceUrl;
  final String notes;

  String queryFor(CatalogItem item) {
    return [
      title.trim().isEmpty ? item.title : title.trim(),
      issueNumber.trim().isEmpty ? item.itemNumber : '#${issueNumber.trim()}',
      publisher.trim().isEmpty ? item.publisher : publisher.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
  }

  String summaryFor(CatalogItem item) {
    final lines = [
      'Metadata correction proposal',
      '',
      'Original:',
      'title: ${item.title}',
      if (item.itemNumber != null) 'issue: ${item.itemNumber}',
      if (item.publisher != null) 'publisher: ${item.publisher}',
      if (item.releaseYear != null) 'year: ${item.releaseYear}',
      if (item.barcode != null) 'barcode: ${item.barcode}',
      if (item.variant != null) 'variant: ${item.variant}',
      '',
      'Suggested:',
      if (title.trim().isNotEmpty) 'title: ${title.trim()}',
      if (issueNumber.trim().isNotEmpty) 'issue: ${issueNumber.trim()}',
      if (publisher.trim().isNotEmpty) 'publisher: ${publisher.trim()}',
      if (releaseYear.trim().isNotEmpty) 'year: ${releaseYear.trim()}',
      if (barcode.trim().isNotEmpty) 'barcode: ${barcode.trim()}',
      if (variant.trim().isNotEmpty) 'variant: ${variant.trim()}',
      if (sourceUrl.trim().isNotEmpty) 'source: ${sourceUrl.trim()}',
      if (notes.trim().isNotEmpty) ...['', 'Notes:', notes.trim()],
    ];
    return lines.join('\n');
  }
}
