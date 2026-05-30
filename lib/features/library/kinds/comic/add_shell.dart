import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/shared/add_bottom_bar.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildComicAddHeader(
  BuildContext context,
  LibraryAddHeaderRequest request,
) {
  final palette = appPalette(context);
  return SizedBox(
    height: 46,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.panelRaised, palette.panel],
        ),
        border: Border(bottom: BorderSide(color: request.accent)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(request.type.workspace.icon, size: 19, color: request.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Comics',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Find issues fast, compare editions, then add directly to your collection.',
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

Widget buildComicAddModeBar(
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  controller:
                      isBarcode ? request.barcodeController : request.queryController,
                  onChanged: isSearch ? request.onQueryChanged : null,
                  onSubmitted: (_) => isBarcode ? request.onLookupBarcode() : request.onSearch(),
                  decoration: InputDecoration(
                    labelText: isBarcode ? 'Barcode / UPC / ISBN' : 'Series, issue or title',
                    hintText: isBarcode
                        ? 'Scan or enter barcode...'
                        : 'Search comics by series, issue, or exact title...',
                    prefixIcon: Icon(
                      isBarcode ? Icons.qr_code_2 : Icons.search,
                    ),
                    suffixIcon: isSearch && request.canScanCover
                        ? IconButton(
                            tooltip: 'Scan cover',
                            onPressed: isBusy || request.isScanningCover
                                ? null
                                : request.onScanCover,
                            icon: request.isScanningCover
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.photo_camera_outlined),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isBusy
                    ? null
                    : (isBarcode ? request.onLookupBarcode : request.onSearch),
                style: libraryAddFilledButtonStyle(request.accent),
                icon: Icon(isBarcode ? Icons.qr_code_2 : Icons.search, size: 18),
                label: Text(isBarcode ? 'Lookup' : 'Search Comics'),
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
                    request.showAdvanced
                        ? Icons.tune
                        : Icons.tune_outlined,
                    size: 18,
                  ),
                  label: const Text('Filters'),
                ),
              ],
            ],
          ),
          if (isSearch && request.showAdvanced) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: request.seriesController,
                    decoration: const InputDecoration(labelText: 'Series'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: request.numberController,
                    decoration: const InputDecoration(labelText: 'Issue'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: request.publisherController,
                    decoration: const InputDecoration(labelText: 'Publisher'),
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
          if (isSearch && request.showSuggestions && request.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Material(
              color: palette.panel,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final suggestion in request.suggestions)
                        ListTile(
                          dense: true,
                          title: Text(suggestion.title),
                          subtitle: suggestion.itemNumber?.trim().isNotEmpty == true
                              ? Text('Issue ${suggestion.itemNumber}')
                              : null,
                          onTap: () => request.onSelectSuggestion(suggestion),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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

  static const _seriesWidth = 230.0;
  static const _issueWidth = 60.0;
  static const _editionWidth = 145.0;
  static const _publisherWidth = 120.0;
  static const _releaseWidth = 95.0;
  static const _formatWidth = 90.0;
  static const _tableWidth =
      96.0 + _seriesWidth + _issueWidth + _editionWidth + _publisherWidth + _releaseWidth + _formatWidth;

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
        child: SizedBox(
          width: _tableWidth + 16,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(width: 36),
                _ComicFixedHeaderCell(label: 'Series', width: _seriesWidth),
                _ComicFixedHeaderCell(label: 'Issue', width: _issueWidth),
                _ComicFixedHeaderCell(label: 'Variant Description', width: _editionWidth),
                _ComicFixedHeaderCell(label: 'Publisher', width: _publisherWidth),
                _ComicFixedHeaderCell(label: 'Release Date', width: _releaseWidth),
                _ComicFixedHeaderCell(label: 'Format', width: _formatWidth),
              ],
            ),
          ),
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
        : request.selectedProviderCandidateId == entry.candidate!.localCatalogId;
    final checked = entry.item != null && request.checkedResultIds.contains(entry.item!.id);
    final owned = entry.item != null && request.ownedCatalogItemIds.contains(entry.item!.id);
    final background = selected
        ? Color.alphaBlend(request.accent.withValues(alpha: 0.2), palette.selection)
        : (odd ? palette.tableOddRow : palette.tableEvenRow);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.item != null
            ? () => request.onSelectResult(entry.item!.id)
            : () => request.onSelectProviderCandidate(entry.candidate!.localCatalogId),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: background,
            border: Border(
              left: BorderSide(
                color: selected ? request.accent : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(color: palette.tableBottomBorder),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _ComicAddSearchPane._tableWidth + 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: entry.item != null
                          ? Checkbox(
                              value: checked,
                              onChanged: (_) => request.onToggleResultCheck(entry.item!.id),
                              activeColor: request.accent,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )
                          : Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: request.accent.withValues(alpha: 0.72),
                            ),
                    ),
                    _seriesCell(context, owned),
                    _cell(_issueText),
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
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              LibraryAddResultBadge(
                entry.item != null
                    ? 'core'
                    : request.type.metadataProviderLabel(entry.candidate!.provider),
                accent: request.accent,
              ),
              if (owned) const LibraryAddResultBadge('In collection'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String text) {
    final width = switch (text) {
      _ when identical(text, _issueText) => _ComicAddSearchPane._issueWidth,
      _ when identical(text, _editionText) => _ComicAddSearchPane._editionWidth,
      _ when identical(text, _publisherText) => _ComicAddSearchPane._publisherWidth,
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
    return entry.item?.publisher?.trim() ?? entry.candidate?.publisher?.trim() ?? '';
  }

  String get _releaseText {
    if (entry.item != null) {
      return _formatReleaseDate(entry.item!.releaseDate, entry.item!.releaseYear);
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  return year?.toString() ?? '';
}