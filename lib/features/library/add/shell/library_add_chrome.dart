import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Kind-specific copy for the shared add-dialog chrome (header + mode bar).
///
/// Everything structural is shared; only labels and a few feature toggles vary
/// between kinds, so each kind supplies a small [LibraryAddChromeLabels] instead
/// of duplicating the whole header/mode-bar widget tree.
class LibraryAddChromeLabels {
  const LibraryAddChromeLabels({
    required this.searchFieldLabel,
    required this.searchFieldHint,
    this.title,
    this.searchButtonLabel,
    this.showCoverScanSuffix = false,
    this.showSuggestions = false,
    this.seriesFieldLabel = 'Series',
    this.issueFieldLabel,
    this.publisherFieldLabel = 'Publisher',
    this.yearFieldLabel = 'Year',
  });

  /// Header title. Defaults to `Add <plural label>`.
  final String? title;

  final String searchFieldLabel;
  final String searchFieldHint;

  /// Search button label. Defaults to `Search <plural label>`.
  final String? searchButtonLabel;

  /// Whether the search field shows the inline cover-scan camera button.
  final bool showCoverScanSuffix;

  /// Whether the mode bar renders the type-ahead suggestions dropdown.
  final bool showSuggestions;

  final String seriesFieldLabel;

  /// When null the issue/number advanced field is hidden.
  final String? issueFieldLabel;
  final String publisherFieldLabel;
  final String yearFieldLabel;
}

/// Shared add-dialog header. Icon and title derive from the kind config.
Widget buildLibraryAddHeader(
  BuildContext context,
  LibraryAddHeaderRequest request, {
  String? title,
}) {
  return SizedBox(
    height: 46,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: request.accent,
        border: Border(
          bottom: BorderSide(color: request.accent.withValues(alpha: 0.92)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(request.type.workspace.icon, size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title ?? 'Add ${request.type.pluralLabel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          LibrarySquareCloseButton(
            tooltip: 'Close',
            onPressed: request.onClose,
            borderColor: Colors.white.withValues(alpha: 0.8),
            foregroundColor: Colors.white,
          ),
        ],
      ),
    ),
  );
}

/// Shared add-dialog mode bar (search/barcode/manual + advanced filters).
Widget buildLibraryAddModeBar(
  BuildContext context,
  LibraryAddModeBarRequest request,
  LibraryAddChromeLabels labels,
) {
  final palette = appPalette(context);
  final isBusy = request.isSearching || request.isSearchingProvider;
  final isBarcode = request.mode == LibraryAddDialogMode.barcode;
  final isSearch = request.mode == LibraryAddDialogMode.search;
  final searchButtonLabel =
      labels.searchButtonLabel ?? 'Search ${request.type.pluralLabel}';
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
                        : labels.searchFieldLabel,
                    hintText: isBarcode
                        ? 'Scan or enter barcode...'
                        : labels.searchFieldHint,
                    prefixIcon: Icon(isBarcode ? Icons.qr_code_2 : Icons.search),
                    suffixIcon:
                        labels.showCoverScanSuffix && isSearch && request.canScanCover
                            ? IconButton(
                                tooltip: 'Scan cover',
                                onPressed: isBusy || request.isScanningCover
                                    ? null
                                    : request.onScanCover,
                                icon: request.isScanningCover
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
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
                label: Text(isBarcode ? 'Lookup' : searchButtonLabel),
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
                  key: const ValueKey('library-add-filters-toggle'),
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
                  selected: request.videoKindFilters!.contains('collection'),
                  label: const Text('Box Sets'),
                  onSelected: (value) => request.onVideoKindFilterChanged
                      ?.call('collection', value),
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
                    key: const ValueKey('library-add-series-field'),
                    controller: request.seriesController,
                    decoration:
                        InputDecoration(labelText: labels.seriesFieldLabel),
                  ),
                ),
                if (labels.issueFieldLabel != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('library-add-number-field'),
                      controller: request.numberController,
                      decoration:
                          InputDecoration(labelText: labels.issueFieldLabel),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const ValueKey('library-add-publisher-field'),
                    controller: request.publisherController,
                    decoration:
                        InputDecoration(labelText: labels.publisherFieldLabel),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    key: const ValueKey('library-add-year-field'),
                    controller: request.yearController,
                    decoration:
                        InputDecoration(labelText: labels.yearFieldLabel),
                  ),
                ),
              ],
            ),
          ],
          if (labels.showSuggestions &&
              isSearch &&
              request.showSuggestions &&
              request.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Material(
              color: palette.panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: palette.divider),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final suggestion in request.suggestions)
                      ListTile(
                        dense: true,
                        title: Text(suggestion.title),
                        subtitle:
                            suggestion.itemNumber?.trim().isNotEmpty == true
                                ? Text('Issue ${suggestion.itemNumber}')
                                : null,
                        onTap: () => request.onSelectSuggestion(suggestion),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
