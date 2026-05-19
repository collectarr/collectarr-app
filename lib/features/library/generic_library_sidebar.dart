import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:flutter/material.dart';

class GenericLibrarySidebar extends StatelessWidget {
  const GenericLibrarySidebar({
    super.key,
    required this.type,
    required this.accent,
    required this.buckets,
    required this.groupMode,
    required this.selectedBucket,
    required this.onSelected,
    required this.onGroupModeChanged,
    required this.onClearFilter,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final GenericLibraryGroupMode groupMode;
  final String selectedBucket;
  final ValueChanged<String> onSelected;
  final ValueChanged<GenericLibraryGroupMode> onGroupModeChanged;
  final VoidCallback? onClearFilter;

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
      backgroundColor: kClzPanel,
      headerColor: const Color(0xFF303030),
      dividerColor: kClzDivider,
      selectedBadgeColor: kClzYellow,
      mutedTextColor: kClzTextMuted,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GenericGroupingMenu(
            type: type,
            groupMode: groupMode,
            onChanged: onGroupModeChanged,
          ),
          IconButton(
            tooltip: 'Clear group filter',
            onPressed: onClearFilter,
            icon: const Icon(Icons.filter_alt_off, size: 18),
          ),
        ],
      ),
    );
  }
}

class GenericLibraryCompactBucketBar extends StatelessWidget {
  const GenericLibraryCompactBucketBar({
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
      decoration: const BoxDecoration(
        color: kClzPanel,
        border: Border(bottom: BorderSide(color: kClzDivider)),
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
              label: Text('${bucket.title} ${bucket.count}'),
              selectedColor: accent.withValues(alpha: 0.42),
              side: BorderSide(color: selected ? accent : kClzDivider),
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
    'music' => Icons.person_2_outlined,
    'movie' => Icons.movie_filter_outlined,
    _ => Icons.folder,
  };
}

class _GenericGroupingMenu extends StatelessWidget {
  const _GenericGroupingMenu({
    required this.type,
    required this.groupMode,
    required this.onChanged,
  });

  final LibraryTypeConfig type;
  final GenericLibraryGroupMode groupMode;
  final ValueChanged<GenericLibraryGroupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GenericLibraryGroupMode>(
      tooltip: 'Group by',
      icon: const Icon(Icons.tune, size: 18),
      initialValue: groupMode,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final mode in genericGroupModesForType(type))
          PopupMenuItem(
            value: mode,
            child: ListTile(
              dense: true,
              leading: Icon(genericGroupModeIcon(mode)),
              title: Text(genericGroupModeLabel(mode, type)),
              trailing:
                  mode == groupMode ? const Icon(Icons.check, size: 18) : null,
            ),
          ),
      ],
    );
  }
}
