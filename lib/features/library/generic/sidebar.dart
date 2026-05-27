import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:flutter/material.dart';

class LibrarySidebar extends StatelessWidget {
  const LibrarySidebar({
    super.key,
    required this.type,
    required this.accent,
    required this.buckets,
    required this.groupMode,
    this.groupLoading = false,
    required this.selectedBucket,
    required this.onSelected,
    required this.onGroupModeChanged,
    required this.onClearFilter,
    this.pinnedGroupModes = const {},
    this.onTogglePinGroupMode,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final LibraryGroupMode groupMode;
  final bool groupLoading;
  final String selectedBucket;
  final ValueChanged<String> onSelected;
  final ValueChanged<LibraryGroupMode> onGroupModeChanged;
  final VoidCallback? onClearFilter;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePinGroupMode;

  @override
  Widget build(BuildContext context) {
    return LibrarySeriesSidebar(
      title: genericGroupModeSidebarTitle(groupMode, type),
      icon: genericGroupModeIcon(groupMode),
      series: buckets,
      selectedSeries: selectedBucket,
      onSelectSeries: onSelected,
      accentColor: accent,
      selectionColor: accent.withValues(alpha: 0.36),
      backgroundColor: appPalette(context).panel,
      headerColor: appPalette(context).surface,
      dividerColor: appPalette(context).divider,
      selectedBadgeColor: appPalette(context).highlight,
      mutedTextColor: appPalette(context).textMuted,
      headerOverride: _SidebarGroupDropdownHeader(
        type: type,
        groupMode: groupMode,
        accent: accent,
        icon: genericGroupModeIcon(groupMode),
        onChanged: onGroupModeChanged,
        groupLoading: groupLoading,
        onClearFilter: onClearFilter,
        pinnedGroupModes: pinnedGroupModes,
        onTogglePin: onTogglePinGroupMode,
      ),
    );
  }
}

class LibraryCompactBucketBar extends StatelessWidget {
  const LibraryCompactBucketBar({
    super.key,
    required this.type,
    required this.accent,
    required this.buckets,
    required this.selectedBucket,
    required this.onSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final String selectedBucket;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).panel,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          itemCount: buckets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            final selected = bucket.title == selectedBucket;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => onSelected(bucket.title),
              avatar: selected
                  ? Icon(genericLibrarySidebarIcon(type), size: 15)
                  : null,
              label: Text(libraryBucketLabel(bucket)),
              selectedColor: accent.withValues(alpha: 0.42),
              side: BorderSide(color: selected ? accent : appPalette(context).divider),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }
}

IconData genericLibrarySidebarIcon(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    CatalogMediaKind.music => Icons.person_2_outlined,
    CatalogMediaKind.movie => Icons.movie_filter_outlined,
    _ => Icons.folder,
  };
}

class _SidebarGroupDropdownHeader extends StatelessWidget {
  const _SidebarGroupDropdownHeader({
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.icon,
    required this.onChanged,
    this.groupLoading = false,
    this.onClearFilter,
    this.pinnedGroupModes = const {},
    this.onTogglePin,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
  final bool groupLoading;
  final VoidCallback? onClearFilter;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final label = genericGroupModeSidebarTitle(groupMode, type);
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: appPalette(context).surface,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showGroupModeMenu(context),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: 18, color: accent),
                  ],
                ),
              ),
            ),
          ),
          if (groupLoading) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            tooltip: 'Clear group filter',
            onPressed: onClearFilter,
            icon: const Icon(Icons.filter_alt_off, size: 16),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  void _showGroupModeMenu(BuildContext context) {
    final modes = libraryGroupModesForType(type);
    final categories = _categorizeGroupModes(modes);
    final pinned = modes.where(pinnedGroupModes.contains).toList();
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset(0, box.size.height));
    showMenu<LibraryGroupMode>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + box.size.width,
        offset.dy,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      items: [
        if (pinned.isNotEmpty) ...[
          PopupMenuItem<LibraryGroupMode>(
            enabled: false,
            height: 28,
            child: Text(
              'Favorites',
              style: TextStyle(
                color: appPalette(context).highlight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (final mode in pinned)
            _buildGroupModeItem(mode, menuContext: context),
          const PopupMenuDivider(height: 8),
        ],
        for (final category in categories) ...[
          PopupMenuItem<LibraryGroupMode>(
            enabled: false,
            height: 28,
            child: Text(
              category.label,
              style: TextStyle(
                color: appPalette(context).textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (final mode in category.modes)
            _buildGroupModeItem(mode, menuContext: context),
        ],
      ],
    ).then((value) {
      if (value != null) onChanged(value);
    });
  }

  PopupMenuItem<LibraryGroupMode> _buildGroupModeItem(
    LibraryGroupMode mode, {
    BuildContext? menuContext,
  }) {
    final isPinned = pinnedGroupModes.contains(mode);
    return PopupMenuItem<LibraryGroupMode>(
      value: mode,
      height: 36,
      child: Row(
        children: [
          Icon(
            genericGroupModeIcon(mode),
            size: 16,
            color: mode == groupMode ? accent : kAppTextSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              genericGroupModeLabel(mode, type),
              style: TextStyle(
                fontWeight:
                    mode == groupMode ? FontWeight.w800 : FontWeight.w500,
                color: mode == groupMode ? accent : null,
              ),
            ),
          ),
          if (mode == groupMode)
            Icon(Icons.check, size: 16, color: accent),
          if (onTogglePin != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTogglePin!(mode),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 14,
                  color: isPinned
                      ? (menuContext != null
                          ? appPalette(menuContext).highlight
                          : kAppHighlight)
                      : (menuContext != null
                          ? appPalette(menuContext).textMuted
                          : kAppTextMuted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<_GroupModeCategory> _categorizeGroupModes(
    List<LibraryGroupMode> modes,
  ) {
    const mainModes = {
      LibraryGroupMode.series,
      LibraryGroupMode.storyArc,
      LibraryGroupMode.character,
      LibraryGroupMode.title,
      LibraryGroupMode.publisher,
      LibraryGroupMode.year,
      LibraryGroupMode.genre,
      LibraryGroupMode.country,
      LibraryGroupMode.language,
      LibraryGroupMode.ageRating,
    };
    const editionModes = {
      LibraryGroupMode.format,
    };
    const crewModes = {
      LibraryGroupMode.director,
      LibraryGroupMode.creator,
    };
    // Everything else is personal.
    final main = modes.where(mainModes.contains).toList();
    final edition = modes.where(editionModes.contains).toList();
    final crew = modes.where(crewModes.contains).toList();
    final personal = modes
        .where((m) =>
            !mainModes.contains(m) &&
            !editionModes.contains(m) &&
            !crewModes.contains(m))
        .toList();
    return [
      if (main.isNotEmpty) _GroupModeCategory('Main', main),
      if (edition.isNotEmpty) _GroupModeCategory('Edition', edition),
      if (crew.isNotEmpty) _GroupModeCategory('Cast & Crew', crew),
      if (personal.isNotEmpty) _GroupModeCategory('Personal', personal),
    ];
  }
}

class _GroupModeCategory {
  const _GroupModeCategory(this.label, this.modes);
  final String label;
  final List<LibraryGroupMode> modes;
}
