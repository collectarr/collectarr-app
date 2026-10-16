import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

import 'library_add_pane_dependencies.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';

class LibraryAddSearchPane extends StatelessWidget {
  const LibraryAddSearchPane({
    super.key,
    required this.type,
    required this.isBusy,
    this.isLoadingMoreResults = false,
    this.hasMoreResults = false,
    this.loadMoreError,
    this.onLoadMoreResults,
    required this.error,
    required this.accent,
    this.selectionColor,
    required this.results,
    required this.selectedResultId,
    required this.checkedResultIds,
    required this.entryCatalogRefs,
    this.coreMatchSummary,
    required this.resultPolicy,
    required this.resultPolicyState,
    required this.onResultPolicyOptionChanged,
    required this.onSelectResult,
    required this.onToggleResultCheck,
    this.searched = false,
    this.headerTrailing,
  });

  final LibraryKindRegistration type;
  final bool isBusy;
  final bool isLoadingMoreResults;
  final bool hasMoreResults;
  final String? loadMoreError;
  final VoidCallback? onLoadMoreResults;
  final String? error;
  final Color accent;
  final Color? selectionColor;
  final List<CatalogSearchCandidate> results;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final Set<CatalogItemRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final LibraryAddResultPolicy resultPolicy;
  final LibraryAddResultPolicyState resultPolicyState;
  final void Function(String id, bool value) onResultPolicyOptionChanged;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  /// Whether a search has run, so the caption stays while a filter empties
  /// the results.
  final bool searched;

  /// Kind filter shown at the right of the results caption.
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final showCaption =
        results.isNotEmpty || (searched && !isBusy && error == null);
    return ColoredBox(
      color: results.isEmpty
          ? libraryAddSearchBackground(context)
          : libraryAddResultsBackground(context),
      child: Column(
        children: [
          if (showCaption)
            _LibraryAddResultsCaption(
              count: results.length,
              hasMore: hasMoreResults,
              trailing: headerTrailing,
            ),
          if (resultPolicy.options.isNotEmpty)
            _LibraryAddResultOptionsBar(
              options: resultPolicy.options,
              state: resultPolicyState,
              accent: accent,
              onChanged: onResultPolicyOptionChanged,
            ),
          Expanded(
            child: _SearchResultsList(
              type: type,
              accent: selectionColor ?? accent,
              useGridResults: resultPolicy.useGridResults,
              isBusy: isBusy,
              error: error,
              results: results,
              selectedResultId: selectedResultId,
              checkedResultIds: checkedResultIds,
              entryCatalogRefs: entryCatalogRefs,
              coreMatchSummary: coreMatchSummary,
              onSelectResult: onSelectResult,
              onToggleResultCheck: onToggleResultCheck,
            ),
          ),
          LibraryAddSearchResultsFooter(
            accent: accent,
            isLoading: isLoadingMoreResults,
            hasMore: hasMoreResults,
            error: loadMoreError,
            onLoadMore: onLoadMoreResults,
          ),
        ],
      ),
    );
  }
}

/// "66 Results" centred over the list, with the kind filter at the right.
class _LibraryAddResultsCaption extends StatelessWidget {
  const _LibraryAddResultsCaption({
    required this.count,
    required this.hasMore,
    this.trailing,
  });

