import 'package:flutter/material.dart';

/// Touch-sized content for native toolbar menus; activation stays with the menu.
class MobileToolbarTrigger extends StatelessWidget {
  const MobileToolbarTrigger(
      {super.key, required this.icon, this.label, this.chevron = false});
  final IconData icon;
  final String? label;
  final bool chevron;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 24),
              if (label != null) ...[
                const SizedBox(width: 8),
                Flexible(
                    child: Text(label!,
                        maxLines: 1, overflow: TextOverflow.ellipsis))
              ],
              if (chevron) ...[
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 20)
              ],
            ])),
      );
}
