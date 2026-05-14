import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _queryController = TextEditingController(text: 'Batman #1');
  final _providerItemIdController = TextEditingController();
  var _providers = const <AdminProviderStatus>[];
  AdminCatalogSummary? _summary;
  AdminSearchStatus? _searchStatus;
  AdminSearchReindexResult? _lastReindex;
  var _searchHistory = const <AdminSearchHistoryEntry>[];
  AdminMetadataItem? _inspectedItem;
  var _duplicates = const <AdminDuplicateCandidate>[];
  var _results = const <ProviderCandidate>[];
  var _selectedProvider = 'gcd';
  AdminProviderIngestResult? _lastIngest;
  String? _statusMessage;
  String? _errorMessage;
  String? _dashboardErrorMessage;
  String? _inspectErrorMessage;
  String? _duplicateStatusMessage;
  String? _duplicateErrorMessage;
  bool _isLoadingDashboard = false;
  bool _isReindexing = false;
  bool _isLoadingProviders = false;
  bool _isSearching = false;
  bool _isDirectIngesting = false;
  String? _inspectingItemId;
  String? _duplicateActionItemId;
  String? _ingestingProviderItemId;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadProviders();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminPanel(
            icon: Icons.dashboard_customize_outlined,
            title: 'Metadata dashboard',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Reindex search',
                  onPressed: _isReindexing ? null : _reindexSearch,
                  icon: _isReindexing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.manage_search_outlined),
                ),
                IconButton(
                  tooltip: 'Refresh dashboard',
                  onPressed: _isLoadingDashboard ? null : _loadDashboard,
                  icon: _isLoadingDashboard
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            child: _DashboardSummary(
              summary: _summary,
              searchStatus: _searchStatus,
              lastReindex: _lastReindex,
              configuredProviders: _configuredProviderCount(),
              registeredProviders: _providers.length,
              selectedProvider: _selectedProvider,
              lastIngest: _lastIngest,
              errorMessage: _dashboardErrorMessage,
            ),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.history_outlined,
            title: 'Search index history',
            child: _SearchHistoryList(history: _searchHistory),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.hub_outlined,
            title: 'Provider status',
            trailing: IconButton(
              tooltip: 'Refresh providers',
              onPressed: _isLoadingProviders ? null : _loadProviders,
              icon: _isLoadingProviders
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
            child: _ProviderStatusList(providers: _providers),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.join_inner_outlined,
            title: 'Duplicate candidates',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_duplicateStatusMessage != null ||
                    _duplicateErrorMessage != null) ...[
                  _MessageRow(
                    message: _duplicateErrorMessage ?? _duplicateStatusMessage!,
                    isError: _duplicateErrorMessage != null,
                  ),
                  const SizedBox(height: 12),
                ],
                _DuplicateCandidateList(
                  candidates: _duplicates,
                  inspectingItemId: _inspectingItemId,
                  actionItemId: _duplicateActionItemId,
                  onInspect: _inspectDuplicateCandidate,
                  onIgnore: _ignoreDuplicateCandidate,
                  onMerge: _mergeDuplicateCandidate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_lastIngest != null ||
              _inspectedItem != null ||
              _inspectErrorMessage != null) ...[
            _AdminPanel(
              icon: Icons.fact_check_outlined,
              title: 'Canonical item inspector',
              child: _inspectErrorMessage != null
                  ? _MessageRow(
                      message: _inspectErrorMessage!,
                      isError: true,
                    )
                  : _CanonicalItemSummary(
                      item: _lastIngest?.item ?? _inspectedItem!,
                      created: _lastIngest?.created,
                    ),
            ),
            const SizedBox(height: 12),
          ],
          _AdminPanel(
            icon: Icons.travel_explore_outlined,
            title: 'Provider ingest',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    final searchableProviders = _providerOptions();
                    final providerField = _ProviderSelector(
                      value: _selectedProvider,
                      providers: searchableProviders,
                      isLoading: _isLoadingProviders,
                      onChanged: (value) {
                        if (value == null || value == _selectedProvider) {
                          return;
                        }
                        setState(() {
                          _selectedProvider = value;
                          _results = const [];
                          _lastIngest = null;
                          _statusMessage = null;
                          _errorMessage = null;
                        });
                      },
                    );
                    final queryField = TextField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Provider query',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchProvider(),
                    );
                    final providerItemIdField = TextField(
                      controller: _providerItemIdController,
                      decoration: const InputDecoration(
                        labelText: 'Provider item ID',
                        prefixIcon: Icon(Icons.tag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _ingestProviderItemId(),
                    );
                    final searchButton = FilledButton.icon(
                      onPressed: _isSearching ? null : _searchProvider,
                      icon: _isSearching
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.manage_search),
                      label: const Text('Search'),
                    );
                    final ingestIdButton = OutlinedButton.icon(
                      onPressed:
                          _isDirectIngesting || searchableProviders.isEmpty
                              ? null
                              : _ingestProviderItemId,
                      icon: _isDirectIngesting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_for_offline_outlined),
                      label: const Text('Ingest ID'),
                    );
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          providerField,
                          const SizedBox(height: 12),
                          queryField,
                          const SizedBox(height: 12),
                          providerItemIdField,
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [searchButton, ingestIdButton],
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 220, child: providerField),
                        const SizedBox(width: 12),
                        Expanded(child: queryField),
                        const SizedBox(width: 12),
                        SizedBox(width: 220, child: providerItemIdField),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [searchButton, ingestIdButton],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_statusMessage != null || _errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _MessageRow(
                    message: _errorMessage ?? _statusMessage!,
                    isError: _errorMessage != null,
                  ),
                ],
                const SizedBox(height: 12),
                _ProviderResultsList(
                  results: _results,
                  ingestingProviderItemId: _ingestingProviderItemId,
                  onIngest: _ingestProviderItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardErrorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final summary = await api.adminCatalogSummary();
      final searchStatus = await api.adminSearchStatus();
      final searchHistory = await api.adminSearchHistory();
      final duplicates = await api.adminDuplicateCandidates(limit: 5);
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _searchStatus = searchStatus;
        _searchHistory = searchHistory;
        _duplicates = duplicates;
        _isLoadingDashboard = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingDashboard = false;
        _dashboardErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _reindexSearch() async {
    setState(() {
      _isReindexing = true;
      _dashboardErrorMessage = null;
    });
    try {
      final result = await ref.read(apiClientProvider).adminReindexSearch();
      if (!mounted) {
        return;
      }
      setState(() {
        _lastReindex = result;
        _isReindexing = false;
        _dashboardErrorMessage =
            result.ok ? null : result.error ?? 'Search reindex failed.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isReindexing = false;
        _dashboardErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _inspectDuplicateCandidate(
    AdminDuplicateCandidate candidate,
  ) async {
    if (candidate.itemIds.isEmpty) {
      return;
    }
    final itemId = candidate.itemIds.first;
    setState(() {
      _inspectingItemId = itemId;
      _duplicateStatusMessage = null;
      _duplicateErrorMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      final item = await ref.read(apiClientProvider).adminGetMetadataItem(
            kind: candidate.kind,
            id: itemId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectedItem = item;
        _lastIngest = null;
        _inspectingItemId = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectingItemId = null;
        _inspectErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _ignoreDuplicateCandidate(
    AdminDuplicateCandidate candidate,
  ) async {
    if (candidate.itemIds.length < 2) {
      return;
    }
    setState(() {
      _duplicateActionItemId = candidate.itemIds.first;
      _duplicateStatusMessage = null;
      _duplicateErrorMessage = null;
    });
    try {
      final result =
          await ref.read(apiClientProvider).adminIgnoreDuplicateCandidate(
                itemIds: candidate.itemIds,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _duplicateStatusMessage =
            'Ignored ${result.affectedItems} duplicate items.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _duplicateErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _mergeDuplicateCandidate(
    AdminDuplicateCandidate candidate,
  ) async {
    if (candidate.itemIds.length < 2) {
      return;
    }
    final targetItemId = candidate.itemIds.first;
    final sourceItemIds = candidate.itemIds.skip(1).toList(growable: false);
    setState(() {
      _duplicateActionItemId = targetItemId;
      _duplicateStatusMessage = null;
      _duplicateErrorMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      final result =
          await ref.read(apiClientProvider).adminMergeDuplicateCandidate(
                targetItemId: targetItemId,
                sourceItemIds: sourceItemIds,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _lastIngest = null;
        _inspectedItem = result.item ?? _inspectedItem;
        _duplicateStatusMessage =
            'Merged ${result.affectedItems} duplicate items.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _duplicateErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoadingProviders = true;
      _errorMessage = null;
    });
    try {
      final providers =
          await ref.read(apiClientProvider).adminProviderStatuses();
      if (!mounted) {
        return;
      }
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
        if (!providers.any((provider) => provider.name == _selectedProvider) &&
            providers.isNotEmpty) {
          _selectedProvider = providers.first.name;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingProviders = false;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _searchProvider() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a provider query.';
        _statusMessage = null;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _results = const [];
      _lastIngest = null;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).adminProviderSearch(
            provider: _selectedProvider,
            query: query,
          );
      final results =
          rows.map(ProviderCandidate.fromJson).toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _results = results;
        _isSearching = false;
        _statusMessage = results.isEmpty
            ? 'No provider results.'
            : '${results.length} provider results.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSearching = false;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _ingestProviderItemId() async {
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a provider item ID.';
        _statusMessage = null;
      });
      return;
    }
    await _ingestProvider(
      provider: _selectedProvider,
      providerItemId: providerItemId,
      isDirect: true,
    );
  }

  Future<void> _ingestProviderItem(ProviderCandidate candidate) async {
    await _ingestProvider(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

  Future<void> _ingestProvider({
    required String provider,
    required String providerItemId,
    bool isDirect = false,
  }) async {
    setState(() {
      _isDirectIngesting = isDirect;
      _ingestingProviderItemId = providerItemId;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final result = await ref.read(apiClientProvider).adminProviderIngest(
            provider: provider,
            providerItemId: providerItemId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = result;
        _inspectedItem = null;
        _inspectErrorMessage = null;
        _isDirectIngesting = false;
        _ingestingProviderItemId = null;
        _statusMessage = result.created
            ? 'Metadata item ingested.'
            : 'Metadata item already exists.';
      });
      _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDirectIngesting = false;
        _ingestingProviderItemId = null;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  int _configuredProviderCount() {
    return _providers.where((provider) => provider.isConfigured).length;
  }

  List<AdminProviderStatus> _providerOptions() {
    return _providers
        .where((provider) => provider.supportsSearch)
        .toList(growable: false);
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({
    required this.summary,
    required this.searchStatus,
    required this.lastReindex,
    required this.configuredProviders,
    required this.registeredProviders,
    required this.selectedProvider,
    required this.lastIngest,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final int configuredProviders;
  final int registeredProviders;
  final String selectedProvider;
  final AdminProviderIngestResult? lastIngest;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    final searchStatus = this.searchStatus;
    if (errorMessage != null && summary == null && searchStatus == null) {
      return _MessageRow(message: errorMessage!, isError: true);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          icon: Icons.extension_outlined,
          label: '$configuredProviders providers live',
        ),
        _StatusChip(
          icon: Icons.manage_search_outlined,
          label: '$registeredProviders providers registered',
        ),
        _StatusChip(
          icon: Icons.source_outlined,
          label: selectedProvider.toUpperCase(),
        ),
        if (summary == null) ...[
          const _StatusChip(
            icon: Icons.hourglass_empty,
            label: 'Catalog metrics loading',
          ),
        ] else ...[
          _StatusChip(
            icon: Icons.library_books_outlined,
            label: '${summary.items} items',
          ),
          _StatusChip(
            icon: Icons.category_outlined,
            label: '${summary.series} series',
          ),
          _StatusChip(
            icon: Icons.link_outlined,
            label: '${summary.providerLinks} provider links',
          ),
          _StatusChip(
            icon: Icons.image_outlined,
            label: '${summary.missingCoverItems} missing covers',
          ),
          _StatusChip(
            icon: Icons.join_inner_outlined,
            label: '${summary.duplicateCandidateGroups} duplicate groups',
          ),
          _StatusChip(
            icon: Icons.pending_actions_outlined,
            label: '${summary.pendingProposals} pending proposals',
          ),
        ],
        if (searchStatus == null)
          const _StatusChip(
            icon: Icons.manage_search_outlined,
            label: 'Search status loading',
          )
        else
          _StatusChip(
            icon: searchStatus.ok
                ? Icons.check_circle_outline
                : Icons.error_outline,
            label: searchStatus.ok
                ? '${searchStatus.indexName}: ${searchStatus.documentCount ?? '-'} docs'
                : 'Search unavailable',
          ),
        if (lastReindex != null)
          _StatusChip(
            icon: lastReindex!.ok
                ? Icons.published_with_changes_outlined
                : Icons.error_outline,
            label: lastReindex!.ok
                ? 'Reindexed ${lastReindex!.indexedDocuments}'
                : 'Reindex failed',
          ),
        if (lastIngest != null)
          _StatusChip(
            icon: lastIngest!.created
                ? Icons.add_circle_outline
                : Icons.fact_check_outlined,
            label: lastIngest!.created ? 'Last ingest new' : 'Already indexed',
          ),
        if (errorMessage != null)
          _StatusChip(
            icon: Icons.error_outline,
            label: errorMessage!,
          ),
      ],
    );
  }
}

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.value,
    required this.providers,
    required this.isLoading,
    required this.onChanged,
  });

  final String value;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = providers.any((provider) => provider.name == value)
        ? value
        : providers.isEmpty
            ? null
            : providers.first.name;
    if (providers.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Provider',
          prefixIcon: const Icon(Icons.extension_outlined),
          border: const OutlineInputBorder(),
          hintText:
              isLoading ? 'Loading providers...' : 'No searchable providers',
        ),
      );
    }
    return DropdownButtonFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Provider',
        prefixIcon: Icon(Icons.extension_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        for (final provider in providers)
          DropdownMenuItem(
            value: provider.name,
            child: Text(provider.displayName, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  const _SearchHistoryList({required this.history});

  final List<AdminSearchHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const _MessageRow(
        message: 'No search reindex runs yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      entry.ok
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: entry.ok ? colorScheme.primary : colorScheme.error,
                    ),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _MiniChip(label: entry.indexName),
                    _MiniChip(label: '${entry.indexedDocuments} docs'),
                    if (entry.error != null && entry.error!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          entry.error!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DuplicateCandidateList extends StatelessWidget {
  const _DuplicateCandidateList({
    required this.candidates,
    required this.inspectingItemId,
    required this.actionItemId,
    required this.onInspect,
    required this.onIgnore,
    required this.onMerge,
  });

  final List<AdminDuplicateCandidate> candidates;
  final String? inspectingItemId;
  final String? actionItemId;
  final ValueChanged<AdminDuplicateCandidate> onInspect;
  final ValueChanged<AdminDuplicateCandidate> onIgnore;
  final ValueChanged<AdminDuplicateCandidate> onMerge;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const _MessageRow(
        message: 'No duplicate candidates detected.',
        isError: false,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final candidate in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DuplicateCandidateTile(
              candidate: candidate,
              isInspecting: candidate.itemIds.contains(inspectingItemId),
              isActing: candidate.itemIds.contains(actionItemId),
              onInspect: () => onInspect(candidate),
              onIgnore: () => onIgnore(candidate),
              onMerge: () => onMerge(candidate),
            ),
          ),
      ],
    );
  }
}

class _DuplicateCandidateTile extends StatelessWidget {
  const _DuplicateCandidateTile({
    required this.candidate,
    required this.isInspecting,
    required this.isActing,
    required this.onInspect,
    required this.onIgnore,
    required this.onMerge,
  });

  final AdminDuplicateCandidate candidate;
  final bool isInspecting;
  final bool isActing;
  final VoidCallback onInspect;
  final VoidCallback onIgnore;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.join_inner_outlined, color: colorScheme.primary),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                candidate.displayTitle,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _MiniChip(label: candidate.kind),
            _MiniChip(label: '${candidate.count} items'),
            if (candidate.itemIds.isNotEmpty)
              _MiniChip(label: 'ID ${_shortId(candidate.itemIds.first)}'),
            OutlinedButton.icon(
              onPressed: isInspecting || isActing || candidate.itemIds.isEmpty
                  ? null
                  : onInspect,
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
                  isActing || candidate.itemIds.length < 2 ? null : onIgnore,
              icon: const Icon(Icons.visibility_off_outlined),
              label: const Text('Ignore'),
            ),
            FilledButton.tonalIcon(
              onPressed:
                  isActing || candidate.itemIds.length < 2 ? null : onMerge,
              icon: isActing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.merge_type_outlined),
              label: const Text('Merge into first'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderStatusList extends StatelessWidget {
  const _ProviderStatusList({required this.providers});

  final List<AdminProviderStatus> providers;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const _MessageRow(
        message: 'Provider status not loaded.',
        isError: false,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final provider in providers)
          _ProviderStatusTile(provider: provider),
      ],
    );
  }
}

class _ProviderStatusTile extends StatelessWidget {
  const _ProviderStatusTile({required this.provider});

  final AdminProviderStatus provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    provider.isConfigured
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: provider.isConfigured
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(provider.status),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (provider.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  provider.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: provider.kind),
                  if (provider.requiresUserKey)
                    const _MiniChip(label: 'key required'),
                  if (provider.nonCommercialOnly)
                    const _MiniChip(label: 'non-commercial'),
                  if (provider.requiresAttribution)
                    const _MiniChip(label: 'attribution'),
                  if (provider.licenseName != null)
                    _MiniChip(label: provider.licenseName!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderResultsList extends StatelessWidget {
  const _ProviderResultsList({
    required this.results,
    required this.ingestingProviderItemId,
    required this.onIngest,
  });

  final List<ProviderCandidate> results;
  final String? ingestingProviderItemId;
  final ValueChanged<ProviderCandidate> onIngest;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final candidate = results[index];
        final isIngesting = ingestingProviderItemId == candidate.providerItemId;
        return _ProviderResultTile(
          candidate: candidate,
          isIngesting: isIngesting,
          onIngest: () => onIngest(candidate),
        );
      },
    );
  }
}

class _ProviderResultTile extends StatelessWidget {
  const _ProviderResultTile({
    required this.candidate,
    required this.isIngesting,
    required this.onIngest,
  });

  final ProviderCandidate candidate;
  final bool isIngesting;
  final VoidCallback onIngest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final cover = SizedBox(
          width: 64,
          height: 88,
          child: LibraryCoverImage(
            title: candidate.title,
            imageUrl: candidate.imageUrl,
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniChip(label: candidate.provider),
                _MiniChip(label: candidate.kind),
                _MiniChip(label: 'ID ${candidate.providerItemId}'),
              ],
            ),
            if (candidate.summary != null &&
                candidate.summary!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                candidate.summary!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
        final button = FilledButton.tonalIcon(
          onPressed: isIngesting ? null : onIngest,
          icon: isIngesting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_for_offline_outlined),
          label: const Text('Ingest'),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 12),
                          Expanded(child: details),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: button,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 12),
                      Expanded(child: details),
                      const SizedBox(width: 12),
                      button,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CanonicalItemSummary extends StatelessWidget {
  const _CanonicalItemSummary({
    required this.item,
    this.created,
  });

  final AdminMetadataItem item;
  final bool? created;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final variant = item.primaryVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;
            final cover = SizedBox(
              width: 84,
              height: 118,
              child: LibraryCoverImage(
                title: item.title,
                itemNumber: item.itemNumber,
                imageUrl: item.displayCoverUrl,
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      created == true
                          ? Icons.add_circle_outline
                          : Icons.fact_check_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.displayTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: item.kind),
                    _MiniChip(label: 'ID ${_shortId(item.id)}'),
                    if (item.seriesTitle != null)
                      _MiniChip(label: item.seriesTitle!),
                    if (item.publisher != null)
                      _MiniChip(label: item.publisher!),
                    if (item.barcode != null) _MiniChip(label: item.barcode!),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Fact(
                        label: 'Editions',
                        value: item.editions.length.toString()),
                    _Fact(
                      label: 'Variants',
                      value: item.editions
                          .fold<int>(
                            0,
                            (count, edition) => count + edition.variants.length,
                          )
                          .toString(),
                    ),
                    _Fact(
                      label: 'Releases',
                      value: item.editions
                          .fold<int>(
                            0,
                            (count, edition) => count + edition.releases.length,
                          )
                          .toString(),
                    ),
                    if (item.pageCount != null)
                      _Fact(label: 'Pages', value: item.pageCount.toString()),
                    if (item.coverDate != null)
                      _Fact(
                          label: 'Cover', value: _formatDate(item.coverDate!)),
                    if (item.storeDate != null)
                      _Fact(
                          label: 'Store', value: _formatDate(item.storeDate!)),
                    if (variant?.coverPriceCents != null)
                      _Fact(
                        label: 'Cover price',
                        value: _formatMoney(
                          variant!.coverPriceCents!,
                          variant.currency ?? item.currency,
                        ),
                      ),
                  ],
                ),
                if (item.providerLinks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final link in item.providerLinks)
                        _MiniChip(
                          label:
                              '${link.provider} ${link.entityType}:${link.providerItemId}',
                        ),
                    ],
                  ),
                ],
              ],
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(height: 12),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cover,
                const SizedBox(width: 12),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.info_outline,
          color: isError ? colorScheme.error : colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _adminErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Admin access was rejected.';
    }
    if (statusCode == 422) {
      return 'Provider request was invalid.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Metadata server could not complete the admin request.';
    }
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  return error.toString();
}

String _shortId(String id) {
  if (id.length <= 8) {
    return id;
  }
  return id.substring(0, 8);
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${_formatDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _formatMoney(int cents, String? currency) {
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null || currency.isEmpty ? amount : '$amount $currency';
}
