import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorLinksTrailersSection extends StatelessWidget {
  const InspectorLinksTrailersSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final links = request.entry.trailerUrls;
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Trailers / links',
      accentColor: request.accent,
      children: [
        LibraryInspectorChipWrap(
          label: 'Links',
          values: [
            for (final link in links) link.title ?? link.url,
          ],
          onValueTap: request.onFilterByValue,
        ),
      ],
    );
  }
}
