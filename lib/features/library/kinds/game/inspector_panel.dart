import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_inspector_info_line.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
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
  return buildLibraryDetailSectionWidgets(
    _buildGameSectionSpecs(context, inspector),
    accentColor: inspector.accent,
  );
}

class GameInspectorPanel extends StatelessWidget {
  const GameInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.inspector.entry;
    final accent = request.inspector.accent;

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
  final creditRows = libraryCreatorsGroupedByRole(inspector.entry.creators);
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
    final entry = inspector.entry;
    final series = entry.series?.seriesTitle?.trim();
    return LibraryInspectorTitleCard(
      entry: entry,
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
    final entry = inspector.entry;
    final palette = appPalette(context);
    final releaseYear = entry.releaseYear?.toString();
    final genreText = entry.genres == null || entry.genres!.isEmpty
        ? null
        : entry.genres!.join(' | ');
    final platforms = entry.game?.platforms.isNotEmpty == true
        ? entry.game!.platforms
        : entry.rawPlatforms ?? const <String>[];

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
                  title: entry.resolvedTitle,
                  itemNumber: entry.itemNumber,
                  imageUrl: entry.displayCoverUrl,
                  accentColor: inspector.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.publisher?.isNotEmpty == true ||
                      releaseYear != null)
                    Text(
                      [
                        if (entry.publisher?.isNotEmpty == true)
                          entry.publisher!,
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
                  if (entry.referenceFormatLabel?.trim().isNotEmpty == true ||
                      entry.variant?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.album_outlined,
                      text: entry.referenceFormatLabel ?? entry.variant ?? '-',
                    ),
                  if (platforms.isNotEmpty)
                    LibraryInspectorInfoLine(
                      icon: Icons.sports_esports_outlined,
                      text: platforms.join(' | '),
                    ),
                  if (entry.audienceRating?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.shield_outlined,
                      text: 'Audience: ${entry.audienceRating!}',
                    ),
                  if (entry.barcode?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.qr_code_2,
                      text: entry.barcode!,
                    ),
                  if (_ebayUri(entry) case final uri?) ...[
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
                          color: palette.panel,
                          border: Border.all(color: palette.divider),
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            'Find sold listings on eBay',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
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
    final entry = inspector.entry;
    final owned = inspector.ownedItem;
    final detailRows = <(String, String)>[
      if (entry.publisher?.trim().isNotEmpty == true)
        ('Publisher', entry.publisher!),
      if (entry.releaseDate != null || entry.releaseYear != null)
        (
          'Release',
          formatNullableDate(entry.releaseDate) ??
              entry.releaseYear!.toString(),
        ),
      if (entry.referenceFormatLabel?.trim().isNotEmpty == true ||
          entry.variant?.trim().isNotEmpty == true)
        ('Format', entry.referenceFormatLabel ?? entry.variant ?? '-'),
      if (entry.audienceRating?.trim().isNotEmpty == true)
        ('Audience rating', entry.audienceRating!),
      if (entry.ageRating?.trim().isNotEmpty == true)
        ('Age rating', entry.ageRating!),
      if (entry.country?.trim().isNotEmpty == true) ('Country', entry.country!),
      if (entry.language?.trim().isNotEmpty == true)
        ('Language', entry.language!),
      if (entry.game?.platforms.isNotEmpty == true)
        ('Platforms', entry.game!.platforms.join(', ')),
      if (entry.game?.toySubtype?.trim().isNotEmpty == true)
        ('Subtype', entry.game!.toySubtype!),
      if (entry.game?.toyType?.trim().isNotEmpty == true)
        ('Type', entry.game!.toyType!),
      if (entry.barcode?.trim().isNotEmpty == true) ('Barcode', entry.barcode!),
      if (entry.genres?.isNotEmpty == true)
        ('Genres', entry.genres!.join(', ')),
      if (entry.tags?.trim().isNotEmpty == true) ('Tags', entry.tags!),
    ];
    final personalRows = <(String, String)>[
      if (owned?.condition?.trim().isNotEmpty == true)
        ('Condition', owned!.condition!),
      if (entry.collectionStatus?.trim().isNotEmpty == true)
        ('Collection status', entry.collectionStatus!),
      if (entry.locationPath?.trim().isNotEmpty == true)
        ('Location', entry.locationPath!),
      if (owned?.storageDevice?.trim().isNotEmpty == true)
        ('Storage device', owned!.storageDevice!),
      if (owned?.storageSlot?.trim().isNotEmpty == true)
        ('Storage slot', owned!.storageSlot!),
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
      if (entry.addedAt != null) ('Added', formatDate(entry.addedAt!)),
      ('Modified', formatDate(entry.updatedAt)),
    ];
    final creditRows = libraryCreatorsGroupedByRole(entry.creators);

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
Uri? _ebayUri(LibraryWorkspaceEntry entry) {
  final query = <String>[
    if (entry.barcode?.trim().isNotEmpty == true) entry.barcode!.trim(),
    entry.resolvedTitle,
    if (entry.series?.seriesTitle?.trim().isNotEmpty == true)
      entry.series!.seriesTitle!.trim(),
    if (entry.releaseYear != null) entry.releaseYear.toString(),
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

