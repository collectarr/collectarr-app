import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_inspector_info_line.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/inspector_sections.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildBoardGameInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return BoardGameInspectorPanel(request: request);
}

List<Widget> buildBoardGameWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest inspector,
) {
  return [
    _BoardGameInspectorMain(inspector: inspector),
    BoardGamePlayStatsSection(request: inspector),
  ];
}

List<Widget> buildBoardGameReleaseInspectorSections(
  BuildContext context,
  LibraryInspectorRequest inspector,
) {
  return [
    _BoardGameInspectorMain(inspector: inspector),
  ];
}

List<Widget> buildBoardGameCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest inspector,
) {
  return [
    _BoardGameInspectorMain(inspector: inspector),
    if (inspector.ownedItem != null || inspector.trackingSummary != null)
      InspectorPersonalStatusSection(
        type: inspector.type,
        item: inspector.item,
        ownedItem: inspector.ownedItem,
        ownedItemDispatch: inspector.ownedItemDispatch,
        trackingSummary: inspector.trackingSummary,
        accent: inspector.accent,
        onFilterByValue: inspector.onFilterByValue,
      ),
  ];
}

Widget buildBoardGameWorkInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    LibraryDetailHero(
      type: request.type,
      item: request.item,
      ownedItem: request.ownedItem,
      ownedCopies: request.ownedCopies,
      accent: request.accent,
    );

Widget buildBoardGameReleaseInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    LibraryDetailHero(
      type: request.type,
      item: request.item,
      ownedItem: request.ownedItem,
      ownedCopies: request.ownedCopies,
      accent: request.accent,
    );

Widget buildBoardGameCopyInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    LibraryDetailHero(
      type: request.type,
      item: request.item,
      ownedItem: request.ownedItem,
      ownedCopies: [
        if (request.ownedItem != null) request.ownedItem!,
      ],
      accent: request.accent,
    );

class BoardGameInspectorPanel extends StatelessWidget {
  const BoardGameInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final item = request.inspector.item;
    final accent = request.inspector.accent;

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
      hero: _BoardGameInspectorHeader(inspector: request.inspector),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Details',
          children: [
            _BoardGameInspectorMain(inspector: request.inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.relations,
          title: 'Play stats',
          children: [
            BoardGamePlayStatsSection(request: request.inspector),
          ],
        ),
        if (request.trailingSections.isNotEmpty)
          LibraryDetailSectionSpec(
            slot: LibraryDetailSectionSlot.activity,
            title: 'More',
            children: request.trailingSections,
          ),
      ],
    );
  }
}

class _BoardGameInspectorHeader extends StatelessWidget {
  const _BoardGameInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final item = inspector.item;
    final adapter = item.dto is BoardGameWorkspaceDto
        ? item.dto as BoardGameWorkspaceDto
        : null;
    final seriesTitle = adapter?.seriesTitle?.trim();
    return LibraryInspectorTitleCard(
      item: item,
      eyebrow: seriesTitle,
      accent: inspector.accent,
    );
  }
}

class _BoardGameInspectorMain extends StatelessWidget {
  const _BoardGameInspectorMain({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final item = inspector.item;
    final dto = item.dto;
    final adapter = dto is BoardGameWorkspaceDto ? dto : null;
    final bgDto = dto is BoardGameWorkspaceDto ? dto : null;
    final metadata = item.source.catalogData is BoardGameWorkspaceCatalogData
        ? (item.source.catalogData! as BoardGameWorkspaceCatalogData).metadata
        : null;
    final palette = appPalette(context);
    final releaseYear = adapter?.releaseDate?.year.toString();
    final creatorsList = metadata?.creators
            .map((Map<String, dynamic> c) => (c['name'] ?? '').toString())
            .where((n) => n.trim().isNotEmpty)
            .toList() ??
        const [];
    final designerText = _joinNonEmpty(creatorsList);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 164,
                height: 164,
                child: LibraryInteractiveCover(
                  title: dto.primaryLabel,
                  itemNumber: adapter?.itemNumber,
                  imageUrl: dto.imageUrl,
                  accentColor: inspector.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bgDto?.publisher?.isNotEmpty == true ||
                      releaseYear != null)
                    Text(
                      [
                        if (bgDto?.publisher?.isNotEmpty == true)
                          bgDto!.publisher!,
                        if (releaseYear != null) '($releaseYear)',
                      ].join(' '),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  const SizedBox(height: 8),
                  if (adapter?.referenceFormatLabel?.trim().isNotEmpty ==
                          true ||
                      adapter?.variant?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.casino_outlined,
                      text: adapter?.referenceFormatLabel ??
                          adapter?.variant ??
                          '-',
                    ),
                  if (designerText != null)
                    LibraryInspectorInfoLine(
                      icon: Icons.design_services_outlined,
                      text: designerText,
                    ),
                  if (bgDto?.barcode?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.qr_code_2,
                      text: bgDto!.barcode!,
                    ),
                  if (_ebayUri(item) case final uri?) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      mouseCursor: WidgetStateMouseCursor.clickable,
                      onTap: () => launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: palette.divider),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'Search on eBay',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (metadata?.synopsis?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Text(
                      metadata!.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Uri? _ebayUri(LibraryProjectionView item) {
  final title = item.dto.primaryLabel.trim();
  if (title.isEmpty) {
    return null;
  }
  return buildEbaySearchUri(query: title);
}

String? _joinNonEmpty(Iterable<String> values) {
  final normalized = [
    for (final value in values)
      if (value.trim().isNotEmpty) value.trim(),
  ];
  if (normalized.isEmpty) {
    return null;
  }
  return normalized.join(' | ');
}
