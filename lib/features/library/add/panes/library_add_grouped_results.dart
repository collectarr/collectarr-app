import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';

import 'library_add_pane_dependencies.dart';

/// Results that share a [LibraryAddResultGrouping.groupKey], in search order.
class LibraryAddResultGroup {
  const LibraryAddResultGroup(this.key, this.variants);

  final String key;
  final List<CatalogSearchCandidate> variants;

  CatalogSearchCandidate get first => variants.first;
}

List<LibraryAddResultGroup> libraryAddResultGroups(
  List<CatalogSearchCandidate> results,
  LibraryAddResultGrouping grouping,
) {
  final groups = <String, List<CatalogSearchCandidate>>{};
  for (final item in results) {
    groups.putIfAbsent(grouping.groupKey(item), () => []).add(item);
  }
  return [
    for (final entry in groups.entries)
      LibraryAddResultGroup(entry.key, entry.value)
  ];
}

Color _headerColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff666666) : const Color(0xffd6d6d6);

Color _tileColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff383838) : const Color(0xffeeeeee);

/// The chosen group's title and detail line, beside the search field.
class LibraryAddGroupHeader extends StatelessWidget {
  const LibraryAddGroupHeader({
    super.key,
    required this.group,
    required this.grouping,
  });

  final LibraryAddResultGroup? group;
  final LibraryAddResultGrouping grouping;

  @override
  Widget build(BuildContext context) {
    final group = this.group;
    if (group == null) return const SizedBox.expand();
    final palette = appPalette(context);
    return Container(
      key: const ValueKey('library-add-group-header'),
      color: _headerColor(palette),
      padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: palette.textPrimary),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.first.summary.primaryLabel,
                style: const TextStyle(
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w700)),
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 13, height: 21 / 13),
              child: grouping.groupDetail(context, group.first),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group rows at the left, the chosen group's variants at the right.
class LibraryAddGroupedResults extends StatelessWidget {
  const LibraryAddGroupedResults({
    super.key,
    required this.grouping,
    required this.groups,
    required this.selectedGroupKey,
    required this.selectedResultId,
    required this.entryCatalogRefs,
    required this.onSelectGroup,
    required this.onSelectResult,
    required this.caption,
    required this.list,
    required this.footer,
    this.variantControls,
  });

  final LibraryAddResultGrouping grouping;
  final List<LibraryAddResultGroup> groups;
  final String? selectedGroupKey;
  final String? selectedResultId;
  final Set<CatalogItemRef> entryCatalogRefs;
  final ValueChanged<String> onSelectGroup;
  final ValueChanged<String> onSelectResult;

  /// Results count above the rows, the list itself when there are no rows
  /// (searching, errors) and the load-more footer below them.
  final Widget caption;
  final Widget? list;
  final Widget footer;

  /// Kind filters above the variants.
  final Widget? variantControls;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selected =
        groups.where((group) => group.key == selectedGroupKey).firstOrNull;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: LibraryAddResultGrouping.listWidth,
          child: Column(
            children: [
              caption,
              Expanded(
                child: list ??
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final group in groups)
                          _GroupRow(
                            group: group,
                            grouping: grouping,
                            selected: group.key == selectedGroupKey,
                            isEntry: group.variants.any((item) =>
                                entryCatalogRefs.contains(item.reference)),
                            onTap: () => onSelectGroup(group.key),
                          ),
                      ],
                    ),
              ),
              footer,
            ],
          ),
        ),
        ColoredBox(
          color: palette.canvas,
          child: const SizedBox(width: 6),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (variantControls != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(child: variantControls),
                ),
              Expanded(
                child: selected == null
                    ? const SizedBox.shrink()
                    // Fixed tiles flowing from the left, as in the reference.
                    : SingleChildScrollView(
                        key: const ValueKey('library-add-variant-grid'),
                        padding: const EdgeInsets.fromLTRB(4, 5, 0, 5),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final item in selected.variants)
                              _VariantTile(
                                item: item,
                                grouping: grouping,
                                selected: item.reference.id == selectedResultId,
                                onTap: () => onSelectResult(item.reference.id),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.grouping,
    required this.selected,
    required this.isEntry,
    required this.onTap,
  });

  final LibraryAddResultGroup group;
  final LibraryAddResultGrouping grouping;
  final bool selected;
  final bool isEntry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final item = group.first;
    return Material(
      color: selected ? palette.utilityAction : Colors.transparent,
      child: InkWell(
        key: ValueKey('library-add-result-group-${group.key}'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        child: Container(
          height: 71,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: libraryAddResultsDivider(context)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 70,
                child: LibraryCoverImage(
                  title: item.summary.primaryLabel,
                  imageUrl: item.summary.imageUrl,
                  fallbackAspectRatio: 52 / 70,
                  borderRadius: 0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.textPrimary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.summary.primaryLabel,
                            style: const TextStyle(
                                fontSize: 15,
                                height: 24 / 15,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        DefaultTextStyle.merge(
                          style: TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              color: selected
                                  ? palette.textPrimary
                                  : palette.textMuted),
                          child: grouping.groupDetail(context, item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8, right: 7),
                child: Tooltip(
                  message: isEntry
                      ? 'Already in collection'
                      : '${group.variants.length} available',
                  child: Container(
                    key: const ValueKey('library-add-group-count'),
                    height: 24,
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isEntry
                          ? LibraryCollectionStatusScope.inCollection.color
                          : _headerColor(palette),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${group.variants.length}',
                        style: TextStyle(
                            color: isEntry ? Colors.white : palette.textPrimary,
                            fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.item,
    required this.grouping,
    required this.selected,
    required this.onTap,
  });

  final CatalogSearchCandidate item;
  final LibraryAddResultGrouping grouping;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final badge = grouping.variantBadge(item);
    return SizedBox(
      width: 174,
      height: 268,
      child: Material(
        color: selected ? palette.utilityAction : _tileColor(palette),
        child: InkWell(
          key: ValueKey('library-add-variant-${item.reference.id}'),
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: palette.textPrimary, fontSize: 14, height: 20 / 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 232,
                    child: LibraryCoverImage(
                      title: item.summary.primaryLabel,
                      imageUrl: item.summary.imageUrl,
                      fallbackAspectRatio: 164 / 232,
                      borderRadius: 0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(grouping.variantLabel(item))),
                    if (badge.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(badge),
                    ],
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
