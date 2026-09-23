import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// Visual configuration for a physical media format badge.
class FormatBadgeStyle {
  const FormatBadgeStyle({
    required this.color,
    required this.icon,
    this.shortLabel,
  });

  final Color color;
  final IconData icon;
  final String? shortLabel;
}

/// A fully resolved badge descriptor supplied by a kind-owned presentation
/// policy. Shared widgets never translate semantic format IDs.
@immutable
class LibraryFormatBadgeDescriptor {
  const LibraryFormatBadgeDescriptor({
    required this.key,
    required this.label,
    required this.style,
  });

  final String key;
  final String label;
  final FormatBadgeStyle style;
}

const fallbackFormatBadgeStyle = FormatBadgeStyle(
  color: Color(0xFF616161),
  icon: Icons.disc_full,
);

LibraryFormatBadgeDescriptor? resolveLibraryFormatBadge({
  required String? key,
  required String? label,
  required FormatBadgeStyle Function(String key) styleForKey,
}) {
  final normalizedKey = key?.trim().toLowerCase();
  if (normalizedKey == null || normalizedKey.isEmpty) return null;
  final normalizedLabel = label?.trim();
  return LibraryFormatBadgeDescriptor(
    key: normalizedKey,
    label: normalizedLabel == null || normalizedLabel.isEmpty
        ? normalizedKey
        : normalizedLabel,
    style: styleForKey(normalizedKey),
  );
}

/// Compact pill badge showing a resolved physical media format.
class FormatBadge extends StatelessWidget {
  const FormatBadge({
    super.key,
    required this.label,
    required this.style,
    this.compact = false,
  });

  factory FormatBadge.fromDescriptor({
    Key? key,
    required LibraryFormatBadgeDescriptor descriptor,
    bool compact = false,
  }) {
    return FormatBadge(
      key: key,
      label: descriptor.style.shortLabel ?? descriptor.label,
      style: descriptor.style,
      compact: compact,
    );
  }

  final String label;
  final FormatBadgeStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = appContrastingTextColor(style.color);
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 6,
            vertical: compact ? 2 : 3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(style.icon, size: compact ? 11 : 13, color: foreground),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of already-resolved format badges.
class FormatBadgeRow extends StatelessWidget {
  const FormatBadgeRow({
    super.key,
    this.format,
    this.compact = false,
    this.discCount,
    this.ageRating,
  });

  final LibraryFormatBadgeDescriptor? format;
  final bool compact;
  final int? discCount;
  final String? ageRating;

  @override
  Widget build(BuildContext context) {
    if (format == null && discCount == null && ageRating == null) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (format != null)
          FormatBadge.fromDescriptor(
            descriptor: format!,
            compact: compact,
          ),
        if (discCount != null && discCount! > 0)
          _InfoBadge(
            icon: Icons.album,
            label: '$discCount Disc${discCount! > 1 ? 's' : ''}',
            compact: compact,
          ),
        if (ageRating != null && ageRating!.trim().isNotEmpty)
          _InfoBadge(
            icon: Icons.shield,
            label: ageRating!,
            compact: compact,
          ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF444444),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 2 : 3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 11 : 13, color: Colors.white),
            if (!compact) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
