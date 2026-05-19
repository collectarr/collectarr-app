import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:flutter/material.dart';

/// Groups comic items by issue number with collapsible headers,
/// showing variant density within each issue.
class ComicsIssueGroupedGrid extends StatefulWidget {
  const ComicsIssueGroupedGrid({
    super.key,
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.useCards,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final bool useCards;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  State<ComicsIssueGroupedGrid> createState() =>
      _ComicsIssueGroupedGridState();
}

class _ComicsIssueGroupedGridState extends State<ComicsIssueGroupedGrid> {
  final _collapsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = _groupByIssue(widget.items);
    final sortedKeys = groups.keys.toList()..sort(_compareIssueKeys);

    return ColoredBox(
      color: kClzGridCanvas,
      child: CustomScrollView(
        slivers: [
          for (final key in sortedKeys) ...[
            SliverToBoxAdapter(
              child: _IssueHeader(
                label: key,
                items: groups[key]!,
                ownedByItemId: widget.ownedByItemId,
                collapsed: _collapsed.contains(key),
                onToggle: () => setState(() {
                  if (_collapsed.contains(key)) {
                    _collapsed.remove(key);
                  } else {
                    _collapsed.add(key);
                  }
                }),
              ),
            ),
            if (!_collapsed.contains(key))
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: widget.useCards
                    ? _buildCardGrid(groups[key]!)
                    : _buildCoverGrid(groups[key]!),
              ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }

  Widget _buildCoverGrid(List<CatalogItem> items) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildCoverTile(items[index]),
        childCount: items.length,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.coverSize,
        mainAxisExtent: widget.coverSize * 1.53,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

  Widget _buildCardGrid(List<CatalogItem> items) {
    final cardHeight =
        (widget.coverSize * 1.12).clamp(138.0, 174.0).toDouble();
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildCardTile(items[index]),
        childCount: items.length,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 430,
        mainAxisExtent: cardHeight,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

  Widget _buildCoverTile(CatalogItem item) {
    final ownedItem = widget.ownedByItemId[item.id];
    return LibraryCoverTile(
      entry: comicWorkspaceEntry(
        item,
        ownedItem,
        null,
        isWishlisted: widget.wishlistIds.contains(item.id),
      ),
      selected: widget.selectedItemIds.contains(item.id) ||
          item.id == widget.selectedItemId,
      onTap: () => widget.onSelectItem(item),
      selectedColor: kClzSelection,
      accentColor: kClzAccent,
      selectionColor: kClzYellow,
      mutedTextColor: kClzTextMuted,
    );
  }

  Widget _buildCardTile(CatalogItem item) {
    final ownedItem = widget.ownedByItemId[item.id];
    final entry = comicWorkspaceEntry(
      item,
      ownedItem,
      null,
      isWishlisted: widget.wishlistIds.contains(item.id),
    );
    return LibraryWorkspaceCard(
      entry: entry,
      selected: widget.selectedItemIds.contains(item.id) ||
          item.id == widget.selectedItemId,
      onTap: () => widget.onSelectItem(item),
      dateFormatter: formatComicDate,
      moneyFormatter: formatComicMoney,
      selectedColor: kClzSelection,
      accentColor: kClzAccent,
      mutedTextColor: kClzTextMuted,
    );
  }

  static Map<String, List<CatalogItem>> _groupByIssue(
      List<CatalogItem> items) {
    final groups = <String, List<CatalogItem>>{};
    for (final item in items) {
      final key = _issueKey(item);
      (groups[key] ??= []).add(item);
    }
    // Sort items within each group: standard covers first, then variants
    for (final list in groups.values) {
      list.sort((a, b) {
        final aIsVariant = _isVariant(a);
        final bIsVariant = _isVariant(b);
        if (aIsVariant != bIsVariant) return aIsVariant ? 1 : -1;
        return (a.variant ?? '').compareTo(b.variant ?? '');
      });
    }
    return groups;
  }

  static String _issueKey(CatalogItem item) {
    final num = item.itemNumber?.trim();
    if (num == null || num.isEmpty) return 'Unnumbered';
    return '#$num';
  }

  static bool _isVariant(CatalogItem item) {
    final v = item.variant?.toLowerCase() ?? '';
    if (v.isEmpty) return false;
    if (v.contains('cover a') ||
        v.contains('regular') ||
        v.contains('standard')) {
      return false;
    }
    return true;
  }

  static int _compareIssueKeys(String a, String b) {
    if (a == 'Unnumbered') return b == 'Unnumbered' ? 0 : 1;
    if (b == 'Unnumbered') return -1;
    final numA = _extractNumber(a);
    final numB = _extractNumber(b);
    if (numA != null && numB != null) return numA.compareTo(numB);
    return a.compareTo(b);
  }

  static double? _extractNumber(String key) {
    final match = RegExp(r'#?\s*(\d+(?:\.\d+)?)').firstMatch(key);
    return match == null ? null : double.tryParse(match.group(1)!);
  }
}

class _IssueHeader extends StatelessWidget {
  const _IssueHeader({
    required this.label,
    required this.items,
    required this.ownedByItemId,
    required this.collapsed,
    required this.onToggle,
  });

  final String label;
  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ownedCount =
        items.where((item) => ownedByItemId.containsKey(item.id)).length;
    final variantCount =
        items.where((item) => _ComicsIssueGroupedGridState._isVariant(item)).length;
    final standardCount = items.length - variantCount;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Row(
          children: [
            Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 18,
              color: kClzAccent,
            ),
            const SizedBox(width: 4),
            Icon(Icons.menu_book, size: 14, color: kClzAccent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kClzAccent,
              ),
            ),
            const SizedBox(width: 8),
            _IssueBadge(
              '$ownedCount/${items.length}',
              color: ownedCount == items.length
                  ? const Color(0xFF4CAF50)
                  : kClzTextMuted,
            ),
            if (variantCount > 0) ...[
              const SizedBox(width: 4),
              _IssueBadge(
                '$standardCount+${variantCount}v',
                color: kClzTextMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  const _IssueBadge(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color),
      ),
    );
  }
}
