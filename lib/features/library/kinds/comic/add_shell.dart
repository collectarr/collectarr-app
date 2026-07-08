import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_chrome.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/shared/add/add_bottom_bar.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildComicAddHeader(
  BuildContext context,
  LibraryAddHeaderRequest request,
) {
  return buildLibraryAddHeader(context, request, title: 'Add Comics');
}

Widget buildComicAddModeBar(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  return buildLibraryAddModeBar(
    context,
    request,
    const LibraryAddChromeLabels(
      searchFieldLabel: 'Series, issue or title',
      searchFieldHint: 'Search comics by series, issue, or exact title...',
      searchButtonLabel: 'Search Comics',
      showCoverScanSuffix: true,
      showSuggestions: true,
      seriesFieldLabel: 'Series',
      issueFieldLabel: 'Issue',
      publisherFieldLabel: 'Publisher',
      yearFieldLabel: 'Year',
    ),
  );
}

Widget buildComicAddSearchPane(
  BuildContext context,
  LibraryAddSearchPaneRequest request,
) {
  return _ComicAddSearchPane(request: request);
}

Widget buildComicAddBottomBar(
  BuildContext context,
  LibraryAddBottomBarRequest request,
) {
  return buildKindAddBottomBar(context, request);
}

class _ComicAddSearchPane extends StatelessWidget {
  const _ComicAddSearchPane({required this.request});

  final LibraryAddSearchPaneRequest request;

