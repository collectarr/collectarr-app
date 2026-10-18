import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/features/library/generic/projection/library_search_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/ui/app_icons.dart';

import '../config/library_workspace_tokens.dart';

class LibraryToolbarSearchSuggestion {
  const LibraryToolbarSearchSuggestion({
    required this.id,
    required this.title,
    String? label,
    this.subtitle,
    this.imageUrl,
    this.libraryEntryRef,
  }) : label = label ?? title;

  final String id;

  /// Search text applied when the suggestion is chosen.
  final String title;

  /// Bold first line, such as "Artist - Title".
  final String label;
  final String? subtitle;
  final String? imageUrl;
  final LibraryEntryRef? libraryEntryRef;
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

  /// Why the "matches:" expression in the box is invalid, if it is.
  String? _patternError;

  void _checkPattern() {
    final error =
        LibrarySearchPattern.parse(widget.controller.text).regExpError;
    if (error != _patternError) setState(() => _patternError = error);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkPattern);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkPattern);
    _patternError =
        LibrarySearchPattern.parse(widget.controller.text).regExpError;
    if (widget.suggestions.isNotEmpty && widget.onSuggestionSelected != null) {
      _overlayController.show();
    }
  }

  @override
  void didUpdateWidget(covariant LibraryToolbarSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_checkPattern);
      widget.controller.addListener(_checkPattern);
      _patternError =
          LibrarySearchPattern.parse(widget.controller.text).regExpError;
    }
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

  void _closeSuggestions() {
    if (_overlayController.isShowing) _overlayController.hide();
    if (mounted) setState(() => _dismissed = true);
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
    final border = palette.isDark ? const Color(0xff5d626c) : palette.divider;
    return TapRegion(
      groupId: this,
      onTapOutside: (_) => _closeSuggestions(),
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: targetWidth,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: palette.isDark ? const Color(0xff383838) : palette.panel,
              border: Border.all(color: border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xff333333),
                  offset: Offset(10, 10),
                  blurRadius: 15,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = widget.suggestions[index];
                        return _SearchSuggestionRow(
                          key: ValueKey(
                            'library-search-suggestion-${suggestion.id}',
                          ),
                          suggestion: suggestion,
                          borderColor: border,
                          onTap: () {
                            widget.onSuggestionSelected?.call(suggestion);
                            _closeSuggestions();
                          },
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      key: const ValueKey('library-search-view-all'),
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        widget.onSearch(widget.controller.text);
                        _closeSuggestions();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View all results',
                              style: TextStyle(
                                fontSize: 12,
                                height: 17 / 12,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(AppIcons.chevronRight,
                                size: 9, color: palette.textPrimary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    const inputHeight = 30.0;
    final showSearchScope = widget.searchTargetOptions.isNotEmpty &&
        widget.onSearchTargetChanged != null;
    final inlineActionCount = 1 +
        (widget.onScanBarcode != null ? 1 : 0) +
        (widget.onScanCover != null ? 1 : 0) +
        (widget.onRandomPick != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 26.0 + 2;
    final inputBackground =
        palette.isDark ? const Color(0xff444444) : palette.field;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          color: palette.textPrimary,
        );
    final iconColor = palette.textPrimary;

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
                      child: Tooltip(
                        message: _patternError == null
                            ? ''
                            : 'Invalid regular expression: ${_patternError!}',
                        child: DecoratedBox(
                          key: _searchBarKey,
                          decoration: BoxDecoration(
                            color: inputBackground,
                            borderRadius: BorderRadius.circular(4),
                            border: _patternError == null
                                ? null
                                : Border.all(color: palette.errorBorder),
                          ),
                          child: SizedBox(
                            height: inputHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    key: widget.textFieldKey,
                                    controller: widget.controller,
                                    cursorColor: palette.utilityAction,
                                    onChanged: widget.onChanged,
                                    onSubmitted: widget.onSearch,
                                    style: textStyle,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: false,
                                      hintText: widget.hintText,
                                      hintStyle: textStyle?.copyWith(
                                        color: palette.isDark
                                            ? const Color(0xff999999)
                                            : palette.textMuted,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(
                                        showSearchScope ? 50 : 8,
                                        5,
                                        4,
                                        5,
                                      ),
                                      suffixIconConstraints: BoxConstraints(
                                        minWidth: inlineActionsWidth,
                                        maxWidth: inlineActionsWidth,
                                        minHeight: inputHeight,
                                        maxHeight: inputHeight,
                                      ),
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _ToolbarSearchInlineAction(
                                              tooltip: widget.searchActive
                                                  ? 'Clear search'
                                                  : 'Search',
                                              onPressed: widget.searchActive
                                                  ? () => widget.onClearSearch
                                                      ?.call()
                                                  : () => widget.onSearch(
                                                      widget.controller.text),
                                              child: Icon(
                                                widget.searchActive
                                                    ? AppIcons.close
                                                    : AppIcons.search,
                                                size: 14,
                                                color: iconColor,
                                              ),
                                            ),
                                            if (widget.onScanBarcode != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Scan barcode',
                                                onPressed:
                                                    widget.onScanBarcode!,
                                                child: SvgPicture.asset(
                                                  AppIcons.barcodeScanSvg,
                                                  key: const ValueKey(
                                                      'library-search-barcode-glyph'),
                                                  width: 22,
                                                  height: 18,
                                                  colorFilter: ColorFilter.mode(
                                                      iconColor,
                                                      BlendMode.srcIn),
                                                ),
                                              ),
                                            if (widget.onScanCover != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Search by cover',
                                                onPressed: widget.onScanCover!,
                                                child: Icon(AppIcons.camera,
                                                    size: 14, color: iconColor),
                                              ),
                                            if (widget.onRandomPick != null)
                                              _ToolbarSearchInlineAction(
                                                tooltip: 'Random pick',
                                                onPressed: widget.onRandomPick!,
                                                child: Icon(AppIcons.dice,
                                                    size: 14, color: iconColor),
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
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        label: tooltip,
        button: true,
        onTap: onPressed,
        excludeSemantics: true,
        child: AppClickTarget(
          onClick: onPressed,
          builder: (context, hovered) => Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hovered ? libraryToolbarControlHover(context) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: child,
          ),
        ),
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
  static const _menuWidth = 160.0;
  bool _hovered = false;

  /// Opens the scope list left-aligned under the button, as in the reference.
  ///
  /// The anchor spans the menu's own width, so Flutter's menu layout lands on
  /// the same left edge whichever half of the window the button is in.
  Future<void> _open() async {
    final palette = appPalette(context);
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final topLeft =
        box.localToGlobal(Offset(-4, box.size.height + 2), ancestor: overlay);
    final anchor = Rect.fromLTWH(topLeft.dx, topLeft.dy, _menuWidth, 0);
    final selected = await showMenu<LibrarySearchTarget>(
      context: context,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      popUpAnimationStyle: AnimationStyle.noAnimation,
      constraints: const BoxConstraints.tightFor(width: _menuWidth),
      color: palette.isDark ? const Color(0xFF444444) : palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: palette.isDark ? const Color(0xFF666666) : palette.divider),
      ),
      items: [
        for (final option in widget.options)
          PopupMenuItem<LibrarySearchTarget>(
            value: option,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              children: [
                _librarySearchTargetIcon(option, palette.textPrimary, size: 16),
                const SizedBox(width: 4),
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
    );
    if (selected != null && mounted) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final buttonBackground = _hovered
        ? (palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright)
        : (palette.isDark ? const Color(0xFF383838) : palette.surface);
    return Tooltip(
      message: 'Search scope',
      child: Semantics(
        button: true,
        expanded: false,
        onTap: _open,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            key: const ValueKey('library-search-target-button'),
            behavior: HitTestBehavior.opaque,
            onTap: _open,
            child: Container(
              width: 44,
              height: 26,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: buttonBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _librarySearchTargetIcon(
                      widget.selected, palette.textPrimary),
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
      ),
    );
  }
}

Widget _librarySearchTargetIcon(LibrarySearchTarget target, Color color,
    {double size = 13}) {
  final icon = switch (target) {
    LibrarySearchTarget.all => AppIcons.searchAll,
    LibrarySearchTarget.mediaOnly => AppIcons.searchMedia,
    LibrarySearchTarget.tracksOnly => AppIcons.searchTracks,
  };
  return SizedBox(
    width: size + 5,
    height: size + 1,
    child: Center(
      child: Icon(
        icon,
        key: ValueKey('library-search-target-icon-${target.name}'),
        size: size,
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

/// One autocomplete row: a 40 px cover, the bold label and a second line,
/// ruled underneath, as in the reference.
class _SearchSuggestionRow extends StatefulWidget {
  const _SearchSuggestionRow({
    super.key,
    required this.suggestion,
    required this.borderColor,
    required this.onTap,
  });

  final LibraryToolbarSearchSuggestion suggestion;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_SearchSuggestionRow> createState() => _SearchSuggestionRowState();
}

class _SearchSuggestionRowState extends State<_SearchSuggestionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final suggestion = widget.suggestion;
    final subtitle = suggestion.subtitle?.trim() ?? '';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 41,
          decoration: BoxDecoration(
            color: _hovered ? libraryToolbarMenuHover(context) : null,
            border: Border(bottom: BorderSide(color: widget.borderColor)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 40,
                child: LibraryCoverImage(
                  title: suggestion.label,
                  imageUrl: suggestion.imageUrl,
                  libraryEntryRef: suggestion.libraryEntryRef,
                  targetCacheWidth: 80,
                  fallbackAspectRatio: 1,
                  borderRadius: 0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 17 / 14,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 18.5 / 13,
                            color: palette.textPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
