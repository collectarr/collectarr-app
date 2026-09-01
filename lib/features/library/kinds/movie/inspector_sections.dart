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
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

List<Widget> buildMovieInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final item = request.item;
  final dto = item.dto;
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;
  final kindMetadata = item.source.catalogItem?.kindMetadata;
  final metadata = kindMetadata is MovieCatalogMetadata ? kindMetadata : null;
  final editionCount = metadata?.releases.length ?? 0;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Title', value: dto.title),
    if (adapter?.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: adapter!.publisher!),
    if (adapter?.releaseDate != null)
      LibraryDetailField(
          label: 'Release date', value: _formatDate(adapter!.releaseDate!)),
    LibraryDetailField(label: 'Releases', value: editionCount.toString()),
    if (adapter?.barcode?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Barcode', value: adapter!.barcode!),
    if (adapter?.country?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Country', value: adapter!.country!),
    if (adapter?.language?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Language', value: adapter!.language!),
    if (metadata?.ageRating?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Age rating', value: metadata!.ageRating!),
    if (metadata?.audienceRating?.trim().isNotEmpty == true)
      LibraryDetailField(
          label: 'Audience rating', value: metadata!.audienceRating!),
    if (metadata?.trailerUrls.isNotEmpty == true)
      LibraryDetailField(
          label: 'Trailers', value: metadata!.trailerUrls.length.toString()),
  ];

  final sections = <Widget>[
    InspectorMetadataFactsSection(
      title: 'Movie details',
      accent: request.accent,
      facts: facts,
      children: [
        if (metadata?.synopsis?.trim().isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              metadata!.synopsis!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    ),
    if ((metadata?.releases.isNotEmpty ?? false))
      InspectorReleasesSection(request: request),
    if ((metadata?.creators ?? const <Map<String, dynamic>>[]).isNotEmpty)
      InspectorContributorsSection(request: request),
    if ((metadata?.links.isNotEmpty ?? false))
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
