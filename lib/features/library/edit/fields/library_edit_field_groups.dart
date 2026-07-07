import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_models.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';

class LibraryVocabularyField extends StatelessWidget {
  const LibraryVocabularyField({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
    this.hint,
    this.validator,
    this.enabled = true,
    this.multiSelect = false,
    this.onChanged,
    this.onManage,
    this.manageTooltip,
  });

  final String label;
  final List<String> options;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool multiSelect;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onManage;
  final String? manageTooltip;

  @override
  Widget build(BuildContext context) {
    if (multiSelect) {
      return TagPickListField(
        controller: controller,
        options: options,
        label: label,
        hint: hint,
        validator: validator,
        enabled: enabled,
      );
    }
    return SingleValuePickField(
      controller: controller,
      options: options,
      label: label,
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      onManage: onManage,
      manageTooltip: manageTooltip,
      showPickerListAction: onManage == null,
      enabled: enabled,
    );
  }
}

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
    this.physicalFormatLabel = 'Physical format',
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
  final String physicalFormatLabel;
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
            label: physicalFormatLabel,
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

class LibraryExternalLinksEditor extends StatelessWidget {
  const LibraryExternalLinksEditor({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    this.emptyMessage = 'No entries yet.',
  });

  final String title;
  final List<EditableUserExternalLink> items;
  final VoidCallback onAdd;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          EditSectionStateMessage(
            message: emptyMessage,
            icon: Icons.link_outlined,
          )
        else
          Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: item.labelController,
                          decoration:
                              const InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: item.urlController,
                          decoration: const InputDecoration(labelText: 'URL'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('Add $title'),
        ),
      ],
    );
  }
}

Widget _responsiveFields(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final twoColumns = constraints.maxWidth >= 620;
      if (!twoColumns) {
        return Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(height: 10),
              children[index],
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: 10),
            Expanded(child: children[index]),
          ],
        ],
      );
    },
  );
}
