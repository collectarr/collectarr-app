import 'dart:math' as math;
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/ui/app_icons.dart';

class MediaLibraryKindMenu extends StatefulWidget {
  const MediaLibraryKindMenu({
    super.key,
    required this.types,
    required this.registry,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final LibraryKindRegistry registry;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  State<MediaLibraryKindMenu> createState() => _MediaLibraryKindMenuState();
}

class _MediaLibraryKindMenuState extends State<MediaLibraryKindMenu> {
  final _anchorKey = GlobalKey();
  final _controller = MenuController();
  final _buttonFocus = FocusNode();
  double _menuWidth = 145;
  double _pointerOffset = 72.5;

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
    final rightDistance = overlay.size.width - bounds.center.dx;
    // Center the panel under its icon where space allows and fill to the edge.
    final width =
        math.min(overlay.size.width, math.max(145.0, rightDistance * 2));
    final left = overlay.size.width - width;
    setState(() {
      _menuWidth = width;
      _pointerOffset = bounds.center.dx - left;
    });
    // The panel hangs from the header's bottom edge; its pointer rises into
    // the header under the icon.
    _controller.open(
        position:
            Offset(left - bounds.left, shellAppBarHeight - 1 - bounds.top));
  }

  @override
  Widget build(BuildContext context) {
    // The header's shared circular button, like Sync and Account.
    final iconButtonStyle = appChromeIconButtonStyle(context);
    return MenuAnchor(
      key: _anchorKey,
      controller: _controller,
      childFocusNode: _buttonFocus,
      useRootOverlay: true,
      crossAxisUnconstrained: false,
      reservedPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
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
          MenuItemButton(
            key: ValueKey('library-kind-picker-item-${type.kind}'),
            onPressed: () => widget.onSelected(type),
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(0, 36)),
              maximumSize: WidgetStatePropertyAll(Size(double.infinity, 36)),
              padding:
                  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 7)),
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor: WidgetStatePropertyAll(Color(0x1F000000)),
            ),
            child: _KindMenuRow(
              type: type,
              icon: widget.registry.tryGet(type.mediaKind)?.identity.icon ??
                  libraryIconForKind(type.mediaKind),
              iconSvgAsset: widget.registry
                  .tryGet(type.mediaKind)
                  ?.identity
                  .collectionIconSvgAsset,
            ),
          ),
      ],
      child: IconButton(
        key: const Key('nav.library-kind-picker'),
        focusNode: _buttonFocus,
        tooltip: 'Switch library',
        style: iconButtonStyle,
        onPressed: _toggle,
        icon: SvgPicture.asset(AppIcons.librarySwitcherSvg,
            width: 20, height: 20),
        padding: EdgeInsets.zero,
      ),
    );
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

class _KindMenuRow extends StatelessWidget {
  const _KindMenuRow({
    required this.type,
    required this.icon,
    this.iconSvgAsset,
  });

  final CatalogMediaType type;
  final IconData icon;
  final String? iconSvgAsset;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.mediaKind);
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: .45)),
            ),
            child: SizedBox.square(
              dimension: 26,
              child: iconSvgAsset == null
                  ? Icon(icon, size: 18, color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(3),
                      child: SvgPicture.asset(iconSvgAsset!,
                          width: 18, height: 18)),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            // Named as in the header brand, in its face.
            child: Text(
              'CLR ${libraryNavLabel(type)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontFamily: appFontFamily,
                fontFamilyFallback: kAppFontFamilyFallback,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
