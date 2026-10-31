import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared card mechanics: the text, value and status each receive space.
class LibraryCardFooter extends StatelessWidget {
  const LibraryCardFooter(
      {super.key,
      required this.label,
      required this.value,
      required this.status,
      required this.selected});
  final String label;
  final String? value;
  final Widget status;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LayoutBuilder(builder: (context, constraints) {
      final hasValue = value != null && constraints.maxWidth >= 96;
      return Row(children: [
        Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: selected ? Colors.white : palette.textMuted))),
        if (hasValue) ...[
          const SizedBox(width: 6),
          ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: (constraints.maxWidth - 33) * 0.60),
              child: Tooltip(
                  message: value!,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2AA4CC),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))))),
        ],
        const SizedBox(width: 6),
        status,
      ]);
    });
  }
}
