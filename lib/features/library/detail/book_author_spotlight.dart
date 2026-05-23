import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/library/detail/creator_detail_page.dart';
import 'package:flutter/material.dart';

class BookAuthorSpotlight extends StatelessWidget {
  const BookAuthorSpotlight({
    super.key,
    required this.creators,
    required this.accent,
    this.centered = false,
  });

  final List<Map<String, dynamic>> creators;
  final Color accent;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final spotlight = _AuthorSpotlightData.fromCreators(creators);
    if (spotlight == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final description = [
      if (spotlight.roleLabel != null) spotlight.roleLabel,
      if (spotlight.supportingLabel != null) spotlight.supportingLabel,
    ].join('  |  ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreatorDetailPage(creatorName: spotlight.name),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.42)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                accent.withValues(alpha: 0.12),
                Colors.black.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AuthorAvatar(
                  imageUrl: spotlight.imageUrl,
                  initials: spotlight.initials,
                  accent: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Author view',
                        textAlign: centered ? TextAlign.center : TextAlign.start,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spotlight.name,
                        textAlign: centered ? TextAlign.center : TextAlign.start,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          textAlign: centered ? TextAlign.center : TextAlign.start,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: accent.withValues(alpha: 0.88),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.imageUrl,
    required this.initials,
    required this.accent,
  });

  final String? imageUrl;
  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.52), width: 1.4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: ClipOval(
        child: trimmedUrl == null || trimmedUrl.isEmpty
            ? ColoredBox(
                color: accent.withValues(alpha: 0.16),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: trimmedUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(
                  color: accent.withValues(alpha: 0.12),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: accent.withValues(alpha: 0.16),
                  child: Center(
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _AuthorSpotlightData {
  const _AuthorSpotlightData({
    required this.name,
    required this.initials,
    this.roleLabel,
    this.supportingLabel,
    this.imageUrl,
  });

  final String name;
  final String initials;
  final String? roleLabel;
  final String? supportingLabel;
  final String? imageUrl;

  static _AuthorSpotlightData? fromCreators(List<Map<String, dynamic>> creators) {
    final normalized = creators
        .map((creator) => _NormalizedCreator.fromMap(creator))
        .whereType<_NormalizedCreator>()
        .toList(growable: false);
    if (normalized.isEmpty) {
      return null;
    }

    _NormalizedCreator lead = normalized.first;
    for (final creator in normalized) {
      if (_isPrimaryBookCreatorRole(creator.role)) {
        lead = creator;
        break;
      }
    }

    final others = normalized.where((creator) => creator.name != lead.name).toList(growable: false);
    final supportingLabel = switch (others.length) {
      0 => null,
      1 => 'with ${others.first.name}',
      2 => 'with ${others[0].name} and ${others[1].name}',
      _ => 'with ${others.first.name} and ${others.length - 1} more',
    };

    return _AuthorSpotlightData(
      name: lead.name,
      initials: _initialsFor(lead.name),
      roleLabel: lead.role,
      supportingLabel: supportingLabel,
      imageUrl: lead.imageUrl,
    );
  }

  static bool _isPrimaryBookCreatorRole(String? role) {
    final normalized = role?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }
    return normalized.contains('author') ||
        normalized.contains('writer') ||
        normalized.contains('novelist');
  }

  static String _initialsFor(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _NormalizedCreator {
  const _NormalizedCreator({
    required this.name,
    this.role,
    this.imageUrl,
  });

  final String name;
  final String? role;
  final String? imageUrl;

  static _NormalizedCreator? fromMap(Map<String, dynamic> data) {
    final name = data['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    final role = data['role']?.toString().trim();
    final imageUrl = data['image_url']?.toString().trim();
    return _NormalizedCreator(
      name: name,
      role: role == null || role.isEmpty ? null : role,
      imageUrl: imageUrl == null || imageUrl.isEmpty ? null : imageUrl,
    );
  }
}