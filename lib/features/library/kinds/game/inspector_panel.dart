import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_inspector_info_line.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildGameInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return GameInspectorPanel(request: request);
}

List<Widget> buildGameInspectorSections(
  BuildContext context,
  LibraryInspectorRequest inspector,
) {
  final specs = _buildGameSectionSpecs(context, inspector);
  return [
    for (final spec in specs) ...spec.children,
  ];
}

class GameInspectorPanel extends StatelessWidget {
  const GameInspectorPanel({super.key, required this.request});

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
      hero: _GameInspectorHeader(inspector: request.inspector),
      sections: [
        ..._buildGameSectionSpecs(context, request.inspector),
        if (request.primarySections.isNotEmpty)
          LibraryDetailSectionSpec(
            slot: LibraryDetailSectionSlot.formatEditionRelease,
            title: 'Primary',
            children: request.primarySections,
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

List<LibraryDetailSectionSpec> _buildGameSectionSpecs(
  BuildContext context,
  LibraryInspectorRequest inspector,
) {
  final creditRows = libraryCreatorsGroupedByRole(
    _gameMetadata(inspector.item)?.creators,
  );
  final sections = <LibraryDetailSectionSpec>[
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Details',
      children: [
        _GameInspectorMain(inspector: inspector),
        const SizedBox(height: 10),
        _GameInspectorDetailsPersonal(inspector: inspector),
      ],
    ),
    if (creditRows.isNotEmpty)
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.people,
        title: 'Credits',
        children: [
          _GameInspectorFactRows(rows: creditRows),
        ],
      ),
  ];
  return sections;
}

class _GameInspectorHeader extends StatelessWidget {
  const _GameInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final dto = inspector.item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final series = adapter?.seriesTitle?.trim();
    return LibraryInspectorTitleCard(
      item: inspector.item,
      eyebrow: series,
      accent: inspector.accent,
    );
  }
}

