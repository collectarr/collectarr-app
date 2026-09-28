part of 'collection_page.dart';

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({
    required this.rows,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<CatalogItemV1WorkspaceItem> rows;
  final _ShelfFilter filter;
  final ValueChanged<_ShelfFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final activeCopies = rows
        .expand((row) => row.copies)
        .where((copy) => copy.status != OwnedCopyStatusV1.sold)
        .toList(growable: false);
    final wishlistCount = rows.where((row) => row.wishlist != null).length;
    final overdueCount = activeCopies.where((copy) {
      final due = copy.loanDueDate;
      if (copy.status != OwnedCopyStatusV1.loaned || due?.day == null) {
        return false;
      }
      final today = DateTime.now();
      return DateTime(due!.year!, due.month!, due.day!)
          .isBefore(DateTime(today.year, today.month, today.day));
    }).length;
    final notesCount = rows.where((row) {
      return row.wishlist?.notes?.trim().isNotEmpty == true ||
          row.copies.any((copy) => copy.notes?.trim().isNotEmpty == true);
    }).length;
    final compact = AppWindowClass.of(context).isCompact;
    final stats = [
      _ShelfStatCard(
        icon: Icons.inventory_2_outlined,
        label: 'Owned copies',
        value: activeCopies.length.toString(),
      ),
      _ShelfStatCard(
        icon: Icons.star_border,
        label: 'Wishlist',
        value: wishlistCount.toString(),
      ),
      _ShelfStatCard(
        icon: Icons.warning_amber_rounded,
        label: 'Overdue loans',
        value: overdueCount.toString(),
      ),
      _ShelfStatCard(
        icon: Icons.notes_outlined,
        label: 'With notes',
        value: notesCount.toString(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final stat in stats)
                SizedBox(width: compact ? 160 : 172, child: stat),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_ShelfFilter>(
              segments: const [
                ButtonSegment(
                  value: _ShelfFilter.all,
                  icon: Icon(Icons.all_inbox_outlined),
                  label: Text('All', key: ValueKey('shelf-filter-all')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.owned,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Owned', key: ValueKey('shelf-filter-owned')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.wishlist,
                  icon: Icon(Icons.star_border),
                  label:
                      Text('Wishlist', key: ValueKey('shelf-filter-wishlist')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.overdue,
                  icon: Icon(Icons.warning_amber_rounded),
                  label: Text('Overdue', key: ValueKey('shelf-filter-overdue')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.notes,
                  icon: Icon(Icons.notes_outlined),
                  label: Text('Notes', key: ValueKey('shelf-filter-notes')),
                ),
              ],
              selected: {filter},
              onSelectionChanged: (value) => onFilterChanged(value.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfStatCard extends StatelessWidget {
  const _ShelfStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemV1ShelfRow extends StatelessWidget {
  const _CatalogItemV1ShelfRow({
    required this.item,
    required this.onOpen,
    required this.onToggleWishlist,
    required this.onRemoveOwned,
  });

  final CatalogItemV1WorkspaceItem item;
  final VoidCallback onOpen;
  final VoidCallback onToggleWishlist;
  final VoidCallback onRemoveOwned;

  @override
  Widget build(BuildContext context) {
    final kind = item.reference.kind;
    final identity = catalogItemV1KindIdentities[kind];
    final activeCopies = item.copies
        .where((copy) => copy.status != OwnedCopyStatusV1.sold)
        .toList(growable: false);
    final soldCopies = item.copies.length - activeCopies.length;
    final overdue = activeCopies.where((copy) {
      final due = copy.loanDueDate;
      if (copy.status != OwnedCopyStatusV1.loaned || due?.day == null) {
        return false;
      }
      final today = DateTime.now();
      return DateTime(due!.year!, due.month!, due.day!)
          .isBefore(DateTime(today.year, today.month, today.day));
    }).length;

    return Card(
      child: ListTile(
        leading: Icon(identity?.icon ?? Icons.inventory_2_outlined),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(identity?.singularLabel ?? kind.apiValue),
            if (activeCopies.isNotEmpty)
              _ShelfChip(
                icon: Icons.inventory_2_outlined,
                label: '${activeCopies.length} owned',
              ),
            if (soldCopies > 0)
              _ShelfChip(icon: Icons.sell_outlined, label: '$soldCopies sold'),
            if (item.wishlist != null)
              const _ShelfChip(icon: Icons.star, label: 'Wishlist'),
            if (overdue > 0)
              _ShelfChip(
                icon: Icons.warning_amber_rounded,
                label: '$overdue overdue',
              ),
            if (item.catalogError != null)
              const _ShelfChip(
                icon: Icons.cloud_off_outlined,
                label: 'Catalog details unavailable',
              ),
          ],
        ),
        trailing: PopupMenuButton<_ShelfAction>(
          tooltip: 'Shelf actions',
          onSelected: (action) {
            switch (action) {
              case _ShelfAction.toggleWishlist:
                onToggleWishlist();
              case _ShelfAction.removeOwned:
                onRemoveOwned();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ShelfAction.toggleWishlist,
              child: Text(item.wishlist == null
                  ? 'Add to wishlist'
                  : 'Remove from wishlist'),
            ),
            if (activeCopies.isNotEmpty)
              const PopupMenuItem(
                value: _ShelfAction.removeOwned,
                child: Text('Remove owned copies'),
              ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

enum _ShelfAction { toggleWishlist, removeOwned }

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No Catalog Items match this Shelf view'));
}
