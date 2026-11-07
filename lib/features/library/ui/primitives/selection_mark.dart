import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:flutter/material.dart';

/// A small selection glyph, independent of icon fonts and input handling.
class LibrarySelectionMark extends StatelessWidget {
  const LibrarySelectionMark({
    super.key,
    required this.checked,
    required this.foregroundColor,
    this.cutoutColor = Colors.transparent,
    this.outlined = false,
    this.indeterminate = false,
  });

  final bool checked;
  final bool indeterminate;
  final bool outlined;
  final Color foregroundColor;
  final Color cutoutColor;

  @override
  Widget build(BuildContext context) => Semantics(
        checked: checked,
        child: AppCheckMark(
          value: indeterminate ? null : checked,
          size: 14,
          look: AppCheckLook(
            fill: outlined ? Colors.transparent : foregroundColor,
            checkedFill: outlined ? Colors.transparent : foregroundColor,
            check: outlined ? foregroundColor : cutoutColor,
            border: outlined ? foregroundColor : null,
            checkedBorder: outlined ? foregroundColor : null,
            borderWidth: 1.2,
            radius: 2,
            tickWidth: 1.5,
          ),
        ),
      );
}
