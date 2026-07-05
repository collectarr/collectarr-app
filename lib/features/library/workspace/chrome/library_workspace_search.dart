import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:flutter/material.dart';

import '../config/library_workspace_tokens.dart';

class LibraryToolbarSearchSuggestion {
  const LibraryToolbarSearchSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
}

class LibraryToolbarSearch extends StatelessWidget {
  const LibraryToolbarSearch({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.selectionColor,
    this.onScanBarcode,
    this.onScanCover,
    this.onRandomPick,
    this.selectedFilterLabel,
    this.onClearFilter,
    this.onChanged,
    this.maxWidth = 300,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
    this.onClearSearch,
    this.searchActive = false,
    this.suggestions = const <LibraryToolbarSearchSuggestion>[],
    this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final String hintText;
  final String? selectedFilterLabel;
  final ValueChanged<String> onSearch;
  final VoidCallback? onScanBarcode;
  final VoidCallback? onScanCover;
  final VoidCallback? onRandomPick;
  final VoidCallback? onClearFilter;
  final ValueChanged<String>? onChanged;
  final Color selectionColor;
  final double maxWidth;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> suggestions;
  final ValueChanged<LibraryToolbarSearchSuggestion>? onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const inputHeight = 34.0;
    final showSearchScope =
        searchTargetOptions.isNotEmpty && onSearchTargetChanged != null;
    final inlineActionCount =
        1 +
        (onScanBarcode != null ? 1 : 0) +
        (onScanCover != null ? 1 : 0) +
        (onRandomPick != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 28.0 + 8;
    const searchScopeWidth = 110.0;
    final inputBackground = Color.alphaBlend(
      (palette.isDark ? Colors.white : palette.accent).withValues(
        alpha: palette.isDark ? 0.045 : 0.03,
      ),
      palette.field,
    );
    final borderColor = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.34 : 0.22),
      palette.divider,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFilterChip =
            selectedFilterLabel != null && constraints.maxWidth >= 340;
        final availableWidth = constraints.hasBoundedWidth
            ? (constraints.maxWidth < maxWidth
                ? constraints.maxWidth
                : maxWidth)
            : maxWidth;
        final canShowSuggestions =
            suggestions.isNotEmpty && onSuggestionSelected != null;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: availableWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: inputBackground,
                          border: Border.all(color: borderColor),
                        ),
                        child: SizedBox(
                          height: inputHeight,
                          child: Row(
                            children: [
                              if (showSearchScope)
                                SizedBox(
                                  width: searchScopeWidth,
                                  child: _ToolbarSearchScopeButton(
                                    selected: searchTarget,
                                    options: searchTargetOptions,
                                    onSelected: onSearchTargetChanged!,
                                  ),
                                ),
                              if (showSearchScope)
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: borderColor,
                                ),
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  onChanged: onChanged,
                                  onSubmitted: onSearch,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 12.5,
                                        height: 1.05,
                                      ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: hintText,
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: palette.textMuted,
                                          fontSize: 12,
                                          height: 1.05,
                                        ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    suffixIconConstraints: BoxConstraints(
                                      minWidth: inlineActionsWidth,
                                      maxWidth: inlineActionsWidth,
                                      minHeight: inputHeight,
                                      maxHeight: inputHeight,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _ToolbarSearchInlineAction(
                                            tooltip: searchActive
                                                ? 'Clear search'
                                                : 'Search',
                                            icon: searchActive
                                                ? Icons.close
                                                : Icons.search,
                                            onPressed: searchActive
                                                ? () {
                                                    onClearSearch?.call();
                                                  }
                                                : () =>
                                                    onSearch(controller.text),
                                          ),
                                          if (onScanBarcode != null)
                                            _ToolbarSearchInlineAction(
                                              tooltip: 'Scan barcode',
                                              icon: Icons.qr_code_2,
                                              onPressed: onScanBarcode!,
                                            ),
                                          if (onScanCover != null)
                                            _ToolbarSearchInlineAction(
                                              tooltip: 'Search by cover',
                                              icon: Icons.image_search,
                                              onPressed: onScanCover!,
                                            ),
                                          if (onRandomPick != null)
                                            _ToolbarSearchInlineAction(
                                              tooltip: 'Random pick',
                                              icon: Icons.casino_outlined,
                                              onPressed: onRandomPick!,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (canShowSuggestions) ...[
                      const SizedBox(height: 4),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.panel,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 260),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              return InkWell(
                                key: ValueKey(
                                  'library-search-suggestion-${suggestion.id}',
                                ),
                                onTap: () => onSuggestionSelected!(suggestion),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestion.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if ((suggestion.subtitle ?? '')
                                          .trim()
                                          .isNotEmpty)
                                        Text(
                                          suggestion.subtitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: palette.textMuted,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showFilterChip) ...[
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    selectionColor.withValues(alpha: 0.14),
                    palette.surface,
                  ),
                  border: Border.all(
                    color: selectionColor.withValues(alpha: 0.55),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedFilterLabel!,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      if (onClearFilter != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClearFilter,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ToolbarSearchInlineAction extends StatelessWidget {
  const _ToolbarSearchInlineAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      width: 28,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          hoverColor: libraryToolbarControlHover(context),
          highlightColor: libraryToolbarControlHover(
            context,
          ).withValues(alpha: 0.9),
        ),
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: palette.textPrimary),
      ),
    );
  }
}

class _ToolbarSearchScopeButton extends StatelessWidget {
  const _ToolbarSearchScopeButton({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final LibrarySearchTarget selected;
  final List<LibrarySearchTarget> options;
  final ValueChanged<LibrarySearchTarget> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PopupMenuButton<LibrarySearchTarget>(
      key: const ValueKey('library-search-target-button'),
      tooltip: 'Search scope',
      initialValue: selected,
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.album_outlined, size: 16, color: palette.textPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _librarySearchTargetLabel(selected),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: palette.textMuted),
          ],
        ),
      ),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<LibrarySearchTarget>(
            value: option,
            child: Text(_librarySearchTargetLabel(option)),
          ),
      ],
    );
  }
}

String _librarySearchTargetLabel(LibrarySearchTarget target) {
  return switch (target) {
    LibrarySearchTarget.all => 'Albums & Tracks',
    LibrarySearchTarget.mediaOnly => 'Albums',
    LibrarySearchTarget.tracksOnly => 'Tracks',
  };
}
