import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

/// Compatibility shim kept for tests and external references.
/// Comics now use the default inspector panel layout from library_inspector.dart.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        request.hero,
        ...request.primarySections,
        if (request.bundleSection != null) request.bundleSection!,
        if (request.conditionGradeSection != null) request.conditionGradeSection!,
        ...request.trailingSections,
      ],
    );
  }
}
