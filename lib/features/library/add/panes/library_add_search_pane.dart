import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/app_spinner.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

import 'library_add_cover_blocks.dart';
import 'library_add_grouped_results.dart';
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
    this.selectedGroupKey,
    this.onSelectGroup,
    this.onAddManually,
    this.coverBlocks,
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

  /// Opens Add Manually from the "Not found?" row under the results.
  final VoidCallback? onAddManually;

  /// Shows the results as cover blocks under one toolbar row, as the
  /// reference shows a series' issues.
  final LibraryAddCoverBlockView? coverBlocks;

  /// Whether a search has run, so the caption stays while a filter empties
  /// the results.
  final bool searched;

  /// Kind filter shown at the right of the results caption, or above the
  /// variants when the kind groups its results.
  final Widget? headerTrailing;

  /// The group whose variants are shown, for kinds that group results.
  final String? selectedGroupKey;
  final ValueChanged<String>? onSelectGroup;

  @override
  Widget build(BuildContext context) {
    final showCaption =
        results.isNotEmpty || (searched && !isBusy && error == null);
    final notFound = onAddManually != null && results.isNotEmpty
        ? LibraryAddNotFoundRow(
            message:
                'Add ${type.identity.singularLabel.toLowerCase()} manually.',
            onTap: onAddManually!)
        : null;
    if (coverBlocks case final view?) {
      final ordered = view.descending ? results.reversed.toList() : results;
      return ColoredBox(
        color: libraryAddResultsBackground(context),
        child: Column(
          children: [
            _LibraryAddBlockToolbar(
              leading: headerTrailing,
              options: resultPolicy.options,
              optionState: resultPolicyState,
              onOptionChanged: onResultPolicyOptionChanged,
              view: view,
            ),
            Expanded(
              // Grid blocks sit on the dialog's grey, as in the reference.
              child: ColoredBox(
                color: view.layout == LibraryAddBlockLayout.grid
                    ? libraryAddSearchBackground(context)
                    : libraryAddResultsBackground(context),
                child: isBusy && results.isEmpty
                    ? const LibraryAddSearchingPlaceholder()
                    : results.isEmpty
                        ? _SearchPaneNoticeStack(error: error)
                        : LibraryAddCoverBlocks(
                            layout: view.layout,
                            results: ordered,
                            block: view.block,
                            selectedResultId: selectedResultId,
                            checkedResultIds: checkedResultIds,
                            onSelectResult: onSelectResult,
                            onToggleResultCheck: onToggleResultCheck,
                            onAddManually: view.onAddManually,
                          ),
              ),
            ),
          ],
        ),
      );
    }
    final grouping = resultPolicy.grouping;
    if (grouping != null) {
      final groups = libraryAddResultGroups(results, grouping);
      return ColoredBox(
        color: libraryAddResultsBackground(context),
        child: LibraryAddGroupedResults(
          grouping: grouping,
          groups: groups,
          selectedGroupKey: selectedGroupKey,
          selectedResultId: selectedResultId,
          entryCatalogRefs: entryCatalogRefs,
          onSelectGroup: (key) => onSelectGroup?.call(key),
          onSelectResult: onSelectResult,
          caption: showCaption
              ? _LibraryAddResultsCaption(
                  count: groups.length, hasMore: hasMoreResults)
              : const SizedBox.shrink(),
          list: results.isEmpty
              ? _SearchResultsList(
                  type: type,
                  accent: selectionColor ?? accent,
                  useGridResults: false,
                  isBusy: isBusy,
                  error: error,
                  results: results,
                  selectedResultId: selectedResultId,
                  checkedResultIds: checkedResultIds,
                  entryCatalogRefs: entryCatalogRefs,
                  onSelectResult: onSelectResult,
                  onToggleResultCheck: onToggleResultCheck,
                )
              : null,
          footer: Column(mainAxisSize: MainAxisSize.min, children: [
            if (notFound != null) notFound,
            LibraryAddSearchResultsFooter(
              accent: accent,
              isLoading: isLoadingMoreResults,
              hasMore: hasMoreResults,
              error: loadMoreError,
              onLoadMore: onLoadMoreResults,
            ),
          ]),
          variantControls: headerTrailing,
        ),
      );
    }
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
          if (resultPolicy.options.isNotEmpty && results.isNotEmpty)
            _LibraryAddResultOptionsBar(
              options: resultPolicy.options,
              state: resultPolicyState,
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
          if (notFound != null) notFound,
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

/// The reference's "Not found?" row after the results, opening Add Manually.
class LibraryAddNotFoundRow extends StatelessWidget {
  const LibraryAddNotFoundRow(
      {super.key, required this.message, required this.onTap});

  /// The line under "Not found?", as "Add comic manually.".
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: libraryAddResultsBackground(context),
      child: InkWell(
        key: const ValueKey('library-add-not-found'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        hoverColor: palette.isDark ? const Color(0xff2d2d2d) : null,
        onTap: onTap,
        child: Container(
          height: 62,
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: libraryAddResultsDivider(context))),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: palette.textPrimary),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 35, child: Icon(AppIcons.edit, size: 20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Not found?',
                          style: TextStyle(
                              fontSize: 15,
                              height: 20 / 15,
                              fontWeight: FontWeight.w700)),
                      Text(message,
                          style:
                              const TextStyle(fontSize: 14, height: 20 / 14)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Icon(AppIcons.chevronRight, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Count and kind controls share a line when they fit, otherwise wrap.
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
    final caption = Text(
        '$count${hasMore ? '+' : ''} ${count == 1 ? 'Result' : 'Results'}',
        style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700));
    return Container(
        key: const ValueKey('library-add-results-caption'),
        constraints: const BoxConstraints(minHeight: 31),
        color: libraryAddResultsBackground(context),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: trailing == null
            ? Center(child: caption)
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [caption, trailing!]));
  }
}

/// The reference's icon toggles over the results, right-aligned.
class _LibraryAddResultOptionsBar extends StatelessWidget {
  const _LibraryAddResultOptionsBar({
    required this.options,
    required this.state,
    required this.onChanged,
  });

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState state;
  final void Function(String id, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 34,
      color: palette.isDark ? const Color(0xff383838) : palette.panelRaised,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _LibraryAddResultOptionToggle(
                option: option,
                selected: state.valueFor(
                  option.id,
                  fallback: option.initialValue,
                ),
                onSelected: (value) => onChanged(option.id, value),
              ),
            ),
        ],
      ),
    );
  }
}

