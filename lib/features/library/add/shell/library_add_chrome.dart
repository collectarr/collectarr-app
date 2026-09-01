import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Kind-specific copy and filter configuration for the shared add-dialog chrome.
class LibraryAddChromeLabels {
  const LibraryAddChromeLabels({
    required this.searchFieldLabel,
    required this.searchFieldHint,
    this.title,
    this.searchButtonLabel,
    this.showCoverScanSuffix = false,
    this.showSuggestions = false,
    this.advancedFiltersBuilder,
  });

  final String? title;
  final String searchFieldLabel;
  final String searchFieldHint;
  final String? searchButtonLabel;
  final bool showCoverScanSuffix;
  final bool showSuggestions;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      advancedFiltersBuilder;
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

Widget buildLibraryAddModeBar(
  BuildContext context,
  LibraryAddModeBarRequest request,
  LibraryAddChromeLabels labels,
) {
  return _LibraryAddChromeModeBar(request: request, labels: labels);
}

class _LibraryAddChromeModeBar extends StatefulWidget {
  const _LibraryAddChromeModeBar({
    required this.request,
    required this.labels,
  });

  final LibraryAddModeBarRequest request;
  final LibraryAddChromeLabels labels;

  @override
  State<_LibraryAddChromeModeBar> createState() =>
      _LibraryAddChromeModeBarState();
}

class _LibraryAddChromeModeBarState extends State<_LibraryAddChromeModeBar> {
  late final TextEditingController _seriesController;
  late final TextEditingController _numberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _yearController;
  late final bool _ownsControllers;

  @override
  void initState() {
    super.initState();
    _ownsControllers = widget.request.seriesController == null;
    _seriesController = widget.request.seriesController ??
        TextEditingController(text: widget.request.seriesText ?? '');
    _numberController = widget.request.numberController ??
        TextEditingController(text: widget.request.numberText ?? '');
    _publisherController = widget.request.publisherController ??
        TextEditingController(text: widget.request.publisherText ?? '');
    _yearController = widget.request.yearController ??
        TextEditingController(text: widget.request.yearText ?? '');
  }

  @override
  void didUpdateWidget(covariant _LibraryAddChromeModeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ownsControllers) {
      if (widget.request.seriesText != null &&
          widget.request.seriesText != _seriesController.text) {
        _seriesController.text = widget.request.seriesText!;
      }
      if (widget.request.numberText != null &&
          widget.request.numberText != _numberController.text) {
        _numberController.text = widget.request.numberText!;
      }
      if (widget.request.publisherText != null &&
          widget.request.publisherText != _publisherController.text) {
        _publisherController.text = widget.request.publisherText!;
      }
      if (widget.request.yearText != null &&
          widget.request.yearText != _yearController.text) {
        _yearController.text = widget.request.yearText!;
      }
    }
  }

