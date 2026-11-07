import 'package:flutter/material.dart';

/// Native action geometry; kind labels, colors, values and commands are inputs.
class LibraryMobileToolbarActions extends StatelessWidget {
  const LibraryMobileToolbarActions(
      {super.key,
      required this.background,
      required this.foreground,
      required this.actions,
      this.coverSizeSlider,
      required this.countLabel});
  final Color background;
  final Color foreground;
  final List<Widget> actions;

  /// Above the count, as in the reference's Images view.
  final Widget? coverSizeSlider;
  final String? countLabel;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
              color: background,
              child: IconButtonTheme(
                  data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: foreground,
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size.square(30),
                          fixedSize: const Size.square(30))),
                  child: SizedBox(
                      height: 40,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                              key: const Key('library.mobile-controls'),
                              children: actions))))),
          if (coverSizeSlider != null) coverSizeSlider!,
          if (countLabel != null)
            Padding(
                key: const Key('library.mobile-count'),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text(countLabel!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700))),
        ],
      );
}