class _LibraryAddResultOptionToggle extends StatelessWidget {
  const _LibraryAddResultOptionToggle({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final LibraryAddResultOption option;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => _LibraryAddIconToggle(
        key: ValueKey('library-add-result-option-${option.id}'),
        label: option.label,
        selected: selected,
        onPressed: () => onSelected(!selected),
        child: _SlashedIcon(
            icon: option.icon, color: appPalette(context).textPrimary),
      );
}

/// A 32 px icon button over the results, #737373 while on.
class _LibraryAddIconToggle extends StatelessWidget {
  const _LibraryAddIconToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        label: label,
        button: true,
        toggled: selected,
        excludeSemantics: true,
        child: AppClickTarget(
          onClick: onPressed,
          builder: (context, hovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? (palette.isDark ? const Color(0xff737373) : palette.divider)
                  : hovered
                      ? libraryToolbarControlHover(context)
                      : null,
              borderRadius: BorderRadius.circular(5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// "All (n)" at the left; the hide toggles, Sort Issues and the grid and
/// list views at the right, in one row as in the reference.
class _LibraryAddBlockToolbar extends StatelessWidget {
  const _LibraryAddBlockToolbar({
    required this.leading,
    required this.options,
    required this.optionState,
    required this.onOptionChanged,
    required this.view,
  });

  final Widget? leading;
  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState optionState;
  final void Function(String id, bool value) onOptionChanged;
  final LibraryAddCoverBlockView view;

  @override
  Widget build(BuildContext context) {
    final color = appPalette(context).textPrimary;
    Widget layoutToggle(
            LibraryAddBlockLayout layout, String label, IconData icon) =>
        _LibraryAddIconToggle(
          key: ValueKey('library-add-layout-${layout.name}'),
          label: label,
          selected: view.layout == layout,
          onPressed: () => view.onLayoutChanged(layout),
          child: Icon(icon, size: 19, color: color),
        );
    return Container(
      key: const ValueKey('library-add-block-toolbar'),
      height: 38,
      padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
      child: Row(
        children: [
          if (leading case final leading?) leading,
          const Spacer(),
          for (final option in options) ...[
            _LibraryAddResultOptionToggle(
              option: option,
              selected: optionState.valueFor(option.id,
                  fallback: option.initialValue),
              onSelected: (value) => onOptionChanged(option.id, value),
            ),
            const SizedBox(width: 8),
          ],
          _LibraryAddIconToggle(
            key: const ValueKey('library-add-sort-issues'),
            label: 'Sort Issues',
            selected: view.descending,
            onPressed: () => view.onDescendingChanged(!view.descending),
            child: Icon(
                view.descending ? AppIcons.sortAlphaUp : AppIcons.sortAlpha,
                size: 18,
                color: color),
          ),
          const SizedBox(width: 20),
          layoutToggle(
              LibraryAddBlockLayout.grid, 'Grid View', AppIcons.viewGrid),
          const SizedBox(width: 8),
          layoutToggle(LibraryAddBlockLayout.list, 'List View',
              AppIcons.viewHorizontalCards),
        ],
      ),
    );
  }
}

/// An icon struck through, as the reference's "hide" toggles.
class _SlashedIcon extends StatelessWidget {
  const _SlashedIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        foregroundPainter: _SlashPainter(color),
        child: Icon(icon, size: 20, color: color),
      );
}

class _SlashPainter extends CustomPainter {
  const _SlashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final from = Offset(size.width * .1, size.height * .95);
    final to = Offset(size.width * .9, size.height * .05);
    // A gap in the background colour keeps the strike legible on the glyph.
    canvas.drawLine(from + const Offset(1.5, 1.5), to + const Offset(1.5, 1.5),
        line..color = const Color(0x99000000));
    canvas.drawLine(from, to, line..color = color);
  }

  @override
  bool shouldRepaint(_SlashPainter oldDelegate) => oldDelegate.color != color;
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
      return const LibraryAddSearchingPlaceholder();
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
                  child: LibraryAddResultCheckbox(
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

class LibraryAddResultCheckbox extends StatelessWidget {
  const LibraryAddResultCheckbox({
    super.key,
    required this.checked,
    required this.onPressed,
    this.partial = false,
    this.size = 30,
  });

  final bool checked;
  final VoidCallback onPressed;

  /// Some, not all, of a set are checked: drawn as a dash.
  final bool partial;
  final double size;

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: checked || partial
                  ? blue
                  : palette.isDark
                      ? const Color(0xff444444)
                      : palette.field,
              border: Border.all(color: blue, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: checked || partial
                ? Icon(checked ? AppIcons.check : AppIcons.minus,
                    size: size * 16 / 30, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Spinner over "Searching..." in the reference's dark placeholder grey,
/// shown while a search has no results yet.
class LibraryAddSearchingPlaceholder extends StatelessWidget {
  const LibraryAddSearchingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff2e3035);
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 80,
                child: Center(child: AppSpinner(size: 56, color: color))),
            Text('Searching...',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 40 / 28,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
