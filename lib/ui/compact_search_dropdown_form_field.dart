import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Compact, searchable select field used for application-wide dropdowns.
///
/// The menu is anchored to the field's lower edge, matches its width, and is
/// constrained to the space available below it. Options scroll independently
/// from the search box.
class CompactSearchDropdownFormField<T> extends FormField<T> {
  CompactSearchDropdownFormField({
    super.key,
    required List<DropdownMenuItem<T>> items,
    T? initialValue,
    ValueChanged<T?>? onChanged,
    FormFieldSetter<T>? onSaved,
    FormFieldValidator<T>? validator,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    InputDecoration decoration = const InputDecoration(),
    Widget? hint,
    Widget? disabledHint,
    TextStyle? style,
    Widget? icon,
    double iconSize = 18,
    Color? iconEnabledColor,
    Color? dropdownColor,
    BorderRadius? borderRadius,
    double? menuMaxHeight,
    double? itemHeight,
    int elevation = 8,
    bool isExpanded = true,
    bool autofocus = false,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    EdgeInsetsGeometry? padding,
    List<Widget> Function(BuildContext)? selectedItemBuilder,
    bool barrierDismissible = true,
  })  : _items = items,
        _onChanged = onChanged,
        _decoration = decoration,
        _hint = hint,
        _disabledHint = disabledHint,
        _style = style,
        _icon = icon,
        _iconSize = iconSize,
        _iconEnabledColor = iconEnabledColor,
        _dropdownColor = dropdownColor,
        _borderRadius = borderRadius,
        _menuMaxHeight = menuMaxHeight,
        _itemHeight = itemHeight,
        _elevation = elevation,
        _isExpanded = isExpanded,
        _autofocus = autofocus,
        _focusNode = focusNode,
        _onTap = onTap,
        _enableFeedback = enableFeedback,
        _alignment = alignment,
        _padding = padding,
        _selectedItemBuilder = selectedItemBuilder,
        _barrierDismissible = barrierDismissible,
        super(
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          enabled: enabled && onChanged != null,
          builder: (field) =>
              (field as _CompactSearchDropdownFormFieldState<T>)._buildField(),
        );

  final List<DropdownMenuItem<T>> _items;
  final ValueChanged<T?>? _onChanged;
  final InputDecoration _decoration;
  final Widget? _hint;
  final Widget? _disabledHint;
  final TextStyle? _style;
  final Widget? _icon;
  final double _iconSize;
  final Color? _iconEnabledColor;
  final Color? _dropdownColor;
  final BorderRadius? _borderRadius;
  final double? _menuMaxHeight;
  final double? _itemHeight;
  final int _elevation;
  final bool _isExpanded;
  final bool _autofocus;
  final FocusNode? _focusNode;
  final VoidCallback? _onTap;
  final bool? _enableFeedback;
  final AlignmentGeometry _alignment;
  final EdgeInsetsGeometry? _padding;
  final List<Widget> Function(BuildContext)? _selectedItemBuilder;
  final bool _barrierDismissible;

  @override
  FormFieldState<T> createState() => _CompactSearchDropdownFormFieldState<T>();
}

/// Searchable counterpart for compact selects that are not part of a Form.
class CompactSearchDropdown<T> extends StatelessWidget {
  const CompactSearchDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.enabled = true,
    this.isDense = true,
    this.isExpanded = true,
    this.decoration = const InputDecoration(
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    this.style,
    this.icon,
    this.iconSize = 18,
    this.dropdownColor,
    this.borderRadius,
    this.menuMaxHeight,
    this.itemHeight,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.padding,
    this.onTap,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? hint;
  final bool enabled;
  final bool isDense;
  final bool isExpanded;
  final InputDecoration decoration;
  final TextStyle? style;
  final Widget? icon;
  final double iconSize;
  final Color? dropdownColor;
  final BorderRadius? borderRadius;
  final double? menuMaxHeight;
  final double? itemHeight;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CompactSearchDropdownFormField<T>(
      key: key ?? ValueKey<T?>(value),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      enabled: enabled,
      decoration: decoration.copyWith(isDense: isDense),
      hint: hint,
      style: style,
      icon: icon,
      iconSize: iconSize,
      dropdownColor: dropdownColor,
      borderRadius: borderRadius,
      menuMaxHeight: menuMaxHeight,
      itemHeight: itemHeight,
      isExpanded: isExpanded,
      focusNode: focusNode,
      autofocus: autofocus,
      enableFeedback: enableFeedback,
      alignment: alignment,
      padding: padding,
      onTap: onTap,
    );
  }
}

