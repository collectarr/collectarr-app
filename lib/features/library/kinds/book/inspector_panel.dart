import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
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
    final item = request.inspector.item;
    final accent = request.inspector.accent;
    final series = item.dto.seriesTitle?.trim();
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
            item: item,
            ownedItem: request.inspector.ownedItem,
            accent: accent,
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
            onToggleOwned: request.onToggleOwned,
            onToggleWishlist: request.onToggleWishlist,
            onEdit: request.onEdit,
            onCorrectMetadata: request.onCorrectMetadata,
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
            if (request.ownedCopiesSection != null) request.ownedCopiesSection!,
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
