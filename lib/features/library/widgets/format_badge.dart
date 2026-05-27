import 'package:flutter/material.dart';

/// Visual configuration for a physical media format badge.
class FormatBadgeStyle {
  const FormatBadgeStyle({
    required this.color,
    required this.icon,
    this.shortLabel,
  });

  final Color color;
  final IconData icon;

  /// Optional short label override (e.g. '4K' instead of '4K UHD').
  final String? shortLabel;
}

/// Color/icon mapping for known physical media format IDs.
const _formatStyles = <String, FormatBadgeStyle>{
  // ── Video ──
  'dvd': FormatBadgeStyle(
    color: Color(0xFFC62828),
    icon: Icons.album,
  ),
  'blu-ray': FormatBadgeStyle(
    color: Color(0xFF1565C0),
    icon: Icons.album,
  ),
  '4k-uhd': FormatBadgeStyle(
    color: Color(0xFF6A1B9A),
    icon: Icons.album,
    shortLabel: '4K',
  ),
  'vhs': FormatBadgeStyle(
    color: Color(0xFF37474F),
    icon: Icons.videocam,
  ),
  'laserdisc': FormatBadgeStyle(
    color: Color(0xFF4E342E),
    icon: Icons.album,
    shortLabel: 'LD',
  ),
  'digital': FormatBadgeStyle(
    color: Color(0xFF00838F),
    icon: Icons.cloud_done,
  ),

  // ── Music ──
  'vinyl': FormatBadgeStyle(
    color: Color(0xFF212121),
    icon: Icons.album,
  ),
  'cd': FormatBadgeStyle(
    color: Color(0xFF546E7A),
    icon: Icons.album,
  ),
  'cassette': FormatBadgeStyle(
    color: Color(0xFF5D4037),
    icon: Icons.settings_input_svideo,
  ),
  'digital-audio': FormatBadgeStyle(
    color: Color(0xFF00838F),
    icon: Icons.cloud_done,
  ),

  // ── Print ──
  'hardcover': FormatBadgeStyle(
    color: Color(0xFF4E342E),
    icon: Icons.menu_book,
    shortLabel: 'HC',
  ),
  'paperback': FormatBadgeStyle(
    color: Color(0xFF558B2F),
    icon: Icons.menu_book,
    shortLabel: 'PB',
  ),
  'mass-market': FormatBadgeStyle(
    color: Color(0xFF827717),
    icon: Icons.menu_book,
    shortLabel: 'MMPB',
  ),
  'ebook': FormatBadgeStyle(
    color: Color(0xFF00838F),
    icon: Icons.tablet_android,
  ),
  'audiobook': FormatBadgeStyle(
    color: Color(0xFF6A1B9A),
    icon: Icons.headphones,
  ),

  // ── Comics ──
  'single-issue': FormatBadgeStyle(
    color: Color(0xFFC62828),
    icon: Icons.description,
    shortLabel: 'Issue',
  ),
  'trade-paperback': FormatBadgeStyle(
    color: Color(0xFF558B2F),
    icon: Icons.menu_book,
    shortLabel: 'TPB',
  ),
  'hardcover-comic': FormatBadgeStyle(
    color: Color(0xFF4E342E),
    icon: Icons.menu_book,
    shortLabel: 'HC',
  ),
  'omnibus': FormatBadgeStyle(
    color: Color(0xFF283593),
    icon: Icons.menu_book,
  ),
  'graphic-novel': FormatBadgeStyle(
    color: Color(0xFF00695C),
    icon: Icons.menu_book,
    shortLabel: 'GN',
  ),
  'digital-comic': FormatBadgeStyle(
    color: Color(0xFF00838F),
    icon: Icons.tablet_android,
  ),

  // ── Games ──
  'physical-disc': FormatBadgeStyle(
    color: Color(0xFF1565C0),
    icon: Icons.album,
    shortLabel: 'Disc',
  ),
  'cartridge': FormatBadgeStyle(
    color: Color(0xFF37474F),
    icon: Icons.memory,
    shortLabel: 'Cart',
  ),
  'digital-game': FormatBadgeStyle(
    color: Color(0xFF00838F),
    icon: Icons.cloud_done,
  ),
  'collectors-edition': FormatBadgeStyle(
    color: Color(0xFFBF360C),
    icon: Icons.star,
    shortLabel: "CE",
  ),
};

const _fallbackStyle = FormatBadgeStyle(
  color: Color(0xFF616161),
  icon: Icons.disc_full,
);

/// Resolves the [FormatBadgeStyle] for a format [id].
FormatBadgeStyle formatBadgeStyleForId(String id) {
  return _formatStyles[id] ?? _fallbackStyle;
}

/// Compact pill badge showing a physical media format.
///
/// Use [FormatBadge.fromId] to resolve style from a format ID string.
class FormatBadge extends StatelessWidget {
  const FormatBadge({
    super.key,
    required this.label,
    required this.style,
    this.compact = false,
  });

  /// Creates a badge from a format ID and optional label override.
  factory FormatBadge.fromId(
    String formatId, {
    Key? key,
    String? labelOverride,
    bool compact = false,
  }) {
    final style = formatBadgeStyleForId(formatId);
    return FormatBadge(
      key: key,
      label: labelOverride ?? style.shortLabel ?? _formatLabelFallback(formatId),
      style: style,
      compact: compact,
    );
  }

  /// Creates a badge from a format ID and its display label.
  factory FormatBadge.fromFormat({
    Key? key,
    required String id,
    required String label,
    bool compact = false,
  }) {
    final style = formatBadgeStyleForId(id);
    return FormatBadge(
      key: key,
      label: style.shortLabel ?? label,
      style: style,
      compact: compact,
    );
  }

  final String label;
  final FormatBadgeStyle style;

  /// If true, shows only the icon without label text.
  final bool compact;

  @override
  Widget build(BuildContext context) {
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
              Icon(style.icon, size: compact ? 11 : 13, color: Colors.white),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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

/// Horizontal row of format badges.
class FormatBadgeRow extends StatelessWidget {
  const FormatBadgeRow({
    super.key,
    required this.formatId,
    this.formatLabel,
    this.compact = false,
    this.discCount,
    this.ageRating,
  });

  final String? formatId;
  final String? formatLabel;
  final bool compact;
  final int? discCount;
  final String? ageRating;

  @override
  Widget build(BuildContext context) {
    if (formatId == null && discCount == null && ageRating == null) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (formatId != null)
          FormatBadge.fromFormat(
            id: formatId!,
            label: formatLabel ?? formatId!,
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
            Icon(icon, size: compact ? 11 : 13, color: Colors.white70),
            if (!compact) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
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

String _formatLabelFallback(String formatId) {
  return formatId
      .replaceAll('-', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
