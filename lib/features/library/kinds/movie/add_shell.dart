import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_chrome.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_kind_bottom_bar.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildMovieAddHeader(
  BuildContext context,
  LibraryAddHeaderRequest request,
) {
  return buildLibraryAddHeader(context, request, title: 'Add Movies');
}

Widget buildMovieAddModeBar(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final baseModeBar = buildLibraryAddModeBar(
    context,
    request,
    const LibraryAddChromeLabels(
      searchFieldLabel: 'Find movies or box sets',
      searchFieldHint: 'Search by title, studio, year, or release...',
      searchButtonLabel: 'Search Movies',
    ),
  );
  if (request.type.addChrome.videoKindFilterOptions.isEmpty ||
      request.mode != LibraryAddDialogMode.search) {
    return baseModeBar;
  }
  final palette = appPalette(context);
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      baseModeBar,
      DecoratedBox(
        decoration: BoxDecoration(
          color: palette.panel,
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              for (final opt
                  in request.type.addChrome.videoKindFilterOptions) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(opt.icon, size: 14, color: request.accent),
                      const SizedBox(width: 4),
                      Text(
                        opt.label,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
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
        LibraryAddSearchSourceToggles(
          showCoreResults: request.showCoreResults,
          showProviderResults: request.showProviderResults,
          onShowCoreResultsChanged: request.onShowCoreResultsChanged,
          onShowProviderResultsChanged: request.onShowProviderResultsChanged,
          resultOptions: request.resultPolicy.options
              .where((option) => option.showInSourceToggles)
              .toList(growable: false),
          resultPolicyState: request.resultPolicyState,
          onResultPolicyOptionChanged: request.onResultPolicyOptionChanged,
        ),
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
                        final publisher =
                            (item?.payload['publisher'] as String?) ??
                                ((item?.payload['publishing']
                                    as Map?)?['original_publisher'] as String?);
                        final subtitle = isCore
                            ? [
                                if (libraryKindReleaseYear(item) != null)
                                  libraryKindReleaseYear(item).toString(),
                                if (publisher != null &&
                                    publisher.trim().isNotEmpty)
                                  publisher.trim(),
                              ].whereType<String>().join(' · ')
                            : [
                                request.type.metadata
                                    .providerLabel(candidate!.provider),
                                if (candidate.summary?.trim().isNotEmpty ==
                                    true)
                                  candidate.summary,
                              ].whereType<String>().join(' · ');
                        final matchSummary = isCore
                            ? request.coreMatchSummary?.call(item)
                            : request.providerMatchSummary?.call(candidate!);
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
                                                  : request.type.metadata
                                                      .providerLabel(
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
  return buildLibraryAddKindBottomBar(context, request);
}

class _MovieSearchGridEntry {
  const _MovieSearchGridEntry.core(this.item) : candidate = null;
  const _MovieSearchGridEntry.provider(this.candidate) : item = null;

  final CatalogItem? item;
  final ProviderCandidate? candidate;
}
