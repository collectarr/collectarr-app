part of '../library_add_dialog.dart';

class LibraryAddShell extends StatelessWidget {
  const LibraryAddShell({
    super.key,
    required this.accent,
    required this.width,
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.onResizeWidth,
    required this.onResizeHeight,
    required this.child,
  });

  final Color accent;
  final double width;
  final double height;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final ValueChanged<double> onResizeWidth;
  final ValueChanged<double> onResizeHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: buildLibraryAddDialogTheme(accent, palette),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width.clamp(minWidth, maxWidth),
            maxHeight: height.clamp(minHeight, maxHeight),
          ),
          child: _ResizableDialogShell(
            accent: accent,
            onResizeWidth: onResizeWidth,
            onResizeHeight: onResizeHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
