import 'package:flutter/material.dart';

/// Compact content for native toolbar menus, in the reference's 30 dp buttons;
/// activation stays with the menu.
class MobileToolbarTrigger extends StatelessWidget {
  const MobileToolbarTrigger(
      {super.key,
      required this.icon,
      this.label,
      this.chevron = false,
      this.iconBackground});
  final IconData icon;
  final String? label;
  final bool chevron;

  /// A square behind the icon alone, as on the reference's Back to folders.
  final Color? iconBackground;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 6),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconBackground case final background?)
                    Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(4)),
                        child: Icon(icon, size: 13))
                  else
                    Icon(icon, size: 18),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)))
                  ],
                  if (chevron) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.expand_more, size: 18)
                  ],
                ])),
      );
}
