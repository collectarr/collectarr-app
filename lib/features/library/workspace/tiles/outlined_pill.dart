import 'package:flutter/material.dart';
import 'card_presentation.dart';

/// A [LibraryCardPill] outlined in [color]: the lead segment, on its own
/// fill when it has one, then the value.
class LibraryOutlinedPill extends StatelessWidget {
  const LibraryOutlinedPill(
      {required this.pill, required this.color, super.key});
  final LibraryCardPill pill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget segment(String text, IconData? icon, Color color) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14))),
        ]);
    final lead = pill.lead;
    final value = pill.value;
    final leadBackground = pill.leadBackground;
    return Container(
        height: 22,
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (lead != null)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: leadBackground == null
                    ? null
                    : BoxDecoration(
                        gradient: leadBackground,
                        borderRadius: value == null
                            ? BorderRadius.circular(4)
                            : const BorderRadius.horizontal(
                                left: Radius.circular(4))),
                alignment: Alignment.center,
                child: segment(
                    lead,
                    pill.leadIcon,
                    leadBackground == null
                        ? color
                        : Colors.black.withValues(alpha: .7))),
          if (value != null)
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: segment(value, pill.valueIcon, color))),
        ]));
  }
}
