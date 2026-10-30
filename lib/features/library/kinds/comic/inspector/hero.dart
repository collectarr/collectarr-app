import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildComicCatalogItemInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    ComicInspectorHeader(request: request);

Widget buildComicLibraryEntryInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    ComicInspectorHeader(request: request);

ComicCatalogItem? comicInspectorItem(LibraryInspectorRequest request) =>
    switch (request.item.dto) {
      final ComicWorkspaceDto dto => dto.comic,
      _ => null,
    };

ComicLibraryEntry? comicInspectorEntry(LibraryInspectorRequest request) =>
    ComicLibraryEntryProjection.fromDispatch(request.libraryEntryDispatch);

/// The reference details header: series and issue badge, story arc and
/// title, key reason, then the cover beside variant, dates, publisher,
/// barcode and eBay, and the Collection Status beside the plot.
class ComicInspectorHeader extends StatelessWidget {
  const ComicInspectorHeader({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final comic = comicInspectorItem(request);
    final entry = comicInspectorEntry(request);
    final series = comic?.seriesTitle?.trim() ?? '';
    final title = comic?.title.trim() ?? '';
    final heading = series.isNotEmpty
        ? series
        : (title.isNotEmpty ? title : request.item.dto.primaryLabel);
    final issue =
        '${comic?.issueNumber?.trim() ?? ''}${comic?.variant?.trim() ?? ''}';
    final subtitle = [
      ...?comic?.storyArcs
          .map((arc) => arc.name?.trim() ?? '')
          .where((name) => name.isNotEmpty),
      if (title.isNotEmpty && title != heading) title,
      if (comic?.subtitle?.trim() case final value? when value.isNotEmpty)
        value,
    ].join(' - ');
    final keyReason = entry?.personal.details.keyReason?.trim() ?? '';
    final onFilter = request.onFilterByValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _FilterText(
              value: heading,
              filterValue: series.isEmpty ? null : series,
              onFilter: onFilter,
              style: TextStyle(
                  fontSize: 24,
                  height: 27 / 24,
                  fontWeight: kAppBoldFontWeight,
                  color: palette.detailHeading),
            ),
          ),
          if (issue.isNotEmpty) _IssueBadge('#$issue'),
        ]),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle,
                style: TextStyle(fontSize: 16, color: palette.textMuted)),
          ),
        if (keyReason.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 22,
                height: 18,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: palette.textMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.vpn_key, size: 12, color: Colors.white),
              ),
              Expanded(
                child: Text(keyReason,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: kAppBoldFontWeight,
                        color: palette.textPrimary)),
              ),
            ]),
          ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final cover = _ComicCover(
              title: heading, comic: comic, entry: entry, width: 140);
          final facts = _ComicFacts(
              comic: comic,
              onFilter: onFilter,
              ebayQuery: '$heading #$issue',
              isWishlisted: request.item.source.isWishlisted);
          final plot = _ComicStatusAndPlot(comic: comic, entry: entry);
          if (constraints.maxWidth < 560) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    cover,
                    const SizedBox(width: 12),
                    Expanded(child: facts),
                  ]),
                  const SizedBox(height: 12),
                  plot,
                ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            cover,
            const SizedBox(width: 12),
            SizedBox(width: 190, child: facts),
            const SizedBox(width: 12),
            Expanded(child: plot),
          ]);
        }),
      ]),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  const _IssueBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: palette.textPrimary, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: kAppBoldFontWeight,
              color: palette.textPrimary)),
    );
  }
}

class _ComicCover extends StatelessWidget {
  const _ComicCover({
    required this.title,
    required this.comic,
    required this.entry,
    required this.width,
  });

  final String title;
  final ComicCatalogItem? comic;
  final ComicLibraryEntry? entry;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: LibraryCoverImage(
          title: title,
          imageUrl: comic?.coverImageUrl,
          libraryEntryRef: entry == null
              ? null
              : LibraryEntryRef(kind: CatalogMediaKind.comic, id: entry!.id),
          fallbackAspectRatio: 0.66,
          borderRadius: 0,
        ),
      );
}

