import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/details/inspector_title_card.dart';
import 'package:collectarr_app/features/library/detail/hero.dart';
import 'package:collectarr_app/features/library/details/models.dart';
import 'package:collectarr_app/features/library/details/panel_scaffold.dart';
import 'package:collectarr_app/features/library/inspector/chrome.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/book/detail/author_spotlight.dart';
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
    final item = request.inspector.item;
    final accent = request.inspector.accent;
    final adapter =
        item.dto is BookWorkspaceDto ? item.dto as BookWorkspaceDto : null;
    final series = adapter?.seriesTitle?.trim();
    final sections = const BookLibraryMediaPresentationBuilder(
      showSummary: true,
    ).buildInspectorSections(
      context: context,
      item: item,
      accent: accent,
    );

    return LibraryDetailPanelScaffold(
      accent: accent,
      toolbar: InspectorUnifiedToolbar(
        item: item,
        detailsLayout: request.inspector.detailsLayout,
        onEdit: request.onEdit,
        onShare: request.onShare,
        onDuplicate: request.onDuplicate,
        onToggleEntry: request.onToggleEntry,
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
            item: item,
            libraryEntry: request.inspector.libraryEntry,
            accent: accent,
            kindEntryContent: buildBookAuthorSpotlight(
              item: item,
              accent: accent,
            ),
          ),
          const SizedBox(height: 6),
          LibraryInspectorTitleCard(
            item: item,
            eyebrow: series,
            accent: accent,
          ),
          const SizedBox(height: 6),
          InspectorActionBar(
            type: request.inspector.type,
            item: item,
            onToggleEntry: request.onToggleEntry,
            onToggleWishlist: request.onToggleWishlist,
            onEdit: request.onEdit,
            extraActions: request.extraActions,
            onOpenDetails: request.onOpenDetails,
          ),
          const SizedBox(height: 10),
        ],
      ),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Details',
          children: [
            if (request.trailingSections.isNotEmpty)
              ...request.trailingSections,
            if (request.bundleSection != null) request.bundleSection!,
            if (request.conditionGradeSection != null)
              request.conditionGradeSection!,
            ...sections,
          ],
        ),
      ],
    );
  }
}
