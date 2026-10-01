import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';

import 'add_schema.dart';

class AddSchemaRenderer<TDraft> extends StatefulWidget {
  factory AddSchemaRenderer({
    Key? key,
    required AddSchema<TDraft> schema,
    required TDraft draft,
    required FutureOr<void> Function(TDraft draft) onSubmit,
    VoidCallback? onCancel,
    String? title,
    String submitLabel = 'Add',
    String? mediaKind,
  }) =>
      AddSchemaRenderer<TDraft>._(
        key: key,
        schema: schema,
        draft: draft,
        onSubmit: onSubmit,
        onCancel: onCancel,
        title: title,
        submitLabel: submitLabel,
        mediaKind: mediaKind,
        onVocabularyValueChanged: null,
        onVocabularyValuesChanged: null,
        embedded: false,
      );

  const AddSchemaRenderer.embedded({
    Key? key,
    required AddSchema<TDraft> schema,
    required TDraft draft,
    String? title,
    String? mediaKind,
    LibraryVocabularyValueChanged? onVocabularyValueChanged,
    LibraryVocabularyValuesChanged? onVocabularyValuesChanged,
  }) : this._(
          key: key,
          schema: schema,
          draft: draft,
          onSubmit: null,
          onCancel: null,
          title: title,
          mediaKind: mediaKind,
          onVocabularyValueChanged: onVocabularyValueChanged,
          onVocabularyValuesChanged: onVocabularyValuesChanged,
          submitLabel: 'Add',
          embedded: true,
        );

  const AddSchemaRenderer._({
    super.key,
    required this.schema,
    required this.draft,
    required this.onSubmit,
    required this.onCancel,
    required this.title,
    required this.mediaKind,
    required this.onVocabularyValueChanged,
    required this.onVocabularyValuesChanged,
    required this.submitLabel,
    required bool embedded,
  }) : _embedded = embedded;

  final AddSchema<TDraft> schema;
  final TDraft draft;
  final FutureOr<void> Function(TDraft draft)? onSubmit;
  final VoidCallback? onCancel;
  final String? title;
  final String submitLabel;
  final String? mediaKind;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final bool _embedded;

  @override
  State<AddSchemaRenderer<TDraft>> createState() =>
      _AddSchemaRendererState<TDraft>();
}

class _AddSchemaRendererState<TDraft> extends State<AddSchemaRenderer<TDraft>> {
  late final Map<String, TextEditingController> _textControllers;
  bool _isSubmitting = false;
  String? _submitError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _textControllers = {};
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = widget.schema.sections
        .where((section) => section.isVisible(widget.draft))
        .toList(growable: false);
    if (visibleSections.isEmpty) {
      return const Center(child: Text('No add fields'));
    }

    final schemaTitle = widget.title ?? widget.schema.title?.call(widget.draft);
    if (widget._embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (schemaTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                schemaTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _buildSections(context, visibleSections),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? math.min(constraints.maxHeight, 720.0)
            : 720.0;
        return SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (schemaTitle != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    schemaTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _buildSections(context, visibleSections),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSections(
    BuildContext context,
    List<AddSectionSpec<TDraft>> sections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          if (section.label.trim().isNotEmpty) ...[
            Text(section.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
          ],
          _buildFieldWrap(
            context,
            section.fields,
            maxColumns: section.maxColumns,
            fullWidthFieldIds: section.fullWidthFieldIds,
            fieldColumnSpans: section.fieldColumnSpans,
            rightAlignedFieldIds: section.rightAlignedFieldIds,
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildFieldWrap(
    BuildContext context,
    List<LibraryFieldSpec<TDraft>> fields, {
    required int maxColumns,
    required Set<String> fullWidthFieldIds,
    required Map<String, int> fieldColumnSpans,
    required Set<String> rightAlignedFieldIds,
  }) {
    final visibleFields = fields
        .where((field) => field.isVisible(widget.draft))
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960
            ? maxColumns
            : constraints.maxWidth >= 680
                ? math.min(maxColumns, 2)
                : 1;
        final columnWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in visibleFields)
              _buildFieldSlot(
                field,
                constraints: constraints,
                columns: columns,
                columnWidth: columnWidth,
                fullWidth: fullWidthFieldIds.contains(field.id),
                span: fieldColumnSpans[field.id] ?? 1,
                rightAligned: rightAlignedFieldIds.contains(field.id),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFieldSlot(
    LibraryFieldSpec<TDraft> field, {
    required BoxConstraints constraints,
    required int columns,
    required double columnWidth,
    required bool fullWidth,
    required int span,
    required bool rightAligned,
  }) {
    final resolvedSpan = fullWidth ? columns : span.clamp(1, columns).toInt();
    final fieldWidth = resolvedSpan * columnWidth + 12 * (resolvedSpan - 1);
    final fieldWidget = _buildField(field);
    if (rightAligned && columns > 1 && !fullWidth) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: fieldWidth, child: fieldWidget),
        ),
      );
    }
    return SizedBox(
      width: fullWidth ? constraints.maxWidth : fieldWidth,
      child: fieldWidget,
    );
  }

  Widget _buildField(LibraryFieldSpec<TDraft> field) =>
      LibraryFieldSpecControlBuilder<TDraft>(
        context: context,
        draft: widget.draft,
        mode: widget._embedded
            ? LibraryFieldSpecControlMode.edit
            : LibraryFieldSpecControlMode.add,
        controllerFor: _controllerFor,
        mediaKind: widget.mediaKind,
        onVocabularyValueChanged: widget.onVocabularyValueChanged,
        onVocabularyValuesChanged: widget.onVocabularyValuesChanged,
        onChanged: () {
          if (mounted) setState(() => _validationError = null);
        },
      ).build(field);

  Widget _buildFooter(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_validationError != null)
              Text(
                _validationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_submitError != null)
              Text(
                _submitError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final schemaError = widget.schema.validate?.call(widget.draft);
    final fieldError = _firstFieldError();
    if (schemaError != null || fieldError != null) {
      setState(() {
        _validationError = schemaError ?? fieldError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      await widget.onSubmit!(widget.draft);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = error.toString();
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  String? _firstFieldError() {
    for (final section in widget.schema.sections) {
      if (!section.isVisible(widget.draft)) continue;
      for (final field in section.fields) {
        if (field.isVisible(widget.draft)) {
          final error = field.validate(widget.draft);
          if (error != null) return error;
        }
      }
    }
    return null;
  }

  TextEditingController _controllerFor(String id, String initialValue) {
    return _textControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initialValue),
    );
  }
}
