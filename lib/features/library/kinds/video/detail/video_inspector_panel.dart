import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart';
import 'package:flutter/material.dart';

Widget buildVideoInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return VideoInspectorPanel(request: request);
}

class VideoInspectorPanel extends StatelessWidget {
  const VideoInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.inspector.entry;
    final accent = request.inspector.accent;
    final sections = buildVideoInspectorSections(request.inspector);

    return LibraryDetailPanelScaffold(
      accent: accent,
      toolbar: InspectorUnifiedToolbar(
        entry: entry,
        detailsLayout: request.inspector.detailsLayout,
        onEdit: request.onEdit,
        onShare: request.onShare,
        onDuplicate: request.onDuplicate,
        onToggleOwned: request.onToggleOwned,
        onLoan: request.onLoan,
        onRefreshMetadata: request.onRefreshMetadata,
        onUnlinkFromCore: request.onUnlinkFromCore,
        onDetailsLayoutChanged: request.onDetailsLayoutChanged,
      ),
      hero: LibraryDetailHero(
        type: request.inspector.type,
        entry: entry,
        ownedItem: request.inspector.ownedItem,
        accent: accent,
      ),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Details',
          children: [
            ...buildLibraryDetailSectionWidgets(
              sections,
              accentColor: accent,
            ),
            if (request.ownedCopiesSection != null ||
                request.conditionGradeSection != null) ...[
              if (request.ownedCopiesSection != null)
                request.ownedCopiesSection!,
              if (request.conditionGradeSection != null) ...[
                if (request.ownedCopiesSection != null)
                  const SizedBox(height: 8),
                request.conditionGradeSection!,
              ],
            ],
            if (request.bundleSection != null) ...[
              const SizedBox(height: 8),
              request.bundleSection!,
            ],
          ],
        ),
        if (request.trailingSections.isNotEmpty)
          LibraryDetailSectionSpec(
            slot: LibraryDetailSectionSlot.activityHistory,
            title: 'More',
            children: request.trailingSections,
          ),
      ],
    );
  }
}
