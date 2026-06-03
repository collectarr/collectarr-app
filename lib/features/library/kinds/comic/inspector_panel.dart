import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildComicInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return ComicInspectorPanel(request: request);
}

class ComicInspectorPanel extends StatelessWidget {
  const ComicInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = request.inspector.accent;
    final children = <Widget>[
      request.hero,
      if (request.ownedCopiesSection != null) ...[
        const SizedBox(height: 8),
        request.ownedCopiesSection!,
      ],
      if (request.bundleSection != null) ...[
        const SizedBox(height: 8),
        request.bundleSection!,
      ],
      if (request.conditionGradeSection != null) ...[
        const SizedBox(height: 8),
        request.conditionGradeSection!,
      ],
      if (request.primarySections.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...request.primarySections,
      ],
      if (request.trailingSections.isNotEmpty) ...[
        ...request.trailingSections,
      ],
      const SizedBox(height: 6),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.3 : 0.22),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        children: children,
      ),
    );
  }
}
