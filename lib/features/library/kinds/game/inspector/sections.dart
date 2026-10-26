import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/details/library_trailer_visibility.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/market_links.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/data.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

GameCatalogMetadata? _metadata(LibraryProjectionView item) =>
    switch (item.source.kindPresentationData) {
      GameWorkspaceData data => data.metadata,
      _ => null,
    };

GameLibraryEntry? _entry(LibraryInspectorRequest request) =>
    GameLibraryEntryProjection.fromDispatch(request.libraryEntryDispatch);

Widget buildGameInspectorHero(
        BuildContext context, LibraryInspectorRequest request) =>
    _GameInspectorHeader(inspector: request);

/// Reference details below the header: Description, Trailer and Personal.
List<Widget> buildGameInspectorSections(
    BuildContext context, LibraryInspectorRequest request) {
  final metadata = _metadata(request.item);
  final entry = _entry(request);
  final description =
      (metadata?.synopsis ?? metadata?.description ?? '').trim();
  final trailers = metadata?.links.where((link) => link.isTrailerLink) ??
      const <GameCatalogLink>[];
  final links = metadata?.links.where((link) => link.isExternalLink) ??
      const <GameCatalogLink>[];
  Widget section(String title, Widget child) =>
      LibraryDetailSection(title: title, collapsible: false, children: [child]);
  return [
    if (description.isNotEmpty)
      section(
          'Description',
          AppFormattedText(description,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14, height: 18 / 14))),
    if (trailers.isNotEmpty)
      LibraryTrailerVisibility(
          child: section('Trailer', _GameLinkList(trailers))),
    if (links.isNotEmpty) section('Links', _GameLinkList(links)),
    if (entry != null) section('Personal', _GamePersonalTable(entry: entry)),
  ];
}

class _GameInspectorHeader extends StatelessWidget {
  const _GameInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final metadata = _metadata(inspector.item);
    final entry = _entry(inspector);
    final onFilter = inspector.onFilterByValue;
    final title = metadata?.title ?? inspector.item.dto.primaryLabel;
    final series = metadata?.seriesTitle?.trim() ?? '';
    final platform = metadata?.platforms.firstOrNull?.trim() ?? '';
    final year = metadata?.releaseDateParts?.year;
    final publishers = splitGamePublishers(metadata?.publisher);
    final developers = metadata?.developers ?? const <String>[];
    final summary = [
      (metadata?.physicalFormatLabel ?? metadata?.physicalFormat)?.trim() ?? '',
      metadata?.audienceRating?.trim() ?? '',
    ].where((value) => value.isNotEmpty).join(' | ');
    final genres = metadata?.genres ?? const <String>[];
    final collectionStatus = libraryCollectionStatusFromValue(
      entry?.personal.collectionStatus ??
          (inspector.item.source.isWishlisted ? 'Wish List' : 'In Collection'),
    );
    final hasStatus = entry != null || inspector.item.source.isWishlisted;
    Widget link(String value,
            {double size = 15, FontWeight weight = FontWeight.w400}) =>
        _FilterLink(
          value: value,
          onFilter: onFilter,
          style: TextStyle(
              fontSize: size, fontWeight: weight, color: palette.textPrimary),
        );
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 1),
          child: Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: kAppBoldFontWeight,
                  color: palette.textMuted)),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (series.isNotEmpty) link(series, weight: kAppBoldFontWeight),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 24,
                    height: 27 / 24,
                    fontWeight: kAppBoldFontWeight,
                    color: palette.itemTitle)),
          ),
          if (hasStatus)
            Tooltip(
              message: collectionStatus.label,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8, top: 2),
                decoration: BoxDecoration(
                  color: collectionStatus.color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child:
                    Icon(collectionStatus.icon, size: 18, color: Colors.white),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 210, maxHeight: 300),
          child: LibraryCoverImage(
            title: title,
            imageUrl: metadata?.coverImageUrl,
            libraryEntryRef: entry == null
                ? null
                : LibraryEntryRef(kind: CatalogMediaKind.game, id: entry.id),
            fallbackAspectRatio: 0.7,
            borderRadius: 0,
          ),
        ),
        if (platform.isNotEmpty || year != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (platform.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: PlatformIcon(platform,
                          size: 24, color: palette.textPrimary),
                    ),
                  if (platform.isNotEmpty)
                    link(platform, weight: kAppBoldFontWeight),
                  if (year != null) link('($year)', weight: kAppBoldFontWeight),
                ]),
          ),
        if (publishers.isNotEmpty) ...[
          label('Publisher'),
          for (final name in publishers) link(name),
        ],
        if (developers.isNotEmpty) ...[
          label('Developer'),
          for (final name in developers) link(name),
        ],
        if (summary.isNotEmpty || genres.isNotEmpty) const SizedBox(height: 18),
        if (summary.isNotEmpty)
          Text(summary,
              style: TextStyle(fontSize: 14, color: palette.textPrimary)),
        if (genres.isNotEmpty)
          Wrap(spacing: 4, children: [
            for (final (index, genre) in genres.indexed) ...[
              if (index > 0)
                Text('|', style: TextStyle(color: palette.textMuted)),
              link(genre, size: 14),
            ],
          ]),
        if (entry != null) _GameValueBadge(entry: entry),
        _GameEbayLink(
            query: [title, if (platform.isNotEmpty) platform].join(' '),
            isWishlisted: inspector.item.source.isWishlisted),
      ]),
    );
  }
}

