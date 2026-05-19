part of 'comics_add_dialog.dart';

class _AddComicTitleBar extends StatelessWidget {
  const _AddComicTitleBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A4A4A), Color(0xFF1B1B1B)],
        ),
        border: Border(bottom: BorderSide(color: _kClzAccent)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.public, color: Color(0xFF03A9DE), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add Comics from Collectarr Core',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddComicPaneResizeHandle extends StatelessWidget {
  const _AddComicPaneResizeHandle({required this.onDragDelta});

  final ValueChanged<double> onDragDelta;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragDelta(details.delta.dx),
        child: Tooltip(
          message: 'Resize results pane',
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(
                width: 2,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComicsSearchFields {
  const _ComicsSearchFields({
    this.query = '',
    this.series = '',
    this.issueNumber = '',
  });

  final String query;
  final String series;
  final String issueNumber;
}

const double _kAddComicModeControlHeight = 36;

class _AddComicModeBar extends StatelessWidget {
  const _AddComicModeBar({
    required this.mode,
    required this.queryController,
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.barcodeBatch,
    required this.barcodeHistory,
    required this.showAdvancedFilters,
    required this.isSearching,
    required this.onModeChanged,
    required this.onAdvancedChanged,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onLookupBarcodeBatch,
    required this.barcodeAddCount,
    required this.barcodeAddLabel,
    required this.onAddBarcodeFound,
    required this.onRemoveBarcodeBatchEntry,
    required this.onClearBarcodeBatch,
    required this.onUseBarcodeHistory,
    required this.onScanBarcode,
    required this.onAddManual,
    required this.onProposeManual,
  });

  final LibraryAddMode mode;
  final TextEditingController queryController;
  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final List<BarcodeLookupEntry> barcodeBatch;
  final List<String> barcodeHistory;
  final bool showAdvancedFilters;
  final bool isSearching;
  final ValueChanged<LibraryAddMode> onModeChanged;
  final ValueChanged<bool> onAdvancedChanged;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final VoidCallback onLookupBarcodeBatch;
  final int barcodeAddCount;
  final String barcodeAddLabel;
  final VoidCallback? onAddBarcodeFound;
  final ValueChanged<String> onRemoveBarcodeBatchEntry;
  final VoidCallback onClearBarcodeBatch;
  final ValueChanged<String> onUseBarcodeHistory;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kClzToolbar,
        border: Border(bottom: BorderSide(color: Color(0xFF111111))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
        child: Column(
          children: [
            _AddModeTabStrip(
              mode: mode,
              onModeChanged: onModeChanged,
              onAddManual: onAddManual,
              onProposeManual: onProposeManual,
              onScanBarcode: onScanBarcode,
            ),
            const SizedBox(height: 7),
            switch (mode) {
              LibraryAddMode.addSeries => Row(
                  children: [
                    Expanded(
                      child: _PrimarySearchField(
                        controller: queryController,
                        hintText: 'Enter series title...',
                        onSubmitted: onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterField(
                      width: 92,
                      controller: yearController,
                      label: 'Year',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      onSubmitted: onSearch,
                    ),
                    const SizedBox(width: 10),
                    _ModeSearchButton(
                      label: 'Search Series',
                      isSearching: isSearching,
                      onPressed: onSearch,
                    ),
                  ],
                ),
              LibraryAddMode.addIssue => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PrimarySearchField(
                            controller: seriesController,
                            hintText: 'Enter series title...',
                            onSubmitted: onSearch,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _FilterField(
                          width: 96,
                          controller: issueController,
                          label: 'Issue',
                          textAlign: TextAlign.center,
                          onSubmitted: onSearch,
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          selected: showAdvancedFilters,
                          onSelected: onAdvancedChanged,
                          avatar: const Icon(Icons.tune, size: 18),
                          label: const Text('Filters'),
                        ),
                        const SizedBox(width: 10),
                        _ModeSearchButton(
                          label: 'Search Issue',
                          isSearching: isSearching,
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                    if (showAdvancedFilters) ...[
                      const SizedBox(height: 8),
                      _AdvancedSearchFilters(
                        seriesController: seriesController,
                        issueController: issueController,
                        publisherController: publisherController,
                        yearController: yearController,
                        barcodeController: barcodeController,
                        onSubmitted: onSearch,
                        includeSeriesAndIssue: false,
                      ),
                    ],
                  ],
                ),
              LibraryAddMode.barcode => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: _kAddComicModeControlHeight,
                            child: TextField(
                              controller: barcodeController,
                              keyboardType: TextInputType.number,
                              onSubmitted: (_) => onLookupBarcode(),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Color(0xFF4A4A4A),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code_2),
                                hintText: 'Scan or enter barcode / UPC...',
                              ),
                            ),
                          ),
                          if (barcodeHistory.isNotEmpty &&
                              barcodeBatch.isEmpty) ...[
                            const SizedBox(height: 8),
                            BarcodeHistoryStrip(
                              codes: barcodeHistory,
                              onUse: onUseBarcodeHistory,
                            ),
                          ],
                          if (barcodeBatch.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            BarcodeBatchPanel(
                              entries: barcodeBatch,
                              isLookingUp: isSearching,
                              addableCount: barcodeAddCount,
                              addFoundLabel: barcodeAddLabel,
                              onLookupAll: onLookupBarcodeBatch,
                              onAddFound: onAddBarcodeFound,
                              onRemove: onRemoveBarcodeBatchEntry,
                              onClear: onClearBarcodeBatch,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: isSearching ? null : onScanBarcode,
                      icon: const Icon(Icons.barcode_reader, size: 18),
                      label: const Text('Scan barcode'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSearching ? null : onLookupBarcode,
                      child: isSearching
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Lookup barcode'),
                    ),
                  ],
                ),
              LibraryAddMode.pullList => const _PullListModePanel(),
            },
          ],
        ),
      ),
    );
  }
}

