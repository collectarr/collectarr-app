import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// Native Add chrome. Query controllers and search/scan behavior stay in the
/// shared mode bar and Add session; this widget only arranges their controls.
class LibraryAddMobileSearchControls<T> extends StatelessWidget {
  const LibraryAddMobileSearchControls({
    super.key,
    required this.tabs,
    required this.selected,
    required this.accent,
    required this.onSelected,
    required this.input,
    this.advanced,
  });

  final List<({T value, String label})> tabs;
  final T selected;
  final Color accent;
  final ValueChanged<T> onSelected;
  final Widget? input;
  final Widget? advanced;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MobileTabStrip<T>(
              tabs: tabs,
              selected: selected,
              color: accent,
              compact: true,
              onSelected: onSelected),
          if (input != null)
            ColoredBox(
              color: appPalette(context).canvas,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: input),
            ),
          if (advanced != null) advanced!,
        ],
      );
}
