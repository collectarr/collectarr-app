import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const kLibraryFolderRowHeight = 27.0;
const kLibraryFolderCountMinWidth = 28.0;

TextStyle libraryFolderTextStyle(BuildContext context) =>
    (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 22 / 14,
      letterSpacing: 0,
    );

Color libraryFolderHoverColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff464950)
        : appPalette(context).panelRaised;

Color libraryFolderDepthColor(BuildContext context, int depth) =>
    Theme.of(context).brightness == Brightness.dark
        ? Color(depth == 0
            ? 0xff383838
            : depth == 1
                ? 0xff292929
                : 0xff191919)
        : Color.alphaBlend(
            Colors.black.withValues(alpha: math.min(depth, 3) * 0.03),
            appPalette(context).panel);

double libraryFolderCountWidth(BuildContext context, Iterable<int> counts) {
  final painter = TextPainter(
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  );
  var width = kLibraryFolderCountMinWidth;
  for (final count in counts.toSet()) {
    painter.text = TextSpan(
        text: count.toString(), style: libraryFolderTextStyle(context));
    painter.layout();
    width = math.max(width, painter.width + 8);
  }
  painter.dispose();
  return width.ceilToDouble();
}

/// One row for flat folders and tree nodes, including their count and selection.
class LibraryFolderRow extends StatefulWidget {
  const LibraryFolderRow({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.accent,
    required this.countWidth,
    this.onTap,
    this.leading,
    this.indentation = 0,
    this.depth = 0,
    this.rowPadding = 4,
    this.separateAfter = false,
  });

  final String label;
  final int count;
  final bool selected;
  final Color accent;
  final double countWidth;
  final VoidCallback? onTap;
  final Widget? leading;
  final double indentation;
  final int depth;
  final double rowPadding;
  final bool separateAfter;

  @override
  State<LibraryFolderRow> createState() => _LibraryFolderRowState();
}

class _LibraryFolderRowState extends State<LibraryFolderRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.selected
        ? widget.accent
        : _hovered
            ? libraryFolderHoverColor(context)
            : libraryFolderDepthColor(context, widget.depth);
    final foreground = widget.selected
        ? appContrastingTextColor(background)
        : appPalette(context).textPrimary;
    final style = libraryFolderTextStyle(context);
    return Padding(
      padding: EdgeInsets.only(bottom: widget.separateAfter ? 5 : 0),
      child: MouseRegion(
        cursor: widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              border: Border(
                  bottom: BorderSide(
                      color: widget.selected
                          ? background
                          : Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xff262626)
                              : appPalette(context).divider)),
            ),
            child: SizedBox(
              height: math.max(
                  kLibraryFolderRowHeight + (widget.rowPadding - 4) * 2,
                  MediaQuery.textScalerOf(context).scale(22) + 5),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth <
                    widget.indentation + widget.countWidth + 40) {
                  return const SizedBox.expand();
                }
                return Padding(
                  padding:
                      EdgeInsets.only(left: 5 + widget.indentation, right: 5),
                  child: Row(children: [
                    if (widget.leading != null) widget.leading!,
                    Expanded(
                        child: Text(widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style.copyWith(color: foreground))),
                    const SizedBox(width: 4),
                    Container(
                      width: widget.countWidth,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? Colors.white
                            : libraryFolderHoverColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(widget.count.toString(),
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: widget.selected
                                  ? libraryAccentTextColor(
                                      widget.accent, Colors.white)
                                  : appPalette(context).textPrimary)),
                    ),
                  ]),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