class _AddModeTabStrip extends StatelessWidget {
  const _AddModeTabStrip({
    required this.mode,
    required this.onModeChanged,
    required this.onAddManual,
    required this.onProposeManual,
    required this.onScanBarcode,
  });

  final LibraryAddMode mode;
  final ValueChanged<LibraryAddMode> onModeChanged;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;
  final VoidCallback onScanBarcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF272A2C),
        border: Border.all(color: const Color(0xFF4D555A)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const Text(
            'Search by',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-series-tab'),
                    icon: Icons.library_books,
                    label: 'Add Series',
                    selected: mode == LibraryAddMode.addSeries,
                    onTap: () => onModeChanged(LibraryAddMode.addSeries),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-issue-tab'),
                    icon: Icons.menu_book,
                    label: 'Add Issue',
                    selected: mode == LibraryAddMode.addIssue,
                    onTap: () => onModeChanged(LibraryAddMode.addIssue),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-barcode-tab'),
                    icon: Icons.qr_code_2,
                    label: 'Barcode',
                    selected: mode == LibraryAddMode.barcode,
                    onTap: () => onModeChanged(LibraryAddMode.barcode),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-pull-list-tab'),
                    icon: Icons.star,
                    label: 'Pull List',
                    selected: mode == LibraryAddMode.pullList,
                    onTap: () => onModeChanged(LibraryAddMode.pullList),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ModeActionButton(
            icon: Icons.edit_note,
            label: 'Manual',
            onPressed: onAddManual,
          ),
          _ModeActionButton(
            icon: Icons.outbox,
            label: 'Propose',
            onPressed: onProposeManual,
          ),
          _ModeActionButton(
            icon: Icons.barcode_reader,
            label: 'Scan',
            onPressed: onScanBarcode,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.menu, size: 26, color: Color(0xFFEDEDED)),
        ],
      ),
    );
  }
}

class _ModeActionButton extends StatelessWidget {
  const _ModeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: kClzAccent,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          minimumSize: const Size(0, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _AdvancedSearchFilters extends StatelessWidget {
  const _AdvancedSearchFilters({
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.onSubmitted,
    this.includeSeriesAndIssue = true,
  });

  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final VoidCallback onSubmitted;
  final bool includeSeriesAndIssue;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (includeSeriesAndIssue) ...[
          _FilterField(
            width: 210,
            controller: seriesController,
            label: 'Series',
            onSubmitted: onSubmitted,
          ),
          _FilterField(
            width: 92,
            controller: issueController,
            label: 'Issue #',
            textAlign: TextAlign.center,
            onSubmitted: onSubmitted,
          ),
        ],
        _FilterField(
          width: 150,
          controller: publisherController,
          label: 'Publisher',
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 92,
          controller: yearController,
          label: 'Year',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 210,
          controller: barcodeController,
          label: 'Barcode / UPC',
          keyboardType: TextInputType.number,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _PrimarySearchField extends StatelessWidget {
  const _PrimarySearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kAddComicModeControlHeight,
      child: _ModeFieldFrame(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [noNewlineFormatter],
          expands: true,
          minLines: null,
          maxLines: null,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          strutStyle: const StrutStyle(
            fontSize: 15,
            height: 1,
            forceStrutHeight: true,
          ),
          onSubmitted: (_) => onSubmitted(),
          style: const TextStyle(
            color: Color(0xFFEDEDED),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9EA9B0)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _kAddComicModeControlHeight,
      child: _ModeFieldFrame(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: [...?inputFormatters, noNewlineFormatter],
          expands: true,
          minLines: null,
          maxLines: null,
          textInputAction: TextInputAction.search,
          textAlign: textAlign,
          textAlignVertical: TextAlignVertical.center,
          strutStyle: const StrutStyle(
            fontSize: 14,
            height: 1,
            forceStrutHeight: true,
          ),
          onSubmitted: (_) => onSubmitted(),
          style: const TextStyle(
            color: Color(0xFFEDEDED),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            hintText: label,
            hintStyle: const TextStyle(color: Color(0xFF9EA9B0)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _ModeFieldFrame extends StatelessWidget {
  const _ModeFieldFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kAddComicModeControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: const Color(0xFF50565A)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: child,
    );
  }
}

class _ModeSearchButton extends StatelessWidget {
  const _ModeSearchButton({
    required this.label,
    required this.isSearching,
    required this.onPressed,
  });

  final String label;
  final bool isSearching;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kAddComicModeControlHeight,
      child: FilledButton(
        onPressed: isSearching ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, _kAddComicModeControlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isSearching
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _PullListModePanel extends StatelessWidget {
  const _PullListModePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AddInfoChip(icon: Icons.event_available, label: 'Upcoming issues'),
          _AddInfoChip(icon: Icons.bookmark_added, label: 'Watched series'),
          _AddInfoChip(icon: Icons.sync, label: 'Provider feeds'),
          _AddInfoChip(icon: Icons.lock_person, label: 'Local preferences'),
        ],
      ),
    );
  }
}

class _AddInfoChip extends StatelessWidget {
  const _AddInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        border: Border.all(color: const Color(0xFF555555)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF18B7EB)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  const _DialogMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}