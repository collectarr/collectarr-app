import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The reference's select beside a listing's filter: a #444 field with a
/// chevron, opening a list joined to its lower edge and aligned to its right,
/// with bold rows that turn #666 under the pointer.
class LibraryAddChoiceMenu<T> extends StatefulWidget {
  const LibraryAddChoiceMenu({
    super.key,
    required this.tooltip,
    required this.width,
    required this.label,
    required this.values,
    required this.labelFor,
    required this.onSelected,
    this.height = 24,
    this.menuWidth = 181,
  });

  final String tooltip;
  final double width;
  final String label;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;
  final double height;
  final double menuWidth;

  @override
  State<LibraryAddChoiceMenu<T>> createState() =>
      _LibraryAddChoiceMenuState<T>();
}

class _LibraryAddChoiceMenuState<T> extends State<LibraryAddChoiceMenu<T>> {
  final _overlay = OverlayPortalController();
  final _link = LayerLink();

  void _toggle() => setState(_overlay.toggle);

  void _close() {
    if (_overlay.isShowing) setState(_overlay.hide);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final fill = palette.isDark ? const Color(0xff444444) : palette.field;
    final open = _overlay.isShowing;
    return TapRegion(
      groupId: _overlay,
      onTapOutside: (_) => _close(),
      child: OverlayPortal(
        controller: _overlay,
        overlayChildBuilder: (context) => CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          child: Align(
            alignment: Alignment.topRight,
            child: TapRegion(
              groupId: _overlay,
              child: _ChoiceList<T>(
                width: widget.menuWidth,
                fill: fill,
                values: widget.values,
                labelFor: widget.labelFor,
                onSelected: (value) {
                  _close();
                  widget.onSelected(value);
                },
              ),
            ),
          ),
        ),
        child: CompositedTransformTarget(
          link: _link,
          child: Semantics(
            button: true,
            label: widget.tooltip,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  padding: const EdgeInsets.only(left: 7, right: 9),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: open
                        ? const BorderRadius.vertical(top: Radius.circular(4))
                        : BorderRadius.circular(4),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                    ),
                    Icon(AppIcons.chevronDown,
                        size: 14, color: palette.textPrimary),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceList<T> extends StatelessWidget {
  const _ChoiceList({
    required this.width,
    required this.fill,
    required this.values,
    required this.labelFor,
    required this.onSelected,
  });

  final double width;
  final Color fill;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x2d000000), offset: Offset(0, 6), blurRadius: 12),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final value in values)
            InkWell(
              onTap: () => onSelected(value),
              mouseCursor: SystemMouseCursors.click,
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              hoverColor:
                  palette.isDark ? const Color(0xff666666) : palette.tableHover,
              child: Container(
                height: 30,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(labelFor(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ),
    );
  }
}
