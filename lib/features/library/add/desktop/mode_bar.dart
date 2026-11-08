part of '../panes/mode_bar.dart';

/// Desktop presentation over the shared Add session and input state.
extension _DesktopAddModeBar on _LibraryAddModeBarState {
  Widget _buildDesktop(BuildContext context) {
    final isBusy = widget.isSearching;
    final searchLabels =
        libraryPresentationForKind(widget.type.kind).searchFieldLabels;
    final palette = appPalette(context);
    final advancedFields = _resolveAdvancedFields();
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
          kindTabs: widget.kindTabs,
          kindTab: widget.kindTab,
          onKindTab: widget.onKindTab,
          onManual: widget.onManual,
          onCoreDataSettings: widget.onCoreDataSettings,
          onScanCover: widget.canScanCover && !widget.isScanningCover
              ? widget.onScanCover
              : null,
        ),
        if (widget.mode != LibraryAddDialogMode.kindTab &&
            (widget.mode != LibraryAddDialogMode.browse ||
                widget.browseTab?.tiles == null))
          _besideSearchRow(ColoredBox(
            color: libraryAddSearchRowBackground(context),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.mode == LibraryAddDialogMode.code &&
                      widget.listingScope != null)
                    Row(children: [
                      Expanded(flex: 3, child: widget.listingScope!),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: widget.listingOwnership!),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _LibraryAddModeTextField(
                          fieldKey: const ValueKey('library-add-code-field'),
                          controller: widget.codeQueryController!,
                          label: widget.codeSearchTab!.label,
                          hintText: widget.codeSearchTab!.hintText,
                          onChanged: widget.onListingFilterChanged,
                          onSubmitted: widget.onSearchCode,
                        ),
                      ),
                    ])
                  else
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
                                  LibraryAddDialogMode.code =>
                                    widget.onSearchCode,
                                  LibraryAddDialogMode.kindTab => null,
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
}
