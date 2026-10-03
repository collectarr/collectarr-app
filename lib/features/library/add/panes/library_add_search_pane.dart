import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

import 'library_add_pane_dependencies.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

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
  });

  final LibraryKindRegistration type;
  final bool isBusy;
  final bool isLoadingMoreResults;
  final bool hasMoreResults;
  final String? loadMoreError;
  final VoidCallback? onLoadMoreResults;
  final String? error;
  final Color accent;
  final List<CatalogSearchCandidate> results;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final Set<CatalogEntityRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final LibraryAddResultPolicy resultPolicy;
  final LibraryAddResultPolicyState resultPolicyState;
  final void Function(String id, bool value) onResultPolicyOptionChanged;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(right: BorderSide(color: palette.divider)),
      ),
      child: Column(
        children: [
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
              accent: accent,
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
  final Set<CatalogEntityRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final notice = _SearchPaneNoticeStack(error: error);
    if (isBusy && results.isEmpty) {
      return _SearchSkeletonList(notice: notice);
    }
    if (results.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          notice,
          SizedBox(
            height: 280,
            child: _NoSearchResults(
              type: type,
              accent: accent,
            ),
          ),
        ],
      );
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
          if (i < results.length - 1)
            Divider(height: 1, thickness: 1, color: palette.divider),
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
  final Set<CatalogEntityRef> entryCatalogRefs;
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
                            child: InkWell(
                              mouseCursor: WidgetStateMouseCursor.clickable,
                              onTap: () =>
                                  onToggleResultCheck(item.reference.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: palette.surfaceDim,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  checked
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: checked
                                      ? libraryAccentTextColor(
                                          accent,
                                          palette.surfaceDim,
                                        )
                                      : palette.textPrimary,
                                ),
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

class _SearchSkeletonList extends StatelessWidget {
  const _SearchSkeletonList({required this.notice});

  final Widget notice;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        const Padding(
          padding: EdgeInsets.all(8),
          child: _ResultSectionHeader(label: 'Searching'),
        ),
        for (var index = 0; index < 6; index++) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color:
                    index.isEven ? palette.tableEvenRow : palette.tableOddRow,
                border: Border.all(color: palette.tableBottomBorder),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    _SkeletonBox(width: 42, height: 56),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: 220, height: 13),
                          SizedBox(height: 8),
                          _SkeletonBox(width: 320, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.surfaceBright,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Text(
        label,
        style: theme.textTheme.tableHeader.copyWith(
          color: palette.textMuted,
        ),
      ),
    );
  }
}

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
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final densityScale = density.metrics.searchScale;
    final summary = matchSummary?.call(item);
    final resultDisplay =
        libraryPresentationForKind(type.kind).builder.buildSearchResultDisplay(
              item: item,
            );
    final subtitle = resultDisplay?.secondaryLine ?? '';
    final detailLine = resultDisplay?.detailLine;
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
    final entryBadgeForeground = appContrastingTextColor(entryBadgeBackground);
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      key: ValueKey('library-add-search-result-${item.reference.id}'),
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.46), palette.selection)
              : isEntry
                  ? entryFill
                  : palette.tableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected
                  ? accent
                  : isEntry
                      ? entryBorder
                      : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8 * densityScale,
            vertical: 5 * densityScale,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: checked,
                  onChanged: (_) => onToggleCheck(),
                  activeColor: accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(
                width: 38,
                height: 56,
                child: LibraryCoverImage(
                  title: item.summary.primaryLabel,
                  itemNumber: null,
                  imageUrl: item.summary.imageUrl,
                ),
              ),
              SizedBox(width: 10 * densityScale),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 170;
                    final showDetailLine =
                        detailLine != null && detailLine.trim().isNotEmpty;
                    final showMatchSummary =
                        summary != null && (!compact || !showDetailLine);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEntry) ...[
                          LibraryAddResultBadge(
                            'Already in collection',
                            icon: Icons.playlist_add_check_rounded,
                            backgroundColor: entryBadgeBackground,
                            borderColor: entryBorder,
                            foregroundColor: entryBadgeForeground,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          resultDisplay?.title ?? item.summary.primaryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: 3 * densityScale),
                          Text(
                            subtitle,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (showDetailLine) ...[
                          SizedBox(height: 2 * densityScale),
                          Text(
                            detailLine,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (showMatchSummary) ...[
                          SizedBox(height: 3 * densityScale),
                          Text(
                            'Matched on: $summary',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  libraryAccentTextColor(accent, palette.panel),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        SizedBox(height: 5 * densityScale),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const LibraryAddResultBadge('core'),
                              const SizedBox(width: 4),
                              LibraryAddResultBadge(item.summary.kind.apiValue),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.type,
    required this.accent,
  });

  final LibraryKindRegistration type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.identity.icon,
              size: 28,
              color: libraryAccentTextColor(accent, palette.panel),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                'Search the catalog or add and propose a Catalog Item manually.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
