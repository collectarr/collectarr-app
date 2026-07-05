import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_shared_sections.dart';
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
    final ownedItem = request.inspector.ownedItem;
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

    return LibraryInspectorPanelLayout(
      entry: entry,
      ownedItem: ownedItem,
      accent: accent,
      children: [
        InspectorUnifiedToolbar(
          entry: entry,
          onEdit: request.onEdit,
          onShare: request.onShare,
          onDuplicate: request.onDuplicate,
          onToggleOwned: request.onToggleOwned,
          onLoan: request.onLoan,
          onRefreshMetadata: request.onRefreshMetadata,
          onUnlinkFromCore: request.onUnlinkFromCore,
          onDetailsLayoutChanged: request.onDetailsLayoutChanged,
        ),
        const SizedBox(height: 8),
        LibraryDetailHero(
          type: request.inspector.type,
          entry: entry,
          ownedItem: ownedItem,
          accent: accent,
        ),
        const SizedBox(height: 6),
        LibraryInspectorTitleStatusCard(
          eyebrow: series,
          title: entry.resolvedTitle,
          accent: accent,
          statusIcon: statusIcon,
          statusLabel: statusLabel,
        ),
        const SizedBox(height: 10),
        InspectorActionBar(
          type: request.inspector.type,
          entry: entry,
          onToggleOwned: request.onToggleOwned,
          onToggleWishlist: request.onToggleWishlist,
          onEdit: request.onEdit,
          onCorrectMetadata: request.onCorrectMetadata,
          extraActions: request.extraActions,
          onOpenDetails: request.onOpenDetails,
        ),
        if (request.trailingSections.isNotEmpty) ...[
          ...request.trailingSections,
          const SizedBox(height: 6),
        ],
        ...buildLibraryInspectorSectionList([
          request.ownedCopiesSection,
          request.bundleSection,
          request.conditionGradeSection,
          if (sections.isNotEmpty) ...sections,
        ]),
      ],
    );
  }
}
