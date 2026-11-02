import 'dart:math' as math;
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/add/mobile/search_controls.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/add/models/advanced_filter.dart';
import 'dependencies.dart';

class LibraryAddIdentifierPrefillBanner extends StatelessWidget {
  const LibraryAddIdentifierPrefillBanner({
    super.key,
    required this.type,
    required this.identifierCode,
  });

  final LibraryKindRegistration type;
  final String identifierCode;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.infoBackground,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.qr_code_2, size: 18, color: palette.infoForeground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Barcode $identifierCode is prefilled for ${type.identity.pluralLabel.toLowerCase()}. Search Core or add it manually with the same code.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.infoForeground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
    required this.isWideLayout,
    required this.mode,
    required this.queryController,
    required this.identifierController,
    this.codeSearchTab,
    this.codeQueryController,
    this.browseTab,
    this.browseQueryController,
    this.onBrowseChanged,
    this.onSearchBrowse,
    this.queryTrailing,
    required this.isSearching,
    required this.onModeChanged,
    required this.onSearch,
    required this.onQueryChanged,
    required this.suggestions,
    this.suggestionDetail,
    required this.showSuggestions,
    required this.onSelectSuggestion,
    required this.onDismissSuggestions,
    required this.canScanCover,
    required this.isScanningCover,
    required this.onScanCover,
    required this.onLookupIdentifier,
    required this.onScanBarcode,
    required this.onSearchCode,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.advancedFilterState,
    required this.onAdvancedFilterChanged,
    required this.advancedFilterDescriptors,
    this.onCoreDataSettings,
    this.searchRowWidth,
    this.searchRowBeside,
    this.showMobileInput = true,
    this.onCoverTabChanged,
    this.coverSelected = false,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final bool isWideLayout;
  final LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController identifierController;

  /// Set with [codeQueryController] when the kind adds a code search tab.
  final LibraryAddCodeSearchTab? codeSearchTab;
  final TextEditingController? codeQueryController;

  /// Set with [browseQueryController] and [onSearchBrowse] when the kind
  /// adds a browse tab.
  final LibraryAddBrowseCapability? browseTab;
  final TextEditingController? browseQueryController;

  /// Each edit of the browse field, for suggestions while typing.
  final ValueChanged<String>? onBrowseChanged;
  final VoidCallback? onSearchBrowse;
  final bool isSearching;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;

  /// Kind control inside the end of the title field in Search mode.
  final Widget? queryTrailing;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final List<CatalogSearchCandidate> suggestions;

  /// The line under a suggestion's title, such as a game's platform; the
  /// kind's search result line otherwise.
  final Widget Function(BuildContext context, CatalogSearchCandidate item)?
      suggestionDetail;
  final bool showSuggestions;
  final ValueChanged<CatalogSearchCandidate> onSelectSuggestion;
  final VoidCallback onDismissSuggestions;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupIdentifier;
  final VoidCallback onScanBarcode;
  final VoidCallback onSearchCode;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilterState;
  final LibraryAddAdvancedFilterChanged onAdvancedFilterChanged;
  final List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors;

  /// Opens the Add/Update from Core settings from the tab row's gear.
  final VoidCallback? onCoreDataSettings;

  /// Narrows the search row to [searchRowWidth] and shows [searchRowBeside]
  /// in the rest, for results laid out in two panes.
  final bool coverSelected;
  final ValueChanged<bool>? onCoverTabChanged;
  final bool showMobileInput;
  final double? searchRowWidth;
  final Widget? searchRowBeside;

  @override
  State<LibraryAddModeBar> createState() => _LibraryAddModeBarState();
}

class _LibraryAddModeBarState extends State<LibraryAddModeBar> {
  final Map<LibraryAddFilterId, TextEditingController> _advancedControllers =
      {};
  final OverlayPortalController _suggestionsOverlayController =
      OverlayPortalController();
  final LayerLink _searchLayerLink = LayerLink();
  final GlobalKey _searchBarKey = GlobalKey();
  bool _dismissed = false;
  bool get _mobileCoverSelected => widget.coverSelected;

