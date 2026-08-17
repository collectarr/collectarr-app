import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// An adaptive, touch-friendly top chrome header designed for mobile and compact viewports.
class CompactLibraryTopChrome extends StatefulWidget
    implements PreferredSizeWidget {
  const CompactLibraryTopChrome({
    super.key,
    required this.titleWidget,
    this.searchController,
    this.searchHint = 'Search collection...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.onAdd,
    this.onScanBarcode,
    this.onOpenFilters,
    this.onOpenViewOptions,
    this.onSync,
    this.isSyncing = false,
    this.syncPendingCount = 0,
    this.extraActions,
    this.height = 48.0,
  });

  final Widget titleWidget;
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final VoidCallback? onAdd;
  final VoidCallback? onScanBarcode;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onOpenViewOptions;
  final VoidCallback? onSync;
  final bool isSyncing;
  final int syncPendingCount;
  final List<Widget>? extraActions;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<CompactLibraryTopChrome> createState() =>
      _CompactLibraryTopChromeState();
}

class _CompactLibraryTopChromeState extends State<CompactLibraryTopChrome> {
  bool _searchExpanded = false;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() {
      _searchExpanded = true;
    });
    _searchFocusNode.requestFocus();
  }

  void _collapseSearch() {
    setState(() {
      _searchExpanded = false;
    });
    widget.searchController?.clear();
    widget.onClearSearch?.call();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);

    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      borderBuilder: (Color? animatedAccent, Brightness brightness) => Border(
        bottom: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent ?? accentData.accent,
            brightness: brightness,
          ),
        ),
      ),
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _searchExpanded
              ? _buildExpandedSearch(context, palette, accentData)
              : _buildStandardBar(context, palette, accentData),
        ),
      ),
    );
  }

  Widget _buildStandardBar(
    BuildContext context,
    AppThemePalette palette,
    LibraryAccentData accentData,
  ) {
    return Row(
      key: const ValueKey('standard_top_bar'),
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: widget.titleWidget,
          ),
        ),
        if (widget.searchController != null || widget.onSearchChanged != null)
          IconButton(
            key: const ValueKey('compact_search_trigger'),
            icon: const Icon(Icons.search, size: 20),
            tooltip: 'Search',
            visualDensity: VisualDensity.compact,
            color: palette.textPrimary,
            onPressed: _expandSearch,
          ),
        if (widget.onScanBarcode != null)
          IconButton(
            key: const ValueKey('compact_barcode_trigger'),
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            tooltip: 'Scan barcode',
            visualDensity: VisualDensity.compact,
            color: palette.textPrimary,
            onPressed: widget.onScanBarcode,
          ),
        if (widget.onOpenFilters != null)
          IconButton(
            key: const ValueKey('compact_filters_trigger'),
            icon: const Icon(Icons.filter_list, size: 20),
            tooltip: 'Filters',
            visualDensity: VisualDensity.compact,
            color: palette.textPrimary,
            onPressed: widget.onOpenFilters,
          ),
        if (widget.onOpenViewOptions != null)
          IconButton(
            key: const ValueKey('compact_view_options_trigger'),
            icon: const Icon(Icons.tune, size: 20),
            tooltip: 'View & Organize',
            visualDensity: VisualDensity.compact,
            color: palette.textPrimary,
            onPressed: widget.onOpenViewOptions,
          ),
        if (widget.onSync != null)
          IconButton(
            key: const ValueKey('compact_sync_trigger'),
            icon: widget.isSyncing
                ? SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accentData.accent,
                    ),
                  )
                : Badge(
                    isLabelVisible: widget.syncPendingCount > 0,
                    label: Text('${widget.syncPendingCount}'),
                    child: const Icon(Icons.sync, size: 20),
                  ),
            tooltip: widget.isSyncing
                ? 'Syncing...'
                : 'Sync (${widget.syncPendingCount} pending)',
            visualDensity: VisualDensity.compact,
            color: palette.textPrimary,
            onPressed: widget.isSyncing ? null : widget.onSync,
          ),
        if (widget.onAdd != null)
          IconButton.filled(
            key: const ValueKey('compact_add_trigger'),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            tooltip: 'Add item',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: accentData.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.onAdd,
          ),
        if (widget.extraActions != null) ...widget.extraActions!,
      ],
    );
  }

  Widget _buildExpandedSearch(
    BuildContext context,
    AppThemePalette palette,
    LibraryAccentData accentData,
  ) {
    return Row(
      key: const ValueKey('expanded_search_bar'),
      children: [
        IconButton(
          key: const ValueKey('compact_search_back'),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Close search',
          visualDensity: VisualDensity.compact,
          color: palette.textPrimary,
          onPressed: _collapseSearch,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            key: const ValueKey('compact_search_text_field'),
            controller: widget.searchController,
            focusNode: _searchFocusNode,
            onChanged: widget.onSearchChanged,
            onSubmitted: widget.onSearchSubmitted,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 14,
              color: palette.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: palette.textMuted,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: accentData.accent.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: palette.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: accentData.accent,
                ),
              ),
              suffixIcon: widget.searchController != null &&
                      widget.searchController!.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        widget.searchController!.clear();
                        widget.onClearSearch?.call();
                        widget.onSearchChanged?.call('');
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