  // Reduced widths to avoid horizontal overflow in various test viewports
  static const _seriesWidth = 144.0;
  static const _issueWidth = 60.0;
  static const _editionWidth = 145.0;
  static const _publisherWidth = 120.0;
  static const _releaseWidth = 95.0;
  static const _formatWidth = 90.0;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final entries = [
      for (final item in request.results) _ComicSearchEntry.core(item),
      for (final candidate in request.providerResults)
        _ComicSearchEntry.provider(candidate),
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
          if (request.isWideLayout) _ComicFilterBar(request: request),
          _tableHeader(context),
          Expanded(
            child: request.isBusy && entries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Search to see comic matches arranged by series, issue, and edition.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) => _ComicSearchRow(
                          request: request,
                          entry: entries[index],
                          odd: index.isOdd,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              SizedBox(width: 36),
              _ComicFixedHeaderCell(label: 'Series', width: _seriesWidth),
              _ComicFixedHeaderCell(label: 'Issue', width: _issueWidth),
              _ComicFixedHeaderCell(
                  label: 'Variant Description', width: _editionWidth),
              _ComicFixedHeaderCell(label: 'Publisher', width: _publisherWidth),
              _ComicFixedHeaderCell(
                  label: 'Release Date', width: _releaseWidth),
              _ComicFixedHeaderCell(label: 'Format', width: _formatWidth),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComicFilterBar extends StatelessWidget {
  const _ComicFilterBar({required this.request});

  final LibraryAddSearchPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            FilterChip(
              label: const Text('Hide owned'),
              selected: request.hideComicOwnedResults,
              onSelected: request.onHideComicOwnedResultsChanged,
              visualDensity: VisualDensity.compact,
            ),
            FilterChip(
              label: const Text('Hide variants'),
              selected: request.hideComicVariantResults,
              onSelected: request.onHideComicVariantResultsChanged,
              visualDensity: VisualDensity.compact,
            ),
            FilterChip(
              label: const Text('Compact issues'),
              selected: request.compactComicIssues,
              onSelected: request.onCompactComicIssuesChanged,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicHeaderCell extends StatelessWidget {
  const _ComicHeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Text(
      label,
      style: TextStyle(
        color: palette.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ComicFixedHeaderCell extends StatelessWidget {
  const _ComicFixedHeaderCell({required this.label, required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: _ComicHeaderCell(label: label));
  }
}

class _ComicSearchRow extends StatelessWidget {
  const _ComicSearchRow({
    required this.request,
    required this.entry,
    required this.odd,
  });

  final LibraryAddSearchPaneRequest request;
  final _ComicSearchEntry entry;
  final bool odd;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selected = entry.item != null
        ? request.selectedResultId == entry.item!.id
        : request.selectedProviderCandidateId ==
            entry.candidate!.localCatalogId;
    final checked =
        entry.item != null && request.checkedResultIds.contains(entry.item!.id);
    final owned = entry.item != null &&
        request.ownedCatalogItemIds.contains(entry.item!.id);
    final background = selected
        ? Color.alphaBlend(
            request.accent.withValues(alpha: 0.2), palette.selection)
        : owned
            ? Color.alphaBlend(
                const Color(0xFF2E7D32).withValues(alpha: 0.1),
                odd ? palette.tableOddRow : palette.tableEvenRow,
              )
            : (odd ? palette.tableOddRow : palette.tableEvenRow);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey(
          'library-add-search-result-${entry.item?.id ?? entry.candidate!.localCatalogId}',
        ),
        onTap: entry.item != null
            ? () => request.onSelectResult(entry.item!.id)
            : () => request
                .onSelectProviderCandidate(entry.candidate!.localCatalogId),
        child: Container(
          height: request.compactComicIssues ? 64 : 72,
          decoration: BoxDecoration(
            color: background,
            border: Border(
              left: BorderSide(
                color: selected
                    ? request.accent
                    : owned
                        ? const Color(0xFF3FA34D)
                        : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(color: palette.tableBottomBorder),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: entry.item != null
                        ? Checkbox(
                            value: checked,
                            onChanged: (_) =>
                                request.onToggleResultCheck(entry.item!.id),
                            activeColor: request.accent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          )
                        : Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: request.accent.withValues(alpha: 0.72),
                          ),
                  ),
                  _seriesCell(context, owned),
                  _issueCell(context),
                  _cell(_editionText),
                  _cell(_publisherText),
                  _cell(_releaseText),
                  _cell(_formatText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _seriesCell(BuildContext context, bool owned) {
    final palette = appPalette(context);
    return SizedBox(
      width: _ComicAddSearchPane._seriesWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _seriesText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              LibraryAddResultBadge(
                entry.item != null
                    ? 'core'
                    : request.type
                        .metadataProviderLabel(entry.candidate!.provider),
                accent: request.accent,
              ),
              if (owned)
                const LibraryAddResultBadge(
                  'Already in collection',
                  icon: Icons.playlist_add_check_rounded,
                  backgroundColor: Color(0xFF163A1D),
                  borderColor: Color(0xFF3FA34D),
                  foregroundColor: Color(0xFFC7FFD0),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _issueCell(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      width: _ComicAddSearchPane._issueWidth,
      child: Align(
        alignment: Alignment.centerLeft,
        child: request.compactComicIssues
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.panel,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.divider),
                ),
                child: Text(
                  _issueText.isNotEmpty ? _issueText : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Text(
                _issueText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  Widget _cell(String text) {
    final width = switch (text) {
      _ when identical(text, _issueText) => _ComicAddSearchPane._issueWidth,
      _ when identical(text, _editionText) => _ComicAddSearchPane._editionWidth,
      _ when identical(text, _publisherText) =>
        _ComicAddSearchPane._publisherWidth,
      _ when identical(text, _releaseText) => _ComicAddSearchPane._releaseWidth,
      _ => _ComicAddSearchPane._formatWidth,
    };
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String get _seriesText {
    if (entry.item != null) {
      return entry.item!.series?.seriesTitle?.trim().isNotEmpty == true
          ? entry.item!.series!.seriesTitle!.trim()
          : entry.item!.title;
    }
    return _candidateSeries(entry.candidate!);
  }

  String get _issueText {
    if (entry.item != null) {
      return entry.item!.itemNumber?.trim() ?? '';
    }
    return entry.candidate!.issueNumber?.trim().isNotEmpty == true
        ? entry.candidate!.issueNumber!.trim()
        : (_parseTitleIssue(entry.candidate!.title)?.$2 ?? '');
  }

  String get _editionText {
    if (entry.item != null) {
      return entry.item!.displayEditionLabel?.trim() ?? '';
    }
    return entry.candidate!.variantName?.trim() ??
        (entry.candidate!.isVariant ? 'Variant' : '');
  }

  String get _publisherText {
    return entry.item?.publisher?.trim() ??
        entry.candidate?.publisher?.trim() ??
        '';
  }

  String get _releaseText {
    if (entry.item != null) {
      return _formatReleaseDate(
          entry.item!.releaseDate, entry.item!.releaseYear);
    }
    final year = entry.candidate!.series?.volumeStartYear;
    return year?.toString() ?? '';
  }

  String get _formatText {
    return entry.item?.physicalFormatLabel?.trim() ?? '';
  }
}

class _ComicSearchEntry {
  const _ComicSearchEntry.core(this.item) : candidate = null;
  const _ComicSearchEntry.provider(this.candidate) : item = null;

  final LibraryMetadataItem? item;
  final ProviderCandidate? candidate;
}

String _candidateSeries(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return _parseTitleIssue(candidate.title)?.$1 ?? candidate.title;
}

(String, String)? _parseTitleIssue(String title) {
  final match = RegExp(r'^(.*?)\s+#\s*([^\s\[]+)').firstMatch(title.trim());
  if (match == null) {
    return null;
  }
  return ((match.group(1) ?? '').trim(), (match.group(2) ?? '').trim());
}

String _formatReleaseDate(DateTime? date, int? year) {
  if (date != null) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  return year?.toString() ?? '';
}
