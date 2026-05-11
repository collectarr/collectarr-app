import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ShelfFilter { all, owned, wishlist, missingGrade, notes }

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  _ShelfFilter filter = _ShelfFilter.all;

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: shelf.when(
        data: (state) {
          final entries = _filteredEntries(state.entries);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ShelfHeader(
                  state: state,
                  filter: filter,
                  onFilterChanged: (value) => setState(() => filter = value),
                ),
              ),
              if (entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyShelf(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _ShelfEntryRow(
                        entry: entries[index],
                        onRemoveOwned: () => _removeOwned(entries[index]),
                        onRemoveWishlist: () => _removeWishlist(entries[index]),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<ShelfEntry> _filteredEntries(List<ShelfEntry> entries) {
    return switch (filter) {
      _ShelfFilter.all => entries,
      _ShelfFilter.owned =>
        entries.where((entry) => entry.isOwned).toList(growable: false),
      _ShelfFilter.wishlist =>
        entries.where((entry) => entry.isWishlisted).toList(growable: false),
      _ShelfFilter.missingGrade =>
        entries.where((entry) => entry.isMissingGrade).toList(growable: false),
      _ShelfFilter.notes =>
        entries.where((entry) => entry.hasNotes).toList(growable: false),
    };
  }

  Future<void> _removeOwned(ShelfEntry entry) async {
    final ownedItem = entry.ownedItem;
    if (ownedItem == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    ref.invalidate(shelfProvider);
  }

  Future<void> _removeWishlist(ShelfEntry entry) async {
    if (!entry.isWishlisted) {
      return;
    }
    await ref
        .read(collectionMutationsProvider)
        .removeFromWishlist(entry.itemId);
    ref.invalidate(shelfProvider);
  }
}

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({
    required this.state,
    required this.filter,
    required this.onFilterChanged,
  });

  final ShelfState state;
  final _ShelfFilter filter;
  final ValueChanged<_ShelfFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ShelfStatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Owned',
                value: state.ownedCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.star_border,
                label: 'Wishlist',
                value: state.wishlistCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.verified_outlined,
                label: 'Missing grade',
                value: state.missingGradeCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.payments_outlined,
                label: 'Paid',
                value: _totalPaidLabel(state),
              ),
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
                  value: _ShelfFilter.missingGrade,
                  icon: Icon(Icons.rule_outlined),
                  label: Text(
                    'Missing grade',
                    key: ValueKey('shelf-filter-missing-grade'),
                  ),
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

  String _totalPaidLabel(ShelfState state) {
    if (state.hasMixedCurrencies) {
      return '${state.pricedCount} priced';
    }
    final cents = state.totalPaidCents;
    if (cents == null || state.primaryCurrency == null) {
      return 'No prices';
    }
    return _formatMoney(cents, state.primaryCurrency!);
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
    return SizedBox(
      width: 170,
      child: Card(
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
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShelfEntryRow extends StatelessWidget {
  const _ShelfEntryRow({
    required this.entry,
    required this.onRemoveOwned,
    required this.onRemoveWishlist,
  });

  final ShelfEntry entry;
  final VoidCallback onRemoveOwned;
  final VoidCallback onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final owned = entry.ownedItem;
    final wishlist = entry.wishlistItem;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            _ShelfCover(entry: entry),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (entry.isOwned)
                        _ShelfChip(
                          icon: Icons.inventory_2,
                          label: owned?.condition ?? 'Owned',
                        ),
                      if (entry.isWishlisted)
                        const _ShelfChip(
                          icon: Icons.star,
                          label: 'Wishlist',
                        ),
                      _ShelfChip(
                        icon: Icons.verified_outlined,
                        label: owned?.grade ?? 'Ungraded',
                      ),
                      if (owned?.pricePaidCents != null &&
                          owned?.currency != null)
                        _ShelfChip(
                          icon: Icons.payments_outlined,
                          label: _formatMoney(
                            owned!.pricePaidCents!,
                            owned.currency!,
                          ),
                        ),
                      if (wishlist?.targetPriceCents != null &&
                          wishlist?.currency != null)
                        _ShelfChip(
                          icon: Icons.sell_outlined,
                          label: _formatMoney(
                            wishlist!.targetPriceCents!,
                            wishlist.currency!,
                          ),
                        ),
                    ],
                  ),
                  if (owned?.personalNotes?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      owned!.personalNotes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(entry.updatedAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                PopupMenuButton<_ShelfAction>(
                  tooltip: 'Shelf actions',
                  onSelected: (action) {
                    switch (action) {
                      case _ShelfAction.removeOwned:
                        onRemoveOwned();
                        break;
                      case _ShelfAction.removeWishlist:
                        onRemoveWishlist();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (entry.isOwned)
                      const PopupMenuItem(
                        value: _ShelfAction.removeOwned,
                        child: Text('Remove owned'),
                      ),
                    if (entry.isWishlisted)
                      const PopupMenuItem(
                        value: _ShelfAction.removeWishlist,
                        child: Text('Remove wishlist'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _ShelfAction { removeOwned, removeWishlist }

class _ShelfCover extends StatelessWidget {
  const _ShelfCover({required this.entry});

  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = entry.catalogItem?.title ?? 'Item';
    final initials = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return SizedBox(
      width: 48,
      height: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No shelf items match this view'));
  }
}

String _formatMoney(int cents, String currency) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (cents.abs() % 100).toString().padLeft(2, '0');
  return '$currency $sign$whole.$fraction';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
