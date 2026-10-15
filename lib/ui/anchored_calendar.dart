import 'package:collectarr_app/ui/app_dialog.dart';
import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A field-anchored calendar. Choosing a day commits; dismissal keeps the value.
Future<DateTime?> showAppAnchoredCalendar({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final box = context.findRenderObject() as RenderBox?;
  final anchor =
      box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;
  final theme = Theme.of(context);
  final palette = appPalette(context);
  return showAppDialog<DateTime>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (popupContext) => LayoutBuilder(builder: (context, constraints) {
      final safe = MediaQuery.paddingOf(context);
      final width =
          math.min(320.0, constraints.maxWidth - safe.horizontal - 16);
      final height =
          math.min(352.0, constraints.maxHeight - safe.vertical - 16);
      final left = anchor.left.clamp(
          safe.left + 8,
          math.max(
              safe.left + 8, constraints.maxWidth - safe.right - width - 8));
      final below = anchor.bottom + 2;
      final top = (below + height <= constraints.maxHeight - safe.bottom - 8
              ? below
              : anchor.top - height - 2)
          .clamp(
              safe.top + 8,
              math.max(safe.top + 8,
                  constraints.maxHeight - safe.bottom - height - 8));
      return Stack(children: [
        Positioned(
          left: left.toDouble(),
          top: top.toDouble(),
          width: width,
          height: height,
          child: Theme(
              data: theme.copyWith(
                colorScheme:
                    theme.colorScheme.copyWith(primary: palette.utilityAction),
                textTheme: theme.textTheme.copyWith(
                    bodyLarge: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary)),
                datePickerTheme: buildAppDatePickerTheme(
                    palette: palette, accent: palette.utilityAction),
              ),
              child: Material(
                color: palette.panelRaised,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: palette.divider)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                    child: CalendarDatePicker(
                  initialDate: initialDate.isBefore(firstDate)
                      ? firstDate
                      : initialDate.isAfter(lastDate)
                          ? lastDate
                          : initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) => Navigator.of(popupContext).pop(date),
                )),
              )),
        )
      ]);
    }),
  );
}
