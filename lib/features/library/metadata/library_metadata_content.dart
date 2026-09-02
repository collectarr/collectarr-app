import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

LibraryMetadataPresentation buildLibraryMetadataPresentation({
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  ValueChanged<String>? onFilterByValue,
  bool includeIdentityFacts = false,
}) {
  VoidCallback? tapFor(String? value) {
    if (onFilterByValue == null || value == null || value.trim().isEmpty) {
      return null;
    }
    return () => onFilterByValue(value.trim());
  }

  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.identity.singularLabel,
    item: item,
    includeIdentityFacts: includeIdentityFacts,
    tapFor: tapFor,
  );
}

class LibraryMetadataContent extends StatelessWidget {
  const LibraryMetadataContent({
    super.key,
    required this.type,
    required this.item,
    this.onFilterByValue,
    this.includeIdentityFacts = false,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final ValueChanged<String>? onFilterByValue;
  final bool includeIdentityFacts;

  @override
  Widget build(BuildContext context) {
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      item: item,
      onFilterByValue: onFilterByValue,
      includeIdentityFacts: includeIdentityFacts,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryDetailFieldTable(fields: presentation.allFacts),
        for (final entry in presentation.sections.entries)
          if (entry.value.values.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (entry.value.renderer == LibraryMetadataSectionRenderer.credits)
              LibraryMetadataCreditsList(
                title: presentation.labels.labelFor(entry.key),
                credits: libraryMetadataCreditValues(entry.value),
                onValueTap: onFilterByValue,
              )
            else
              _LibraryMetadataValueList(
                label: presentation.labels.labelFor(
                  entry.value.inlineLabelKey ?? entry.key,
                ),
                values: libraryMetadataTextValues(entry.value),
                onValueTap: onFilterByValue,
              ),
          ],
      ],
    );
  }
}

class _LibraryMetadataValueList extends StatelessWidget {
  const _LibraryMetadataValueList({
    required this.label,
    required this.values,
    this.onValueTap,
  });

  final String label;
  final List<String> values;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 0,
              runSpacing: 2,
              children: [
                for (var index = 0; index < values.length; index += 1)
                  _LibraryMetadataInlineValue(
                    value: values[index],
                    trailingComma: index < values.length - 1,
                    onTap: onValueTap == null
                        ? null
                        : () => onValueTap!(values[index]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryMetadataInlineValue extends StatelessWidget {
  const _LibraryMetadataInlineValue({
    required this.value,
    required this.trailingComma,
    this.onTap,
  });

  final String value;
  final bool trailingComma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final text = Text(
      trailingComma ? '$value, ' : value,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            decoration: onTap == null ? null : TextDecoration.underline,
            decorationColor: palette.textMuted.withValues(alpha: 0.4),
          ),
    );
    if (onTap == null) {
      return text;
    }
    return Tooltip(
      message: 'Show all with $value',
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: text,
      ),
    );
  }
}