  @override
  void initState() {
    super.initState();
    _syncAdvancedControllers(_resolveAdvancedFields());
    if (widget.showSuggestions && widget.suggestions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_suggestionsOverlayController.isShowing &&
            !_dismissed &&
            widget.showSuggestions &&
            widget.suggestions.isNotEmpty) {
          _suggestionsOverlayController.show();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant LibraryAddModeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAdvancedControllers(_resolveAdvancedFields());
    final canShow =
        widget.showSuggestions && widget.suggestions.isNotEmpty && !_dismissed;
    if (canShow && !_suggestionsOverlayController.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_suggestionsOverlayController.isShowing &&
            !_dismissed &&
            widget.showSuggestions &&
            widget.suggestions.isNotEmpty) {
          _suggestionsOverlayController.show();
        }
      });
    } else if (!canShow && _suggestionsOverlayController.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _suggestionsOverlayController.isShowing) {
          _suggestionsOverlayController.hide();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _advancedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleQueryChanged(String value) {
    setState(() => _dismissed = false);
    widget.onQueryChanged(value);
  }

  void _handleSearch() {
    if (_suggestionsOverlayController.isShowing) {
      _suggestionsOverlayController.hide();
    }
    setState(() => _dismissed = true);
    widget.onDismissSuggestions();
    final fields = _resolveAdvancedFields();
    for (final field in fields) {
      widget.onAdvancedFilterChanged(
        field.id,
        LibraryAddTextFilterValue(
          field.parse(_advancedControllers[field.id]!.text),
        ),
      );
    }
    widget.onSearch();
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

  Widget _buildSuggestionsOverlay(BuildContext overlayContext) {
    if (_dismissed || !widget.showSuggestions || widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    final renderBox =
        _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    final targetWidth =
        renderBox?.hasSize == true ? renderBox!.size.width : 540.0;
    final palette = appPalette(overlayContext);
    final borderColor = Color.alphaBlend(
      widget.accent.withValues(alpha: palette.isDark ? 0.34 : 0.22),
      palette.divider,
    );
    return Align(
      alignment: Alignment.topLeft,
      // The tap region sits inside the follower: outside it, hits are tested
      // where the overlay is laid out, not where the list is drawn, so taps
      // on a suggestion only closed the list.
      child: CompositedTransformFollower(
        link: _searchLayerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: Offset.zero,
        child: TapRegion(
          groupId: this,
          onTapOutside: (_) {
            if (_suggestionsOverlayController.isShowing) {
              _suggestionsOverlayController.hide();
            }
            if (mounted) {
              setState(() {
                _dismissed = true;
              });
            }
            widget.onDismissSuggestions();
          },
          child: SizedBox(
            width: targetWidth,
            child: Material(
              color: palette.panel,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // The reference's "Search for" row and heading come first.
                  itemCount: widget.suggestions.length + 2,
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox.shrink()
                      : Divider(height: 1, color: palette.divider),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _SuggestedSearchRow(
                          query: widget.queryController.text,
                          onTap: _handleSearch);
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                        child: Text('Or pick from these suggestions:',
                            style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      );
                    }
                    final item = widget.suggestions[index - 2];
                    return _SuggestionTile(
                      type: widget.type,
                      item: item,
                      detail: widget.suggestionDetail?.call(context, item),
                      accent: widget.accent,
                      onTap: () {
                        if (_suggestionsOverlayController.isShowing) {
                          _suggestionsOverlayController.hide();
                        }
                        if (mounted) {
                          setState(() {
                            _dismissed = true;
                          });
                        }
                        widget.onSelectSuggestion(item);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LibraryAddAdvancedFilterField<String>> _resolveAdvancedFields() {
    return widget.advancedFilterDescriptors;
  }

  Widget _buildInput(String searchLabel, String queryHint) =>
      switch (widget.mode) {
        LibraryAddDialogMode.browse => _LibraryAddModeTextField(
            mobile: appPresentationPlatform.isNativeMobile,
            fieldKey: const ValueKey('library-add-browse-field'),
            controller: widget.browseQueryController!,
            label: widget.browseTab!.label,
            hintText: widget.browseTab!.hintText,
            onChanged: widget.onBrowseChanged,
            onSubmitted: widget.onSearchBrowse!,
          ),
        LibraryAddDialogMode.search => OverlayPortal(
            controller: _suggestionsOverlayController,
            overlayChildBuilder: _buildSuggestionsOverlay,
            child: CompositedTransformTarget(
              link: _searchLayerLink,
              child: KeyedSubtree(
                key: _searchBarKey,
                child: _LibraryAddModeTextField(
                  mobile: appPresentationPlatform.isNativeMobile,
                  fieldKey: const ValueKey('library-add-query-field'),
                  controller: widget.queryController,
                  label: searchLabel,
                  hintText: queryHint,
                  onChanged: _handleQueryChanged,
                  onSubmitted: _handleSearch,
                  trailing: widget.queryTrailing,
                ),
              ),
            ),
          ),
        LibraryAddDialogMode.identifier => _LibraryAddModeTextField(
            mobile: appPresentationPlatform.isNativeMobile,
            fieldKey: const ValueKey('library-add-barcode-field'),
            controller: widget.identifierController,
            label: 'Barcode / UPC / ISBN',
            hintText: 'Enter barcode...',
            keyboardType: TextInputType.number,
            onSubmitted: widget.onLookupIdentifier,
            trailing:
                _LibraryAddScanBarcodeButton(onPressed: widget.onScanBarcode),
          ),
        LibraryAddDialogMode.code => _LibraryAddModeTextField(
            mobile: appPresentationPlatform.isNativeMobile,
            fieldKey: const ValueKey('library-add-code-field'),
            controller: widget.codeQueryController!,
            label: widget.codeSearchTab!.label,
            hintText: widget.codeSearchTab!.hintText,
            onSubmitted: widget.onSearchCode,
            trailing: widget.queryTrailing,
          ),
      };

  Widget _buildMobile(
      BuildContext context, String searchLabel, String queryHint) {
    final tabs = <({LibraryAddDialogMode? value, String label})>[
      if (widget.canScanCover) (value: null, label: 'Cover'),
      (value: LibraryAddDialogMode.identifier, label: 'Barcode'),
      if (widget.browseTab case final tab?)
        (value: LibraryAddDialogMode.browse, label: tab.label),
      (value: LibraryAddDialogMode.search, label: searchLabel),
      if (widget.codeSearchTab case final tab?)
        (value: LibraryAddDialogMode.code, label: tab.label),
    ];
    return LibraryAddMobileSearchControls<LibraryAddDialogMode?>(
      tabs: tabs,
      selected: _mobileCoverSelected ? null : widget.mode,
      accent: widget.accent,
      onSelected: (mode) {
        FocusScope.of(context).unfocus();
        widget.onDismissSuggestions();
        widget.onCoverTabChanged?.call(mode == null);
        if (mode != null) widget.onModeChanged(mode);
      },
      input: _mobileCoverSelected
          ? FilledButton.icon(
              onPressed: widget.isScanningCover ? null : widget.onScanCover,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan cover'))
          : widget.showMobileInput
              ? _besideSearchRow(_buildInput(searchLabel, queryHint))
              : null,
      advanced: !_mobileCoverSelected &&
              widget.mode == LibraryAddDialogMode.search &&
              _resolveAdvancedFields().isNotEmpty
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              TextButton.icon(
                  onPressed: widget.onToggleAdvanced,
                  icon: Icon(widget.showAdvanced
                      ? Icons.expand_less
                      : Icons.expand_more),
                  label: const Text('Advanced search')),
              if (widget.showAdvanced)
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: _AdvancedSearchFields(
                        advancedFilterDescriptors: _resolveAdvancedFields(),
                        controllers: _advancedControllers,
                        onSubmitted: _handleSearch)),
            ])
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isSearching;
    final searchLabels =
        libraryPresentationForKind(widget.type.kind).searchFieldLabels;
    final palette = appPalette(context);
    final advancedFields = _resolveAdvancedFields();
    _syncAdvancedControllers(advancedFields);
    if (appPresentationPlatform.isNativeMobile) {
      return _buildMobile(
          context, searchLabels.addSearchTabLabel, searchLabels.queryHint);
    }
    if (widget.isWideLayout) {
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
                          widget.onModeChanged(LibraryAddDialogMode.identifier),
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
                        child: OverlayPortal(
                          controller: _suggestionsOverlayController,
                          overlayChildBuilder: _buildSuggestionsOverlay,
                          child: CompositedTransformTarget(
                            link: _searchLayerLink,
                            child: KeyedSubtree(
                              key: _searchBarKey,
                              child: LibraryToolbarSearch(
                                textFieldKey:
                                    const ValueKey('library-add-query-field'),
                                controller: widget.queryController,
                                hintText: searchLabels.queryHint,
                                onSearch: (_) => _handleSearch(),
                                onChanged: _handleQueryChanged,
                                onScanBarcode: () => widget.onModeChanged(
                                    LibraryAddDialogMode.identifier),
                                onScanCover: widget.canScanCover
                                    ? widget.onScanCover
                                    : null,
                                selectionColor: widget.accent,
                                maxWidth: 620,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LibraryAddModeButton(
                      label: 'Search ${widget.type.identity.pluralLabel}',
                      icon: Icons.search,
                      accent: widget.accent,
                      isBusy: widget.isSearching,
                      onPressed: isBusy ? null : _handleSearch,
                    ),
                  ] else if (widget.mode ==
                      LibraryAddDialogMode.identifier) ...[
                    _LibraryAddModeButton(
                      label: 'Lookup',
                      icon: Icons.manage_search,
                      accent: widget.accent,
                      isBusy: widget.isSearching,
                      onPressed: isBusy ? null : widget.onLookupIdentifier,
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
                          controller: widget.identifierController,
                          label: 'Barcode / UPC / ISBN',
                          hintText: 'Scan or enter barcode / UPC / ISBN...',
                          keyboardType: TextInputType.number,
                          onSubmitted: widget.onLookupIdentifier,
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
                          fontSize: 13,
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
              if (widget.mode == LibraryAddDialogMode.search &&
                  widget.showAdvanced) ...[
                const SizedBox(height: 6),
                _AdvancedSearchFields(
                  advancedFilterDescriptors: advancedFields,
                  controllers: _advancedControllers,
                  onSubmitted: _handleSearch,
                ),
              ],
            ],
          ),
        ),
      );
    }
    final showAdvancedToggle = advancedFields.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LibraryAddModeTabStrip(
          searchLabel: searchLabels.addSearchTabLabel,
          searchIcon: searchLabels.addSearchTabIcon ?? AppIcons.search,
          mode: widget.mode,
          onModeChanged: widget.onModeChanged,
          browseTab: widget.browseTab,
          codeSearchTab: widget.codeSearchTab,
          onManual: widget.onManual,
          onCoreDataSettings: widget.onCoreDataSettings,
          onScanCover: widget.canScanCover && !widget.isScanningCover
              ? widget.onScanCover
              : null,
        ),
        _besideSearchRow(ColoredBox(
          color: libraryAddSearchBackground(context),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (widget.mode == LibraryAddDialogMode.search &&
                        showAdvancedToggle) ...[
                      _AdvancedToggleButton(
                        expanded: widget.showAdvanced,
                        accent: widget.accent,
                        onPressed: widget.onToggleAdvanced,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Expanded(
                        child: _buildInput(searchLabels.addSearchTabLabel,
                            searchLabels.queryHint)),
                    const SizedBox(width: 10),
                    _LibraryAddSearchButton(
                      isBusy: widget.isSearching,
                      onPressed: isBusy
                          ? null
                          : switch (widget.mode) {
                              LibraryAddDialogMode.browse =>
                                widget.onSearchBrowse,
                              LibraryAddDialogMode.search => _handleSearch,
                              LibraryAddDialogMode.identifier =>
                                widget.onLookupIdentifier,
                              LibraryAddDialogMode.code => widget.onSearchCode,
                            },
                    ),
                  ],
                ),
                if (widget.mode == LibraryAddDialogMode.search &&
                    widget.showAdvanced) ...[
                  const SizedBox(height: 5),
                  _AdvancedSearchFields(
                    advancedFilterDescriptors: advancedFields,
                    controllers: _advancedControllers,
                    onSubmitted: _handleSearch,
                  ),
                ],
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _besideSearchRow(Widget searchRow) {
    final width = widget.searchRowWidth;
    final beside = widget.searchRowBeside;
    if (width == null || beside == null) return searchRow;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: width, child: searchRow),
          ColoredBox(
            color: appPalette(context).canvas,
            child: const SizedBox(width: 6),
          ),
          Expanded(child: beside),
        ],
      ),
    );
  }
}

class _LibraryAddModeTabStrip extends StatelessWidget {
  const _LibraryAddModeTabStrip({
    required this.searchLabel,
    required this.searchIcon,
    required this.mode,
    required this.onModeChanged,
    required this.browseTab,
    required this.codeSearchTab,
    required this.onManual,
    this.onCoreDataSettings,
    this.onScanCover,
  });

  final String searchLabel;
  final IconData searchIcon;
  final LibraryAddDialogMode mode;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final LibraryAddBrowseCapability? browseTab;
  final LibraryAddCodeSearchTab? codeSearchTab;
  final VoidCallback onManual;
  final VoidCallback? onCoreDataSettings;
  final VoidCallback? onScanCover;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 35,
      color: palette.isDark ? const Color(0xff383838) : palette.panelRaised,
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (browseTab case final tab?)
                    LibraryAddModeTab(
                      icon: Icon(tab.icon),
                      label: tab.label,
                      selected: mode == LibraryAddDialogMode.browse,
                      onTap: () => onModeChanged(LibraryAddDialogMode.browse),
                    ),
                  LibraryAddModeTab(
                    icon: Icon(searchIcon),
                    label: searchLabel,
                    selected: mode == LibraryAddDialogMode.search,
                    onTap: () => onModeChanged(LibraryAddDialogMode.search),
                  ),
                  LibraryAddModeTab(
                    icon: SvgPicture.asset(
                      AppIcons.barcodeScanSvg,
                      width: 20,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                          palette.textPrimary, BlendMode.srcIn),
                    ),
                    label: 'Barcode',
                    selected: mode == LibraryAddDialogMode.identifier,
                    onTap: () => onModeChanged(LibraryAddDialogMode.identifier),
                  ),
                  if (codeSearchTab case final tab?)
                    LibraryAddModeTab(
                      icon: Icon(tab.icon ?? AppIcons.tags),
                      label: tab.label,
                      selected: mode == LibraryAddDialogMode.code,
                      onTap: () => onModeChanged(LibraryAddDialogMode.code),
                    ),
                  if (onCoreDataSettings != null)
                    _LibraryAddModeIconButton(
                      icon: AppIcons.settings,
                      tooltip: 'Add/Update from Core settings',
                      onPressed: onCoreDataSettings!,
                    ),
                  if (onScanCover != null)
                    _LibraryAddModeIconButton(
                      icon: AppIcons.camera,
                      tooltip: 'Search by cover',
                      onPressed: onScanCover!,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: TextButton(
              key: const ValueKey('library-add-manually'),
              onPressed: onManual,
              style: TextButton.styleFrom(
                foregroundColor: palette.textPrimary,
                overlayColor: Colors.transparent,
                minimumSize: const Size(0, 30),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                textStyle: TextStyle(
                  fontFamily: appFontFamily,
                  fontFamilyFallback: kAppFontFamilyFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Manually'),
                  SizedBox(width: 5),
                  Icon(AppIcons.chevronRight, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryAddModeIconButton extends StatelessWidget {
  const _LibraryAddModeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: 0.5,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: onPressed,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: SizedBox(
              width: 38,
              height: 30,
              child:
                  Icon(icon, size: 14, color: appPalette(context).textPrimary),
            ),
          ),
        ));
  }
}

/// The blue Search button beside the Add dialog's field.
class _LibraryAddSearchButton extends StatelessWidget {
  const _LibraryAddSearchButton(
      {required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      height: 34,
      child: FilledButton(
        key: const ValueKey('library-add-search-button'),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.utilityAction,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              palette.utilityAction.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(81, 34),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          textStyle: TextStyle(
            fontFamily: appFontFamily,
            fontFamilyFallback: kAppFontFamilyFallback,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: isBusy
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Search'),
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
          foregroundColor: libraryAccentTextColor(
            accent,
            Theme.of(context).colorScheme.surface,
          ),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          textStyle: TextStyle(
            fontFamily: appFontFamily,
            fontFamilyFallback: kAppFontFamilyFallback,
            fontWeight: FontWeight.w700,
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
    this.onChanged,
    this.keyboardType,
    this.trailing,
    this.mobile = false,
  });

  final bool mobile;
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final VoidCallback onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    void submit() {
      if (mobile) FocusScope.of(context).unfocus();
      onSubmitted();
    }

    final field = TextField(
      key: fieldKey,
      controller: controller,
      onChanged: onChanged,
      cursorColor: palette.utilityAction,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: [noNewlineFormatter],
      autofocus: mobile && controller.text.isEmpty,
      expands: !mobile,
      minLines: mobile ? 1 : null,
      maxLines: mobile ? 1 : null,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (_) => submit(),
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        fillColor: Colors.transparent,
        border: mobile
            ? const OutlineInputBorder(borderRadius: BorderRadius.zero)
            : InputBorder.none,
        enabledBorder: mobile
            ? OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: palette.divider))
            : InputBorder.none,
        focusedBorder: mobile
            ? OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: palette.utilityAction, width: 2))
            : InputBorder.none,
        disabledBorder: InputBorder.none,
        semanticCounterText: label,
        labelText: mobile ? hintText : null,
        floatingLabelBehavior: mobile ? FloatingLabelBehavior.always : null,
        suffixIcon: mobile
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                if (trailing != null) trailing!,
                IconButton(
                    tooltip: 'Search',
                    onPressed: submit,
                    icon: const Icon(Icons.search)),
              ])
            : trailing,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 34, minHeight: 34),
        hintText: mobile ? null : hintText,
        hintStyle: TextStyle(
          color: palette.isDark ? const Color(0xff999999) : palette.textMuted,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
    if (mobile) return SizedBox(height: 56, child: field);
    return SizedBox(height: 34, child: _LibraryAddModeFieldFrame(child: field));
  }
}

/// The barcode glyph of the main search bar, opening the scanner.
class _LibraryAddScanBarcodeButton extends StatelessWidget {
  const _LibraryAddScanBarcodeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Scan barcode',
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: SvgPicture.asset(
              AppIcons.barcodeScanSvg,
              width: 22,
              height: 18,
              colorFilter: ColorFilter.mode(
                  appPalette(context).textPrimary, BlendMode.srcIn),
            ),
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xff444444) : palette.field,
        borderRadius: BorderRadius.circular(4),
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
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback? onPressed;
  final bool isBusy;

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
    return SizedBox(
      height: kLibraryAddModeControlHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: libraryAddFilledButtonStyle(accent),
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
    final palette = appPalette(context);
    final selectedFill = Color.alphaBlend(
      accent.withValues(alpha: 0.15),
      Theme.of(context).colorScheme.surface,
    );
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
          foregroundColor: expanded
              ? libraryAccentTextColor(accent, selectedFill)
              : palette.textSecondary,
          backgroundColor: expanded ? selectedFill : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(
              color: expanded ? accent.withValues(alpha: 0.5) : palette.divider,
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
    this.advancedFilterDescriptors = const [],
    required this.controllers,
    required this.onSubmitted,
  });

  final List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors;
  final Map<LibraryAddFilterId, TextEditingController> controllers;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    if (advancedFilterDescriptors.isEmpty) return const SizedBox.shrink();
    if (appPresentationPlatform.isNativeMobile) {
      return LayoutBuilder(
          builder: (context, constraints) =>
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final descriptor in advancedFilterDescriptors)
                  SizedBox(
                      width: math.min(
                          descriptor.width ?? 200, constraints.maxWidth),
                      child: _AdvancedField(
                          fieldKey: descriptor.key,
                          controller: controllers[descriptor.id]!,
                          hint: descriptor.label,
                          keyboardType: descriptor.keyboardType,
                          onSubmitted: onSubmitted)),
              ]));
    }
    return Row(
      children: [
        for (int i = 0; i < advancedFilterDescriptors.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          if (advancedFilterDescriptors[i].width != null)
            SizedBox(
              width: advancedFilterDescriptors[i].width,
              child: _AdvancedField(
                fieldKey: advancedFilterDescriptors[i].key,
                controller: controllers[advancedFilterDescriptors[i].id]!,
                hint: advancedFilterDescriptors[i].label,
                keyboardType: advancedFilterDescriptors[i].keyboardType,
                onSubmitted: onSubmitted,
              ),
            )
          else
            Expanded(
              flex: advancedFilterDescriptors[i].flex,
              child: _AdvancedField(
                fieldKey: advancedFilterDescriptors[i].key,
                controller: controllers[advancedFilterDescriptors[i].id]!,
                hint: advancedFilterDescriptors[i].label,
                keyboardType: advancedFilterDescriptors[i].keyboardType,
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
          cursorColor: appPalette(context).utilityAction,
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
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
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

/// The reference's blue first row: search for what was typed.
class _SuggestedSearchRow extends StatelessWidget {
  const _SuggestedSearchRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        key: const ValueKey('library-add-suggested-query-search'),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          height: 34,
          color: appPalette(context).utilityAction,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            const Icon(AppIcons.search, size: 16, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Search for "${query.trim().toLowerCase()}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const Icon(AppIcons.chevronRight, size: 14, color: Colors.white),
          ]),
        ),
      );
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.type,
    required this.item,
    this.detail,
    required this.accent,
    required this.onTap,
  });

  final LibraryKindRegistration type;
  final CatalogSearchCandidate item;

  /// Replaces the result line under the title when set.
  final Widget? detail;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final display = libraryPresentationForKind(type.kind)
        .builder
        .buildSearchResultDisplay(item: item);
    final subtitle = [
      display?.secondaryLine,
      item.summary.subtitle,
    ]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
    final subtitleText =
        subtitle.isEmpty ? item.summary.kind.apiValue : subtitle.join(' / ');
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      hoverColor:
          palette.isDark ? const Color(0xFF464950) : palette.surfaceBright,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            if (item.summary.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  item.summary.imageUrl!,
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
                    item.summary.primaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (detail case final detail?)
                    DefaultTextStyle.merge(
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 13),
                        child: IconTheme.merge(
                            data: IconThemeData(color: palette.textMuted),
                            child: detail))
                  else if (subtitleText.isNotEmpty)
                    Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 13,
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
