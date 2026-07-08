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
  final entry = request.entry;
  final video = entry.video;
  final editionCount = entry.editions.length;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Title', value: entry.resolvedTitle),
    if (entry.originalTitle?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Original title', value: entry.originalTitle!),
    if (entry.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: entry.publisher!),
    if (entry.releaseDate != null)
      LibraryDetailField(label: 'Release date', value: _formatDate(entry.releaseDate!)),
    if (video?.runtimeMinutes != null)
      LibraryDetailField(label: 'Runtime', value: '${video!.runtimeMinutes} min'),
    if (video?.color?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'HDR / color', value: video!.color!),
    if (video?.screenRatio?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Screen ratio', value: video!.screenRatio!),
    if (video?.audioTracks?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Audio', value: video!.audioTracks!),
    if (video?.subtitles?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Subtitles', value: video!.subtitles!),
    if (video?.layers?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Layers', value: video!.layers!),
    LibraryDetailField(label: 'Releases', value: editionCount.toString()),
    if (entry.barcode?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Barcode', value: entry.barcode!),
    if (entry.country?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Country', value: entry.country!),
    if (entry.language?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Language', value: entry.language!),
    if (entry.ageRating?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Age rating', value: entry.ageRating!),
    if (entry.audienceRating?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Audience rating', value: entry.audienceRating!),
    if (entry.trailerUrls.isNotEmpty)
      LibraryDetailField(label: 'Trailers', value: entry.trailerUrls.length.toString()),
    LibraryDetailField(label: 'Cover', value: entry.hasMissingCover ? 'Missing' : 'Ready'),
    LibraryDetailField(label: 'Metadata', value: entry.hasMissingMetadata ? 'Missing' : 'Ready'),
  ];

  final sections = <Widget>[
    InspectorMetadataFactsSection(
      title: 'Movie details',
      accent: request.accent,
      facts: facts,
      children: [
        if (entry.synopsis?.trim().isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              entry.synopsis!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    ),
    if (entry.editions.isNotEmpty || video?.nrDiscs != null)
      InspectorReleasesSection(request: request),
    if ((entry.creators ?? const <Map<String, dynamic>>[]).isNotEmpty)
      InspectorContributorsSection(request: request),
    if (entry.trailerUrls.isNotEmpty)
      InspectorLinksTrailersSection(request: request),
    if (request.ownedItem != null || request.trackingEntry != null)
      InspectorPersonalStatusSection(
        entry: entry,
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
    final entry = request.inspector.entry;
    final accent = request.inspector.accent;
    final sections = buildMovieInspectorSections(context, request.inspector);

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
      hero: LibraryDetailHero(
        type: request.inspector.type,
        entry: entry,
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
            if (request.trailingSections.isNotEmpty) ...request.trailingSections,
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
