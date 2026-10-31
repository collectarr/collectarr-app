import 'package:flutter/material.dart';
import 'package:collectarr_app/core/fonts/local_font_controller.dart';

/// Keep painting, wrapping and automatic column sizing on the same font.
TextStyle libraryTableCellTextStyle(BuildContext context,
        {double fontSize = 14}) =>
    (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      // Local faces keep their calibrated normal slot; the bundled list face
      // needs more ink to match the reference's dense rows.
      fontWeight: LocalFontController.instance.isGilroyActive
          ? FontWeight.w400
          : FontWeight.w700,
    );

class LibraryTableCellText extends StatelessWidget {
  const LibraryTableCellText(
    this.value, {
    this.emptyText = '-',
    this.fontSize = 14,
    super.key,
  });

  final String? value;
  final String emptyText;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.isEmpty;
    // An ellipsis truncates after the first line even without maxLines, so
    // wrapped cells must not request one.
    final wraps = LibraryTableCellDisplayScope.wraps(context);
    return Text(
      isEmpty ? emptyText : value!,
      maxLines: wraps ? null : 1,
      overflow: wraps ? TextOverflow.clip : TextOverflow.ellipsis,
      style: libraryTableCellTextStyle(context, fontSize: fontSize).copyWith(
        color: isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
      ),
    );
  }
}

/// A custom list cell that tells wrapped rows which text to fit.
abstract interface class LibraryMeasuredTableCell {
  /// The longest text the cell can show.
  String get measuredText;
}

/// The text a list cell shows, used to size wrapped rows.
String libraryTableCellText(Widget cell) => switch (cell) {
      LibraryTableCellText(:final value, :final emptyText) =>
        value == null || value.isEmpty ? emptyText : value,
      Text(:final data) => data ?? '',
      LibraryMeasuredTableCell(:final measuredText) => measuredText,
      _ => '',
    };

class LibraryTableCellDisplayScope extends InheritedWidget {
  const LibraryTableCellDisplayScope({
    super.key,
    required this.wrap,
    required super.child,
  });
  final bool wrap;
  static bool wraps(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LibraryTableCellDisplayScope>()
          ?.wrap ??
      false;
  @override
  bool updateShouldNotify(LibraryTableCellDisplayScope oldWidget) =>
      wrap != oldWidget.wrap;
}
