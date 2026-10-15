import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

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

class LibraryToolbarSearch extends StatefulWidget {
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
  State<LibraryToolbarSearch> createState() => _LibraryToolbarSearchState();
}

class _LibraryToolbarSearchState extends State<LibraryToolbarSearch> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _searchBarKey = GlobalKey();
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (widget.suggestions.isNotEmpty && widget.onSuggestionSelected != null) {
      _overlayController.show();
    }
  }

  @override
  void didUpdateWidget(covariant LibraryToolbarSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suggestions != oldWidget.suggestions) {
      _dismissed = false;
    }
    final canShow = widget.suggestions.isNotEmpty &&
        widget.onSuggestionSelected != null &&
        !_dismissed;
    if (canShow && !_overlayController.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_overlayController.isShowing &&
            !_dismissed &&
            widget.suggestions.isNotEmpty &&
            widget.onSuggestionSelected != null) {
          _overlayController.show();
        }
      });
    } else if (!canShow && _overlayController.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayController.isShowing) {
          _overlayController.hide();
        }
      });
    }
  }

  Widget _buildSuggestionsOverlay(BuildContext overlayContext) {
    if (_dismissed ||
        widget.suggestions.isEmpty ||
        widget.onSuggestionSelected == null) {
      return const SizedBox.shrink();
    }
    final renderBox =
        _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    final targetWidth =
        renderBox?.hasSize == true ? renderBox!.size.width : widget.maxWidth;
    final palette = appPalette(overlayContext);
    final borderColor = Color.alphaBlend(
      widget.selectionColor.withValues(alpha: palette.isDark ? 0.34 : 0.22),
      palette.divider,
    );
    return TapRegion(
      groupId: this,
      onTapOutside: (_) {
        if (_overlayController.isShowing) {
          _overlayController.hide();
        }
        if (mounted) {
          setState(() {
            _dismissed = true;
          });
        }
      },
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 4),
        child: SizedBox(
          width: targetWidth,
          child: Material(
            color: palette.panel,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
              side: BorderSide(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = widget.suggestions[index];
                  return InkWell(
                    mouseCursor: WidgetStateMouseCursor.clickable,
                    key: ValueKey(
                      'library-search-suggestion-${suggestion.id}',
                    ),
                    onTap: () {
                      widget.onSuggestionSelected?.call(suggestion);
                      if (_overlayController.isShowing) {
                        _overlayController.hide();
                      }
                      if (mounted) {
                        setState(() {
                          _dismissed = true;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if ((suggestion.subtitle ?? '').trim().isNotEmpty)
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const inputHeight = 34.0;
    final showSearchScope = widget.searchTargetOptions.isNotEmpty &&
        widget.onSearchTargetChanged != null;
    final inlineActionCount = 1 +
        (widget.onScanBarcode != null ? 1 : 0) +
        (widget.onScanCover != null ? 1 : 0) +
        (widget.onRandomPick != null ? 1 : 0);
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
            widget.selectedFilterLabel != null && constraints.maxWidth >= 340;
        final availableWidth = constraints.hasBoundedWidth
            ? (constraints.maxWidth < widget.maxWidth
                ? constraints.maxWidth
                : widget.maxWidth)
            : widget.maxWidth;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: availableWidth),
                child: TapRegion(
                  groupId: this,
                  child: OverlayPortal(
                    controller: _overlayController,
                    overlayLocation: OverlayChildLocation.rootOverlay,
                    overlayChildBuilder: _buildSuggestionsOverlay,
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: ClipRRect(
                        key: _searchBarKey,
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
                                    key: widget.textFieldKey,
                                    controller: widget.controller,
                                    cursorColor:
                                        appPalette(context).utilityAction,
                                    onChanged: widget.onChanged,
                                    onSubmitted: widget.onSearch,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 12.5,
                                          height: 1.05,
                                        ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: widget.hintText,
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
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _ToolbarSearchInlineAction(
                                              tooltip: widget.searchActive
                                                  ? 'Clear search'
                                                  : 'Search',
                                              icon: widget.searchActive
                                                  ? Icons.close
                                                  : Icons.search,
                                              onPressed: widget.searchActive
                                                  ? () {
                                                      widget.onClearSearch
                                                          ?.call();
                                                    }
                                                  : () => widget.onSearch(
                                                      widget.controller.text),
                                            ),
                                            if (widget.onScanBarcode != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Scan barcode',
                                                icon: Icons.barcode_reader,
                                                onPressed:
                                                    widget.onScanBarcode!,
                                              ),
                                            if (widget.onScanCover != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Search by cover',
                                                icon: Icons.image_search,
                                                onPressed: widget.onScanCover!,
                                              ),
                                            if (widget.onRandomPick != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Random pick',
                                                icon: Icons.casino_outlined,
                                                onPressed: widget.onRandomPick!,
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
                                      selected: widget.searchTarget,
                                      options: widget.searchTargetOptions,
                                      onSelected: widget.onSearchTargetChanged!,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showFilterChip) ...[
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    widget.selectionColor.withValues(alpha: 0.14),
                    palette.surface,
                  ),
                  border: Border.all(
                    color: widget.selectionColor.withValues(alpha: 0.55),
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
                        widget.selectedFilterLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.selectionColor,
                        ),
                      ),
                      if (widget.onClearFilter != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onClearFilter,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: widget.selectionColor,
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
        hoverColor:
            palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright,
        focusColor:
            palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright,
      ),
      child: PopupMenuButton<LibrarySearchTarget>(
        key: const ValueKey('library-search-target-button'),
        tooltip: 'Search scope',
        onSelected: widget.onSelected,
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        offset: const Offset(-18, 2),
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
        color: menuBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        menuPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: menuBorder),
        ),
        itemBuilder: (context) => [
          for (final option in widget.options)
            PopupMenuItem<LibrarySearchTarget>(
              value: option,
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 7),
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
                        fontWeight: FontWeight.w500,
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
  final icon = switch (target) {
    LibrarySearchTarget.all => AppIcons.searchAll,
    LibrarySearchTarget.mediaOnly => AppIcons.searchMedia,
    LibrarySearchTarget.tracksOnly => AppIcons.searchTracks,
  };
  return SizedBox(
    width: 18,
    height: 14,
    child: Center(
      child: Icon(
        icon,
        key: ValueKey('library-search-target-icon-${target.name}'),
        size: 13,
        color: color,
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
