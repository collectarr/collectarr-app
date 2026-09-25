import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Library navigation settings widgets
// ---------------------------------------------------------------------------

class SettingsLibraryNavigationPanel extends StatelessWidget {
  const SettingsLibraryNavigationPanel({
    super.key,
    required this.catalog,
    required this.preferences,
    required this.onOrderChanged,
    required this.onVisibilityChanged,
    required this.onAccentChanged,
    required this.onReset,
  });

  final List<CatalogMediaType> catalog;
  final LibraryNavPreferences preferences;
  final ValueChanged<List<String>> onOrderChanged;
  final void Function(String kind, bool visible) onVisibilityChanged;
  final Future<void> Function(String kind, Color? color) onAccentChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final groups = _orderedSettingsLibraryNavGroups(catalog, preferences);
    final visibleGroups = [
      for (final group in groups)
        if (group.types.any((type) => preferences.isVisible(type.kind))) group,
    ];
    final hiddenCount = groups.length - visibleGroups.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LibraryNavSummary(
          visibleCount: visibleGroups.length,
          hiddenCount: hiddenCount,
        ),
        const SizedBox(height: 12),
        Text(
          'Choose which libraries appear in the app bar picker and arrange their order.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        _LibraryNavPreview(
          groups:
              visibleGroups.isEmpty ? groups.take(1).toList() : visibleGroups,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Library groups',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset library navigation'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag groups to reorder the CLZ-style top-level entries. Grouped families now behave like single libraries in the UI, even though their stored preference order still expands back to the underlying kinds.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: groups.length,
          onReorderItem: (oldIndex, newIndex) {
            final reordered = [...groups];
            final moved = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, moved);
            onOrderChanged(_expandSettingsGroupKinds(reordered));
          },
          itemBuilder: (context, index) {
            final group = groups[index];
            final hiddenKinds = [
              for (final type in group.types)
                if (!preferences.isVisible(type.kind)) type,
            ];
            final allVisible = hiddenKinds.isEmpty;
            final reordered = [...groups];
            final mediaKind = group.primaryType.mediaKind;
            final kind = group.primaryType.kind;
            final defaultAccent = libraryDefaultAccentForKind(mediaKind);
            final effectiveAccent = libraryAccentForKind(mediaKind);
            final hasAccentOverride =
                preferences.accentHexForKind(kind) != null;
            return ListTile(
              key: ValueKey('library-nav-${group.id}'),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: SizedBox(
                width: 74,
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    const SizedBox(width: 6),
                    _LibraryNavTypeIcon(group: group),
                  ],
                ),
              ),
              title: Text(group.label),
              subtitle: Text(
                [
                  allVisible ? 'Visible' : 'Hidden',
                  _groupProviders(group).isEmpty
                      ? 'No provider'
                      : 'Providers: ${_groupProviders(group).join(', ')}',
                ].join(' | '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                children: [
                  IconButton(
                    tooltip: 'Move up',
                    onPressed: index == 0
                        ? null
                        : () {
                            final moved = reordered.removeAt(index);
                            reordered.insert(index - 1, moved);
                            onOrderChanged(
                                _expandSettingsGroupKinds(reordered));
                          },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: 'Move down',
                    onPressed: index == groups.length - 1
                        ? null
                        : () {
                            final moved = reordered.removeAt(index);
                            reordered.insert(index + 1, moved);
                            onOrderChanged(
                                _expandSettingsGroupKinds(reordered));
                          },
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    tooltip: 'Pick accent color',
                    onPressed: () async {
                      final picked = await _showLibraryAccentPickerDialog(
                        context,
                        initialColor: effectiveAccent,
                        defaultColor: defaultAccent,
                        title: group.label,
                      );
                      if (picked == null) {
                        return;
                      }
                      await onAccentChanged(kind, picked);
                    },
                    icon: Icon(
                      Icons.palette_outlined,
                      color: effectiveAccent,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reset accent color',
                    onPressed: hasAccentOverride
                        ? () => onAccentChanged(kind, null)
                        : null,
                    icon: const Icon(Icons.restart_alt),
                  ),
                  Switch(
                    value: allVisible,
                    onChanged: (value) {
                      for (final type in group.types) {
                        onVisibilityChanged(type.kind, value);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LibraryNavSummary extends StatelessWidget {
  const _LibraryNavSummary({
    required this.visibleCount,
    required this.hiddenCount,
  });

  final int visibleCount;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SettingsMiniStat(
          icon: Icons.visibility_outlined,
          label: '$visibleCount visible',
        ),
        _SettingsMiniStat(
          icon: Icons.visibility_off_outlined,
          label: '$hiddenCount hidden',
        ),
        const _SettingsMiniStat(
          icon: Icons.apps_outlined,
          label: 'App bar picker',
        ),
      ],
    );
  }
}

class _LibraryNavPreview extends StatelessWidget {
  const _LibraryNavPreview({
    required this.groups,
  });

  final List<LibraryNavGroup> groups;

  @override
  Widget build(BuildContext context) {
    final visible = groups.take(4).toList();
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Switch libraries from the app bar menu.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SizedBox(
                width: 210,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Switch library',
                        onPressed: null,
                        icon: const Icon(Icons.apps_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    for (final group in visible)
                      _LibraryNavPreviewRow(group: group),
                    if (groups.length > visible.length)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'More libraries',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryNavTypeIcon extends StatelessWidget {
  const _LibraryNavTypeIcon({required this.group});

  final LibraryNavGroup group;

  @override
  Widget build(BuildContext context) {
    final type = group.primaryType;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: libraryAccentForKind(type.mediaKind).withValues(alpha: 0.18),
        border: Border.all(color: libraryAccentForKind(type.mediaKind)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: 30,
        child: Icon(
          libraryIconForKind(type.mediaKind),
          size: 17,
          color: libraryAccentForKind(type.mediaKind),
        ),
      ),
    );
  }
}

class _LibraryNavPreviewRow extends StatelessWidget {
  const _LibraryNavPreviewRow({required this.group});

  final LibraryNavGroup group;

  @override
  Widget build(BuildContext context) {
    final type = group.primaryType;
    final accent = libraryAccentForKind(type.mediaKind);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(3),
              ),
              child: SizedBox.square(
                dimension: 22,
                child: Icon(libraryIconForKind(type.mediaKind),
                    size: 14, color: accent),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMiniStat extends StatelessWidget {
  const _SettingsMiniStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

List<CatalogMediaType> _orderedSettingsMediaTypes(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  final byKind = {
    for (final type in catalog) type.kind: type,
  };
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel ||
          defaultLibraryKindRegistry.tryGet(type.mediaKind) != null)
        type.kind: type,
  };
  final defaultKinds = [
    for (final registration in defaultLibraryKindRegistry.allKinds)
      registration.kind.apiValue,
  ];
  for (final kind in defaultKinds) {
    topLevelByKind.putIfAbsent(kind, () {
      final fromCatalog = byKind[kind];
      if (fromCatalog != null) {
        return fromCatalog;
      }
      for (final type in fallbackMediaCatalog) {
        if (type.kind == kind) {
          return type;
        }
      }
      return CatalogMediaType(
        kind: kind,
        singularLabel: _settingsKindLabel(kind),
        pluralLabel: _settingsKindLabel(kind),
        routeSegments: [kind],
        isTopLevel: true,
      );
    });
  }
  final orderedKinds = preferences.orderedKinds([
    ...defaultKinds,
    ...topLevelByKind.keys,
  ]);
  final ordered = <CatalogMediaType>[];
  for (final kind in orderedKinds) {
    final type = topLevelByKind.remove(kind);
    if (type != null) {
      ordered.add(type);
    }
  }
  ordered.addAll(topLevelByKind.values.toList()
    ..sort((a, b) => a.pluralLabel.compareTo(b.pluralLabel)));
  return ordered.isEmpty
      ? fallbackMediaCatalog.where((type) => type.isTopLevel).toList()
      : ordered;
}

List<LibraryNavGroup> _orderedSettingsLibraryNavGroups(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  return buildLibraryNavGroups(
    _orderedSettingsMediaTypes(catalog, preferences),
  );
}

List<String> _expandSettingsGroupKinds(List<LibraryNavGroup> groups) {
  return [
    for (final group in groups)
      for (final type in group.types) type.kind,
  ];
}

List<String> _groupProviders(LibraryNavGroup group) {
  final providers = <String>{};
  for (final type in group.types) {
    providers.addAll(type.providers);
  }
  final ordered = providers.toList()..sort();
  return ordered;
}

String _settingsKindLabel(String kind) {
  final normalized = kind.trim();
  if (normalized.isEmpty) {
    return 'Library';
  }
  final parts = normalized
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'Library';
  }
  return parts
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Future<Color?> _showLibraryAccentPickerDialog(
  BuildContext context, {
  required Color initialColor,
  required Color defaultColor,
  required String title,
}) async {
  var color = initialColor;
  final hsv = HSVColor.fromColor(initialColor);
  var hue = hsv.hue;
  var saturation = hsv.saturation;
  var value = hsv.value;

  Color current() => HSVColor.fromAHSV(1, hue, saturation, value).toColor();

  return showDialog<Color>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          color = current();
          return AccentAlertDialog(
            title: Text('Accent: $title'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _colorSlider(
                    context,
                    label: 'Hue',
                    value: hue,
                    min: 0,
                    max: 360,
                    onChanged: (next) => setState(() => hue = next),
                  ),
                  _colorSlider(
                    context,
                    label: 'Saturation',
                    value: saturation,
                    min: 0,
                    max: 1,
                    onChanged: (next) => setState(() => saturation = next),
                  ),
                  _colorSlider(
                    context,
                    label: 'Value',
                    value: value,
                    min: 0,
                    max: 1,
                    onChanged: (next) => setState(() => value = next),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(defaultColor),
                child: const Text('Use default'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(color),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _colorSlider(
  BuildContext context, {
  required String label,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  return Row(
    children: [
      SizedBox(
        width: 84,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}
