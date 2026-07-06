import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';

class LibraryInspectorSectionSpec {
  const LibraryInspectorSectionSpec({
    required this.title,
    this.children = const [],
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
}

List<Widget> buildLibraryInspectorSectionWidgets(
  List<LibraryInspectorSectionSpec> sections,
) {
  return [
    for (final section in sections)
      LibraryDetailSection(
        title: section.title,
        initiallyExpanded: section.initiallyExpanded,
        children: section.children,
      ),
  ];
}

List<Widget> buildLibraryInspectorSectionFlow({
  required List<Widget> beforeBodySections,
  required List<Widget> bodySections,
  required List<Widget> afterBodySections,
}) {
  return [
    ...beforeBodySections,
    ...bodySections,
    ...afterBodySections,
  ];
}

class LibraryInspectorTitleStatusCard extends StatelessWidget {
  const LibraryInspectorTitleStatusCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.accent,
    required this.statusIcon,
    required this.statusLabel,
  });

  final String eyebrow;
  final String title;
  final Color accent;
  final IconData statusIcon;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 16),
                const SizedBox(width: 6),
                Text(statusLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
