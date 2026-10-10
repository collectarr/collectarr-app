import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.textFieldKey,
  });

  final Key? textFieldKey;
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
    final inlineActionCount = 1 +
        (onScanBarcode != null ? 1 : 0) +
        (onScanCover != null ? 1 : 0) +
        (onRandomPick != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 28.0 + 8;
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
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: TextField(
                                  key: textFieldKey,
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
                                    contentPadding: EdgeInsets.fromLTRB(
                                      showSearchScope ? 50 : 10,
                                      8,
                                      10,
                                      8,
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
                              if (showSearchScope)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _ToolbarSearchScopeButton(
                                    selected: searchTarget,
                                    options: searchTargetOptions,
                                    onSelected: onSearchTargetChanged!,
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
                                mouseCursor: WidgetStateMouseCursor.clickable,
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
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: palette.textMuted,
                            ),
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

class _ToolbarSearchScopeButton extends StatefulWidget {
  const _ToolbarSearchScopeButton({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final LibrarySearchTarget selected;
  final List<LibrarySearchTarget> options;
  final ValueChanged<LibrarySearchTarget> onSelected;

  @override
  State<_ToolbarSearchScopeButton> createState() =>
      _ToolbarSearchScopeButtonState();
}

class _ToolbarSearchScopeButtonState extends State<_ToolbarSearchScopeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final buttonBackground = _hovered
        ? (palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright)
        : (palette.isDark ? const Color(0xFF383838) : palette.surface);
    final menuBackground =
        palette.isDark ? const Color(0xFF444444) : palette.panelRaised;
    final menuBorder =
        palette.isDark ? const Color(0xFF666666) : palette.divider;
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright,
        focusColor: palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright,
      ),
      child: PopupMenuButton<LibrarySearchTarget>(
        key: const ValueKey('library-search-target-button'),
        tooltip: 'Search scope',
        initialValue: widget.selected,
        onSelected: widget.onSelected,
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        offset: const Offset(-18, 2),
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
        color: menuBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        menuPadding: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: menuBorder),
        ),
        itemBuilder: (context) => [
          for (final option in widget.options)
            PopupMenuItem<LibrarySearchTarget>(
              value: option,
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _librarySearchTargetIcon(option, palette.textPrimary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _librarySearchTargetLabel(option),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Container(
            width: 44,
            height: 26,
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: buttonBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _hovered
                    ? palette.accent.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _librarySearchTargetIcon(widget.selected, palette.textPrimary),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: palette.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _librarySearchTargetIcon(LibrarySearchTarget target, Color color) {
  final asset = switch (target) {
    LibrarySearchTarget.all => 'assets/sidebar_icons/database.svg',
    LibrarySearchTarget.mediaOnly => 'assets/sidebar_icons/compact-disc.svg',
    LibrarySearchTarget.tracksOnly => 'assets/tab_icons/music.svg',
  };
  return SizedBox(
    width: 18,
    height: 14,
    child: Center(
      child: SvgPicture.asset(
        key: ValueKey('library-search-target-icon-${target.name}'),
        asset,
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    ),
  );
}

String _librarySearchTargetLabel(LibrarySearchTarget target) {
  return switch (target) {
    LibrarySearchTarget.all => 'Albums & Tracks',
    LibrarySearchTarget.mediaOnly => 'Albums',
    LibrarySearchTarget.tracksOnly => 'Tracks',
  };
}
