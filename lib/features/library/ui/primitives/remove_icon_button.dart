import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The cross that removes a value from a field: the same glyph as a dialog's
/// close button, underlined under the pointer as in the reference.
final class LibraryRemoveIconButton extends StatefulWidget {
  const LibraryRemoveIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.width = 30,
    this.height = 34,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  State<LibraryRemoveIconButton> createState() =>
      _LibraryRemoveIconButtonState();
}

class _LibraryRemoveIconButtonState extends State<LibraryRemoveIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = appPalette(context).textPrimary.withValues(alpha: .7);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: MouseRegion(
          cursor: widget.onPressed == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: Container(
                  width: 11,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _hovered && widget.onPressed != null
                            ? color
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: OverflowBox(
                    maxWidth: 14,
                    maxHeight: 14,
                    child: Icon(AppIcons.close, size: 14, color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
