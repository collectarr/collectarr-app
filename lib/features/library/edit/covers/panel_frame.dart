import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One reference cover panel: its title, a toolbar with the top corners
/// rounded and the framed image below it.
final class LibraryCoverPanelFrame extends StatelessWidget {
  const LibraryCoverPanelFrame({
    super.key,
    required this.title,
    required this.toolbar,
    required this.child,
    this.toolbarColor,
    this.padding = const EdgeInsets.all(LibraryCoverPanelFrame.inset),
  });

  /// The space between the frame and the cover.
  static const double inset = 10;

  final String title;
  final Widget toolbar;
  final Widget child;

  /// Replaces the black toolbar, as while cropping.
  final Color? toolbarColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final previewBorder = BorderSide(
        color: palette.isDark ? const Color(0xff666666) : palette.divider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Opacity(
            opacity: 0.7,
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, height: 19 / 13),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: toolbarColor ??
                  (palette.isDark ? const Color(0xff131313) : palette.toolbar),
              border: toolbarColor != null
                  ? null
                  : Border(
                      top: BorderSide(
                          color: palette.isDark
                              ? const Color(0xff252525)
                              : palette.divider),
                      bottom: BorderSide(
                          color: palette.isDark
                              ? const Color(0xff010101)
                              : palette.divider),
                    ),
            ),
            child: toolbar,
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: palette.isDark ? const Color(0xff444444) : palette.surface,
              border: Border(
                left: previewBorder,
                right: previewBorder,
                bottom: previewBorder,
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A 30 px toolbar button: 14 px glyph and label, a rounded hover and a
/// quarter-opacity disabled state.
final class LibraryCoverToolbarButton extends StatelessWidget {
  const LibraryCoverToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.foregroundColor,
    this.hoverColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = foregroundColor ?? palette.textPrimary;
    return Opacity(
      opacity: onPressed == null ? 0.25 : 1,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          textStyle: TextStyle(
              fontFamily: appFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14),
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          overlayColor:
              hoverColor ?? (palette.isDark ? const Color(0xff464950) : null),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          minimumSize: const Size(0, 30),
          maximumSize: const Size(double.infinity, 30),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // Standard density keeps the 30 px height; compact would shrink it.
          visualDensity: VisualDensity.standard,
        ),
        // The reference's fixed-width glyph sits right against its label.
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14),
          const SizedBox(width: 3),
          Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
