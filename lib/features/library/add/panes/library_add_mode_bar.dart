import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'library_add_pane_dependencies.dart';

class LibraryAddBarcodePrefillBanner extends StatelessWidget {
  const LibraryAddBarcodePrefillBanner({
    super.key,
    required this.type,
    required this.barcode,
  });

  final LibraryTypeConfig type;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppBannerInfoBackground,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2, size: 18, color: kAppAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Barcode $barcode is prefilled for ${type.pluralLabel.toLowerCase()}. Search Core or add it manually with the same code.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryAddModeBar extends StatefulWidget {
  const LibraryAddModeBar({
    super.key,
    required this.type,
    required this.accent,
    required this.isMovieDesktopChrome,
    required this.mode,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.onModeChanged,
    required this.onSearch,
    required this.onQueryChanged,
    required this.suggestions,
    required this.showSuggestions,
    required this.onSelectSuggestion,
    required this.onDismissSuggestions,
    required this.canScanCover,
    required this.isScanningCover,
    required this.onScanCover,
    required this.onLookupBarcode,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    this.seriesController,
    this.numberController,
    this.publisherController,
    this.yearController,
    this.seriesText,
    this.numberText,
    this.publisherText,
    this.yearText,
    this.onSeriesChanged,
    this.onNumberChanged,
    this.onPublisherChanged,
    this.onYearChanged,
    this.advancedFilterFields = const [],
    this.advancedFiltersBuilder,
    this.videoKindFilters,
    this.onVideoKindFilterChanged,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final bool isMovieDesktopChrome;
  final LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final List<LibraryMetadataItem> suggestions;
  final bool showSuggestions;
  final ValueChanged<LibraryMetadataItem> onSelectSuggestion;
  final VoidCallback onDismissSuggestions;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupBarcode;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final TextEditingController? seriesController;
  final TextEditingController? numberController;
  final TextEditingController? publisherController;
  final TextEditingController? yearController;
  final String? seriesText;
  final String? numberText;
  final String? publisherText;
  final String? yearText;
  final ValueChanged<String>? onSeriesChanged;
  final ValueChanged<String>? onNumberChanged;
  final ValueChanged<String>? onPublisherChanged;
  final ValueChanged<String>? onYearChanged;
  final List<LibraryAddAdvancedFilterField> advancedFilterFields;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      advancedFiltersBuilder;
  final Set<String>? videoKindFilters;
  final void Function(String kind, bool checked)? onVideoKindFilterChanged;

  @override
  State<LibraryAddModeBar> createState() => _LibraryAddModeBarState();
}

class _LibraryAddModeBarState extends State<LibraryAddModeBar> {
  late final TextEditingController _seriesController;
  late final TextEditingController _numberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _yearController;
  late final bool _ownsControllers;

  @override
  void initState() {
    super.initState();
    _ownsControllers = widget.seriesController == null;
    _seriesController = widget.seriesController ??
        TextEditingController(text: widget.seriesText ?? '');
    _numberController = widget.numberController ??
        TextEditingController(text: widget.numberText ?? '');
    _publisherController = widget.publisherController ??
        TextEditingController(text: widget.publisherText ?? '');
    _yearController = widget.yearController ??
        TextEditingController(text: widget.yearText ?? '');
  }

  @override
  void didUpdateWidget(covariant LibraryAddModeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ownsControllers) {
      if (widget.seriesText != null &&
          widget.seriesText != _seriesController.text) {
        _seriesController.text = widget.seriesText!;
      }
      if (widget.numberText != null &&
          widget.numberText != _numberController.text) {
        _numberController.text = widget.numberText!;
      }
      if (widget.publisherText != null &&
          widget.publisherText != _publisherController.text) {
        _publisherController.text = widget.publisherText!;
      }
      if (widget.yearText != null &&
          widget.yearText != _yearController.text) {
        _yearController.text = widget.yearText!;
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
    widget.onSeriesChanged?.call(_seriesController.text);
    widget.onNumberChanged?.call(_numberController.text);
    widget.onPublisherChanged?.call(_publisherController.text);
    widget.onYearChanged?.call(_yearController.text);
    widget.onSearch();
  }

  List<LibraryAddAdvancedFilterField> _resolveAdvancedFields() {
    if (widget.advancedFilterFields.isNotEmpty) {
      return widget.advancedFilterFields;
    }
    final req = LibraryAddModeBarRequest(
      type: widget.type,
      accent: widget.accent,
      isMovieDesktopChrome: widget.isMovieDesktopChrome,
      mode: widget.mode,
      queryController: widget.queryController,
      barcodeController: widget.barcodeController,
      isSearching: widget.isSearching,
      isSearchingProvider: widget.isSearchingProvider,
      onModeChanged: widget.onModeChanged,
      onSearch: _handleSearch,
      onQueryChanged: widget.onQueryChanged,
      suggestions: widget.suggestions,
      showSuggestions: widget.showSuggestions,
      onSelectSuggestion: widget.onSelectSuggestion,
      onDismissSuggestions: widget.onDismissSuggestions,
      canScanCover: widget.canScanCover,
      isScanningCover: widget.isScanningCover,
      onScanCover: widget.onScanCover,
      onLookupBarcode: widget.onLookupBarcode,
      onManual: widget.onManual,
      showAdvanced: widget.showAdvanced,
      onToggleAdvanced: widget.onToggleAdvanced,
      seriesController: _seriesController,
      numberController: _numberController,
      publisherController: _publisherController,
      yearController: _yearController,
    );
    return libraryKindRuntimeForKind(widget.type.workspace.kind)
            .add
            .advancedFilterFieldsBuilder
            ?.call(req) ??
        const [];
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isSearching || widget.isSearchingProvider;
    final searchLabels = libraryMediaSearchFieldLabels(widget.type);
    final palette = appPalette(context);
    final advancedFields = _resolveAdvancedFields();
    if (widget.isMovieDesktopChrome) {
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
                  if (widget.mode == LibraryAddDialogMode.search) ...[
                    _AdvancedToggleButton(
                      expanded: widget.showAdvanced,
                      accent: widget.accent,
                      onPressed: widget.onToggleAdvanced,
                    ),
                    _LibraryAddModeActionButton(
                      icon: Icons.qr_code_2,
                      label: 'Barcode',
                      accent: widget.accent,
                      onPressed: () =>
                          widget.onModeChanged(LibraryAddDialogMode.barcode),
                    ),
                    _LibraryAddModeActionButton(
                      icon: Icons.edit_note,
                      label: 'Manual',
                      accent: widget.accent,
                      onPressed: widget.onManual,
                    ),
                    const Spacer(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LibraryToolbarSearch(
                          textFieldKey:
                              const ValueKey('library-add-query-field'),
                          controller: widget.queryController,
                          hintText: searchLabels.queryHint,
                          onSearch: (_) => _handleSearch(),
                          onChanged: widget.onQueryChanged,
                          onScanBarcode: () =>
                              widget.onModeChanged(LibraryAddDialogMode.barcode),
                          onScanCover: widget.canScanCover ? widget.onScanCover : null,
                          selectionColor: widget.accent,
                          maxWidth: 620,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LibraryAddModeButton(
                      label: 'Search ${widget.type.pluralLabel}',
                      icon: Icons.search,
                      accent: widget.accent,
                      isBusy: widget.isSearching,
                      onPressed: isBusy ? null : _handleSearch,
                    ),
                  ] else if (widget.mode == LibraryAddDialogMode.barcode) ...[
                    _LibraryAddModeButton(
                      label: 'Lookup',
                      icon: Icons.manage_search,
                      accent: widget.accent,
                      isBusy: widget.isSearching,
                      onPressed: isBusy ? null : widget.onLookupBarcode,
                    ),
                    const SizedBox(width: 6),
                    _LibraryAddModeActionButton(
                      icon: Icons.search,
                      label: 'Search',
                      accent: widget.accent,
                      onPressed: () =>
                          widget.onModeChanged(LibraryAddDialogMode.search),
                    ),
                    _LibraryAddModeActionButton(
                      icon: Icons.edit_note,
                      label: 'Manual',
                      accent: widget.accent,
                      onPressed: widget.onManual,
                    ),
                    const Spacer(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _LibraryAddModeTextField(
                          fieldKey: const ValueKey('library-add-barcode-field'),
                          controller: widget.barcodeController,
                          label: 'Barcode / UPC / ISBN',
                          hintText: 'Scan or enter barcode / UPC / ISBN...',
                          keyboardType: TextInputType.number,
                          onSubmitted: widget.onLookupBarcode,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Text(
                        'Create a quick draft, then review details before saving it to your collection.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LibraryAddModeActionButton(
                      icon: Icons.search,
                      label: 'Back to Search',
                      accent: widget.accent,
                      onPressed: () =>
                          widget.onModeChanged(LibraryAddDialogMode.search),
                    ),
                  ],
                ],
              ),
              if (widget.mode == LibraryAddDialogMode.search && widget.showAdvanced) ...[
                const SizedBox(height: 6),
                _AdvancedSearchFields(
                  searchLabels: searchLabels,
                  seriesController: _seriesController,
                  numberController: _numberController,
                  publisherController: _publisherController,
                  yearController: _yearController,
                  advancedFilterFields: advancedFields,
                  onSubmitted: _handleSearch,
                ),
              ],
              if (widget.mode == LibraryAddDialogMode.search &&
                  widget.videoKindFilters != null &&
                  widget.onVideoKindFilterChanged != null) ...[
                const SizedBox(height: 6),
                _VideoKindFilterRow(
                  options: widget.type.addChrome.videoKindFilterOptions,
                  filters: widget.videoKindFilters!,
                  accent: widget.accent,
                  onChanged: widget.onVideoKindFilterChanged!,
                ),
              ],
              if (widget.mode == LibraryAddDialogMode.search &&
                  widget.showSuggestions &&
                  widget.suggestions.isNotEmpty)
                _SuggestionDropdown(
                  suggestions: widget.suggestions,
                  accent: widget.accent,
                  onSelect: widget.onSelectSuggestion,
                  onDismiss: widget.onDismissSuggestions,
                ),
            ],
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
        child: Column(
          children: [
            _LibraryAddModeTabStrip(
              type: widget.type,
              accent: widget.accent,
              mode: widget.mode,
              onModeChanged: widget.onModeChanged,
              onManual: widget.onManual,
              onScan: () => widget.onModeChanged(LibraryAddDialogMode.barcode),
            ),
            const SizedBox(height: 7),
            switch (widget.mode) {
              LibraryAddDialogMode.search => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _AdvancedToggleButton(
                          expanded: widget.showAdvanced,
                          accent: widget.accent,
                          onPressed: widget.onToggleAdvanced,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LibraryToolbarSearch(
                            textFieldKey:
                                const ValueKey('library-add-query-field'),
                            controller: widget.queryController,
                            hintText: searchLabels.queryHint,
                            onSearch: (_) => _handleSearch(),
                            onChanged: widget.onQueryChanged,
                            onScanBarcode: () =>
                                widget.onModeChanged(LibraryAddDialogMode.barcode),
                            onScanCover: widget.canScanCover ? widget.onScanCover : null,
                            selectionColor: widget.accent,
                            maxWidth: 620,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _LibraryAddModeButton(
                          label: 'Search ${widget.type.pluralLabel}',
                          icon: Icons.search,
                          accent: widget.accent,
                          isBusy: widget.isSearching,
                          onPressed: isBusy ? null : _handleSearch,
                        ),
                      ],
                    ),
                    if (widget.showAdvanced) ...[
                      const SizedBox(height: 6),
                      _AdvancedSearchFields(
                        searchLabels: searchLabels,
                        seriesController: _seriesController,
                        numberController: _numberController,
                        publisherController: _publisherController,
                        yearController: _yearController,
                        advancedFilterFields: advancedFields,
                        onSubmitted: _handleSearch,
                      ),
                    ],
                    if (widget.videoKindFilters != null &&
                        widget.onVideoKindFilterChanged != null)
                      _VideoKindFilterRow(
                        options: widget.type.addChrome.videoKindFilterOptions,
                        filters: widget.videoKindFilters!,
                        accent: widget.accent,
                        onChanged: widget.onVideoKindFilterChanged!,
                      ),
                    if (widget.showSuggestions && widget.suggestions.isNotEmpty)
                      _SuggestionDropdown(
                        suggestions: widget.suggestions,
                        accent: widget.accent,
                        onSelect: widget.onSelectSuggestion,
                        onDismiss: widget.onDismissSuggestions,
                      ),
                  ],
                ),
              LibraryAddDialogMode.barcode => Row(
                  children: [
                    Expanded(
                      child: _LibraryAddModeTextField(
                        fieldKey: const ValueKey('library-add-barcode-field'),
                        controller: widget.barcodeController,
                        label: 'Barcode / UPC / ISBN',
                        hintText: 'Scan or enter barcode / UPC / ISBN...',
                        keyboardType: TextInputType.number,
                        onSubmitted: widget.onLookupBarcode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Lookup barcode',
                      icon: Icons.manage_search,
                      accent: widget.accent,
                      isBusy: widget.isSearching,
                      onPressed: isBusy ? null : widget.onLookupBarcode,
                    ),
                  ],
                ),
              LibraryAddDialogMode.manual => Row(
                  children: [
                    Icon(Icons.edit_note, size: 18, color: widget.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Start a manual draft here, then review the full editor before saving.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Manual draft',
                      icon: Icons.edit_note,
                      accent: widget.accent,
                      outlined: true,
                      onPressed: widget.onManual,
                    ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _LibraryAddModeTabStrip extends StatelessWidget {
  const _LibraryAddModeTabStrip({
    required this.type,
    required this.accent,
    required this.mode,
    required this.onModeChanged,
    required this.onManual,
    required this.onScan,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryAddDialogMode mode;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final VoidCallback onManual;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Text(
            'Search by',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddModeTab(
                    icon: type.workspace.icon,
                    label: 'Search',
                    accent: accent,
                    selected: mode == LibraryAddDialogMode.search,
                    onTap: () => onModeChanged(LibraryAddDialogMode.search),
                  ),
                  LibraryAddModeTab(
                    icon: Icons.qr_code_2,
                    label: 'Barcode',
                    accent: accent,
                    selected: mode == LibraryAddDialogMode.barcode,
                    onTap: () => onModeChanged(LibraryAddDialogMode.barcode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _LibraryAddModeActionButton(
            icon: Icons.edit_note,
            label: 'Manual',
            accent: accent,
            onPressed: onManual,
          ),
          _LibraryAddModeActionButton(
            icon: Icons.barcode_reader,
            label: 'Scan',
            accent: accent,
            onPressed: onScan,
          ),
          const SizedBox(width: 4),
          Icon(Icons.menu, size: 26, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _LibraryAddModeActionButton extends StatelessWidget {
  const _LibraryAddModeActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: accent,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _LibraryAddModeTextField extends StatelessWidget {
  const _LibraryAddModeTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onSubmitted,
    this.keyboardType,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: kLibraryAddModeControlHeight,
      child: _LibraryAddModeFieldFrame(
        child: TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: [noNewlineFormatter],
          expands: true,
          minLines: null,
          maxLines: null,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          onSubmitted: (_) => onSubmitted(),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            semanticCounterText: label,
            hintText: hintText,
            hintStyle: TextStyle(color: palette.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ),
    );
  }
}

class _LibraryAddModeFieldFrame extends StatelessWidget {
  const _LibraryAddModeFieldFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: kLibraryAddModeControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: child,
    );
  }
}

class _LibraryAddModeButton extends StatelessWidget {
  const _LibraryAddModeButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onPressed,
    this.isBusy = false,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 7),
              Text(label),
            ],
          );
    final style = outlined
        ? libraryAddOutlinedButtonStyle(accent)
        : libraryAddFilledButtonStyle(accent);
    return SizedBox(
      height: kLibraryAddModeControlHeight,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: style,
              child: child,
            ),
    );
  }
}

class _AdvancedToggleButton extends StatelessWidget {
  const _AdvancedToggleButton({
    required this.expanded,
    required this.accent,
    required this.onPressed,
  });

  final bool expanded;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kLibraryAddModeControlHeight,
      width: kLibraryAddModeControlHeight,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          expanded ? Icons.unfold_less : Icons.unfold_more,
          size: 20,
        ),
        tooltip: expanded ? 'Hide advanced fields' : 'Show advanced fields',
        style: IconButton.styleFrom(
          foregroundColor: expanded ? accent : kAppTextSecondary,
          backgroundColor:
              expanded ? accent.withValues(alpha: 0.15) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(
              color:
                  expanded ? accent.withValues(alpha: 0.5) : kAppBorderSubtle,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AdvancedSearchFields extends StatelessWidget {
  const _AdvancedSearchFields({
    required this.searchLabels,
    this.seriesController,
    this.numberController,
    this.publisherController,
    this.yearController,
    this.advancedFilterFields = const [],
    required this.onSubmitted,
  });

  final LibraryMediaSearchFieldLabels searchLabels;
  final TextEditingController? seriesController;
  final TextEditingController? numberController;
  final TextEditingController? publisherController;
  final TextEditingController? yearController;
  final List<LibraryAddAdvancedFilterField> advancedFilterFields;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    if (advancedFilterFields.isNotEmpty) {
      return Row(
        children: [
          for (int i = 0; i < advancedFilterFields.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            if (advancedFilterFields[i].width != null)
              SizedBox(
                width: advancedFilterFields[i].width,
                child: _AdvancedField(
                  fieldKey: advancedFilterFields[i].key,
                  controller: advancedFilterFields[i].controller,
                  hint: advancedFilterFields[i].label,
                  onSubmitted: onSubmitted,
                ),
              )
            else
              Expanded(
                flex: i == 0 ? 3 : (i == 1 ? 1 : 2),
                child: _AdvancedField(
                  fieldKey: advancedFilterFields[i].key,
                  controller: advancedFilterFields[i].controller,
                  hint: advancedFilterFields[i].label,
                  onSubmitted: onSubmitted,
                ),
              ),
          ],
        ],
      );
    }
    return Row(
      children: [
        if (seriesController != null)
          Expanded(
            flex: 3,
            child: _AdvancedField(
              fieldKey: const ValueKey('library-add-series-field'),
              controller: seriesController!,
              hint: searchLabels.seriesHint,
              onSubmitted: onSubmitted,
            ),
          ),
        if (numberController != null) ...[
          if (seriesController != null) const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: _AdvancedField(
              fieldKey: const ValueKey('library-add-number-field'),
              controller: numberController!,
              hint: searchLabels.numberHint,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
        if (publisherController != null) ...[
          if (seriesController != null || numberController != null)
            const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _AdvancedField(
              fieldKey: const ValueKey('library-add-publisher-field'),
              controller: publisherController!,
              hint: searchLabels.publisherHint,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
        if (yearController != null) ...[
          if (seriesController != null ||
              numberController != null ||
              publisherController != null)
            const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: _AdvancedField(
              fieldKey: const ValueKey('library-add-year-field'),
              controller: yearController!,
              hint: 'Year',
              keyboardType: TextInputType.number,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ],
    );
  }
}

class _AdvancedField extends StatelessWidget {
  const _AdvancedField({
    required this.fieldKey,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.keyboardType,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      height: 30,
      child: _LibraryAddModeFieldFrame(
        child: TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: [noNewlineFormatter],
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          onSubmitted: (_) => onSubmitted(),
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: palette.textMuted,
              fontSize: 13,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
      ),
    );
  }
}

class _SuggestionDropdown extends StatelessWidget {
  const _SuggestionDropdown({
    required this.suggestions,
    required this.accent,
    required this.onSelect,
    required this.onDismiss,
  });

  final List<LibraryMetadataItem> suggestions;
  final Color accent;
  final ValueChanged<LibraryMetadataItem> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: palette.field,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: palette.divider),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return _SuggestionTile(
            item: item,
            accent: accent,
            onTap: () => onSelect(item),
          );
        },
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  final LibraryMetadataItem item;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final year = item.releaseDate?.year;
    final subtitle = [
      if (year != null) year.toString(),
      item.mediaKind.apiValue,
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            if (item.coverImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  item.coverImageUrl!,
                  width: 28,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 28, height: 40),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: accent),
          ],
        ),
      ),
    );
  }
}

class _VideoKindFilterRow extends StatelessWidget {
  const _VideoKindFilterRow({
    required this.options,
    required this.filters,
    required this.accent,
    required this.onChanged,
  });

  final List<LibraryAddVideoKindFilterOption> options;
  final Set<String> filters;
  final Color accent;
  final void Function(String kind, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          for (final option in options) ...[
            _VideoKindCheckbox(
              label: option.label,
              icon: option.icon,
              checked: filters.contains(option.kind),
              accent: accent,
              textColor: palette.textMuted,
              onChanged: (checked) => onChanged(option.kind, checked),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _VideoKindCheckbox extends StatelessWidget {
  const _VideoKindCheckbox({
    required this.label,
    required this.icon,
    required this.checked,
    required this.accent,
    required this.textColor,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool checked;
  final Color accent;
  final Color textColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: checked ? accent : textColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: checked ? accent : textColor,
                fontSize: 11,
                fontWeight: checked ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
