import 'dart:math' as math;
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dropup attached to the collection strip, including at the window edge.
class LibraryCollectionMenu extends StatefulWidget {
  const LibraryCollectionMenu(
      {super.key,
      required this.collections,
      required this.activeId,
      required this.accent,
      required this.onSelected,
      required this.onManage});
  final List<LibraryCollectionSummary> collections;
  final String? activeId;
  final Color accent;
  final ValueChanged<LibraryCollectionSummary> onSelected;
  final VoidCallback onManage;
  @override
  State<LibraryCollectionMenu> createState() => _LibraryCollectionMenuState();
}

class _LibraryCollectionMenuState extends State<LibraryCollectionMenu> {
  final _overlay = OverlayPortalController();
  @override
  Widget build(BuildContext context) => OverlayPortal.overlayChildLayoutBuilder(
        controller: _overlay,
        overlayLocation: OverlayChildLocation.rootOverlay,
        overlayChildBuilder: _menu,
        child: Tooltip(
            message: 'Collections',
            child: Builder(builder: (context) {
              final palette = appPalette(context);
              return InkWell(
                key: const ValueKey('library-collection-menu'),
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _overlay.toggle(),
                borderRadius: BorderRadius.circular(4),
                hoverColor: palette.isDark
                    ? const Color(0xff383838)
                    : palette.surfaceBright,
                highlightColor: Colors.transparent,
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(AppIcons.menu,
                        size: 16,
                        color: palette.textPrimary.withValues(alpha: .75))),
              );
            })),
      );

  Widget _menu(BuildContext context, OverlayChildLayoutInfo info) {
    final palette = appPalette(context);
    final anchor = MatrixUtils.transformRect(
        info.childPaintTransform, Offset.zero & info.childSize);
    final style = TextStyle(
        fontFamily: appFontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary);
    final width = math.min(
        info.overlaySize.width - 6,
        measureLibraryToolbarDropdownWidth(context,
            labels: [
              ...widget.collections.map((c) => c.name),
              'Manage Collections'
            ],
            textStyle: style,
            leadingWidth: 17.5 +
                (widget.collections.any((c) =>
                        libraryKindRegistrationForKind(
                                catalogMediaKindFromApiValue(c.kind))
                            .identity
                            .collectionIconSvgAsset !=
                        null)
                    ? 23
                    : 0),
            leadingSpacing: 4,
            trailingWidth: 0,
            horizontalPadding: 16,
            minWidth: 160));
    final desiredHeight = widget.collections.length * 30.0 + 35;
    final opensAbove = anchor.top >= math.min(desiredHeight + 6, 120);
    final height = math.min(
        desiredHeight,
        math.max(
            0.0,
            opensAbove
                ? anchor.top - 6
                : info.overlaySize.height - anchor.bottom - 6));
    Widget item(
            {required Widget child,
            required VoidCallback onTap,
            double height = 30,
            Color? color}) =>
        Material(
            color: color ?? Colors.transparent,
            child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  _overlay.hide();
                  onTap();
                },
                child: SizedBox(
                    height: height,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                            alignment: Alignment.centerLeft, child: child)))));
    return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _overlay.hide
        },
        child: Focus(
            autofocus: true,
            child: Stack(children: [
              Positioned.fill(
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque, onTap: _overlay.hide)),
              Positioned(
                  left: anchor.left.clamp(
                      3.0, math.max(3.0, info.overlaySize.width - width - 3)),
                  top: opensAbove ? anchor.top - height - 3 : anchor.bottom + 3,
                  width: width,
                  height: height,
                  child: Material(
                      key: const ValueKey('library-collection-dropup'),
                      color: palette.isDark
                          ? const Color(0xff444444)
                          : palette.panelRaised,
                      shape: Border.all(
                          color: palette.isDark
                              ? const Color(0xff666666)
                              : palette.divider),
                      child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: DefaultTextStyle(
                              style: style,
                              child:
                                  ListView(padding: EdgeInsets.zero, children: [
                                for (final collection in widget.collections)
                                  item(
                                      onTap: () =>
                                          widget.onSelected(collection),
                                      color: collection.id == widget.activeId
                                          ? widget.accent
                                          : null,
                                      child: Row(children: [
                                        // A gutter for the check mark keeps every
                                        // name aligned, as in the reference.
                                        SizedBox(
                                            width: 22,
                                            child:
                                                collection.id == widget.activeId
                                                    ? const Icon(AppIcons.check,
                                                        size: 12,
                                                        color: Colors.white)
                                                    : null),
                                        if (libraryKindRegistrationForKind(
                                                    catalogMediaKindFromApiValue(
                                                        collection.kind))
                                                .identity
                                                .collectionIconSvgAsset
                                            case final asset?) ...[
                                          SvgPicture.asset(asset,
                                              width: 18,
                                              height: 18,
                                              colorFilter: ColorFilter.mode(
                                                  collection.id ==
                                                          widget.activeId
                                                      ? Colors.white
                                                      : palette.textPrimary,
                                                  BlendMode.srcIn)),
                                          const SizedBox(width: 5),
                                        ],
                                        Expanded(
                                            child: Text(collection.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: collection.id ==
                                                        widget.activeId
                                                    ? const TextStyle(
                                                        color: Colors.white)
                                                    : null)),
                                      ])),
                                item(
                                    height: 33,
                                    onTap: widget.onManage,
                                    child: Row(children: [
                                      Icon(AppIcons.collections,
                                          size: 14, color: palette.textPrimary),
                                      const SizedBox(width: 4),
                                      const Expanded(
                                          child: Text('Manage Collections',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                    ])),
                              ]))))),
            ])));
  }
}
