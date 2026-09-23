import 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class LibraryDateEditField extends StatelessWidget {
  const LibraryDateEditField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return LibraryDateFieldButton(
          label: label,
          value: parseDate(value.text),
          onChanged: (picked) {
            final text = picked == null ? '' : formatDate(picked);
            if (controller.text != text) {
              controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }
          },
        );
      },
    );
  }
}

class LibraryTitleMetadataFields extends StatelessWidget {
  const LibraryTitleMetadataFields({
    super.key,
    required this.titleController,
    this.sortKeyController,
    this.originalTitleController,
    this.localizedTitleController,
    this.searchAliasesController,
    this.titleLabel = 'Title',
    this.searchAliasesLabel = 'Search aliases',
    this.showSortKey = true,
  });

  final TextEditingController titleController;
  final TextEditingController? sortKeyController;
  final TextEditingController? originalTitleController;
  final TextEditingController? localizedTitleController;
  final TextEditingController? searchAliasesController;
  final String titleLabel;
  final String searchAliasesLabel;
  final bool showSortKey;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      _field(titleController, titleLabel, validator: _requiredTitle),
      if (showSortKey && sortKeyController != null)
        _field(sortKeyController!, 'Sort title'),
      if (originalTitleController != null)
        _field(originalTitleController!, 'Original title'),
      if (localizedTitleController != null)
        _field(localizedTitleController!, 'Localized title'),
      if (searchAliasesController != null)
        EditTokenListField(
          controller: searchAliasesController!,
          label: searchAliasesLabel,
          hint: 'Add alias',
        ),
    ];
    return _responsiveFields(fields);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return LibraryEditTextField(
      controller: controller,
      label: label,
      validator: validator,
    );
  }

  String? _requiredTitle(String? value) {
    return emptyToNull(value ?? '') == null ? 'Enter a title' : null;
  }
}

class LibraryReleaseIdentityFields extends StatelessWidget {
  const LibraryReleaseIdentityFields({
    super.key,
    required this.editionTitleController,
    required this.variantController,
    required this.barcodeController,
    required this.releaseDateController,
    required this.releaseYearController,
    required this.physicalFormatController,
    required this.physicalFormatOptions,
    required this.onPhysicalFormatChanged,
    this.onPhysicalFormatManage,
    this.formatLabel = 'Physical format',
    this.editionTitleLabel = 'Edition title',
    this.variantLabel = 'Variant',
    this.barcodeLabel = 'Barcode',
    this.releaseDateLabel = 'Release date',
    this.releaseYearLabel = 'Release year',
    this.showReleaseYear = true,
    this.showPhysicalFormat = true,
  });

  final TextEditingController editionTitleController;
  final TextEditingController variantController;
  final TextEditingController barcodeController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;
  final TextEditingController physicalFormatController;
  final List<String> physicalFormatOptions;
  final ValueChanged<String?> onPhysicalFormatChanged;
  final VoidCallback? onPhysicalFormatManage;
  final String formatLabel;
  final String editionTitleLabel;
  final String variantLabel;
  final String barcodeLabel;
  final String releaseDateLabel;
  final String releaseYearLabel;
  final bool showReleaseYear;
  final bool showPhysicalFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _responsiveFields([
          _field(editionTitleController, editionTitleLabel),
          _field(variantController, variantLabel),
          _field(barcodeController, barcodeLabel),
        ]),
        const SizedBox(height: 10),
        _responsiveFields([
          LibraryDateEditField(
            label: releaseDateLabel,
            controller: releaseDateController,
          ),
          if (showReleaseYear)
            _field(
              releaseYearController,
              releaseYearLabel,
              validator: optionalIntValidator,
            ),
          if (!showReleaseYear) const SizedBox.shrink(),
        ]),
        const SizedBox(height: 10),
        if (showPhysicalFormat) ...[
          LibraryVocabularyField(
            label: formatLabel,
            controller: physicalFormatController,
            options: physicalFormatOptions,
            onChanged: onPhysicalFormatChanged,
            onManage: onPhysicalFormatManage,
            manageTooltip: 'Manage physical formats',
          ),
        ],
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return LibraryEditTextField(
      controller: controller,
      label: label,
      validator: validator,
    );
  }
}

class LibraryContributionEditor extends StatelessWidget {
  const LibraryContributionEditor({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'Add entry',
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return EditTokenListField(
      controller: controller,
      label: label,
      hint: hint,
    );
  }
}

class LibraryExternalLinksEditor extends StatefulWidget {
  const LibraryExternalLinksEditor({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    this.emptyMessage = 'No entries yet.',
    this.accent,
  });

  final String title;
  final List<EditableUserExternalLink> items;
  final VoidCallback onAdd;
  final String emptyMessage;
  final Color? accent;

  @override
  State<LibraryExternalLinksEditor> createState() =>
      _LibraryExternalLinksEditorState();
}

class _LibraryExternalLinksEditorState
    extends State<LibraryExternalLinksEditor> {
  void _add() {
    widget.onAdd();
    setState(() {});
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final item = widget.items.removeAt(oldIndex);
    widget.items.insert(newIndex, item);
    setState(() {});
  }

  void _removeSelected(
    List<LibraryExternalLinkEditRow<EditableUserExternalLink>> selectedRows,
  ) {
    final selected = {for (final row in selectedRows) row.identity};
    widget.items.removeWhere((item) {
      if (!selected.contains(item)) return false;
      item.dispose();
      return true;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LibraryExternalLinksTable<EditableUserExternalLink>(
      rows: [
        for (final item in widget.items)
          LibraryExternalLinkEditRow<EditableUserExternalLink>(
            identity: item,
            urlController: item.urlController,
            descriptionController: item.labelController,
          ),
      ],
      accent: widget.accent ?? Theme.of(context).colorScheme.primary,
      addLabel: 'Add ${widget.title}',
      emptyMessage: widget.emptyMessage,
      onAdd: _add,
      onReorder: _reorder,
      onRemoveSelected: _removeSelected,
    );
  }
}

Widget _responsiveFields(List<Widget> children) {
  return LibraryEditResponsiveRow(children: children);
}
