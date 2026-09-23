import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

final class AdminCatalogItemList extends StatelessWidget {
  const AdminCatalogItemList({
    required this.items,
    required this.hasSearched,
    required this.inspectingItemId,
    required this.updatingItemId,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
    super.key,
  });

  final List<AdminMetadataItem> items;
  final bool hasSearched;
  final String? inspectingItemId;
  final String? updatingItemId;
  final ValueChanged<AdminMetadataItem> onInspect;
  final ValueChanged<AdminMetadataItem> onEdit;
  final ValueChanged<AdminMetadataItem> onInspectCovers;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(hasSearched
          ? 'No catalog items matched the current search.'
          : 'Search by title or choose a category to load catalog results.');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final isInspecting = inspectingItemId == item.id;
        final isUpdating = updatingItemId == item.id;
        final colors = Theme.of(context).colorScheme;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cover = SizedBox(
                  width: 58,
                  height: 82,
                  child: LibraryCoverImage(
                    title: item.title,
                    itemNumber: item.itemNumber,
                    imageUrl: item.displayCoverUrl,
                  ),
                );
                final detail = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Chip(label: item.kind),
                        if (item.displayCoverUrl == null)
                          const _Chip(label: 'missing cover'),
                      ],
                    ),
                  ],
                );
                final actions = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isInspecting || isUpdating
                          ? null
                          : () => onInspect(item),
                      icon: isInspecting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.visibility_outlined),
                      label: const Text('Inspect'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          isUpdating ? null : () => onInspectCovers(item),
                      icon: const Icon(Icons.image_search_outlined),
                      label: const Text('Covers'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: isUpdating ? null : () => onEdit(item),
                      icon: isUpdating
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ],
                );
                if (constraints.maxWidth < 680) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 12),
                          Expanded(child: detail),
                        ],
                      ),
                      const SizedBox(height: 12),
                      actions,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(width: 12),
                    Expanded(child: detail),
                    const SizedBox(width: 12),
                    actions,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

final class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
