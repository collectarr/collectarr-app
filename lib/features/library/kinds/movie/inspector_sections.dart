import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:flutter/material.dart';

List<Widget> buildMovieInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMovieEntitySections(
    context,
    request,
    includeReleaseList: true,
    includePersonalStatus: true,
  );
}

List<Widget> buildMovieWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMovieEntitySections(
    context,
    request,
    includeReleaseList: true,
    includePersonalStatus: false,
  );
}

List<Widget> buildMovieReleaseInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMovieEntitySections(
    context,
    request,
    includeReleaseList: false,
    includePersonalStatus: false,
  );
}

List<Widget> buildMovieCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMovieEntitySections(
    context,
    request,
    includeReleaseList: false,
    includePersonalStatus: true,
  );
}

List<Widget> _buildMovieEntitySections(
  BuildContext context,
  LibraryInspectorRequest request, {
  required bool includeReleaseList,
  required bool includePersonalStatus,
}) {
  final item = request.item;
  final dto = item.dto;
  final adapter = dto is MovieWorkspaceDto ? dto : null;
  final movieDto = dto is MovieWorkspaceDto ? dto : null;
  final metadata = item.source.catalogData is MovieWorkspaceCatalogData
      ? (item.source.catalogData! as MovieWorkspaceCatalogData).metadata
      : null;
  final editionCount = metadata?.releases.length ?? 0;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Title', value: dto.primaryLabel),
    if (movieDto?.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: movieDto!.publisher!),
    if (adapter?.releaseDate != null)
      LibraryDetailField(
          label: 'Release date', value: _formatDate(adapter!.releaseDate!)),
    if (includeReleaseList)
      LibraryDetailField(label: 'Releases', value: editionCount.toString()),
    if (movieDto?.barcode?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Barcode', value: movieDto!.barcode!),
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
    if (includeReleaseList && (metadata?.releases.isNotEmpty ?? false))
      InspectorReleasesSection(request: request),
    if ((metadata?.creators ?? const <Map<String, dynamic>>[]).isNotEmpty)
      InspectorContributorsSection(request: request),
    if ((metadata?.links.isNotEmpty ?? false))
      InspectorLinksTrailersSection(request: request),
    if (includePersonalStatus &&
        (request.ownedItem != null || request.trackingSummary != null))
      InspectorPersonalStatusSection(
        type: request.type,
        item: item,
        ownedItem: request.ownedItem,
        trackingSummary: request.trackingSummary,
        accent: request.accent,
        onFilterByValue: request.onFilterByValue,
      ),
  ];

  return sections;
}

Widget buildMovieWorkInspectorHero(
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

Widget buildMovieReleaseInspectorHero(
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

Widget buildMovieCopyInspectorHero(
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
