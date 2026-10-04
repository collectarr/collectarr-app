import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_layout.dart';
import 'package:collectarr_app/features/library/schema/library_schema_text_controller_store.dart';

import 'library_form_schema.dart';

class LibraryFieldSpecRenderer<TDraft> extends StatefulWidget {
  /// Renders schema fields inside their owning Add or Edit form shell.
  ///
  /// Selection interactions are configured independently from embedded
  /// layout so a kind can keep the same pick-list behavior in both modes.
  const LibraryFieldSpecRenderer.embedded({
    super.key,
    required this.schema,
    required this.draft,
    this.title,
    this.emptyMessage = 'No add fields',
    this.mediaKind,
    this.onVocabularyValueChanged,
    this.onVocabularyValuesChanged,
    this.onChanged,
    this.controllerFor,
    this.focusNodeFor,
    this.controlMode = LibraryFieldSpecControlMode.edit,
  });

  final LibraryFormSchema<TDraft> schema;
  final TDraft draft;
  final String? title;
  final String? emptyMessage;
  final String? mediaKind;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final VoidCallback? onChanged;

  /// Supplies a parent-owned controller registry when fields must survive
  /// conditional tab unmounts. Otherwise this renderer owns its controllers.
  final TextEditingController Function(String id, String initialValue)?
      controllerFor;

  /// Lets a parent route focus and scrolling to a field after validation.
  final FocusNode? Function(String fieldId)? focusNodeFor;
  final LibraryFieldSpecControlMode controlMode;

  @override
  State<LibraryFieldSpecRenderer<TDraft>> createState() =>
      _LibraryFieldSpecRendererState<TDraft>();
}

class _LibraryFieldSpecRendererState<TDraft>
    extends State<LibraryFieldSpecRenderer<TDraft>> {
  final _textControllers = LibrarySchemaTextControllerStore();

  @override
  void dispose() {
    _textControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = widget.schema.sections
        .where((section) => section.isVisible(widget.draft))
        .toList(growable: false);
    if (visibleSections.isEmpty) {
      final message = widget.emptyMessage;
      return message == null
          ? const SizedBox.shrink()
          : Center(child: Text(message));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        _buildSections(context, visibleSections),
      ],
    );
  }

  Widget _buildSections(
    BuildContext context,
    List<LibraryFormSectionSpec<TDraft>> sections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          if (section.label.trim().isNotEmpty) ...[
            Text(section.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
          ],
          LibraryFieldSpecLayout<TDraft>(
            fields: section.fields,
            draft: widget.draft,
            buildField: _buildField,
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

  Widget _buildField(LibraryFieldSpec<TDraft> field) =>
      LibraryFieldSpecControlBuilder<TDraft>(
        context: context,
        draft: widget.draft,
        mode: widget.controlMode,
        controllerFor: _controllerFor,
        focusNodeFor: widget.focusNodeFor,
        mediaKind: widget.mediaKind,
        onVocabularyValueChanged: widget.onVocabularyValueChanged,
        onVocabularyValuesChanged: widget.onVocabularyValuesChanged,
        onChanged: widget.onChanged,
      ).build(field);

  TextEditingController _controllerFor(String id, String initialValue) {
    return widget.controllerFor?.call(id, initialValue) ??
        _textControllers.controllerFor(id, initialValue);
  }
}
