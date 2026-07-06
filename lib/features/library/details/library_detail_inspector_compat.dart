import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';

@Deprecated('Use LibraryDetailField instead.')
class LibraryInspectorFactData {
  const LibraryInspectorFactData(
    this.label,
    this.value, {
    this.onTap,
    this.tooltip,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? tooltip;

  LibraryDetailField toDetailField() {
    return LibraryDetailField(
      label: label,
      value: value,
      onTap: onTap,
      tooltip: tooltip,
    );
  }
}

@Deprecated('Use LibraryDetailSection.')
class LibraryInspectorSection extends StatelessWidget {
  const LibraryInspectorSection({
    super.key,
    required this.title,
    required this.children,
    this.accentColor,
    this.mutedTextColor,
    this.collapsible = true,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;
  final Color? accentColor;
  final Color? mutedTextColor;
  final bool collapsible;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: title,
      collapsible: collapsible,
      initiallyExpanded: initiallyExpanded,
      accentColor: accentColor,
      children: children,
    );
  }
}

@Deprecated('Use LibraryDetailFieldTable.')
class LibraryInspectorFactGrid extends StatelessWidget {
  const LibraryInspectorFactGrid({super.key, required this.facts});

  final List<LibraryInspectorFactData> facts;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailFieldTable(
      fields: [
        for (final fact in facts) fact.toDetailField(),
      ],
    );
  }
}

@Deprecated('Use LibraryDetailFieldRow.')
class LibraryInspectorFact extends StatelessWidget {
  const LibraryInspectorFact(
    this.label,
    this.value, {
    super.key,
    this.mutedTextColor,
    this.onTap,
    this.tooltip,
  });

  final String label;
  final String value;
  final Color? mutedTextColor;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailFieldRow(
      field: LibraryDetailField(
        label: label,
        value: value,
        onTap: onTap,
        tooltip: tooltip,
      ),
    );
  }
}

@Deprecated('Use LibraryDetailChipGroupWidget.')
class LibraryInspectorChipSection extends StatelessWidget {
  const LibraryInspectorChipSection({
    super.key,
    required this.title,
    required this.values,
    this.onValueTap,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: title,
      children: [
        LibraryDetailChipGroupWidget(
          values: values,
          onValueTap: onValueTap,
        ),
      ],
    );
  }
}

@Deprecated('Use LibraryDetailChipGroupWidget.')
class LibraryInspectorChipWrap extends StatelessWidget {
  const LibraryInspectorChipWrap({
    super.key,
    required this.values,
    this.label,
    this.onValueTap,
  });

  final List<String> values;
  final String? label;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailChipGroupWidget(
      label: label,
      values: values,
      onValueTap: onValueTap,
    );
  }
}

@Deprecated('Use LibraryDetailChip.')
class LibraryInspectorChip extends StatelessWidget {
  const LibraryInspectorChip(
    this.value, {
    super.key,
    this.onTap,
    this.accent,
  });

  final String value;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailChip(
      value,
      onTap: onTap,
      accent: accent,
    );
  }
}

@Deprecated('Use LibraryDetailSection/LibraryDetailPanelScaffold wrappers.')
class LibraryEmptyInspector extends StatelessWidget {
  const LibraryEmptyInspector({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    this.mutedTextColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color? mutedTextColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No $label selected',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
