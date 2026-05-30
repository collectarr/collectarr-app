part of 'collection_page.dart';

// Shelf header, distribution, stats, entry row, volumes, cover, chip

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({
    required this.state,
    required this.filter,
    required this.overdueCount,
    required this.onFilterChanged,
  });

  final ShelfState state;
  final _ShelfFilter filter;
  final int overdueCount;
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
                icon: Icons.tag_outlined,
                label: 'Quantity',
                value: state.totalQuantity.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.star_border,
                label: 'Wishlist',
                value: state.wishlistCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.key_outlined,
                label: 'Key comics',
                value: state.keyComicCount.toString(),
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
              _ShelfStatCard(
                icon: Icons.cloud_off_outlined,
                label: 'Missing metadata',
                value: state.missingMetadataCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.trending_up_outlined,
                label: 'Market value',
                value: _totalMarketValueLabel(state),
              ),
              _ShelfStatCard(
                icon: Icons.sell_outlined,
                label: 'Sold',
                value: _totalSoldLabel(state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ShelfDistributionPanel(state: state),
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
          if (overdueCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$overdueCount overdue loan${overdueCount == 1 ? '' : 's'} in your shelf',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
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

  String _totalMarketValueLabel(ShelfState state) {
    if (state.marketValuedCount == 0) {
      return 'No values';
    }
    if (state.hasMixedCurrencies) {
      return '${state.marketValuedCount} valued';
    }
    final cents = state.totalMarketValueCents;
    if (cents == null || state.primaryCurrency == null) {
      return '${state.marketValuedCount} valued';
    }
    return _formatMoney(cents, state.primaryCurrency!);
  }

  String _totalSoldLabel(ShelfState state) {
    if (state.soldCount == 0) {
      return 'None';
    }
    if (state.hasMixedCurrencies) {
      return '${state.soldCount} sold';
    }
    final cents = state.totalSellCents;
    if (cents == null || state.primaryCurrency == null) {
      return '${state.soldCount} sold';
    }
    return '${state.soldCount} — ${_formatMoney(cents, state.primaryCurrency!)}';
  }
}

class _ShelfDistributionPanel extends StatelessWidget {
  const _ShelfDistributionPanel({required this.state});

  final ShelfState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DistributionGroup(title: 'Grades', values: state.gradeCounts),
            _DistributionGroup(
              title: 'Conditions',
              values: state.conditionCounts,
            ),
            _DistributionGroup(
              title: 'Read status',
              values: state.readStatusCounts,
            ),
            _DistributionGroup(
              title: 'Locations',
              values: state.storageBoxCounts,
            ),
            _DistributionGroup(
              title: 'Top series',
              values: state.seriesCounts,
              maxItems: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionGroup extends StatelessWidget {
  const _DistributionGroup({
    required this.title,
    required this.values,
    this.maxItems,
  });

  final String title;
  final Map<String, int> values;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final sorted = values.entries.toList(growable: false)
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) {
          return byCount;
        }
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });
    final visible = maxItems == null
        ? sorted
        : sorted.take(maxItems!).toList(growable: false);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (values.isEmpty)
                const Chip(label: Text('None'))
              else
                for (final entry in visible)
                  Chip(label: Text('${entry.key}: ${entry.value}')),
            ],
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

class _ShelfEntryRow extends ConsumerStatefulWidget {
  const _ShelfEntryRow({
    required this.entry,
    required this.onRemoveOwned,
    required this.onRemoveWishlist,
  });

  final ShelfEntry entry;
  final VoidCallback onRemoveOwned;
  final VoidCallback onRemoveWishlist;

  @override
  ConsumerState<_ShelfEntryRow> createState() => _ShelfEntryRowState();
}

class _ShelfEntryRowState extends ConsumerState<_ShelfEntryRow> {
  bool _volumesExpanded = false;

  bool get _isManga => widget.entry.catalogItem?.kind == 'manga';

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                      if (owned?.personalNotes?.trim().isNotEmpty ??
                          false) ...[
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
                            widget.onRemoveOwned();
                            break;
                          case _ShelfAction.removeWishlist:
                            widget.onRemoveWishlist();
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
            if (_isManga) ...[
              const SizedBox(height: 6),
              _ShelfVolumesToggle(
                expanded: _volumesExpanded,
                onToggle: () =>
                    setState(() => _volumesExpanded = !_volumesExpanded),
              ),
            ],
            if (_isManga && _volumesExpanded)
              _ShelfVolumesPanel(itemId: entry.itemId),
          ],
        ),
      ),
    );
  }
}

class _ShelfVolumesToggle extends StatelessWidget {
  const _ShelfVolumesToggle({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              expanded ? 'Hide volumes' : 'Show volumes',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfVolumesPanel extends ConsumerWidget {
  const _ShelfVolumesPanel({required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumesAsync = ref.watch(shelfVolumesProvider(itemId));
    return volumesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Could not load volumes',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      data: (volumes) {
        if (volumes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No volumes available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: volumes
                .map((v) => _ShelfVolumeTile(volume: v))
                .toList(),
          ),
        );
      },
    );
  }
}

class _ShelfVolumeTile extends StatefulWidget {
  const _ShelfVolumeTile({required this.volume});

  final Season volume;

  @override
  State<_ShelfVolumeTile> createState() => _ShelfVolumeTileState();
}

class _ShelfVolumeTileState extends State<_ShelfVolumeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final volume = widget.volume;
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: volume.posterUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: CachedNetworkImage(
                    imageUrl: volume.posterUrl!,
                    width: 32,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.menu_book, size: 20),
          title: Text(
            volume.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            [
              if (volume.episodeCount != null)
                '${volume.episodeCount} chapters',
              if (volume.airDate != null) volume.airDate!,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: volume.episodes.isNotEmpty
              ? Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                )
              : null,
          onTap: volume.episodes.isNotEmpty
              ? () => setState(() => _expanded = !_expanded)
              : null,
        ),
        if (_expanded && volume.episodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 8, bottom: 4),
            child: Column(
              children: volume.episodes
                  .map((ch) => _ShelfChapterRow(chapter: ch))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ShelfChapterRow extends StatelessWidget {
  const _ShelfChapterRow({required this.chapter});

  final Episode chapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              'Ch. ${chapter.episodeNumber}',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              chapter.title,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chapter.pageCount != null || chapter.runtimeMinutes != null)
            Text(
              '${chapter.pageCount ?? chapter.runtimeMinutes}p',
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
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
