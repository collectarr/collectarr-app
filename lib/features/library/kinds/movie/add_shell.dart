import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/shared/add_bottom_bar.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildMovieAddHeader(
  BuildContext context,
  LibraryAddHeaderRequest request,
) {
  final palette = appPalette(context);
  return SizedBox(
    height: 44,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(request.type.workspace.icon, size: 18, color: request.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Movies',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Browse releases, compare covers, and add directly to your library.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: request.onClose,
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    ),
  );
}

Widget buildMovieAddModeBar(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final palette = appPalette(context);
  final isBusy = request.isSearching || request.isSearchingProvider;
  final isBarcode = request.mode == LibraryAddDialogMode.barcode;
  final isSearch = request.mode == LibraryAddDialogMode.search;
  return DecoratedBox(
    decoration: BoxDecoration(
      color: palette.panelRaised,
      border: Border(bottom: BorderSide(color: palette.divider)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey(
                    isBarcode
                        ? 'library-add-barcode-field'
                        : 'library-add-query-field',
                  ),
                  controller: isBarcode
                      ? request.barcodeController
                      : request.queryController,
                  onChanged: isSearch ? request.onQueryChanged : null,
                  onSubmitted: (_) => isBarcode
                      ? request.onLookupBarcode()
                      : request.onSearch(),
                  decoration: InputDecoration(
                    labelText: isBarcode
                        ? 'Barcode / UPC / ISBN'
                        : 'Find movies or box sets',
                    hintText: isBarcode
                        ? 'Scan or enter barcode...'
                        : 'Search by title, studio, year, or release...',
                    prefixIcon:
                        Icon(isBarcode ? Icons.qr_code_2 : Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isBusy
                    ? null
                    : (isBarcode ? request.onLookupBarcode : request.onSearch),
                style: libraryAddFilledButtonStyle(request.accent),
                icon:
                    Icon(isBarcode ? Icons.qr_code_2 : Icons.search, size: 18),
                label: Text(isBarcode ? 'Lookup' : 'Search Movies'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<LibraryAddDialogMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<LibraryAddDialogMode>(
                      value: LibraryAddDialogMode.search,
                      label: Text('Search'),
                      icon: Icon(Icons.search, size: 18),
                    ),
                    ButtonSegment<LibraryAddDialogMode>(
                      value: LibraryAddDialogMode.barcode,
                      label: Text('Barcode'),
                      icon: Icon(Icons.qr_code_2, size: 18),
                    ),
                    ButtonSegment<LibraryAddDialogMode>(
                      value: LibraryAddDialogMode.manual,
                      label: Text('Manual'),
                      icon: Icon(Icons.edit_note, size: 18),
                    ),
                  ],
                  selected: {request.mode},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      final value = selection.first;
                      request.onModeChanged(value);
                      if (value == LibraryAddDialogMode.manual) {
                        request.onManual();
                      }
                    }
                  },
                ),
              ),
              if (isSearch) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: request.onToggleAdvanced,
                  style: libraryAddOutlinedButtonStyle(request.accent),
                  icon: Icon(
                    request.showAdvanced ? Icons.tune : Icons.tune_outlined,
                    size: 18,
                  ),
                  label: const Text('Filters'),
                ),
              ],
            ],
          ),
          if (isSearch && request.videoKindFilters != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: request.videoKindFilters!.contains('movie'),
                  label: const Text('Movies'),
                  onSelected: (value) =>
                      request.onVideoKindFilterChanged?.call('movie', value),
                ),
                FilterChip(
                  selected: request.videoKindFilters!.contains('tv'),
                  label: const Text('TV'),
                  onSelected: (value) =>
                      request.onVideoKindFilterChanged?.call('tv', value),
                ),
              ],
            ),
          ],
          if (isSearch && request.showAdvanced) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: request.seriesController,
                    decoration:
                        const InputDecoration(labelText: 'Series / Franchise'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: request.publisherController,
                    decoration: const InputDecoration(labelText: 'Studio'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: request.yearController,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

Widget buildMovieAddSearchPane(
  BuildContext context,
  LibraryAddSearchPaneRequest request,
) {
  final palette = appPalette(context);
  final entries = <_MovieSearchGridEntry>[
    for (final item in request.results) _MovieSearchGridEntry.core(item),
    for (final candidate in request.providerResults)
      _MovieSearchGridEntry.provider(candidate),
  ];
  return DecoratedBox(
    decoration: BoxDecoration(
      color: palette.panelRaised,
      border: Border(right: BorderSide(color: palette.divider)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.error != null) AppErrorBanner(request.error!),
        Expanded(
          child: request.isBusy && entries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Search to see movie releases and provider matches.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 174,
                        mainAxisExtent: 292,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final item = entry.item;
                        final candidate = entry.candidate;
                        final isCore = item != null;
                        final selected = isCore
                            ? item.id == request.selectedResultId
                            : candidate!.localCatalogId ==
                                request.selectedProviderCandidateId;
                        final checked = isCore &&
                            request.checkedResultIds.contains(item.id);
                        final title = isCore ? item.title : candidate!.title;
                        final coverUrl =
                            isCore ? item.displayCoverUrl : candidate!.imageUrl;
                        final subtitle = isCore
                            ? [
                                if (item.releaseYear != null)
                                  item.releaseYear.toString(),
                                if (item.publisher?.trim().isNotEmpty == true)
                                  item.publisher,
                              ].whereType<String>().join(' · ')
                            : [
                                request.type
                                    .metadataProviderLabel(candidate!.provider),
                                if (candidate.summary?.trim().isNotEmpty ==
                                    true)
                                  candidate.summary,
                              ].whereType<String>().join(' · ');
                        final matchSummary = isCore
                            ? _movieMetadataMatchSummary(
                                item,
                                request.providerQueryText,
                                request.providerPublisherText,
                                request.providerYearText)
                            : _movieProviderMatchSummary(
                                candidate!,
                                request.providerQueryText,
                                request.providerPublisherText,
                                request.providerYearText);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isCore
                                ? () => request.onSelectResult(item.id)
                                : () => request.onSelectProviderCandidate(
                                    candidate!.localCatalogId),
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: selected
                                    ? Color.alphaBlend(
                                        request.accent.withValues(alpha: 0.22),
                                        palette.selection,
                                      )
                                    : palette.tableEvenRow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? request.accent
                                      : palette.divider,
                                  width: selected ? 1.6 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: LibraryCoverImage(
                                                title: title,
                                                imageUrl: coverUrl,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 6,
                                            bottom: 6,
                                            child: LibraryAddResultBadge(
                                              isCore
                                                  ? 'core'
                                                  : request.type
                                                      .metadataProviderLabel(
                                                          candidate!.provider),
                                              accent: request.accent,
                                            ),
                                          ),
                                          if (isCore)
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: InkWell(
                                                onTap: () =>
                                                    request.onToggleResultCheck(
                                                        item.id),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    checked
                                                        ? Icons.check_circle
                                                        : Icons
                                                            .radio_button_unchecked,
                                                    size: 18,
                                                    color: checked
                                                        ? request.accent
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        height: 1.05,
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: palette.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                    if (matchSummary != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Matched on: $matchSummary',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: request.accent
                                              .withValues(alpha: 0.92),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                    if (isCore &&
                                        request.ownedCatalogItemIds
                                            .contains(item.id)) ...[
                                      const SizedBox(height: 5),
                                      const LibraryAddResultBadge(
                                          'In collection'),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

Widget buildMovieAddBottomBar(
  BuildContext context,
  LibraryAddBottomBarRequest request,
) {
  return buildKindAddBottomBar(context, request);
}

class _MovieSearchGridEntry {
  const _MovieSearchGridEntry.core(this.item) : candidate = null;
  const _MovieSearchGridEntry.provider(this.candidate) : item = null;

  final LibraryMetadataItem? item;
  final ProviderCandidate? candidate;
}

String? _movieMetadataMatchSummary(
  LibraryMetadataItem item,
  String queryText,
  String publisherText,
  String yearText,
) {
  final matches = <String>[];
  void addIfContains(String label, String needle, Iterable<String?> haystacks) {
    final normalizedNeedle = needle.trim().toLowerCase();
    if (normalizedNeedle.isEmpty || matches.contains(label)) {
      return;
    }
    for (final haystack in haystacks) {
      final normalizedHaystack = haystack?.trim().toLowerCase();
      if (normalizedHaystack != null &&
          normalizedHaystack.contains(normalizedNeedle)) {
        matches.add(label);
        return;
      }
    }
  }

  addIfContains('Title', queryText, [item.title]);
  addIfContains('Studio', publisherText, [item.publisher]);
  addIfContains('Year', yearText,
      [item.releaseYear?.toString(), item.releaseDate?.year.toString()]);
  return matches.isEmpty ? null : matches.join(', ');
}

String? _movieProviderMatchSummary(
  ProviderCandidate candidate,
  String queryText,
  String publisherText,
  String yearText,
) {
  final matches = <String>[];
  void addIfContains(String label, String needle, Iterable<String?> haystacks) {
    final normalizedNeedle = needle.trim().toLowerCase();
    if (normalizedNeedle.isEmpty || matches.contains(label)) {
      return;
    }
    for (final haystack in haystacks) {
      final normalizedHaystack = haystack?.trim().toLowerCase();
      if (normalizedHaystack != null &&
          normalizedHaystack.contains(normalizedNeedle)) {
        matches.add(label);
        return;
      }
    }
  }

  addIfContains('Title', queryText, [candidate.title, candidate.summary]);
  addIfContains('Studio', publisherText, [candidate.publisher]);
  addIfContains(
      'Year', yearText, [candidate.series?.volumeStartYear?.toString()]);
  return matches.isEmpty ? null : matches.join(', ');
}
