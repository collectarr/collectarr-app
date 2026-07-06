part of '../library_add_dialog.dart';

class LibraryAddShell extends StatelessWidget {
  const LibraryAddShell({
    super.key,
    required this.accent,
    required this.header,
    required this.body,
    this.footer,
    this.maxWidth = 1320,
    this.maxHeight = 860,
    this.density = LibraryDensity.comfortable,
  });

  final Color accent;
  final double maxWidth;
  final double maxHeight;
  final LibraryDensity density;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: buildLibraryAddDialogTheme(accent, palette),
      child: LibraryDialogScaffold(
        header: header,
        footer: footer,
        accent: accent,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        density: density,
        child: body,
      ),
    );
  }
}
