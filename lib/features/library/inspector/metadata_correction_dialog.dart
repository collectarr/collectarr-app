import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
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
  required LibraryMetadataCorrectionSource source,
  required LibraryKindModule type,
}) async {
  final draft = await showDialog<_MetadataCorrectionDraft>(
    context: context,
    builder: (context) => _MetadataCorrectionDialog(
      source: source,
      contributor: libraryAdminContributorForKind(type.kind),
    ),
  );
  if (draft == null || !context.mounted) return;

  try {
    final query = draft.query;
    final String title =
        draft.title.trim().isEmpty ? source.title : draft.title.trim();
    final response = await createLibraryMetadataProposal(
      api: ref.read(apiClientProvider),
      type: type,
      query: query,
      title: title,
      summary: draft.summary,
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
  const _MetadataCorrectionDialog({
    required this.source,
    required this.contributor,
  });

  final LibraryMetadataCorrectionSource source;
  final LibraryAdminContributor? contributor;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final Map<String, TextEditingController> _fieldControllers;

  List<LibraryAdminProposalField> get _kindFields =>
      widget.contributor?.proposalFields ?? const [];

  @override
  void initState() {
    super.initState();
    _fieldControllers = {
      for (final field in _kindFields)
        field.key: TextEditingController(
          text: field.read(widget.source.payload),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    _titleController.dispose();
    _sourceUrlController.dispose();
    _notesController.dispose();
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
              _CorrectionField(
                width: 220,
                controller: _titleController,
                label: 'Title',
              ),
              for (final field in _kindFields)
                _CorrectionField(
                  width: 220,
                  controller: _controllerForFieldKey(field.key),
                  label: field.label,
                  maxLines: field.maxLines,
                ),
              _CorrectionField(
                width: 220,
                controller: _sourceUrlController,
                label: 'Source URL',
              ),
              _CorrectionField(
                width: 460,
                controller: _notesController,
                label: 'Notes',
                maxLines: 3,
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
                query: _buildQuery(),
                summary: _buildSummary(),
              ),
            );
          },
          child: const Text('Send correction'),
        ),
      ],
    );
  }

  late final TextEditingController _titleController =
      TextEditingController(text: widget.source.title);
  late final TextEditingController _sourceUrlController =
      TextEditingController();
  late final TextEditingController _notesController = TextEditingController();

  TextEditingController _controllerForFieldKey(String key) {
    final controller = _fieldControllers[key];
    if (controller == null) {
      throw StateError('Unsupported proposal metadata field key: $key');
    }
    return controller;
  }

  String _buildQuery() {
    final values = _fieldValues();
    return [
      _titleController.text.trim(),
      ...values.values.map((value) => value.trim()),
    ].where((value) => value.isNotEmpty).join(' ');
  }

  String _buildSummary() {
    final values = _fieldValues();
    final lines = <String>[
      'Metadata correction proposal',
      '',
      'Original:',
      'title: ${widget.source.title}',
    ];
    final originalPayload = widget.source.payload;
    for (final field in _kindFields) {
      final value = field.read(originalPayload).trim();
      if (value.isNotEmpty) {
        lines.add('${field.label}: $value');
      }
    }
    lines.addAll(['', 'Suggested:']);
    if (_titleController.text.trim().isNotEmpty) {
      lines.add('title: ${_titleController.text.trim()}');
    }
    for (final field in _kindFields) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isNotEmpty) {
        lines.add('${field.label}: $value');
      }
    }
    if (_sourceUrlController.text.trim().isNotEmpty) {
      lines.add('source: ${_sourceUrlController.text.trim()}');
    }
    if (_notesController.text.trim().isNotEmpty) {
      lines.addAll(['', 'Notes:', _notesController.text.trim()]);
    }
    return lines.join('\n');
  }

  Map<String, String> _fieldValues() => {
        for (final field in _kindFields)
          field.key: _controllerForFieldKey(field.key).text,
      };
}

class _CorrectionField extends StatelessWidget {
  const _CorrectionField({
    required this.width,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MetadataCorrectionTextField(
        controller: controller,
        label: label,
        maxLines: maxLines,
        isDense: true,
      ),
    );
  }
}

class _MetadataCorrectionDraft {
  const _MetadataCorrectionDraft({
    required this.title,
    required this.query,
    required this.summary,
  });

  final String title;
  final String query;
  final String summary;
}
