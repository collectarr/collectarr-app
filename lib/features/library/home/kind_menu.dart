import 'dart:math';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/config/kind_style.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/home/nav_models.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaLibraryKindMenu extends StatefulWidget {
  const MediaLibraryKindMenu({
    super.key,
    required this.types,
    required this.registry,
    required this.onSelected,
    required this.activeKind,
    required this.trigger,
  });

  final List<CatalogMediaType> types;
  final LibraryKindRegistry registry;
  final ValueChanged<CatalogMediaType> onSelected;
  final CatalogMediaKind activeKind;

  /// What the switcher opens from: the header's library title.
  final Widget trigger;

  @override
  State<MediaLibraryKindMenu> createState() => _MediaLibraryKindMenuState();
}

class _MediaLibraryKindMenuState extends State<MediaLibraryKindMenu> {
  final _anchorKey = GlobalKey();
  final _controller = MenuController();
  final _buttonFocus = FocusNode();
  double _menuWidth = _desktopMenuWidth;
  double _pointerOffset = _desktopMenuWidth / 2;
  bool _open = false;
  bool _openedByPointer = false;

  static const _desktopMenuWidth = 240.0;

  @override
  void dispose() {
    _buttonFocus.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isOpen) {
      _controller.close();
      return;
    }
    final anchor = _anchorKey.currentContext?.findRenderObject();
    final overlay =
        Overlay.of(context, rootOverlay: true).context.findRenderObject();
    if (anchor is! RenderBox || overlay is! RenderBox) return;
    final bounds =
        anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
    final native = appPresentationPlatform.isNativeMobile;
    final width = native
        ? overlay.size.width
        : min(overlay.size.width, _desktopMenuWidth);
    final left = native ? 0.0 : min(bounds.left, overlay.size.width - width);
    setState(() {
      _menuWidth = width;
      _pointerOffset = bounds.center.dx - left;
    });
    // The panel hangs from the header's bottom edge; its pointer rises into
    // the header under the title.
    _controller.open(
        position: Offset(left - bounds.left,
            native ? bounds.height : shellAppBarHeight - 1 - bounds.top));
  }

  void _setOpen(bool open) {
    if (mounted) setState(() => _open = open);
  }

  /// Opening moves focus to the title. Only keyboard users keep it on close,
  /// or a mouse dismissal would leave the title lit by its focus color.
  void _handleClose() {
    _setOpen(false);
    if (_openedByPointer) _buttonFocus.unfocus();
    _openedByPointer = false;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      key: _anchorKey,
      controller: _controller,
      childFocusNode: _buttonFocus,
      useRootOverlay: true,
      crossAxisUnconstrained: false,
      reservedPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      onOpen: () => _setOpen(true),
      onClose: _handleClose,
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(
            Theme.of(context).shadowColor.withValues(alpha: .2)),
        elevation: const WidgetStatePropertyAll(6),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(_menuWidth)),
        shape: WidgetStatePropertyAll(
            _LibraryMenuBorder(pointerOffset: _pointerOffset)),
      ),
      menuChildren: [
        for (final type in _familyEntryTypes())
          _KindMenuItem(
            key: ValueKey('library-kind-picker-item-${type.kind}'),
            type: type,
            selected: _isSelected(type),
            icon: widget.registry.tryGet(type.mediaKind)?.identity.icon ??
                libraryIconForKind(type.mediaKind),
            iconSvgAsset: widget.registry
                .tryGet(type.mediaKind)
                ?.identity
                .collectionIconSvgAsset,
            onPressed: () => widget.onSelected(type),
          ),
      ],
      child: Tooltip(
        message: 'Switch library',
        child: Material(
          // Lit while open, like hovering, so the title reads as a button.
          color:
              _open ? Colors.white.withValues(alpha: .16) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            key: const Key('nav.library-kind-picker'),
            focusNode: _buttonFocus,
            mouseCursor: WidgetStateMouseCursor.clickable,
            borderRadius: BorderRadius.circular(4),
            hoverColor: Colors.white.withValues(alpha: .16),
            focusColor: Colors.white.withValues(alpha: .16),
            onTapDown: (_) => _openedByPointer = true,
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: widget.trigger),
                const SizedBox(width: 5),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    size: 20, color: Colors.white),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSelected(CatalogMediaType type) {
    if (type.mediaKind == widget.activeKind) return true;
    final family =
        widget.registry.tryGet(widget.activeKind)?.identity.collectionFamily;
    return family != null &&
        family ==
            widget.registry.tryGet(type.mediaKind)?.identity.collectionFamily;
  }

  /// One entry per collection family: Hardware and Toys open from the Games
  /// collection tabs, as in the reference app list.
  List<CatalogMediaType> _familyEntryTypes() {
    final families = <String>{};
    return widget.types.where((type) {
      final family =
          widget.registry.tryGet(type.mediaKind)?.identity.collectionFamily;
      return family == null || families.add(family);
    }).toList();
  }
}