  final int count;
  final bool hasMore;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      key: const ValueKey('library-add-results-caption'),
      constraints: const BoxConstraints(minHeight: 31),
      color: libraryAddResultsBackground(context),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$count${hasMore ? '+' : ''} ${count == 1 ? 'Result' : 'Results'}',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}

class _LibraryAddResultOptionsBar extends StatelessWidget {
  const _LibraryAddResultOptionsBar({
    required this.options,
    required this.state,
    required this.accent,
    required this.onChanged,
  });

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState state;
  final Color accent;
  final void Function(String id, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in options)
              _LibraryAddResultOptionChip(
                option: option,
                selected: state.valueFor(
                  option.id,
                  fallback: option.initialValue,
                ),
                accent: accent,
                onSelected: (value) => onChanged(option.id, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAddResultOptionChip extends StatelessWidget {
  const _LibraryAddResultOptionChip({
    required this.option,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final LibraryAddResultOption option;
  final bool selected;
  final Color accent;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedColor = Color.alphaBlend(
      accent.withValues(alpha: 0.2),
      palette.panel,
    );
    return FilterChip(
      label: Text(option.label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: selectedColor,
      checkmarkColor: appContrastingTextColor(selectedColor),
      labelStyle: TextStyle(
        color: selected
            ? appContrastingTextColor(selectedColor)
            : palette.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class LibraryAddSearchResultsFooter extends StatelessWidget {
  const LibraryAddSearchResultsFooter({
    super.key,
    required this.accent,
    required this.isLoading,
    required this.hasMore,
    this.error,
    this.onLoadMore,
  });

  final Color accent;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if ((!hasMore && error == null) || onLoadMore == null) {
      return const SizedBox.shrink();
    }
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            if (error != null) ...[
              Expanded(
                child: Text(
                  error!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ] else
              const Spacer(),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onLoadMore,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      error == null ? Icons.expand_more : Icons.refresh,
                      size: 16,
                    ),
              label: Text(
                isLoading
                    ? 'Loading…'
                    : error == null
                        ? 'Load more'
                        : 'Retry',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.7)),
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPaneNoticeStack extends StatelessWidget {
  const _SearchPaneNoticeStack({
    required this.error,
  });

  final String? error;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (error == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != null) AppErrorBanner(error!),
        Divider(height: 1, thickness: 1, color: palette.divider),
      ],
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.type,
    required this.accent,
    required this.useGridResults,
    required this.isBusy,
    required this.error,
    required this.results,
    required this.selectedResultId,
    required this.checkedResultIds,
    required this.entryCatalogRefs,
    this.coreMatchSummary,
    required this.onSelectResult,
    required this.onToggleResultCheck,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final bool useGridResults;
  final bool isBusy;
  final String? error;
  final List<CatalogSearchCandidate> results;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final Set<CatalogItemRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final notice = _SearchPaneNoticeStack(error: error);
    if (isBusy && results.isEmpty) {
      return const Center(child: Text('Searching...'));
    }
    if (results.isEmpty) {
      return ListView(padding: EdgeInsets.zero, children: [notice]);
    }
    if (useGridResults) {
      return _SearchResultsGrid(
        type: type,
        accent: accent,
        results: results,
        selectedResultId: selectedResultId,
        checkedResultIds: checkedResultIds,
        entryCatalogRefs: entryCatalogRefs,
        coreMatchSummary: coreMatchSummary,
        onSelectResult: onSelectResult,
        onToggleResultCheck: onToggleResultCheck,
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        for (var i = 0; i < results.length; i++) ...[
          SearchResultTile(
            type: type,
            item: results[i],
            accent: accent,
            selected: results[i].reference.id == selectedResultId,
            checked: checkedResultIds.contains(results[i].reference.id),
            isEntry: entryCatalogRefs.contains(results[i].reference),
            matchSummary: coreMatchSummary,
            onSelect: () => onSelectResult(results[i].reference.id),
            onToggleCheck: () => onToggleResultCheck(results[i].reference.id),
          ),
        ],
      ],
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  const _SearchResultsGrid({
    required this.type,
    required this.accent,
    required this.results,
    required this.selectedResultId,
    required this.checkedResultIds,
    required this.entryCatalogRefs,
    this.coreMatchSummary,
    required this.onSelectResult,
    required this.onToggleResultCheck,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final List<CatalogSearchCandidate> results;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final Set<CatalogItemRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final densityScale = density.metrics.searchScale;
    return GridView.builder(
      padding: EdgeInsets.all(12 * densityScale),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 174,
        mainAxisExtent: 292 * densityScale,
        mainAxisSpacing: 10 * densityScale,
        crossAxisSpacing: 10 * densityScale,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final isEntry = entryCatalogRefs.contains(item.reference);
        final selected = item.reference.id == selectedResultId;
        final checked = checkedResultIds.contains(item.reference.id);
        final coreDisplay = libraryPresentationForKind(type.kind)
            .builder
            .buildSearchResultDisplay(item: item);
        final title = coreDisplay?.title ?? item.summary.primaryLabel;
        final coverUrl = item.summary.imageUrl;
        final subtitle =
            coreDisplay?.secondaryLine ?? item.summary.subtitle ?? '';
        final matchSummary = coreMatchSummary?.call(item);
        final entryTone = Theme.of(context).colorScheme.tertiary;
        final entryFill = Color.alphaBlend(
          entryTone.withValues(alpha: 0.16),
          palette.tableEvenRow,
        );
        final entryBorder = entryTone.withValues(alpha: 0.6);
        final entryBadgeBackground = Color.alphaBlend(
          entryTone.withValues(alpha: palette.isDark ? 0.34 : 0.16),
          palette.surfaceDim,
        );
        final entryBadgeForeground =
            appContrastingTextColor(entryBadgeBackground);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: WidgetStateMouseCursor.clickable,
            onTap: () => onSelectResult(item.reference.id),
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.22), palette.selection)
                    : isEntry
                        ? entryFill
                        : palette.tableEvenRow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? accent
                      : isEntry
                          ? entryBorder
                          : palette.divider,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8 * densityScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LibraryCoverImage(
                                title: title,
                                imageUrl: coverUrl,
                              ),
                            ),
                          ),
                          if (isEntry)
                            Positioned(
                              left: 6,
                              top: 6,
                              child: LibraryAddResultBadge(
                                'In collection',
                                key: ValueKey(
                                    'library-add-entry-badge-${item.reference.id}'),
                                icon: Icons.playlist_add_check_rounded,
                                backgroundColor: entryBadgeBackground,
                                borderColor: entryBorder,
                                foregroundColor: entryBadgeForeground,
                              ),
                            ),
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: LibraryAddResultBadge(
                              'core',
                              accent: accent,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: SizedBox.square(
                              dimension: 24,
                              child: Checkbox(
                                value: checked,
                                onChanged: (_) =>
                                    onToggleResultCheck(item.reference.id),
                                activeColor: accent,
                                checkColor: Colors.white,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * densityScale),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 4 * densityScale),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (matchSummary != null) ...[
                      SizedBox(height: 4 * densityScale),
                      Text(
                        'Matched on: $matchSummary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: libraryAccentTextColor(accent, palette.panel),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (isEntry) ...[
                      SizedBox(height: 5 * densityScale),
                      LibraryAddResultBadge(
                        'Already in collection',
                        icon: Icons.playlist_add_check_rounded,
                        backgroundColor: entryBadgeBackground,
                        borderColor: entryBorder,
                        foregroundColor: entryBadgeForeground,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A Core result as the reference lists it: cover, bold title, artist line,
/// edition with the barcode at the right, and a checkbox for adding several.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.matchSummary,
    required this.selected,
    required this.checked,
    this.isEntry = false,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final LibraryKindRegistration type;
  final CatalogSearchCandidate item;
  final Color accent;
  final String? Function(CatalogSearchCandidate item)? matchSummary;
  final bool selected;
  final bool checked;
  final bool isEntry;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final summary = matchSummary?.call(item);
    final display =
        libraryPresentationForKind(type.kind).builder.buildSearchResultDisplay(
              item: item,
            );
    final secondary = display?.secondaryLine ?? '';
    final detail = display?.detailLine ?? '';
    final trailing = display?.trailingDetail ?? '';
    const text = TextStyle(fontSize: 14, height: 20 / 14);
    final row = Material(
      color: selected ? palette.utilityAction : Colors.transparent,
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        key: ValueKey('library-add-search-result-${item.reference.id}'),
        onTap: onSelect,
        child: Container(
          height: 71,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: libraryAddResultsDivider(context)),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: text.copyWith(color: palette.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 65,
                  height: 70,
                  child: LibraryCoverImage(
                    title: item.summary.primaryLabel,
                    imageUrl: item.summary.imageUrl,
                    fallbackAspectRatio: 65 / 70,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isEntry) ...[
                              Tooltip(
                                message: 'Already in collection',
                                child: Container(
                                  key: const ValueKey(
                                      'library-add-result-in-collection'),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: LibraryCollectionStatusScope
                                        .inCollection.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Flexible(
                              child: Text(
                                display?.title ?? item.summary.primaryLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 21.4 / 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (secondary.isNotEmpty) Text(secondary),
                        Row(
                          children: [
                            Expanded(child: Text(detail)),
                            if (trailing.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(trailing),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 13),
                  child: _ResultCheckbox(
                    checked: checked,
                    onPressed: onToggleCheck,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return summary == null
        ? row
        : Tooltip(message: 'Matched on: $summary', child: row);
  }
}

class _ResultCheckbox extends StatelessWidget {
  const _ResultCheckbox({required this.checked, required this.onPressed});

  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final blue = palette.utilityAction;
    return Semantics(
      checked: checked,
      button: true,
      label: 'Add to selection',
      child: GestureDetector(
        key: const ValueKey('library-add-result-checkbox'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: checked
                  ? blue
                  : palette.isDark
                      ? const Color(0xff444444)
                      : palette.field,
              border: Border.all(color: blue, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: checked
                ? const Icon(AppIcons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
