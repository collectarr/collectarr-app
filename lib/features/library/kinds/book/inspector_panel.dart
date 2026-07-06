import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_title_status_card.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:flutter/material.dart';

Widget buildBookInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return BookInspectorPanel(request: request);
}

class BookInspectorPanel extends StatelessWidget {
  const BookInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.inspector.entry;
    final accent = request.inspector.accent;
    final series = entry.series?.seriesTitle?.trim();
    final statusIcon =
        entry.isOwned ? Icons.inventory_2_outlined : Icons.star_border;
    final statusLabel = entry.isOwned
        ? 'In collection'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Catalog';
    final sections = const BookLibraryMediaPresentationBuilder(
      showSummary: true,
    ).buildInspectorSections(
      context: context,
      entry: entry,
      accent: accent,
    );

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
      hero: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryDetailHero(
            type: request.inspector.type,
            entry: entry,
            ownedItem: request.inspector.ownedItem,
            accent: accent,
          ),
          const SizedBox(height: 6),
          LibraryDetailTitleStatusCard(
            eyebrow: series,
            title: entry.resolvedTitle,
            accent: accent,
            statusIcon: statusIcon,
            statusLabel: statusLabel,
          ),
          const SizedBox(height: 10),
        ],
      ),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Details',
          children: [
            if (request.trailingSections.isNotEmpty) ...request.trailingSections,
            if (request.ownedCopiesSection != null)
              request.ownedCopiesSection!,
            if (request.bundleSection != null)
              request.bundleSection!,
            if (request.conditionGradeSection != null)
              request.conditionGradeSection!,
            ...sections,
          ],
        ),
      ],
    );
  }
}
