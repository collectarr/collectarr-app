import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:flutter/material.dart';

List<Widget> buildMovieInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final item = request.item;
  final dto = item.dto;
  final catalogItem = item.source.catalogItem?.toCatalogItem();
  final editionCount = catalogItem?.editions.length ?? 0;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Title', value: dto.title),
    if (dto.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: dto.publisher!),
    if (dto.releaseDate != null)
      LibraryDetailField(
          label: 'Release date', value: _formatDate(dto.releaseDate!)),
    LibraryDetailField(label: 'Releases', value: editionCount.toString()),
    if (dto.barcode?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Barcode', value: dto.barcode!),
    if (dto.country?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Country', value: dto.country!),
    if (dto.language?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Language', value: dto.language!),
    if (catalogItem?.ageRating?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Age rating', value: catalogItem!.ageRating!),
    if (catalogItem?.audienceRating?.trim().isNotEmpty == true)
      LibraryDetailField(
          label: 'Audience rating', value: catalogItem!.audienceRating!),
    if (catalogItem?.trailerUrls.isNotEmpty == true)
      LibraryDetailField(
          label: 'Trailers', value: catalogItem!.trailerUrls.length.toString()),
  ];

  final sections = <Widget>[
    InspectorMetadataFactsSection(
      title: 'Movie details',
      accent: request.accent,
      facts: facts,
      children: [
        if (catalogItem?.synopsis?.trim().isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              catalogItem!.synopsis!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    ),
    if ((catalogItem?.editions.isNotEmpty ?? false))
      InspectorReleasesSection(request: request),
    if ((catalogItem?.creators ?? const <Map<String, dynamic>>[]).isNotEmpty)
      InspectorContributorsSection(request: request),
    if ((catalogItem?.trailerUrls.isNotEmpty ?? false))
      InspectorLinksTrailersSection(request: request),
    if (request.ownedItem != null || request.trackingEntry != null)
      InspectorPersonalStatusSection(
        item: item,
        ownedItem: request.ownedItem,
        trackingEntry: request.trackingEntry,
        accent: request.accent,
        onFilterByValue: request.onFilterByValue,
      ),
  ];

  return sections;
}

Widget buildMovieInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return _MovieInspectorPanel(request: request);
}

class _MovieInspectorPanel extends StatelessWidget {
  const _MovieInspectorPanel({required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final item = request.inspector.item;
    final accent = request.inspector.accent;
    final sections = buildMovieInspectorSections(context, request.inspector);

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
      hero: LibraryDetailHero(
        type: request.inspector.type,
        item: item,
        ownedItem: request.inspector.ownedItem,
        accent: accent,
      ),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Details',
          children: [
            ...sections,
            if (request.ownedCopiesSection != null) ...[
              request.ownedCopiesSection!,
              const SizedBox(height: 8),
            ],
            if (request.bundleSection != null) ...[
              request.bundleSection!,
              const SizedBox(height: 8),
            ],
            if (request.conditionGradeSection != null) ...[
              request.conditionGradeSection!,
              const SizedBox(height: 8),
            ],
            if (request.trailingSections.isNotEmpty)
              ...request.trailingSections,
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
