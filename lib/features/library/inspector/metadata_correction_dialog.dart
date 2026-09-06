import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a dialog to propose metadata corrections for any media type.
Future<void> showMetadataCorrectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Object item,
  required LibraryKindModule type,
}) async {
  final draft = await showDialog<_MetadataCorrectionDraft>(
    context: context,
    builder: (context) => _MetadataCorrectionDialog(item: item),
  );
  if (draft == null || !context.mounted) return;

  try {
    final query = draft.queryFor(item);
    final itemTitle = _itemTitle(item);
    final String title =
        draft.title.trim().isEmpty ? itemTitle : draft.title.trim();
    final response = await createLibraryMetadataProposal(
      api: ref.read(apiClientProvider),
      type: type,
      query: query,
      title: title,
      summary: draft.summaryFor(item),
    );
    await recordLibraryMetadataProposalResponse(
      response: response,
      type: type,
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

  final dynamic item;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final Map<String, TextEditingController> _fieldControllers;

  @override
  void initState() {
    super.initState();
    _fieldControllers = {
      for (final field in kProposalCorrectionFields)
        field.key: TextEditingController(text: _initialFieldText(field.key)),
    };
  }

  @override
  void dispose() {
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
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
              for (final field in kProposalCorrectionFields)
                _CorrectionField(
                  width: field.compactWidth ?? 220,
                  controller: _controllerForFieldKey(field.key),
                  label: field.label,
                  keyboardType: sharedFieldKeyboardType(field),
                  maxLines: field.maxLines,
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
                title: _controllerForFieldKey('title').text,
                issueNumber: _controllerForFieldKey('item_number').text,
                publisher: _controllerForFieldKey('publisher').text,
                releaseYear: _controllerForFieldKey('release_year').text,
                barcode: _controllerForFieldKey('barcode').text,
                variant: _controllerForFieldKey('variant').text,
                sourceUrl: _controllerForFieldKey('source_url').text,
                notes: _controllerForFieldKey('notes').text,
              ),
            );
          },
          child: const Text('Send correction'),
        ),
      ],
    );
  }

  TextEditingController _controllerForFieldKey(String key) {
    final controller = _fieldControllers[key];
    if (controller == null) {
      throw StateError('Unsupported proposal metadata field key: $key');
    }
    return controller;
  }

  String _initialFieldText(String key) {
    final item = _asCatalogItem(widget.item);
    final payload = item.payload;
    final title = item.title;
    final releaseYear = item.releaseYear;
    return switch (key) {
      'title' => title,
      'item_number' =>
        (payload['item_number'] ?? payload['itemNumber'])?.toString() ?? '',
      'publisher' => payload['publisher']?.toString() ?? '',
      'release_year' => releaseYear?.toString() ?? '',
      'barcode' => payload['barcode']?.toString() ?? '',
      'variant' => payload['variant']?.toString() ?? '',
      'source_url' => '',
      'notes' => '',
      _ => '',
    };
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

Map<String, dynamic> _itemPayload(Object item) {
  return _asCatalogItem(item).toSyncPayload();
}

String _itemTitle(Object item) {
  return _asCatalogItem(item).title;
}

int? _itemReleaseYear(Object item) {
  return _asCatalogItem(item).releaseYear;
}

CatalogItem _asCatalogItem(Object? item) {
  if (item is CatalogItem) return item;
  throw ArgumentError.value(item, 'item', 'Unsupported catalog item type');
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

  String queryFor(Object item) {
    final payload = _itemPayload(item);
    final itemNumber =
        (payload['item_number'] ?? payload['itemNumber'])?.toString();
    final pub = payload['publisher']?.toString();
    return [
      title.trim().isEmpty ? _itemTitle(item) : title.trim(),
      issueNumber.trim().isEmpty ? itemNumber : '#${issueNumber.trim()}',
      publisher.trim().isEmpty ? pub : publisher.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
  }

  String summaryFor(Object item) {
    final payload = _itemPayload(item);
    final itemNumber =
        (payload['item_number'] ?? payload['itemNumber'])?.toString();
    final pub = payload['publisher']?.toString();
    final barcodeVal = payload['barcode']?.toString();
    final variantVal = payload['variant']?.toString();

    final lines = [
      'Metadata correction proposal',
      '',
      'Original:',
      'title: ${_itemTitle(item)}',
      if (itemNumber != null) 'issue: $itemNumber',
      if (pub != null) 'publisher: $pub',
      if (_itemReleaseYear(item) != null) 'year: ${_itemReleaseYear(item)}',
      if (barcodeVal != null) 'barcode: $barcodeVal',
      if (variantVal != null) 'variant: $variantVal',
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
