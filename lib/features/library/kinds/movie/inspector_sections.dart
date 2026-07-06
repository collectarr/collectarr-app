import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

List<Widget> buildMovieInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final entry = request.entry;
  final video = entry.video;
  final editionCount = entry.editions.length;
  final facts = <LibraryInspectorFactData>[
    LibraryInspectorFactData('Title', entry.resolvedTitle),
    if (entry.originalTitle?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Original title', entry.originalTitle!),
    if (entry.publisher?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Studio', entry.publisher!),
    if (entry.releaseDate != null)
      LibraryInspectorFactData('Release date', _formatDate(entry.releaseDate!)),
    if (video?.runtimeMinutes != null)
      LibraryInspectorFactData('Runtime', '${video!.runtimeMinutes} min'),
    if (video?.color?.trim().isNotEmpty == true)
      LibraryInspectorFactData('HDR / color', video!.color!),
    if (video?.screenRatio?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Screen ratio', video!.screenRatio!),
    if (video?.audioTracks?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Audio', video!.audioTracks!),
    if (video?.subtitles?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Subtitles', video!.subtitles!),
    if (video?.layers?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Layers', video!.layers!),
    LibraryInspectorFactData('Releases', editionCount.toString()),
    if (entry.barcode?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Barcode', entry.barcode!),
    if (entry.country?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Country', entry.country!),
    if (entry.language?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Language', entry.language!),
    if (entry.ageRating?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Age rating', entry.ageRating!),
    if (entry.audienceRating?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Audience rating', entry.audienceRating!),
    if (entry.trailerUrls.isNotEmpty)
      LibraryInspectorFactData(
        'Trailers',
        entry.trailerUrls.length.toString(),
      ),
    LibraryInspectorFactData(
      'Cover',
      entry.hasMissingCover ? 'Missing' : 'Ready',
    ),
    LibraryInspectorFactData(
      'Metadata',
      entry.hasMissingMetadata ? 'Missing' : 'Ready',
    ),
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
