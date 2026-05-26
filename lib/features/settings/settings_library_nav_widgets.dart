part of 'settings_page.dart';

// ---------------------------------------------------------------------------
// Library navigation settings widgets
// ---------------------------------------------------------------------------

class _LibraryNavSettings extends StatelessWidget {
  const _LibraryNavSettings({
    required this.catalog,
    required this.preferences,
    required this.onPlacementChanged,
    required this.onOrderChanged,
    required this.onVisibilityChanged,
    required this.onReset,
  });

  final List<CatalogMediaType> catalog;
  final LibraryNavPreferences preferences;
  final ValueChanged<LibraryNavPlacement> onPlacementChanged;
  final ValueChanged<List<String>> onOrderChanged;
  final void Function(String kind, bool visible) onVisibilityChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final types = _orderedSettingsMediaTypes(catalog, preferences);
    final visibleTypes = [
      for (final type in types)
        if (preferences.isVisible(type.kind)) type,
    ];
    final hiddenCount = types.length - visibleTypes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LibraryNavSummary(
          visibleCount: visibleTypes.length,
          hiddenCount: hiddenCount,
          placement: preferences.placement,
        ),
        const SizedBox(height: 12),
        Text(
          'Position',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            SegmentedButton<LibraryNavPlacement>(
              segments: const [
                ButtonSegment(
                  value: LibraryNavPlacement.top,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('Top bar'),
                ),
                ButtonSegment(
                  value: LibraryNavPlacement.left,
                  icon: Icon(Icons.vertical_split_outlined),
                  label: Text('Left rail'),
                ),
              ],
              selected: {preferences.placement},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  onPlacementChanged(selection.first),
            ),
            Text(
              preferences.placement == LibraryNavPlacement.top
                  ? 'Extra libraries collapse into More when the window is narrow.'
                  : 'The vertical rail keeps libraries visible on dense desktop layouts.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LibraryNavPreview(
          types: visibleTypes.isEmpty ? types.take(1).toList() : visibleTypes,
          placement: preferences.placement,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Libraries',
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
          'Drag rows or use the arrow buttons to reorder. Hidden libraries are removed from the top bar/rail, but can be restored here.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: types.length,
          onReorderItem: (oldIndex, newIndex) {
            final reordered = types.map((type) => type.kind).toList();
            final moved = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, moved);
            onOrderChanged(reordered);
          },
          itemBuilder: (context, index) {
            final type = types[index];
            final visible = preferences.isVisible(type.kind);
            final reordered = types.map((type) => type.kind).toList();
            return ListTile(
              key: ValueKey('library-nav-${type.kind}'),
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
                    _LibraryNavTypeIcon(type: type),
                  ],
                ),
              ),
              title: Text(type.pluralLabel),
              subtitle: Text(
                [
                  visible ? 'Visible' : 'Hidden',
                  type.providers.isEmpty
                      ? 'No provider'
                      : 'Providers: ${type.providers.join(', ')}',
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
                            onOrderChanged(reordered);
                          },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: 'Move down',
                    onPressed: index == types.length - 1
                        ? null
                        : () {
                            final moved = reordered.removeAt(index);
                            reordered.insert(index + 1, moved);
                            onOrderChanged(reordered);
                          },
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  Switch(
                    value: visible,
                    onChanged: (value) => onVisibilityChanged(
                      type.kind,
                      value,
                    ),
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
    required this.placement,
  });

  final int visibleCount;
  final int hiddenCount;
  final LibraryNavPlacement placement;

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
        _SettingsMiniStat(
          icon: placement == LibraryNavPlacement.top
              ? Icons.view_week_outlined
              : Icons.vertical_split_outlined,
          label: placement == LibraryNavPlacement.top ? 'Top bar' : 'Left rail',
        ),
        const _SettingsMiniStat(
          icon: Icons.more_horiz,
          label: 'Overflow uses More',
        ),
      ],
    );
  }
}

class _LibraryNavPreview extends StatelessWidget {
  const _LibraryNavPreview({
    required this.types,
    required this.placement,
  });

  final List<CatalogMediaType> types;
  final LibraryNavPlacement placement;

  @override
  Widget build(BuildContext context) {
    final visible = types.take(5).toList();
    final overflow = types.length - visible.length;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: placement == LibraryNavPlacement.left
            ? Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final type in visible.take(4))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _LibraryNavPreviewTile(type: type),
                          ),
                        if (overflow > 0)
                          _LibraryNavPreviewBadge(label: '+$overflow'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Left rail keeps library switching pinned beside the workspace.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final type in visible)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _LibraryNavPreviewButton(type: type),
                            ),
                          if (overflow > 0)
                            _LibraryNavPreviewBadge(label: 'More +$overflow'),
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
  const _LibraryNavTypeIcon({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: libraryAccentForKind(type.kind).withValues(alpha: 0.18),
        border: Border.all(color: libraryAccentForKind(type.kind)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: 30,
        child: Icon(
          libraryIconForKind(type.kind),
          size: 17,
          color: libraryAccentForKind(type.kind),
        ),
      ),
    );
  }
}

class _LibraryNavPreviewButton extends StatelessWidget {
  const _LibraryNavPreviewButton({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.22),
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(libraryIconForKind(type.kind), size: 15, color: accent),
            const SizedBox(width: 5),
            Text(
              type.pluralLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryNavPreviewTile extends StatelessWidget {
  const _LibraryNavPreviewTile({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.20),
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: 36,
        child: Icon(libraryIconForKind(type.kind), size: 18, color: accent),
      ),
    );
  }
}

class _LibraryNavPreviewBadge extends StatelessWidget {
  const _LibraryNavPreviewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
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
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel) type.kind: type,
  };
  final defaultKinds = [
    for (final config in collectarrLibraryTypes.types)
      config.workspace.kind.apiValue,
  ];
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