/// Variant, Release and Cover dates, publisher, barcode and the eBay link.
class _ComicFacts extends ConsumerWidget {
  const _ComicFacts({
    required this.comic,
    required this.onFilter,
    required this.ebayQuery,
    required this.isWishlisted,
  });

  final ComicCatalogItem? comic;
  final ValueChanged<String>? onFilter;
  final String ebayQuery;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final bold = TextStyle(
        fontSize: 15,
        fontWeight: kAppBoldFontWeight,
        color: palette.textPrimary);
    final variant = comic?.variantDescription?.trim() ?? '';
    final release = _date(comic?.releaseDateParts, comic?.releaseDate);
    final cover = _date(comic?.coverDateParts, comic?.coverDate);
    final publisher = comic?.publisher?.trim() ?? '';
    final imprint = comic?.imprint?.trim() ?? '';
    final barcode = comic?.barcode?.trim() ?? '';
    Widget dated(String label, String value) => Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(children: [
            SizedBox(width: 66, child: Text('$label:', style: bold)),
            Expanded(child: Text(value, style: bold)),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (variant.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(variant, style: bold),
        ),
      if (release.isNotEmpty) dated('Release', release),
      if (cover.isNotEmpty) dated('Cover', cover),
      for (final name in [publisher, imprint])
        if (name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _FilterText(
                value: name,
                onFilter: onFilter,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: kAppBoldFontWeight,
                    color: palette.textPrimary)),
          ),
      if (barcode.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Icon(AppIcons.barcode, size: 14, color: palette.textPrimary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(barcode,
                  style: TextStyle(fontSize: 14, color: palette.textPrimary)),
            ),
          ]),
        ),
      if (ref.watch(uiPreferencesProvider) case final preferences
          when preferences.ebayNextToCover &&
              preferences.allowsEbayLinks(isWishlisted))
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () =>
                  launchEbaySearch(ebayQuery, isWishlisted: isWishlisted),
              child: Text('Find sold listings on eBay',
                  style: TextStyle(
                      fontSize: 14,
                      color: palette.link,
                      decoration: TextDecoration.underline,
                      decorationColor: palette.link)),
            ),
          ),
        ),
    ]);
  }
}

/// The collection copy's Collection Status, then the plot.
class _ComicStatusAndPlot extends StatelessWidget {
  const _ComicStatusAndPlot({required this.comic, required this.entry});

  final ComicCatalogItem? comic;
  final ComicLibraryEntry? entry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final plot = [comic?.synopsis, comic?.description]
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet();
    final status = entry == null
        ? null
        : libraryCollectionStatusFromValue(entry!.personal.collectionStatus);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (status != null)
        Tooltip(
          message: status.label,
          child:
              LibraryCollectionStatusIcon(collectionStatus: status, size: 30),
        ),
      for (final text in plot)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AppFormattedText(text,
              textAlign: TextAlign.justify,
              style: TextStyle(
                  fontSize: 14, height: 18 / 14, color: palette.textPrimary)),
        ),
    ]);
  }
}

class _FilterText extends StatelessWidget {
  const _FilterText({
    required this.value,
    required this.onFilter,
    required this.style,
    String? filterValue,
  }) : filterValue = filterValue ?? value;

  final String value;
  final String? filterValue;
  final ValueChanged<String>? onFilter;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final onTap = onFilter == null || filterValue == null
        ? null
        : () => onFilter!(filterValue!);
    return MouseRegion(
      cursor:
          onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: Text(value, style: style)),
    );
  }
}

String _date(PartialDate? parts, DateTime? date) {
  final value = parts ?? (date == null ? null : PartialDate.fromDateTime(date));
  return value == null ? '' : AppFormats.current.formatPartialDate(value);
}
