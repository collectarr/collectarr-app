import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
              side: BorderSide(
                color: selected ? accent : appPalette(context).divider,
              ),
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