/// The reference's eBay link under the value box ("next to cover").
class _GameEbayLink extends ConsumerWidget {
  const _GameEbayLink({required this.query, required this.isWishlisted});

  final String query;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(uiPreferencesProvider).ebayNextToCover) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: GameEbaySoldLink(query: query, isWishlisted: isWishlisted),
    );
  }
}

/// "CIB | $ 17.58" with what the tier includes, as in the reference.
class _GameValueBadge extends StatelessWidget {
  const _GameValueBadge({required this.entry});

  final GameLibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final personal = entry.personal;
    final headline = gameValueSummary(personal);
    if (headline == null) return const SizedBox.shrink();
    final includes =
        switch ((personal.details.hasBox, personal.details.hasManual)) {
      (true, true) => 'Includes box & manual',
      (true, _) => 'Includes box',
      (_, true) => 'Includes manual',
      _ => null,
    };
    const border = Color(0xFF0082A6);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: border,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text(headline,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: kAppBoldFontWeight,
                  color: Colors.white)),
        ),
        if (includes != null)
          Container(
            color: const Color(0xFFB1D8EA),
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            child: Text(includes,
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          ),
        if (personal.details.valuations != null)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            child: GamePriceChartingLink(
              label: 'Values by PriceCharting',
              priceChartingId: personal.details.priceChartingId,
              fontSize: 14,
              plainStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF3680A3)),
            ),
          ),
      ]),
    );
  }
}

class _GamePersonalTable extends StatelessWidget {
  const _GamePersonalTable({required this.entry});

  final GameLibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final personal = entry.personal;
    final details = personal.details;
    final rows = <(String, String)>[
      (
        'Value',
        personal.marketValueCents == null
            ? '-'
            : AppFormats.current.formatMoney(personal.marketValueCents,
                personal.currency ?? AppFormats.current.currency)
      ),
      ('Index', personal.indexNumber?.toString() ?? '-'),
      // The reference marks completion with a check or a cross.
      ('Completed', details.completed == true ? '✓' : '✕'),
      if (details.completedDate?.isoString case final date?)
        ('Completed Date', date),
      if (personal.rating != null) ('My Rating', '${personal.rating}/10'),
      if (details.storageDevice?.trim().isNotEmpty == true)
        ('Storage Device', details.storageDevice!),
      if (details.storageSlot?.trim().isNotEmpty == true)
        ('Storage Slot', details.storageSlot!),
      if (entry.createdAt case final created?)
        ('Added Date', AppFormats.current.formatDateTime(created)),
      ('Modified Date', AppFormats.current.formatDateTime(entry.updatedAt)),
    ];
    return LibraryDetailFieldTable(
      minCellWidth: 320,
      labelWidth: 132,
      showHeader: false,
      fields: [
        for (final row in rows) LibraryDetailField(label: row.$1, value: row.$2)
      ],
    );
  }
}

class _GameLinkList extends StatelessWidget {
  const _GameLinkList(this.links);

  final Iterable<GameCatalogLink> links;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final link in links)
            InkWell(
              onTap: () => launchUrl(Uri.parse(link.url)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(link.title ?? link.label ?? link.url,
                    style: TextStyle(
                        fontSize: 14, color: appPalette(context).link)),
              ),
            ),
        ],
      );
}

class _FilterLink extends StatelessWidget {
  const _FilterLink(
      {required this.value, required this.onFilter, required this.style});

  final String value;
  final ValueChanged<String>? onFilter;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: onFilter == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onFilter == null ? null : () => onFilter!(value),
          child: Text(value, style: style),
        ),
      );
}