class _KindMenuItem extends StatefulWidget {
  const _KindMenuItem(
      {super.key,
      required this.type,
      required this.selected,
      required this.icon,
      this.iconSvgAsset,
      required this.onPressed});
  final CatalogMediaType type;
  final bool selected;
  final IconData icon;
  final String? iconSvgAsset;
  final VoidCallback onPressed;

  @override
  State<_KindMenuItem> createState() => _KindMenuItemState();
}

class _KindMenuItemState extends State<_KindMenuItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colorEnabled = widget.selected || _hovered || _focused;
    final accent = libraryAccentForKind(widget.type.mediaKind);
    final icon = DecoratedBox(
      decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withValues(alpha: .45))),
      child: SizedBox.square(
          dimension: 26,
          child: widget.iconSvgAsset == null
              ? Icon(widget.icon, size: 18, color: Colors.white)
              : Padding(
                  padding: const EdgeInsets.all(3),
                  child: SvgPicture.asset(widget.iconSvgAsset!,
                      width: 18, height: 18))),
    );
    return Semantics(
      selected: widget.selected,
      child: MenuItemButton(
        onPressed: widget.onPressed,
        requestFocusOnHover: false,
        onHover: (value) => setState(() => _hovered = value),
        onFocusChange: (value) => setState(() => _focused = value),
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(0, 36)),
          maximumSize: WidgetStatePropertyAll(Size(double.infinity, 36)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 7)),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStatePropertyAll(Color(0x1F000000)),
        ),
        child: SizedBox(
            height: 36,
            child: Row(children: [
              ColorFiltered(
                key: ValueKey('library-kind-icon-${widget.type.kind}'),
                colorFilter: colorEnabled
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                    : const ColorFilter.matrix([
                        0.38,
                        0.54,
                        0.08,
                        0,
                        0,
                        0.18,
                        0.74,
                        0.08,
                        0,
                        0,
                        0.18,
                        0.54,
                        0.28,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                child: icon,
              ),
              const SizedBox(width: 7),
              Expanded(
                  child: Text('CLR ${libraryNavLabel(widget.type)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colorEnabled
                              ? const Color(0xFF333333)
                              : const Color(0xFF757575),
                          fontFamily: appFontFamily,
                          fontFamilyFallback: kAppFontFamilyFallback,
                          fontSize: 16,
                          fontWeight: FontWeight.w400))),
            ])),
      ),
    );
  }
}

/// The app switcher is a square white popover in either skin, framed by a
/// translucent hairline, with an 11 px anchor pointer.
class _LibraryMenuBorder extends OutlinedBorder {
  const _LibraryMenuBorder(
      {required this.pointerOffset,
      super.side = const BorderSide(color: Color(0x33000000))});
  final double pointerOffset;

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _LibraryMenuBorder(pointerOffset: pointerOffset, side: side ?? this.side);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final pointerX = rect.left + pointerOffset.clamp(14.0, rect.width - 14.0);
    return Path.combine(
      PathOperation.union,
      Path()..addRect(rect),
      Path()
        ..moveTo(pointerX - 11, rect.top + 1)
        ..lineTo(pointerX, rect.top - 10)
        ..lineTo(pointerX + 11, rect.top + 1)
        ..close(),
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      getOuterPath(rect, textDirection: textDirection),
      Paint()
        ..color = side.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = side.width,
    );
  }
}
