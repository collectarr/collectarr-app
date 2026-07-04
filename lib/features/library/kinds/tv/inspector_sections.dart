import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart'
    as video_sections;
import 'package:flutter/material.dart';

List<Widget> buildTvInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return video_sections.buildVideoInspectorSections(context, request);
}

Widget buildTvInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return buildVideoInspectorPanel(context, request);
}
