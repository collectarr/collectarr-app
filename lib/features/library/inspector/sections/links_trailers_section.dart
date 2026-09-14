import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:flutter/material.dart';

class InspectorLinksTrailersSection extends StatelessWidget {
  const InspectorLinksTrailersSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final links = request.type.presentation.builder.buildWorkspaceLinks(
      request.item.source,
    );
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: 'Trailers / links',
      accentColor: request.accent,
      children: [
        LibraryDetailChipGroupWidget(
          label: 'Links',
          values: [
            for (final link in links) link.displayLabel,
          ],
          onValueTap: request.onFilterByValue,
        ),
      ],
    );
  }
}
