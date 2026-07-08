import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';

class InspectorMetadataFactsSection extends StatelessWidget {
  const InspectorMetadataFactsSection({
    super.key,
    required this.title,
    required this.accent,
    required this.facts,
    this.children = const <Widget>[],
  });

  final String title;
  final Color accent;
  final List<LibraryDetailField> facts;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty && children.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: title,
      accentColor: accent,
      children: [
        if (facts.isNotEmpty) LibraryDetailFieldTable(fields: facts),
        if (children.isNotEmpty) ...[
          if (facts.isNotEmpty) const SizedBox(height: 8),
          ...children,
        ],
      ],
    );
  }
}


