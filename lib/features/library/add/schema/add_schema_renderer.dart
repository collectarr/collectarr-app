import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_layout.dart';
import 'package:collectarr_app/features/library/schema/library_schema_text_controller_store.dart';

import 'add_schema.dart';

class AddSchemaRenderer<TDraft> extends StatefulWidget {
  /// Renders schema fields inside their owning Add or Edit form shell.
  ///
  /// Selection interactions are configured independently from embedded
  /// layout so a kind can keep the same pick-list behavior in both modes.
  const AddSchemaRenderer.embedded({
    super.key,
    required this.schema,
    required this.draft,
    this.title,
    this.mediaKind,
    this.onVocabularyValueChanged,
    this.onVocabularyValuesChanged,
    this.onChanged,
    this.controlMode = LibraryFieldSpecControlMode.edit,
  });

  final AddSchema<TDraft> schema;
  final TDraft draft;
  final String? title;
  final String? mediaKind;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final VoidCallback? onChanged;
  final LibraryFieldSpecControlMode controlMode;

  @override
  State<AddSchemaRenderer<TDraft>> createState() =>
      _AddSchemaRendererState<TDraft>();
}

class _AddSchemaRendererState<TDraft> extends State<AddSchemaRenderer<TDraft>> {
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
      return const Center(child: Text('No add fields'));
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
        mediaKind: widget.mediaKind,
        onVocabularyValueChanged: widget.onVocabularyValueChanged,
        onVocabularyValuesChanged: widget.onVocabularyValuesChanged,
        onChanged: widget.onChanged,
      ).build(field);

  TextEditingController _controllerFor(String id, String initialValue) {
    return _textControllers.controllerFor(id, initialValue);
  }
}
