import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_inspector_info_line.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/inspector_sections.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
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
          slot: LibraryDetailSectionSlot.people,
          title: 'Play stats',
          children: [
            BoardGamePlayStatsSection(request: request.inspector),
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

class _BoardGameInspectorHeader extends StatelessWidget {
  const _BoardGameInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final item = inspector.item;
    final seriesTitle = item.dto.seriesTitle?.trim();
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
    final catalogItem = item.source.catalogItem?.toCatalogItem();
    final palette = appPalette(context);
    final releaseYear = dto.releaseDate?.year.toString();
    final creatorsList = catalogItem?.creators
            ?.map((Map<String, dynamic> c) => (c['name'] ?? '').toString())
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
                  title: dto.title,
                  itemNumber: dto.itemNumber,
                  imageUrl: dto.coverImageUrl,
                  accentColor: inspector.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dto.publisher?.isNotEmpty == true || releaseYear != null)
                    Text(
                      [
                        if (dto.publisher?.isNotEmpty == true) dto.publisher!,
                        if (releaseYear != null) '($releaseYear)',
                      ].join(' '),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  const SizedBox(height: 8),
                  if (dto.referenceFormatLabel?.trim().isNotEmpty == true ||
                      dto.variant?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.casino_outlined,
                      text: dto.referenceFormatLabel ?? dto.variant ?? '-',
                    ),
                  if (designerText != null)
                    LibraryInspectorInfoLine(
                      icon: Icons.design_services_outlined,
                      text: designerText,
                    ),
                  if (dto.barcode?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.qr_code_2,
                      text: dto.barcode!,
                    ),
                  if (_ebayUri(item) case final uri?) ...[
                    const SizedBox(height: 8),
                    InkWell(
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
                  if (catalogItem?.synopsis?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Text(
                      catalogItem!.synopsis!,
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

Uri? _ebayUri(LibraryProjectionRuntime item) {
  final title = item.dto.title.trim();
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
