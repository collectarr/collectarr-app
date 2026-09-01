import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
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
  });

  final String? title;
  final String searchFieldLabel;
  final String searchFieldHint;
  final String? searchButtonLabel;
  final bool showCoverScanSuffix;
  final bool showSuggestions;
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
  final Map<LibraryAddFilterId, TextEditingController> _advancedControllers =
      {};

  @override
  void initState() {
    super.initState();
    _syncAdvancedControllers(widget.request.advancedFilterDescriptors);
  }

  @override
  void didUpdateWidget(covariant _LibraryAddChromeModeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAdvancedControllers(widget.request.advancedFilterDescriptors);
  }

  @override
  void dispose() {
    for (final controller in _advancedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    final fields = widget.request.advancedFilterDescriptors;
    for (final field in fields) {
      widget.request.onAdvancedFilterChanged(
        field.id,
        field.parse(_advancedControllers[field.id]!.text),
      );
    }
    widget.request.onSearch();
  }

  TextEditingController _controllerFor(
    LibraryAddAdvancedFilterField<String> field,
  ) {
    return _advancedControllers.putIfAbsent(
      field.id,
      () => TextEditingController(text: field.textValue),
    );
  }

  void _syncAdvancedControllers(
    List<LibraryAddAdvancedFilterField<String>> fields,
  ) {
    final ids = fields.map((field) => field.id).toSet();
    for (final id in _advancedControllers.keys.toList()) {
      if (!ids.contains(id)) {
        _advancedControllers.remove(id)?.dispose();
      }
    }
    for (final field in fields) {
      final controller = _controllerFor(field);
      if (controller.text != field.textValue) {
        controller.text = field.textValue;
      }
    }
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
    final advancedFields = request.advancedFilterDescriptors;
    _syncAdvancedControllers(advancedFields);

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
                    onSubmitted: (_) =>
                        isBarcode ? request.onLookupBarcode() : _handleSearch(),
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
                  icon: Icon(isBarcode ? Icons.qr_code_2 : Icons.search,
                      size: 18),
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
              if (advancedFields.isNotEmpty)
                Row(
                  children: [
                    for (var i = 0; i < advancedFields.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      if (advancedFields[i].width != null)
                        SizedBox(
                          width: advancedFields[i].width,
                          child: TextField(
                            key: advancedFields[i].key,
                            controller:
                                _advancedControllers[advancedFields[i].id]!,
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
                            controller:
                                _advancedControllers[advancedFields[i].id]!,
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
              if (request.kindSpecificPaneBuilder != null)
                request.kindSpecificPaneBuilder!(context, request),
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
