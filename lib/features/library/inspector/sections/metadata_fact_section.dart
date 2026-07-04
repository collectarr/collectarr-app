import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
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
  final List<LibraryInspectorFactData> facts;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty && children.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: title,
      accentColor: accent,
      children: [
        if (facts.isNotEmpty) LibraryInspectorFactGrid(facts: facts),
        if (children.isNotEmpty) ...[
          if (facts.isNotEmpty) const SizedBox(height: 8),
          ...children,
        ],
      ],
    );
  }
}