  @override
  void dispose() {
    if (_ownsControllers) {
      _seriesController.dispose();
      _numberController.dispose();
      _publisherController.dispose();
      _yearController.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    widget.request.onSeriesChanged?.call(_seriesController.text);
    widget.request.onNumberChanged?.call(_numberController.text);
    widget.request.onPublisherChanged?.call(_publisherController.text);
    widget.request.onYearChanged?.call(_yearController.text);
    widget.request.onSearch();
  }

  List<LibraryAddAdvancedFilterField> _resolveAdvancedFields() {
    if (widget.request.advancedFilterFields.isNotEmpty) {
      return widget.request.advancedFilterFields;
    }
    final req = LibraryAddModeBarRequest(
      type: widget.request.type,
      accent: widget.request.accent,
      isMovieDesktopChrome: widget.request.isMovieDesktopChrome,
      mode: widget.request.mode,
      queryController: widget.request.queryController,
      barcodeController: widget.request.barcodeController,
      isSearching: widget.request.isSearching,
      isSearchingProvider: widget.request.isSearchingProvider,
      onModeChanged: widget.request.onModeChanged,
      onSearch: _handleSearch,
      onQueryChanged: widget.request.onQueryChanged,
      suggestions: widget.request.suggestions,
      showSuggestions: widget.request.showSuggestions,
      onSelectSuggestion: widget.request.onSelectSuggestion,
      onDismissSuggestions: widget.request.onDismissSuggestions,
      canScanCover: widget.request.canScanCover,
      isScanningCover: widget.request.isScanningCover,
      onScanCover: widget.request.onScanCover,
      onLookupBarcode: widget.request.onLookupBarcode,
      onManual: widget.request.onManual,
      showAdvanced: widget.request.showAdvanced,
      onToggleAdvanced: widget.request.onToggleAdvanced,
      seriesController: _seriesController,
      numberController: _numberController,
      publisherController: _publisherController,
      yearController: _yearController,
    );
    return libraryKindRuntimeForKind(widget.request.type.workspace.kind)
            .add
            .advancedFilterFieldsBuilder
            ?.call(req) ??
        const [];
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final labels = widget.labels;
    final palette = appPalette(context);
    final isBusy = request.isSearching || request.isSearchingProvider;
    final isBarcode = request.mode == LibraryAddDialogMode.barcode;
    final isSearch = request.mode == LibraryAddDialogMode.search;
    final searchButtonLabel =
        labels.searchButtonLabel ?? 'Search ${request.type.pluralLabel}';
    final advancedFields = _resolveAdvancedFields();

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
                        : _handleSearch(),
                    decoration: InputDecoration(
                      labelText: isBarcode
                          ? 'Barcode / UPC / ISBN'
                          : labels.searchFieldLabel,
                      hintText: isBarcode
                          ? 'Scan or enter barcode...'
                          : labels.searchFieldHint,
                      prefixIcon:
                          Icon(isBarcode ? Icons.qr_code_2 : Icons.search),
                      suffixIcon: labels.showCoverScanSuffix &&
                              isSearch &&
                              request.canScanCover
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
                      : (isBarcode ? request.onLookupBarcode : _handleSearch),
                  style: libraryAddFilledButtonStyle(request.accent),
                  icon:
                      Icon(isBarcode ? Icons.qr_code_2 : Icons.search, size: 18),
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
            if (isSearch && request.showAdvanced) ...[
              const SizedBox(height: 8),
              if (labels.advancedFiltersBuilder != null)
                labels.advancedFiltersBuilder!(context, request)
              else if (request.advancedFiltersBuilder != null)
                request.advancedFiltersBuilder!(context, request)
              else if (advancedFields.isNotEmpty)
                Row(
                  children: [
                    for (var i = 0; i < advancedFields.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      if (advancedFields[i].width != null)
                        SizedBox(
                          width: advancedFields[i].width,
                          child: TextField(
                            key: advancedFields[i].key,
                            controller: advancedFields[i].controller,
                            keyboardType: advancedFields[i].keyboardType,
                            onSubmitted: (_) => _handleSearch(),
                            decoration: InputDecoration(
                              labelText: advancedFields[i].label,
                              hintText: advancedFields[i].hintText,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          flex: advancedFields[i].flex,
                          child: TextField(
                            key: advancedFields[i].key,
                            controller: advancedFields[i].controller,
                            keyboardType: advancedFields[i].keyboardType,
                            onSubmitted: (_) => _handleSearch(),
                            decoration: InputDecoration(
                              labelText: advancedFields[i].label,
                              hintText: advancedFields[i].hintText,
                            ),
                          ),
                        ),
                    ],
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
                        () {
                          final itemNumber = suggestion.kindMetadata
                              .toSyncPayload()['item_number'] as String?;
                          return ListTile(
                            dense: true,
                            title: Text(suggestion.title),
                            subtitle: itemNumber?.trim().isNotEmpty == true
                                ? Text('Issue $itemNumber')
                                : null,
                            onTap: () => request.onSelectSuggestion(suggestion),
                          );
                        }(),
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
}