class _GameInspectorMain extends StatelessWidget {
  const _GameInspectorMain({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final item = inspector.item;
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final metadata = _gameMetadata(item);
    final palette = appPalette(context);
    final releaseYear = adapter?.releaseDate?.year.toString();
    final genres = metadata?.genres;
    final genreText =
        genres == null || genres.isEmpty ? null : genres.join(' | ');
    final platforms = metadata?.platforms ?? const <String>[];

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
                  itemNumber: adapter?.itemNumber,
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
                  if (adapter?.publisher?.isNotEmpty == true ||
                      releaseYear != null)
                    Text(
                      [
                        if (adapter?.publisher?.isNotEmpty == true)
                          adapter!.publisher!,
                        if (releaseYear != null) '($releaseYear)',
                      ].join(' '),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  if (genreText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      genreText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (adapter?.referenceFormatLabel?.trim().isNotEmpty ==
                          true ||
                      adapter?.variant?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.album_outlined,
                      text: adapter?.referenceFormatLabel ??
                          adapter?.variant ??
                          '-',
                    ),
                  if (platforms.isNotEmpty)
                    LibraryInspectorInfoLine(
                      icon: Icons.sports_esports_outlined,
                      text: platforms.join(' | '),
                    ),
                  if (metadata?.ageRating?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.shield_outlined,
                      text: 'Age rating: ${metadata!.ageRating!}',
                    ),
                  if (adapter?.barcode?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.qr_code_2,
                      text: adapter!.barcode!,
                    ),
                  if (_ebayUri(item) case final uri?) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 13,
                              color: palette.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Search eBay',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: palette.textMuted,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ],
                        ),
                      ),
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

class _GameInspectorDetailsPersonal extends StatelessWidget {
  const _GameInspectorDetailsPersonal({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final item = inspector.item;
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final metadata = _gameMetadata(item);
    final owned = item.source.ownedItem;
    final releaseYear = adapter?.releaseDate?.year;
    final detailRows = <(String, String)>[
      if (adapter?.publisher?.trim().isNotEmpty == true)
        ('Publisher', adapter!.publisher!),
      if (adapter?.releaseDate != null || releaseYear != null)
        (
          'Release',
          formatNullableDate(adapter?.releaseDate) ?? releaseYear!.toString(),
        ),
      if (adapter?.referenceFormatLabel?.trim().isNotEmpty == true ||
          adapter?.variant?.trim().isNotEmpty == true)
        ('Format', adapter?.referenceFormatLabel ?? adapter?.variant ?? '-'),
      if (metadata?.ageRating?.trim().isNotEmpty == true)
        ('Age rating', metadata!.ageRating!),
      if (adapter?.country?.trim().isNotEmpty == true)
        ('Country', adapter!.country!),
      if (adapter?.language?.trim().isNotEmpty == true)
        ('Language', adapter!.language!),
      if (metadata?.platforms.isNotEmpty == true)
        ('Platforms', metadata!.platforms.join(', ')),
      if (metadata?.toySubtype?.trim().isNotEmpty == true)
        ('Subtype', metadata!.toySubtype!),
      if (metadata?.toyType?.trim().isNotEmpty == true)
        ('Type', metadata!.toyType!),
      if (adapter?.barcode?.trim().isNotEmpty == true)
        ('Barcode', adapter!.barcode!),
      if (metadata?.genres.isNotEmpty == true)
        ('Genres', metadata!.genres.join(', ')),
      if (item.source.tags?.trim().isNotEmpty == true)
        ('Tags', item.source.tags!),
    ];
    final personalRows = <(String, String)>[
      if (owned?.condition?.trim().isNotEmpty == true)
        ('Condition', owned!.condition!),
      if (item.source.ownedItem?.collectionStatus?.trim().isNotEmpty == true)
        ('Collection status', item.source.ownedItem!.collectionStatus!),
      if (item.source.locationPath?.trim().isNotEmpty == true)
        ('Location', item.source.locationPath!),
      if (owned?.musicDetails?.storageDevice?.trim().isNotEmpty == true)
        ('Storage device', owned!.musicDetails!.storageDevice!),
      if (owned?.musicDetails?.storageSlot?.trim().isNotEmpty == true)
        ('Storage slot', owned!.musicDetails!.storageSlot!),
      if (owned?.ownerLabel?.trim().isNotEmpty == true)
        ('Owner', owned!.ownerLabel!),
      if (owned?.pricePaidCents != null)
        ('Price paid', formatMoney(owned!.pricePaidCents, owned.currency)),
      if (owned?.marketValueCents != null)
        ('Current value', formatMoney(owned!.marketValueCents, owned.currency)),
      if (owned?.purchaseDate != null)
        ('Purchase date', formatDate(owned!.purchaseDate!)),
      if (owned?.purchaseStore?.trim().isNotEmpty == true)
        ('Purchase store', owned!.purchaseStore!),
      if (item.source.ownedItem?.createdAt != null)
        ('Added', formatDate(item.source.ownedItem!.createdAt!)),
      ('Modified', formatDate(item.source.updatedAt)),
    ];
    final creditRows = libraryCreatorsGroupedByRole(metadata?.creators);

    return Column(
      children: [
        LibraryDetailSection(
          title: 'Info',
          accentColor: inspector.accent,
          children: [
            _GameInspectorFactRows(rows: detailRows),
          ],
        ),
        LibraryDetailSection(
          title: 'Personal',
          accentColor: inspector.accent,
          children: [
            _GameInspectorFactRows(rows: personalRows),
          ],
        ),
        LibraryDetailSection(
          title: 'Credits',
          accentColor: inspector.accent,
          children: [
            _GameInspectorFactRows(rows: creditRows),
          ],
        ),
      ],
    );
  }
}

GameCatalogMetadata? _gameMetadata(LibraryProjectionRuntime item) {
  final metadata = item.source.catalogItem?.kindMetadata;
  return metadata is GameCatalogMetadata ? metadata : null;
}

class _GameInspectorFactRows extends StatelessWidget {
  const _GameInspectorFactRows({
    required this.rows,
  });

  final List<(String label, String value)> rows;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isEmpty)
          Text(
            '-',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
          )
        else
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      row.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

Uri? _ebayUri(LibraryProjectionRuntime item) {
  final dto = item.dto;
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;
  final seriesTitle = adapter?.seriesTitle;
  final query = <String>[
    if (adapter?.barcode?.trim().isNotEmpty == true) adapter!.barcode!.trim(),
    dto.title,
    if (seriesTitle?.trim().isNotEmpty == true) seriesTitle!.trim(),
    if (adapter?.releaseDate != null) adapter!.releaseDate!.year.toString(),
  ].join(' ');
  if (query.trim().isEmpty) {
    return null;
  }
  return buildEbaySearchUri(
    query: query,
    categoryPath: '/sch/139973/i.html',
    soldOnly: true,
  );
}
