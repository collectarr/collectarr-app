import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

import 'library_add_pane_dependencies.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'library_add_search_unified.dart';

class LibraryAddSearchPane extends StatelessWidget {
  const LibraryAddSearchPane({
    super.key,
    required this.type,
    required this.isBusy,
    required this.error,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.searchedProvider,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    this.coreMatchSummary,
    this.providerMatchSummary,
    required this.isWideLayout,
    required this.resultPolicy,
    required this.resultPolicyState,
    required this.onResultPolicyOptionChanged,
    required this.showCoreResults,
    required this.showProviderResults,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
    required this.onShowCoreResultsChanged,
    required this.onShowProviderResultsChanged,
    required this.onSearchCore,
  });

  final LibraryKindModule type;
  final bool isBusy;
  final String? error;
  final Color accent;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String? Function(CatalogItem item)? coreMatchSummary;
  final String? Function(ProviderCandidate candidate)? providerMatchSummary;
  final bool isWideLayout;
  final LibraryAddResultPolicy resultPolicy;
  final LibraryAddResultPolicyState resultPolicyState;
  final void Function(String id, bool value) onResultPolicyOptionChanged;
  final bool showCoreResults;
  final bool showProviderResults;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final ValueChanged<bool> onShowCoreResultsChanged;
  final ValueChanged<bool> onShowProviderResultsChanged;
  final VoidCallback onSearchCore;

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
          LibraryAddSearchSourceToggles(
            showCoreResults: showCoreResults,
            showProviderResults: showProviderResults,
            onShowCoreResultsChanged: onShowCoreResultsChanged,
            onShowProviderResultsChanged: onShowProviderResultsChanged,
            resultOptions: resultPolicy.options
                .where((option) => option.showInSourceToggles)
                .toList(growable: false),
            resultPolicyState: resultPolicyState,
            onResultPolicyOptionChanged: onResultPolicyOptionChanged,
          ),
          Expanded(
            child: _SearchResultsList(
              type: type,
              accent: accent,
              useGridResults: resultPolicy.useGridResults,
              selectedProvider: selectedProvider,
              isBusy: isBusy,
              error: error,
              searchedProvider: searchedProvider,
              results: results,
              providerResults: providerResults,
              resultPolicy: resultPolicy,
              queuedProviderIngests: queuedProviderIngests,
              selectedResultId: selectedResultId,
              selectedProviderCandidateId: selectedProviderCandidateId,
              checkedResultIds: checkedResultIds,
              checkedProviderIds: checkedProviderIds,
              ownedCatalogItemIds: ownedCatalogItemIds,
              coreMatchSummary: coreMatchSummary,
              providerMatchSummary: providerMatchSummary,
              onSearchCore: onSearchCore,
              onSelectResult: onSelectResult,
              onSelectProviderCandidate: onSelectProviderCandidate,
              onToggleResultCheck: onToggleResultCheck,
              onToggleProviderCheck: onToggleProviderCheck,
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryAddSearchSourceToggles extends StatelessWidget {
  const LibraryAddSearchSourceToggles({
    super.key,
    required this.showCoreResults,
    required this.showProviderResults,
    required this.onShowCoreResultsChanged,
    required this.onShowProviderResultsChanged,
    required this.resultOptions,
    required this.resultPolicyState,
    required this.onResultPolicyOptionChanged,
  });

  final bool showCoreResults;
  final bool showProviderResults;
  final ValueChanged<bool> onShowCoreResultsChanged;
  final ValueChanged<bool> onShowProviderResultsChanged;
  final List<LibraryAddResultOption> resultOptions;
  final LibraryAddResultPolicyState resultPolicyState;
  final void Function(String id, bool value) onResultPolicyOptionChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          bottom: BorderSide(color: palette.divider),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _SearchSourceToggle(
              label: 'Core results',
              value: showCoreResults,
              onChanged: onShowCoreResultsChanged,
            ),
            _SearchSourceToggle(
              label: 'Provider results',
              value: showProviderResults,
              onChanged: onShowProviderResultsChanged,
            ),
            for (final option in resultOptions)
              _SearchSourceToggle(
                label: option.label,
                value: resultPolicyState.valueFor(
                  option.id,
                  fallback: option.initialValue,
                ),
                onChanged: (value) =>
                    onResultPolicyOptionChanged(option.id, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchSourceToggle extends StatelessWidget {
  const _SearchSourceToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 18,
              child: IgnorePointer(
                child: Checkbox(
                  value: value,
                  onChanged: null,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
    required this.queuedProviderIngests,
    required this.isBusy,
    required this.accent,
    required this.onSearchCore,
  });

  final String? error;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final bool isBusy;
  final Color accent;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (error == null && queuedProviderIngests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (queuedProviderIngests.isNotEmpty)
          _QueuedIngestNotice(
            count: queuedProviderIngests.length,
            accent: accent,
            onSearchCore: isBusy ? null : onSearchCore,
          ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(
              top: queuedProviderIngests.isNotEmpty ? 6 : 0,
            ),
            child: AppErrorBanner(error!),
          ),
        Divider(height: 1, thickness: 1, color: palette.divider),
      ],
    );
  }
}

class _QueuedIngestNotice extends StatelessWidget {
  const _QueuedIngestNotice({
    required this.count,
    required this.accent,
    required this.onSearchCore,
  });

  final int count;
  final Color accent;
  final VoidCallback? onSearchCore;

  @override
  Widget build(BuildContext context) {
    final jobLabel = count == 1 ? 'job' : 'jobs';
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppBannerInfoBackground,
        border: Border.all(color: accent.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.playlist_add_check, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count Core ingest $jobLabel queued. Run or retry them in Admin, then search Core again.',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSearchCore,
              style: libraryAddOutlinedButtonStyle(accent),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Search Core again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.type,
    required this.accent,
    required this.useGridResults,
    required this.selectedProvider,
    required this.isBusy,
    required this.error,
    required this.searchedProvider,
    required this.results,
    required this.providerResults,
    required this.resultPolicy,
    required this.queuedProviderIngests,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    this.coreMatchSummary,
    this.providerMatchSummary,
    required this.onSearchCore,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
  });

  final LibraryKindModule type;
  final Color accent;
  final bool useGridResults;
  final String selectedProvider;
  final bool isBusy;
  final String? error;
  final bool searchedProvider;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final LibraryAddResultPolicy resultPolicy;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String? Function(CatalogItem item)? coreMatchSummary;
  final String? Function(ProviderCandidate candidate)? providerMatchSummary;
  final VoidCallback onSearchCore;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final notice = _SearchPaneNoticeStack(
      error: error,
      queuedProviderIngests: queuedProviderIngests,
      isBusy: isBusy,
      accent: accent,
      onSearchCore: onSearchCore,
    );
    if (isBusy && results.isEmpty && providerResults.isEmpty) {
      return _SearchSkeletonList(notice: notice);
    }
    if (results.isEmpty && providerResults.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          notice,
          SizedBox(
            height: 280,
            child: _NoSearchResults(
              type: type,
              accent: accent,
              selectedProvider: selectedProvider,
              searchedProvider: searchedProvider,
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
        providerResults: providerResults,
        queuedProviderIngests: queuedProviderIngests,
        selectedResultId: selectedResultId,
        selectedProviderCandidateId: selectedProviderCandidateId,
        checkedResultIds: checkedResultIds,
        ownedCatalogItemIds: ownedCatalogItemIds,
        providerLabel: type.metadata.providerLabel,
        coreMatchSummary: coreMatchSummary,
        providerMatchSummary: providerMatchSummary,
        onSelectResult: onSelectResult,
        onSelectProviderCandidate: onSelectProviderCandidate,
        onToggleResultCheck: onToggleResultCheck,
      );
    }
    final fallbackProviderLabel = _fallbackProviderLabel();
    // Hide mixed-provider summary; provider badges are sufficient.
    // final mixedProviderSummary = _mixedProviderSummary();
    final groups = buildUnifiedGroups(
      coreResults: results,
      providerResults: providerResults,
      resultPolicy: resultPolicy,
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        if (fallbackProviderLabel != null)
          _ProviderFallbackNotice(
            requestedProvider: type.metadata.providerLabel(selectedProvider),
            fallbackProvider: fallbackProviderLabel,
          ),
        // mixed provider summary removed per UX preference.
        for (var i = 0; i < groups.length; i++) ...[
          LibraryAddUnifiedGroupNode(
            key: ValueKey(groups[i].key),
            type: type,
            group: groups[i],
            accent: accent,
            selectedResultId: selectedResultId,
            selectedProviderCandidateId: selectedProviderCandidateId,
            checkedResultIds: checkedResultIds,
            ownedCatalogItemIds: ownedCatalogItemIds,
            queuedProviderIngests: queuedProviderIngests,
            providerLabel: type.metadata.providerLabel,
            onSelectResult: onSelectResult,
            onSelectProviderCandidate: onSelectProviderCandidate,
            onToggleResultCheck: onToggleResultCheck,
            onToggleProviderCheck: onToggleProviderCheck,
            coreMatchSummary: coreMatchSummary,
            providerMatchSummary: providerMatchSummary,
          ),
          if (i < groups.length - 1)
            Divider(height: 1, thickness: 1, color: palette.divider),
        ],
      ],
    );
  }

  String? _fallbackProviderLabel() {
    final providers = _providerIdsInOrder();
    if (providers.length != 1) {
      return null;
    }
    final onlyProvider = providers.first;
    if (onlyProvider != selectedProvider) {
      return type.metadata.providerLabel(onlyProvider);
    }
    return null;
  }

  List<String> _providerIdsInOrder() {
    final providers = <String>[];
    for (final item in providerResults) {
      if (!providers.contains(item.provider)) {
        providers.add(item.provider);
      }
    }
    return providers;
  }
}

class _SearchResultsGrid extends StatelessWidget {
  const _SearchResultsGrid({
    required this.type,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.ownedCatalogItemIds,
    required this.providerLabel,
    this.coreMatchSummary,
    this.providerMatchSummary,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
  });

  final LibraryKindModule type;
  final Color accent;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> ownedCatalogItemIds;
  final String Function(String providerId) providerLabel;
  final String? Function(CatalogItem item)? coreMatchSummary;
  final String? Function(ProviderCandidate candidate)? providerMatchSummary;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final entries = <_SearchGridEntry>[
      for (final item in results) _SearchGridEntry.core(item),
      for (final candidate in providerResults)
        _SearchGridEntry.provider(candidate),
    ];
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
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final item = entry.item;
        final candidate = entry.candidate;
        final isCore = item != null;
        final isOwned = isCore && ownedCatalogItemIds.contains(item.id);
        final selected = isCore
            ? item.id == selectedResultId
            : candidate!.localCatalogId == selectedProviderCandidateId;
        final checked = isCore && checkedResultIds.contains(item.id);
        final title = isCore ? item.title : candidate!.title;
        final coverUrl = isCore ? item.displayCoverUrl : candidate!.imageUrl;
        final corePublisher = isCore
            ? ((item.payload['publisher'] ??
                    (item.payload['publishing'] as Map?)?['original_publisher'])
                as String?)
            : null;
        final subtitle = isCore
            ? [
                if (libraryKindReleaseYear(item) != null)
                  libraryKindReleaseYear(item).toString(),
                if (corePublisher != null) corePublisher,
              ].whereType<String>().join(' · ')
            : [
                if (candidate != null) providerLabel(candidate.provider),
                if (candidate?.summary?.trim().isNotEmpty == true)
                  candidate?.summary,
              ].whereType<String>().join(' · ');
        final matchSummary = isCore
            ? coreMatchSummary?.call(item)
            : providerMatchSummary?.call(candidate!);
        final ownedTone = Theme.of(context).colorScheme.tertiary;
        final ownedFill = Color.alphaBlend(
          ownedTone.withValues(alpha: 0.16),
          palette.tableEvenRow,
        );
        final ownedBorder = ownedTone.withValues(alpha: 0.6);
        final ownedBadgeBackground = Color.alphaBlend(
          ownedTone.withValues(alpha: palette.isDark ? 0.34 : 0.16),
          palette.surfaceDim,
        );
        final ownedBadgeForeground =
            ThemeData.estimateBrightnessForColor(ownedBadgeBackground) ==
                    Brightness.dark
                ? Colors.white
                : palette.textPrimary;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCore
                ? () => onSelectResult(item.id)
                : () => onSelectProviderCandidate(candidate!.localCatalogId),
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.22), palette.selection)
                    : isOwned
                        ? ownedFill
                        : palette.tableEvenRow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? accent
                      : isOwned
                          ? ownedBorder
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
                          if (isOwned)
                            Positioned(
                              left: 6,
                              top: 6,
                              child: LibraryAddResultBadge(
                                'In collection',
                                key: ValueKey(
                                    'library-add-owned-badge-${item.id}'),
                                icon: Icons.playlist_add_check_rounded,
                                backgroundColor: ownedBadgeBackground,
                                borderColor: ownedBorder,
                                foregroundColor: ownedBadgeForeground,
                              ),
                            ),
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: LibraryAddResultBadge(
                              isCore
                                  ? 'core'
                                  : providerLabel(candidate!.provider),
                              accent: accent,
                            ),
                          ),
                          if (isCore)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: InkWell(
                                onTap: () => onToggleResultCheck(item.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: palette.surfaceDim
                                        .withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    checked
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                    color:
                                        checked ? accent : palette.textPrimary,
                                  ),
                                ),
                              ),
                            )
                          else if (queuedProviderIngests[
                                  candidate!.localCatalogId] !=
                              null)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Icon(
                                Icons.playlist_add_check,
                                size: 18,
                                color: accent,
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
                        fontWeight: FontWeight.w900,
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
                          fontSize: 11,
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
                          color: accent.withValues(alpha: 0.92),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (isOwned) ...[
                      SizedBox(height: 5 * densityScale),
                      LibraryAddResultBadge(
                        'Already in collection',
                        icon: Icons.playlist_add_check_rounded,
                        backgroundColor: ownedBadgeBackground,
                        borderColor: ownedBorder,
                        foregroundColor: ownedBadgeForeground,
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

class _SearchGridEntry {
  const _SearchGridEntry.core(this.item) : candidate = null;
  const _SearchGridEntry.provider(this.candidate) : item = null;

  final CatalogItem? item;
  final ProviderCandidate? candidate;
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

class _ProviderFallbackNotice extends StatelessWidget {
  const _ProviderFallbackNotice({
    required this.requestedProvider,
    required this.fallbackProvider,
  });

  final String requestedProvider;
  final String fallbackProvider;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kAppBannerWarningBackground,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: kAppHighlight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$requestedProvider unavailable, $fallbackProvider fallback used.',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
    this.isOwned = false,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final LibraryKindModule type;
  final CatalogItem item;
  final Color accent;
  final String? Function(CatalogItem item)? matchSummary;
  final bool selected;
  final bool checked;
  final bool isOwned;
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
        type.presentation.builder.buildSearchResultDisplay(item: item);
    final payload = item.payload;
    final publisher = (payload['publisher'] ??
        (payload['publishing'] as Map?)?['original_publisher']) as String?;
    final physicalFormatLabel = payload['physical_format_label'] as String?;
    final barcode = payload['barcode'] as String?;
    final itemNumber = (payload['item_number'] ??
        (payload['publishing'] as Map?)?['issue_number']) as String?;
    final subtitle = resultDisplay?.secondaryLine ??
        [
          if (publisher != null) publisher,
          if (libraryKindReleaseYear(item) != null)
            libraryKindReleaseYear(item).toString(),
          if (physicalFormatLabel != null) physicalFormatLabel,
          if (barcode != null) barcode,
        ].whereType<String>().join(' | ');
    final detailLine = resultDisplay?.detailLine;
    final ownedTone = Theme.of(context).colorScheme.tertiary;
    final ownedFill = Color.alphaBlend(
      ownedTone.withValues(alpha: 0.16),
      palette.tableEvenRow,
    );
    final ownedBorder = ownedTone.withValues(alpha: 0.6);
    final ownedBadgeBackground = Color.alphaBlend(
      ownedTone.withValues(alpha: palette.isDark ? 0.34 : 0.16),
      palette.surfaceDim,
    );
    final ownedBadgeForeground =
        ThemeData.estimateBrightnessForColor(ownedBadgeBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return InkWell(
      key: ValueKey('library-add-search-result-${item.id}'),
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.46), palette.selection)
              : isOwned
                  ? ownedFill
                  : palette.tableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected
                  ? accent
                  : isOwned
                      ? ownedBorder
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
                  title: item.title,
                  itemNumber: itemNumber,
                  imageUrl: item.displayCoverUrl,
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
                        if (isOwned) ...[
                          LibraryAddResultBadge(
                            'Already in collection',
                            icon: Icons.playlist_add_check_rounded,
                            backgroundColor: ownedBadgeBackground,
                            borderColor: ownedBorder,
                            foregroundColor: ownedBadgeForeground,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          resultDisplay?.title ??
                              (itemNumber == null
                                  ? item.title
                                  : '${item.title} #$itemNumber'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
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
                              fontSize: 12,
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
                              fontSize: 11,
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
                              color: accent.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
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
                              LibraryAddResultBadge(item.kind),
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

class ProviderCandidateTile extends StatelessWidget {
  const ProviderCandidateTile({
    super.key,
    required this.type,
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    required this.queuedIngest,
    this.matchSummary,
    required this.selected,
    required this.onSelect,
  });

  final LibraryKindModule type;
  final ProviderCandidate candidate;
  final Color accent;
  final String providerLabel;
  final LibraryQueuedProviderIngest? queuedIngest;
  final String? Function(ProviderCandidate candidate)? matchSummary;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final densityScale = density.metrics.searchScale;
    final summary = matchSummary?.call(candidate);
    final subtitle = [
      providerLabel,
      candidate.summary,
      candidate.providerItemId,
    ].whereType<String>().join(' | ');
    return InkWell(
      key: ValueKey('library-add-search-result-${candidate.localCatalogId}'),
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.46), palette.selection)
              : palette.tableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 56,
                child: LibraryCoverImage(
                  title: candidate.title,
                  imageUrl: candidate.imageUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 170;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          candidate.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (summary != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Matched on: $summary',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              LibraryAddResultBadge(providerLabel),
                              if (queuedIngest != null) ...[
                                const SizedBox(width: 5),
                                LibraryAddResultBadge(
                                  '${queuedIngest!.statusLabel} ${queuedIngest!.shortId}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(width: 8 * densityScale),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? accent : palette.textMuted,
                size: 20,
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
    required this.selectedProvider,
    required this.searchedProvider,
  });

  final LibraryKindModule type;
  final Color accent;
  final String selectedProvider;
  final bool searchedProvider;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.identity.icon, size: 28, color: accent),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _message {
    if (type.metadata.supportedProvidersForKind(type.kind).isEmpty) {
      return 'No Core providers are configured for this library yet. Add a manual item to keep working locally.';
    }
    if (searchedProvider) {
      return 'No ${type.metadata.providerLabel(selectedProvider)} candidates found. Try a broader query or add a manual item.';
    }
    return 'Search Core, lookup a barcode, search ${type.metadata.providerLabel(selectedProvider)}, or add a manual item if Core is offline.';
  }
}
