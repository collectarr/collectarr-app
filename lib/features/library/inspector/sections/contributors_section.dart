import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InspectorContributorsSection extends StatelessWidget {
  const InspectorContributorsSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final creators = request.entry.creators ?? const <Map<String, dynamic>>[];
    if (creators.isEmpty) {
      return const SizedBox.shrink();
    }
    final byRole = <String, List<_ContributorChipData>>{};
    for (final credit in creators) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = credit['role']?.toString().trim();
      final key = (role == null || role.isEmpty) ? 'Cast & crew' : role;
      byRole.putIfAbsent(key, () => <_ContributorChipData>[]).add(
            _ContributorChipData(
              name: name,
              imageUrl: credit['image_url']?.toString().trim(),
            ),
          );
    }
    final entries = byRole.entries.toList(growable: false);
    return LibraryDetailSection(
      title: 'Cast & crew',
      accentColor: request.accent,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _ContributorGroup(
            label: entries[i].key,
            values: entries[i].value,
            onValueTap: request.onFilterByValue,
          ),
          if (i != entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ContributorGroup extends StatelessWidget {
  const _ContributorGroup({
    required this.label,
    required this.values,
    required this.onValueTap,
  });

  final String label;
  final List<_ContributorChipData> values;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final palette = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values)
              _ContributorChip(
                data: value,
                accent: accent,
                onPressed:
                    onValueTap == null ? null : () => onValueTap!(value.name),
                surfaceColor: palette.surfaceContainerHighest,
              ),
          ],
        ),
      ],
    );
  }
}

class _ContributorChipData {
  const _ContributorChipData({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String? imageUrl;
}

class _ContributorChip extends StatelessWidget {
  const _ContributorChip({
    required this.data,
    required this.accent,
    required this.onPressed,
    required this.surfaceColor,
  });

  final _ContributorChipData data;
  final Color accent;
  final VoidCallback? onPressed;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imageUrl;
    final avatar = imageUrl == null || imageUrl.isEmpty
        ? CircleAvatar(
            radius: 10,
            backgroundColor: accent.withValues(alpha: 0.22),
            child: const Icon(Icons.person, size: 12),
          )
        : CircleAvatar(
            radius: 10,
            backgroundColor: accent.withValues(alpha: 0.18),
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
            child: const Icon(Icons.person, size: 12),
          );
    return ActionChip(
      avatar: avatar,
      label: Text(
        data.name,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onPressed,
      backgroundColor: surfaceColor,
      side: BorderSide(color: accent.withValues(alpha: 0.16)),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