class _CompactSearchDropdownFormFieldState<T> extends FormFieldState<T> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _menuScrollController = ScrollController();

  double _fieldWidth = 0;
  double _menuHeight = 320;
  String _searchQuery = '';

  CompactSearchDropdownFormField<T> get _dropdown =>
      widget as CompactSearchDropdownFormField<T>;

  bool get _isEnabled => _dropdown.enabled && _dropdown._onChanged != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overlayController.isShowing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_overlayController.isShowing) return;
      _measureMenu();
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CompactSearchDropdownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != _dropdown.initialValue) {
      setValue(_dropdown.initialValue);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _menuScrollController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (!_isEnabled) return;
    if (_overlayController.isShowing) {
      _closeMenu();
      return;
    }

    _dropdown._onTap?.call();
    _measureMenu();
    _searchController.clear();
    _searchQuery = '';
    if (_menuScrollController.hasClients) {
      _menuScrollController.jumpTo(0);
    }
    _overlayController.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayController.isShowing) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _measureMenu() {
    final anchor = _anchorKey.currentContext?.findRenderObject();
    final overlay =
        Overlay.of(context, rootOverlay: true).context.findRenderObject();
    if (anchor is! RenderBox || overlay is! RenderBox) return;

    final topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlay);
    final available = overlay.size.height -
        topLeft.dy -
        anchor.size.height -
        MediaQuery.viewInsetsOf(context).bottom -
        8;
    final maxHeight = _dropdown._menuMaxHeight ?? 320;
    _fieldWidth = anchor.size.width;
    _menuHeight = math.max(44.0, math.min(maxHeight, available));
  }

  void _closeMenu() {
    if (!_overlayController.isShowing) return;
    _overlayController.hide();
    _searchFocusNode.unfocus();
  }

  List<DropdownMenuItem<T>> get _visibleItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _dropdown._items;
    return _dropdown._items.where((item) {
      final label = _labelFor(item.child);
      final value = item.value?.toString() ?? '';
      return '$label $value'.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  String _labelFor(Widget widget) {
    final text = switch (widget) {
      Text(:final data, :final textSpan) =>
        data ?? textSpan?.toPlainText() ?? '',
      RichText(:final text) => text.toPlainText(),
      Tooltip(:final message, :final child) =>
        '${message ?? ''} ${child == null ? '' : _labelFor(child)}',
      Icon(:final semanticLabel) => semanticLabel ?? '',
      Row(:final children) ||
      Column(:final children) =>
        children.map(_labelFor).join(' '),
      Padding(:final child) => child == null ? '' : _labelFor(child),
      SizedBox(:final child) => child == null ? '' : _labelFor(child),
      Align(:final child) => child == null ? '' : _labelFor(child),
      Expanded(:final child) => _labelFor(child),
      Flexible(:final child) => _labelFor(child),
      _ => '',
    };
    return text.trim();
  }

  Widget _buildField() {
    final theme = Theme.of(context);
    final selectedIndex = _dropdown._items.indexWhere(
      (item) => item.value == value,
    );
    final selectedItem =
        selectedIndex < 0 ? null : _dropdown._items[selectedIndex];
    final fieldEnabled = _dropdown.enabled;
    final canOpen = _isEnabled;
    final selectedWidgets = _dropdown._selectedItemBuilder?.call(context);
    final selectedChild = selectedIndex >= 0 &&
            selectedWidgets != null &&
            selectedIndex < selectedWidgets.length
        ? selectedWidgets[selectedIndex]
        : selectedItem?.child;
    final displayedChild = selectedChild ??
        (fieldEnabled ? _dropdown._hint : _dropdown._disabledHint) ??
        (selectedIndex < 0 ? _dropdown._hint : null);

    final decoration = _dropdown._decoration.copyWith(
      enabled: fieldEnabled,
      isDense: true,
      contentPadding: _dropdown._decoration.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      errorText: errorText ?? _dropdown._decoration.errorText,
    );

    return TapRegion(
      groupId: this,
      onTapOutside: (_) {
        if (_dropdown._barrierDismissible) _closeMenu();
      },
      child: OverlayPortal.targetsRootOverlay(
        controller: _overlayController,
        overlayChildBuilder: _buildMenu,
        child: Focus(
          focusNode: _dropdown._focusNode,
          autofocus: _dropdown._autofocus,
          child: CompositedTransformTarget(
            key: _anchorKey,
            link: _layerLink,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: canOpen ? _toggleMenu : null,
                enableFeedback: _dropdown._enableFeedback ?? true,
                borderRadius: decoration.border is OutlineInputBorder
                    ? (decoration.border! as OutlineInputBorder)
                        .borderRadius
                        .resolve(Directionality.of(context))
                    : null,
                child: InputDecorator(
                  decoration: decoration,
                  isEmpty: displayedChild == null,
                  isFocused: _overlayController.isShowing,
                  child: Row(
                    mainAxisSize: _dropdown._isExpanded
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: _dropdown._isExpanded
                            ? FlexFit.tight
                            : FlexFit.loose,
                        child: displayedChild == null
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: _dropdown._alignment,
                                child: DefaultTextStyle.merge(
                                  style: _dropdown._style ??
                                      theme.textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  child: ClipRect(child: displayedChild),
                                ),
                              ),
                      ),
                      const SizedBox(width: 4),
                      IconTheme.merge(
                        data: IconThemeData(
                          size: _dropdown._iconSize,
                          color: canOpen
                              ? _dropdown._iconEnabledColor ??
                                  theme.colorScheme.onSurfaceVariant
                              : theme.disabledColor,
                        ),
                        child: _dropdown._icon ??
                            const Icon(Icons.arrow_drop_down),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext overlayContext) {
    final theme = Theme.of(overlayContext);
    final palette = _dropdown._dropdownColor ?? theme.colorScheme.surface;
    final shape = RoundedRectangleBorder(
      borderRadius: _dropdown._borderRadius ?? BorderRadius.circular(8),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
    final options = _visibleItems;
    final itemHeight = _dropdown._itemHeight ?? 38;
    final itemPadding = _dropdown._padding?.resolve(
          Directionality.of(overlayContext),
        ) ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 3);

    return TapRegion(
      groupId: this,
      onTapOutside: (_) {
        if (_dropdown._barrierDismissible) _closeMenu();
      },
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 4),
        child: Material(
          color: palette,
          elevation: _dropdown._elevation.toDouble(),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _fieldWidth,
            height: _menuHeight,
            child: Column(
              children: [
                SizedBox(
                  height: math.min(42.0, _menuHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (query) =>
                          setState(() => _searchQuery = query),
                      textInputAction: TextInputAction.search,
                      style: theme.textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Search…',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 34, minHeight: 32),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _searchFocusNode.requestFocus();
                                },
                                icon: const Icon(Icons.close, size: 16),
                              ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Expanded(
                  child: options.isEmpty
                      ? Center(
                          child: Text(
                            'No matches',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: _menuScrollController,
                          thumbVisibility: options.length > 5,
                          child: ListView.builder(
                            controller: _menuScrollController,
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            itemCount: options.length,
                            itemExtent: itemHeight,
                            itemBuilder: (context, index) {
                              final item = options[index];
                              final isSelected = item.value == value;
                              return Material(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.42)
                                    : Colors.transparent,
                                child: InkWell(
                                  onTap: item.enabled
                                      ? () => _selectItem(item)
                                      : null,
                                  child: SizedBox(
                                    height: itemHeight,
                                    child: Padding(
                                      padding: itemPadding,
                                      child: Align(
                                        alignment: _dropdown._alignment,
                                        child: DefaultTextStyle.merge(
                                          style: item.enabled
                                              ? (_dropdown._style ??
                                                  theme.textTheme.bodyMedium)
                                              : theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                  color: theme.disabledColor,
                                                ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          child: ClipRect(child: item.child),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectItem(DropdownMenuItem<T> item) {
    if (!_isEnabled || !item.enabled) return;
    item.onTap?.call();
    didChange(item.value);
    _dropdown._onChanged?.call(item.value);
    _closeMenu();
  }
}
