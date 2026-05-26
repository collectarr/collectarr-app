part of 'library_add_dialog.dart';

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.type, required this.accent});

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kAppDivider, kAppSurfaceDim],
          ),
          border: Border(bottom: BorderSide(color: accent)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(type.workspace.icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Add ${type.pluralLabel} from Collectarr Core',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodePrefillBanner extends StatelessWidget {
  const _BarcodePrefillBanner({
    required this.type,
    required this.barcode,
  });

  final LibraryTypeConfig type;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kAppBannerInfoBackground,
        border: Border(bottom: _kLibraryAddBorder),
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
                style: const TextStyle(
                  color: Colors.white,
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

class _LibraryAddModeBar extends StatelessWidget {
  const _LibraryAddModeBar({
    required this.type,
    required this.accent,
    required this.mode,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.onModeChanged,
    required this.onSearch,
    required this.canScanCover,
    required this.isScanningCover,
    required this.onScanCover,
    required this.onLookupBarcode,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.seriesController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final _LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final ValueChanged<_LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupBarcode;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;

  @override
  Widget build(BuildContext context) {
    final isBusy = isSearching || isSearchingProvider;
    final searchLabels = libraryMediaSearchFieldLabels(type);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kAppToolbar,
        border: Border(bottom: BorderSide(color: kAppField)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
        child: Column(
          children: [
            _LibraryAddModeTabStrip(
              type: type,
              accent: accent,
              mode: mode,
              onModeChanged: onModeChanged,
              onManual: onManual,
              onScan: () => onModeChanged(_LibraryAddDialogMode.barcode),
            ),
            const SizedBox(height: 7),
            switch (mode) {
              _LibraryAddDialogMode.search => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LibraryAddModeTextField(
                            fieldKey:
                                const ValueKey('library-add-query-field'),
                            controller: queryController,
                            label: 'Search Collectarr Core',
                            hintText: searchLabels.queryHint,
                            onSubmitted: onSearch,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _AdvancedToggleButton(
                          expanded: showAdvanced,
                          accent: accent,
                          onPressed: onToggleAdvanced,
                        ),
                        if (canScanCover) ...[
                          const SizedBox(width: 6),
                          _LibraryAddModeButton(
                            label: 'Scan cover',
                            icon: Icons.photo_camera_outlined,
                            accent: accent,
                            isBusy: isScanningCover,
                            outlined: true,
                            onPressed: isBusy || isScanningCover
                                ? null
                                : onScanCover,
                          ),
                        ],
                        const SizedBox(width: 6),
                        _LibraryAddModeButton(
                          label: _searchButtonLabel,
                          icon: Icons.search,
                          accent: accent,
                          isBusy: isSearching,
                          onPressed: isBusy ? null : onSearch,
                        ),
                      ],
                    ),
                    if (showAdvanced) ...[
                      const SizedBox(height: 6),
                      _AdvancedSearchFields(
                        searchLabels: searchLabels,
                        seriesController: seriesController,
                        numberController: numberController,
                        publisherController: publisherController,
                        yearController: yearController,
                        onSubmitted: onSearch,
                      ),
                    ],
                  ],
                ),
              _LibraryAddDialogMode.barcode => Row(
                  children: [
                    Expanded(
                      child: _LibraryAddModeTextField(
                        fieldKey: const ValueKey('library-add-barcode-field'),
                        controller: barcodeController,
                        label: 'Barcode / UPC / ISBN',
                        hintText: 'Scan or enter barcode / UPC / ISBN...',
                        keyboardType: TextInputType.number,
                        onSubmitted: onLookupBarcode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Lookup barcode',
                      icon: Icons.manage_search,
                      accent: accent,
                      isBusy: isSearching,
                      onPressed: isBusy ? null : onLookupBarcode,
                    ),
                  ],
                ),
              _LibraryAddDialogMode.manual => Row(
                  children: [
                    Icon(Icons.edit_note, size: 18, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Start a manual draft here, then review the full editor before saving.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Manual draft',
                      icon: Icons.edit_note,
                      accent: accent,
                      outlined: true,
                      onPressed: onManual,
                    ),
                  ],
                ),
              _LibraryAddDialogMode.browse => Row(
                  children: [
                    Expanded(
                      child: _LibraryAddModeTextField(
                        fieldKey: const ValueKey('library-add-browse-field'),
                        controller: queryController,
                        label: 'Browse media catalog',
                        hintText:
                            'Filter by title to browse editions and variants...',
                        onSubmitted: onSearch,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _LibraryAddModeButton(
                      label: 'Browse',
                      icon: Icons.explore,
                      accent: accent,
                      isBusy: isSearching,
                      onPressed: isBusy ? null : onSearch,
                    ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }

  String get _searchButtonLabel {
    return 'Search ${type.pluralLabel}';
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
  final _LibraryAddDialogMode mode;
  final ValueChanged<_LibraryAddDialogMode> onModeChanged;
  final VoidCallback onManual;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: kAppSurfaceSubtle,
        border: Border.all(color: accent.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const Text(
            'Search by',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: kAppTextBright,
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
                    selected: mode == _LibraryAddDialogMode.search,
                    onTap: () => onModeChanged(_LibraryAddDialogMode.search),
                  ),
                  LibraryAddModeTab(
                    icon: Icons.qr_code_2,
                    label: 'Barcode',
                    accent: accent,
                    selected: mode == _LibraryAddDialogMode.barcode,
                    onTap: () => onModeChanged(_LibraryAddDialogMode.barcode),
                  ),
                  LibraryAddModeTab(
                    icon: Icons.explore,
                    label: 'Browse',
                    accent: accent,
                    selected: mode == _LibraryAddDialogMode.browse,
                    onTap: () => onModeChanged(_LibraryAddDialogMode.browse),
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
          const Icon(Icons.menu, size: 26, color: kAppTextBright),
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
    return SizedBox(
      height: _kLibraryAddModeControlHeight,
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
          style: const TextStyle(
            color: kAppTextBright,
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
            hintStyle: const TextStyle(color: kAppTextHint),
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
    return Container(
      height: _kLibraryAddModeControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kAppField,
        border: Border.all(color: kAppBorderSubtle),
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
        ? _libraryAddOutlinedButtonStyle(accent)
      : libraryAddFilledButtonStyle(accent);
    return SizedBox(
      height: _kLibraryAddModeControlHeight,
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
      height: _kLibraryAddModeControlHeight,
      width: _kLibraryAddModeControlHeight,
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
              color: expanded ? accent.withValues(alpha: 0.5) : kAppBorderSubtle,
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
    required this.seriesController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
    required this.onSubmitted,
  });

  final LibraryMediaSearchFieldLabels searchLabels;
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _AdvancedField(
            fieldKey: const ValueKey('library-add-series-field'),
            controller: seriesController,
            hint: searchLabels.seriesHint,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 1,
          child: _AdvancedField(
            fieldKey: const ValueKey('library-add-number-field'),
            controller: numberController,
            hint: searchLabels.numberHint,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: _AdvancedField(
            fieldKey: const ValueKey('library-add-publisher-field'),
            controller: publisherController,
            hint: searchLabels.publisherHint,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: _AdvancedField(
            fieldKey: const ValueKey('library-add-year-field'),
            controller: yearController,
            hint: 'Year',
            keyboardType: TextInputType.number,
            onSubmitted: onSubmitted,
          ),
        ),
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
          style: const TextStyle(
            color: kAppTextBright,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
              color: kAppTextHint,
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
