import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard search or add candidate result row in Library UI.
///
/// Standardizes:
/// - Thumbnail/leading presentation
/// - Title and subtitle typography
/// - Badges / tag alignment
/// - Trailing action / status indicator
/// - Hover / selected background states
class LibraryResultRow extends StatelessWidget {
  const LibraryResultRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.badges = const [],
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
    this.accent,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> badges;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final rowAccent = accent ?? palette.accent;

    final backgroundColor = isSelected
        ? palette.selection
        : Colors.transparent;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        hoverColor: palette.surfaceSubtle,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: palette.divider),
              left: isSelected
                  ? BorderSide(color: rowAccent, width: 3)
                  : BorderSide.none,
            ),
          ),
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.sectionTitle.copyWith(
                        color: palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!.trim(),
                        style: theme.textTheme.supportingText.copyWith(
                          color: palette.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: badges,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
