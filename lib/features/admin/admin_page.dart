import 'dart:async';

import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/physical_media_formats.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _catalogQueryController = TextEditingController();
  final _queryController = TextEditingController();
  final _providerItemIdController = TextEditingController();
  final _jobProviderItemIdController = TextEditingController();
  final _ingestJobQueryController = TextEditingController();
  var _mediaTypes = const <CatalogMediaType>[];
  var _providers = const <AdminProviderStatus>[];
  AdminCatalogSummary? _summary;
  AdminSearchStatus? _searchStatus;
  AdminSearchReindexResult? _lastReindex;
  var _searchHistory = const <AdminSearchHistoryEntry>[];
  var _auditLogs = const <AdminAuditLogEntry>[];
  var _ingestHistory = const <AdminProviderIngestHistoryEntry>[];
  var _ingestJobs = const <AdminProviderIngestJob>[];
  AdminProviderIngestJobSummary? _ingestJobSummary;
  static const _ingestPollInterval = Duration(seconds: 15);
  Timer? _ingestPollTimer;
  DateTime? _ingestJobsRefreshedAt;
  var _catalogItems = const <AdminMetadataItem>[];
  var _duplicates = const <AdminDuplicateCandidate>[];
  var _results = const <ProviderCandidate>[];
  String? _catalogKindFilter;
  var _selectedProvider = '';
  String? _selectedProviderKindFilter;
  String? _ingestJobStatusFilter;
  String? _ingestJobProviderFilter;
  AdminProviderIngestResult? _lastIngest;
  String? _statusMessage;
  String? _errorMessage;
  String? _dashboardErrorMessage;
  String? _catalogStatusMessage;
  String? _catalogErrorMessage;
  String? _inspectErrorMessage;
  String? _duplicateStatusMessage;
  String? _duplicateErrorMessage;
  bool _isLoadingDashboard = false;
  bool _isReindexing = false;
  bool _isLoadingProviders = false;
  bool _isSearchingCatalog = false;
  bool _isRunningJobs = false;
  bool _isPollingIngestJobs = false;
  bool _autoRefreshIngestJobs = true;
  bool _isSearching = false;
  bool _isDirectIngesting = false;
  String? _inspectingItemId;
  String? _updatingCatalogItemId;
  String? _duplicateActionItemId;
  String? _ingestingProviderItemId;
  String? _jobActionId;
  int? _retryingHistoryId;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadMediaTypes();
    _loadProviders();
    _searchCatalog();
    _restartIngestPolling();
  }

  @override
  void dispose() {
    _ingestPollTimer?.cancel();
    _catalogQueryController.dispose();
    _queryController.dispose();
    _providerItemIdController.dispose();
    _jobProviderItemIdController.dispose();
    _ingestJobQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: animationDuration,
        ),
      ),
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
              selectedProviderLabel: _selectedProviderLabel(),
              lastIngest: _lastIngest,
              errorMessage: _dashboardErrorMessage,
            ),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.inventory_2_outlined,
            title: 'Canonical catalog browser',
            trailing: IconButton(
              tooltip: 'Search catalog',
              onPressed: _isSearchingCatalog ? null : _searchCatalog,
              icon: _isSearchingCatalog
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final kindField = _ProviderKindSelector(
                      value: _catalogKindFilter,
                      kinds: _catalogKindOptions(),
                      kindLabels: _catalogKindLabels(),
                      isLoading: _isLoadingProviders,
                      onChanged: (value) {
                        setState(() {
                          _catalogKindFilter =
                              value == null || value.isEmpty ? null : value;
                        });
                        _searchCatalog();
                      },
                    );
                    final queryField = TextField(
                      controller: _catalogQueryController,
                      decoration: const InputDecoration(
                        labelText: 'Catalog search',
                        prefixIcon: Icon(Icons.manage_search_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchCatalog(),
                    );
                    final searchButton = FilledButton.icon(
                      onPressed: _isSearchingCatalog ? null : _searchCatalog,
                      icon: _isSearchingCatalog
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Search'),
                    );
                    if (constraints.maxWidth < 640) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          kindField,
                          const SizedBox(height: 12),
                          queryField,
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: searchButton,
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 180, child: kindField),
                        const SizedBox(width: 12),
                        Expanded(child: queryField),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: searchButton,
                        ),
                      ],
                    );
                  },
                ),
                if (_catalogStatusMessage != null ||
                    _catalogErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  _MessageRow(
                    message: _catalogErrorMessage ?? _catalogStatusMessage!,
                    isError: _catalogErrorMessage != null,
                  ),
                ],
                const SizedBox(height: 12),
                _CatalogItemList(
                  items: _catalogItems,
                  inspectingItemId: _inspectingItemId,
                  updatingItemId: _updatingCatalogItemId,
                  onInspect: _inspectCatalogItem,
                  onEdit: _showMetadataCorrectionDialog,
                  onInspectCovers: _showCoverInspectionDialog,
                ),
              ],
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
            icon: Icons.manage_history_outlined,
            title: 'Admin audit log',
            child: _AdminAuditLogList(logs: _auditLogs),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.report_problem_outlined,
            title: 'Provider ingest history',
            child: _ProviderIngestHistoryList(
              history: _ingestHistory,
              retryingHistoryId: _retryingHistoryId,
              onRetry: _retryIngestHistory,
            ),
          ),
          const SizedBox(height: 12),
          _AdminPanel(
            icon: Icons.queue_outlined,
            title: 'Provider ingest jobs',
            trailing: IconButton(
              tooltip: 'Refresh ingest jobs',
              onPressed: _isPollingIngestJobs
                  ? null
                  : () => unawaited(_refreshIngestJobs()),
              icon: _isPollingIngestJobs
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
            child: _ProviderIngestJobPanel(
              jobs: _ingestJobs,
              summary: _ingestJobSummary,
              autoRefresh: _autoRefreshIngestJobs,
              isPolling: _isPollingIngestJobs,
              refreshedAt: _ingestJobsRefreshedAt,
              statusFilter: _ingestJobStatusFilter,
              providerFilter: _ingestJobProviderFilter,
              selectedProvider: _selectedProvider,
              providers: _providerOptions(forIngest: true),
              isLoadingProviders: _isLoadingProviders,
              providerItemIdController: _jobProviderItemIdController,
              queryController: _ingestJobQueryController,
              isRunningJobs: _isRunningJobs,
              actionJobId: _jobActionId,
              onProviderChanged: _changeSelectedProvider,
              onAutoRefreshChanged: _changeIngestJobAutoRefresh,
              onStatusFilterChanged: _changeIngestJobStatusFilter,
              onProviderFilterChanged: _changeIngestJobProviderFilter,
              onApplyFilters: () => unawaited(_refreshIngestJobs()),
              onRefresh: () => unawaited(_refreshIngestJobs()),
              onQueueCurrent: _queueCurrentProviderItemId,
              onRunPending: _runPendingIngestJobs,
              onRun: _runIngestJob,
              onRetry: _retryIngestJob,
            ),
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
          if (_lastIngest != null || _inspectErrorMessage != null) ...[
            _AdminPanel(
              icon: Icons.fact_check_outlined,
              title: 'Canonical item inspector',
              child: _inspectErrorMessage != null
                  ? _MessageRow(
                      message: _inspectErrorMessage!,
                      isError: true,
                    )
                  : _CanonicalItemSummary(
                      item: _lastIngest!.item,
                      created: _lastIngest?.created,
                      auditLogs: const <AdminAuditLogEntry>[],
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
                    final kindField = _ProviderKindSelector(
                      value: _selectedProviderKindFilter,
                      kinds: _providerKindOptions(forSearch: true),
                      kindLabels: _catalogKindLabels(),
                      isLoading: _isLoadingProviders,
                      onChanged: _changeProviderKindFilter,
                    );
                    final searchableProviders = _providerOptions();
                    final providerField = _ProviderSelector(
                      value: _selectedProvider,
                      providers: searchableProviders,
                      isLoading: _isLoadingProviders,
                      onChanged: (value) {
                        _changeSelectedProvider(value);
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
                          kindField,
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
                        SizedBox(width: 150, child: kindField),
                        const SizedBox(width: 12),
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
                  canIngestProvider: _providerSupportsIngest,
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
      final auditLogs = await api.adminAuditLogs(limit: 8);
      final ingestHistory = await api.adminProviderIngestHistory();
      final ingestJobSummary = await api.adminProviderIngestJobSummary();
      final ingestJobQuery = _ingestJobQueryController.text.trim();
      final ingestJobs = await api.adminProviderIngestJobs(
        status: _ingestJobStatusFilter,
        provider: _ingestJobProviderFilter,
        query: ingestJobQuery.isEmpty ? null : ingestJobQuery,
        limit: 8,
      );
      final duplicates = await api.adminDuplicateCandidates(limit: 5);
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _searchStatus = searchStatus;
        _searchHistory = searchHistory;
        _auditLogs = auditLogs;
        _ingestHistory = ingestHistory;
        _ingestJobs = ingestJobs;
        _ingestJobSummary = ingestJobSummary;
        _ingestJobsRefreshedAt = DateTime.now().toUtc();
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

  Future<void> _refreshIngestJobs({bool silent = false}) async {
    if (_isPollingIngestJobs || _isLoadingDashboard) {
      return;
    }
    setState(() {
      _isPollingIngestJobs = true;
      if (!silent) {
        _errorMessage = null;
      }
    });
    try {
      final api = ref.read(apiClientProvider);
      final ingestJobQuery = _ingestJobQueryController.text.trim();
      final results = await Future.wait<Object>([
        api.adminProviderIngestHistory(),
        api.adminProviderIngestJobSummary(),
        api.adminProviderIngestJobs(
          status: _ingestJobStatusFilter,
          provider: _ingestJobProviderFilter,
          query: ingestJobQuery.isEmpty ? null : ingestJobQuery,
          limit: 8,
        ),
      ]);
      final ingestHistory = results[0] as List<AdminProviderIngestHistoryEntry>;
      final ingestJobSummary = results[1] as AdminProviderIngestJobSummary;
      final ingestJobs = results[2] as List<AdminProviderIngestJob>;
      if (!mounted) {
        return;
      }
      setState(() {
        _ingestHistory = ingestHistory;
        _ingestJobSummary = ingestJobSummary;
        _ingestJobs = ingestJobs;
        _ingestJobsRefreshedAt = DateTime.now().toUtc();
        _isPollingIngestJobs = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPollingIngestJobs = false;
        if (!silent) {
          _errorMessage = _adminErrorMessage(error);
        }
      });
    }
  }

  void _restartIngestPolling() {
    _ingestPollTimer?.cancel();
    if (!_autoRefreshIngestJobs) {
      return;
    }
    _ingestPollTimer = Timer.periodic(_ingestPollInterval, (_) {
      if (!_hasPollableIngestJobs ||
          _isPollingIngestJobs ||
          _isLoadingDashboard) {
        return;
      }
      unawaited(_refreshIngestJobs(silent: true));
    });
  }

  bool get _hasPollableIngestJobs {
    final summary = _ingestJobSummary;
    final summaryHasActiveJobs = summary != null &&
        (summary.queued > 0 ||
            summary.running > 0 ||
            summary.dueQueued > 0 ||
            summary.staleRunning > 0);
    return summaryHasActiveJobs ||
        _ingestJobs.any((job) => job.isQueued || job.isRunning);
  }

  void _changeIngestJobAutoRefresh(bool value) {
    setState(() {
      _autoRefreshIngestJobs = value;
    });
    _restartIngestPolling();
  }

  Future<void> _retryIngestHistory(
    AdminProviderIngestHistoryEntry entry,
  ) async {
    setState(() {
      _retryingHistoryId = entry.id;
      _errorMessage = null;
      _statusMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      final result = await ref.read(apiClientProvider).adminRetryProviderIngest(
            historyId: entry.id,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _retryingHistoryId = null;
        _lastIngest = result;
        _statusMessage = result.created
            ? 'Provider ingest retried.'
            : 'Provider item already exists.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _retryingHistoryId = null;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _searchCatalog() async {
    setState(() {
      _isSearchingCatalog = true;
      _catalogStatusMessage = null;
      _catalogErrorMessage = null;
    });
    try {
      final items = await ref.read(apiClientProvider).adminCatalogItems(
            query: _catalogQueryController.text,
            kind: _catalogKindFilter,
            limit: 12,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogItems = items;
        _isSearchingCatalog = false;
        _catalogStatusMessage = items.isEmpty
            ? 'No catalog items found.'
            : '${items.length} catalog items.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSearchingCatalog = false;
        _catalogErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _inspectCatalogItem(AdminMetadataItem item) async {
    setState(() {
      _inspectingItemId = item.id;
      _inspectErrorMessage = null;
    });
    try {
      final fresh = await ref.read(apiClientProvider).adminGetMetadataItem(
            kind: item.kind,
            id: item.id,
          );
      final auditLogs = await ref.read(apiClientProvider).adminAuditLogs(
            entityType: 'item',
            entityId: item.id,
            limit: 8,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = null;
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(fresh, auditLogs);
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

  Future<void> _showCanonicalItemInspectionDialog(
    AdminMetadataItem item,
    List<AdminAuditLogEntry> auditLogs,
  ) async {
    final action = await showDialog<_CanonicalInspectAction>(
      context: context,
      builder: (context) => _CanonicalItemInspectionDialog(
        item: item,
        auditLogs: auditLogs,
      ),
    );
    if (action == null || !mounted) {
      return;
    }
    switch (action) {
      case _CanonicalInspectAction.edit:
        await _showMetadataCorrectionDialog(item);
        await _inspectCatalogItem(item);
      case _CanonicalInspectAction.covers:
        await _showCoverInspectionDialog(item);
        await _inspectCatalogItem(item);
    }
  }

  Future<void> _showMetadataCorrectionDialog(AdminMetadataItem item) async {
    final physicalFormats = physicalMediaFormatsForKind(
      _mediaTypes.isEmpty ? fallbackMediaCatalog : _mediaTypes,
      item.kind,
    );
    final correction = await showDialog<_CatalogCorrection>(
      context: context,
      builder: (context) => _MetadataCorrectionDialog(
        item: item,
        physicalFormats: physicalFormats,
      ),
    );
    if (correction == null || !mounted) {
      return;
    }
    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogStatusMessage = null;
      _catalogErrorMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      final updated = await ref.read(apiClientProvider).adminUpdateCatalogItem(
            kind: item.kind,
            id: item.id,
            title: correction.title,
            itemNumber: correction.itemNumber,
            synopsis: correction.synopsis,
            pageCount: correction.pageCount,
            publisher: correction.publisher,
            releaseDate: correction.releaseDate,
            physicalFormat: correction.physicalFormat,
            variantName: correction.variantName,
            barcode: correction.barcode,
            coverImageUrl: correction.coverImageUrl,
            thumbnailImageUrl: correction.thumbnailImageUrl,
            includeNulls: true,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _lastIngest = null;
        _catalogStatusMessage = 'Metadata correction saved.';
        _catalogItems = [
          for (final row in _catalogItems) row.id == updated.id ? updated : row,
        ];
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _showCoverInspectionDialog(AdminMetadataItem item) async {
    final update = await showDialog<_CoverUpdate>(
      context: context,
      builder: (context) => _CoverInspectionDialog(item: item),
    );
    if (update == null || !mounted) {
      return;
    }
    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogStatusMessage = null;
      _catalogErrorMessage = null;
    });
    try {
      final updated = await ref.read(apiClientProvider).adminUpdateCatalogItem(
            kind: item.kind,
            id: item.id,
            coverImageUrl: update.coverImageUrl,
            thumbnailImageUrl: update.thumbnailImageUrl,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogItems = [
          for (final row in _catalogItems) row.id == updated.id ? updated : row,
        ];
        _catalogStatusMessage = 'Cover URL updated.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _queueCurrentProviderItemId() async {
    final provider = _selectedProvider.trim();
    if (provider.isEmpty ||
        !_providerOptions(forIngest: true).any(
          (option) => option.name == provider,
        )) {
      setState(() {
        _errorMessage = 'Select an ingest provider first.';
        _statusMessage = null;
      });
      return;
    }
    final providerItemId = _jobProviderItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a provider item ID.';
        _statusMessage = null;
      });
      return;
    }
    setState(() {
      _jobActionId = 'new';
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      await ref.read(apiClientProvider).adminCreateProviderIngestJob(
            provider: provider,
            providerItemId: providerItemId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _jobActionId = null;
        _statusMessage = 'Provider ingest job queued.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _jobActionId = null;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _runPendingIngestJobs() async {
    setState(() {
      _isRunningJobs = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .adminRunPendingProviderIngestJobs(limit: 5);
      if (!mounted) {
        return;
      }
      setState(() {
        _isRunningJobs = false;
        _statusMessage = result.recovered > 0
            ? 'Processed ${result.processed} ingest jobs; recovered ${result.recovered} stale jobs.'
            : 'Processed ${result.processed} ingest jobs.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRunningJobs = false;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _runIngestJob(AdminProviderIngestJob job) async {
    await _runSingleIngestJob(job, retry: false);
  }

  Future<void> _retryIngestJob(AdminProviderIngestJob job) async {
    await _runSingleIngestJob(job, retry: true);
  }

  Future<void> _runSingleIngestJob(
    AdminProviderIngestJob job, {
    required bool retry,
  }) async {
    setState(() {
      _jobActionId = job.id;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final updated = retry
          ? await ref
              .read(apiClientProvider)
              .adminRetryProviderIngestJob(jobId: job.id)
          : await ref
              .read(apiClientProvider)
              .adminRunProviderIngestJob(jobId: job.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _jobActionId = null;
        _statusMessage = 'Ingest job ${updated.status}.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _jobActionId = null;
        _errorMessage = _adminErrorMessage(error);
      });
    }
  }

  void _changeIngestJobStatusFilter(String? status) {
    setState(() {
      _ingestJobStatusFilter = status == null || status.isEmpty ? null : status;
    });
    unawaited(_refreshIngestJobs());
  }

  void _changeIngestJobProviderFilter(String? provider) {
    setState(() {
      _ingestJobProviderFilter =
          provider == null || provider.isEmpty ? null : provider;
    });
    unawaited(_refreshIngestJobs());
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
      final auditLogs = await ref.read(apiClientProvider).adminAuditLogs(
            entityType: 'item',
            entityId: itemId,
            limit: 8,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = null;
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(item, auditLogs);
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
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ignore duplicate group?'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DestructiveWarning(
                    icon: Icons.visibility_off_outlined,
                    message:
                        'This hides the duplicate group from admin review. No catalog records are deleted, but the decision is audit logged.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${candidate.itemIds.length} items will be marked as reviewed for ${candidate.displayTitle}.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('Ignore group'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
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
    final selection = await showDialog<_DuplicateMergeSelection>(
      context: context,
      builder: (context) => _DuplicateMergeReviewDialog(candidate: candidate),
    );
    if (selection == null || !mounted || selection.sourceItemIds.isEmpty) {
      return;
    }
    final targetItemId = selection.targetItemId;
    final sourceItemIds = selection.sourceItemIds;
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
        _duplicateStatusMessage =
            'Merged ${result.affectedItems} duplicate items.';
      });
      await _loadDashboard();
      if (result.item != null) {
        await _inspectCatalogItem(result.item!);
      }
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
      final selectableProviders = [
        for (final provider in providers)
          if (provider.supportsSearch || provider.supportsIngest) provider,
      ];
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
        _selectedProvider = _preferredProvider(
          selectableProviders,
          current: _selectedProvider,
        );
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

  Future<void> _loadMediaTypes() async {
    try {
      final mediaTypes = await ref.read(mediaCatalogProvider.future);
      if (!mounted) {
        return;
      }
      setState(() {
        _mediaTypes = mediaTypes;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mediaTypes = const [];
      });
    }
  }

  Future<void> _searchProvider() async {
    final query = _queryController.text.trim();
    final provider = _selectedProvider.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a provider query.';
        _statusMessage = null;
      });
      return;
    }
    if (provider.isEmpty ||
        !_providerOptions().any((option) => option.name == provider)) {
      setState(() {
        _errorMessage = 'Select a searchable provider first.';
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
      final selectedKind = _selectedProviderKind();
      final rows = await ref.read(apiClientProvider).adminProviderSearch(
            provider: provider,
            query: query,
            kind: selectedKind,
          );
      final results = rows
          .map(
            (row) => ProviderCandidate.fromJson(
              row,
              fallbackKind: selectedKind ?? _fallbackProviderKind(),
            ),
          )
          .toList(growable: false);
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
    final provider = _selectedProvider.trim();
    if (provider.isEmpty ||
        !_providerOptions(forIngest: true).any(
          (option) => option.name == provider,
        )) {
      setState(() {
        _errorMessage = 'Select an ingest provider first.';
        _statusMessage = null;
      });
      return;
    }
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a provider item ID.';
        _statusMessage = null;
      });
      return;
    }
    await _ingestProvider(
      provider: provider,
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

  void _changeProviderKindFilter(String? kind) {
    final normalizedKind = kind?.trim();
    final nextKind = normalizedKind == null || normalizedKind.isEmpty
        ? null
        : normalizedKind;
    final options = _providerOptions(kind: nextKind);
    setState(() {
      _selectedProviderKindFilter = nextKind;
      _selectedProvider = _preferredProvider(
        options,
        current: _selectedProvider,
      );
      _results = const [];
      _lastIngest = null;
      _statusMessage = null;
      _errorMessage = null;
    });
  }

  void _changeSelectedProvider(String? value) {
    final provider = value?.trim();
    if (provider == null || provider.isEmpty || provider == _selectedProvider) {
      return;
    }
    setState(() {
      _selectedProvider = provider;
      _results = const [];
      _lastIngest = null;
      _statusMessage = null;
      _errorMessage = null;
    });
  }

  String? _selectedProviderKind() {
    for (final provider in _providers) {
      if (provider.name == _selectedProvider) {
        final filterKind = _selectedProviderKindFilter;
        if (filterKind != null &&
            provider.effectiveKinds.contains(filterKind)) {
          return filterKind;
        }
        return provider.kind;
      }
    }
    return null;
  }

  String _fallbackProviderKind() {
    final catalogOptions = _catalogKindOptions();
    return _selectedProviderKind() ??
        _catalogKindFilter ??
        (catalogOptions.isEmpty ? 'comic' : catalogOptions.first);
  }

  List<String> _catalogKindOptions() {
    final kinds = <String>{
      for (final type in _mediaTypes)
        if (type.isTopLevel && type.kind.isNotEmpty) type.kind,
    };
    for (final provider in _providers) {
      for (final kind in provider.effectiveKinds) {
        if (kind.isNotEmpty) {
          kinds.add(kind);
        }
      }
    }
    final labels = _catalogKindLabels();
    return kinds.toList(growable: false)
      ..sort((left, right) => _compareMediaKinds(left, right, labels));
  }

  List<String> _providerKindOptions({required bool forSearch}) {
    final kinds = <String>{};
    for (final provider in _providers) {
      final supported =
          forSearch ? provider.supportsSearch : provider.supportsIngest;
      if (!supported) {
        continue;
      }
      for (final kind in provider.effectiveKinds) {
        if (kind.isNotEmpty) {
          kinds.add(kind);
        }
      }
    }
    final labels = _catalogKindLabels();
    return kinds.toList(growable: false)
      ..sort((left, right) => _compareMediaKinds(left, right, labels));
  }

  Map<String, String> _catalogKindLabels() {
    return {
      for (final type in _mediaTypes)
        if (type.kind.isNotEmpty) type.kind: _mediaTypeDisplayLabel(type),
    };
  }

  List<AdminProviderStatus> _providerOptions({
    String? kind,
    bool forIngest = false,
  }) {
    final filterKind = kind ?? _selectedProviderKindFilter;
    return [
      for (final provider in _providers)
        if ((forIngest ? provider.supportsIngest : provider.supportsSearch) &&
            (filterKind == null ||
                provider.effectiveKinds.contains(filterKind)))
          provider,
    ];
  }

  String _selectedProviderLabel() {
    for (final provider in _providers) {
      if (provider.name == _selectedProvider) {
        return provider.displayName;
      }
    }
    return _selectedProvider.isEmpty ? 'No provider' : _selectedProvider;
  }

  bool _providerSupportsIngest(String providerName) {
    for (final provider in _providers) {
      if (provider.name == providerName) {
        return provider.supportsIngest;
      }
    }
    return false;
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
    required this.selectedProviderLabel,
    required this.lastIngest,
    required this.errorMessage,
  });

  final AdminCatalogSummary? summary;
  final AdminSearchStatus? searchStatus;
  final AdminSearchReindexResult? lastReindex;
  final int configuredProviders;
  final int registeredProviders;
  final String selectedProviderLabel;
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
          label: selectedProviderLabel,
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
            icon: Icons.image_search_outlined,
            label: summary.coverCoverageLabel,
          ),
          _StatusChip(
            icon: Icons.hub_outlined,
            label: summary.providerCoverageLabel,
          ),
          _StatusChip(
            icon: Icons.image_outlined,
            label: '${summary.missingCoverItems} missing covers',
          ),
          _StatusChip(
            icon: Icons.link_off_outlined,
            label: '${summary.missingProviderLinkItems} missing IDs',
          ),
          _StatusChip(
            icon: Icons.join_inner_outlined,
            label: '${summary.duplicateCandidateGroups} duplicate groups',
          ),
          _StatusChip(
            icon: summary.providerIngestFailures == 0
                ? Icons.download_done_outlined
                : Icons.error_outline,
            label: '${summary.providerIngestFailures} ingest failures',
          ),
          _StatusChip(
            icon: Icons.download_for_offline_outlined,
            label: '${summary.providerIngestSuccesses} ingests ok',
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
    final selected =
        providers.any((provider) => provider.name == value) ? value : null;
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
      hint: Text(isLoading ? 'Loading providers...' : 'Select provider'),
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

class _ProviderKindSelector extends StatelessWidget {
  const _ProviderKindSelector({
    required this.value,
    required this.kinds,
    required this.kindLabels,
    required this.isLoading,
    required this.onChanged,
  });

  final String? value;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kinds.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Media kind',
          prefixIcon: const Icon(Icons.category_outlined),
          border: const OutlineInputBorder(),
          hintText: isLoading ? 'Loading kinds...' : 'No provider kinds',
        ),
      );
    }
    final selected = value != null && kinds.contains(value) ? value! : '';
    return DropdownButtonFormField<String>(
      key: ValueKey('provider-kind-$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Media kind',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('All media', overflow: TextOverflow.ellipsis),
        ),
        for (final kind in kinds)
          DropdownMenuItem(
            value: kind,
            child: Text(_providerKindLabel(kind, kindLabels),
                overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CatalogItemList extends StatelessWidget {
  const _CatalogItemList({
    required this.items,
    required this.inspectingItemId,
    required this.updatingItemId,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
  });

  final List<AdminMetadataItem> items;
  final String? inspectingItemId;
  final String? updatingItemId;
  final ValueChanged<AdminMetadataItem> onInspect;
  final ValueChanged<AdminMetadataItem> onEdit;
  final ValueChanged<AdminMetadataItem> onInspectCovers;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _MessageRow(
        message: 'No catalog results loaded.',
        isError: false,
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return _CatalogItemTile(
          item: item,
          isInspecting: inspectingItemId == item.id,
          isUpdating: updatingItemId == item.id,
          onInspect: () => onInspect(item),
          onEdit: () => onEdit(item),
          onInspectCovers: () => onInspectCovers(item),
        );
      },
    );
  }
}

class _CatalogItemTile extends StatelessWidget {
  const _CatalogItemTile({
    required this.item,
    required this.isInspecting,
    required this.isUpdating,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
  });

  final AdminMetadataItem item;
  final bool isInspecting;
  final bool isUpdating;
  final VoidCallback onInspect;
  final VoidCallback onEdit;
  final VoidCallback onInspectCovers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cover = SizedBox(
              width: 58,
              height: 82,
              child: LibraryCoverImage(
                title: item.title,
                itemNumber: item.itemNumber,
                imageUrl: item.displayCoverUrl,
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: item.kind),
                    _MiniChip(label: 'ID ${_shortId(item.id)}'),
                    if (item.publisher != null)
                      _MiniChip(label: item.publisher!),
                    if (item.barcode != null) _MiniChip(label: item.barcode!),
                    if (item.displayCoverUrl == null)
                      const _MiniChip(label: 'missing cover'),
                  ],
                ),
              ],
            );
            final buttons = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isInspecting || isUpdating ? null : onInspect,
                  icon: isInspecting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                  label: const Text('Inspect'),
                ),
                OutlinedButton.icon(
                  onPressed: isUpdating ? null : onInspectCovers,
                  icon: const Icon(Icons.image_search_outlined),
                  label: const Text('Covers'),
                ),
                FilledButton.tonalIcon(
                  onPressed: isUpdating ? null : onEdit,
                  icon: isUpdating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            );
            if (constraints.maxWidth < 680) {
              return Column(
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
                  buttons,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cover,
                const SizedBox(width: 12),
                Expanded(child: details),
                const SizedBox(width: 12),
                buttons,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProviderIngestJobPanel extends StatelessWidget {
  const _ProviderIngestJobPanel({
    required this.jobs,
    required this.summary,
    required this.autoRefresh,
    required this.isPolling,
    required this.refreshedAt,
    required this.statusFilter,
    required this.providerFilter,
    required this.selectedProvider,
    required this.providers,
    required this.isLoadingProviders,
    required this.providerItemIdController,
    required this.queryController,
    required this.isRunningJobs,
    required this.actionJobId,
    required this.onProviderChanged,
    required this.onAutoRefreshChanged,
    required this.onStatusFilterChanged,
    required this.onProviderFilterChanged,
    required this.onApplyFilters,
    required this.onRefresh,
    required this.onQueueCurrent,
    required this.onRunPending,
    required this.onRun,
    required this.onRetry,
  });

  final List<AdminProviderIngestJob> jobs;
  final AdminProviderIngestJobSummary? summary;
  final bool autoRefresh;
  final bool isPolling;
  final DateTime? refreshedAt;
  final String? statusFilter;
  final String? providerFilter;
  final String selectedProvider;
  final List<AdminProviderStatus> providers;
  final bool isLoadingProviders;
  final TextEditingController providerItemIdController;
  final TextEditingController queryController;
  final bool isRunningJobs;
  final String? actionJobId;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<bool> onAutoRefreshChanged;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String?> onProviderFilterChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onRefresh;
  final VoidCallback onQueueCurrent;
  final VoidCallback onRunPending;
  final ValueChanged<AdminProviderIngestJob> onRun;
  final ValueChanged<AdminProviderIngestJob> onRetry;

  @override
  Widget build(BuildContext context) {
    final filterValue = statusFilter ?? '';
    final providerFilterValue = providerFilter ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null) ...[
          _ProviderIngestJobSummaryBar(summary: summary!),
          const SizedBox(height: 12),
        ],
        _ProviderIngestJobRefreshStrip(
          autoRefresh: autoRefresh,
          isPolling: isPolling,
          refreshedAt: refreshedAt,
          onAutoRefreshChanged: onAutoRefreshChanged,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: filterValue,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status filter',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All jobs')),
                  DropdownMenuItem(value: 'queued', child: Text('Queued')),
                  DropdownMenuItem(value: 'running', child: Text('Running')),
                  DropdownMenuItem(value: 'failed', child: Text('Failed')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: onStatusFilterChanged,
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: providerFilterValue,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Provider filter',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text(
                      'All providers',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final provider in providers)
                    DropdownMenuItem(
                      value: provider.name,
                      child: Text(
                        provider.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onProviderFilterChanged,
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: queryController,
                decoration: const InputDecoration(
                  labelText: 'Job search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onApplyFilters(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onApplyFilters,
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Apply filters'),
            ),
            SizedBox(
              width: 220,
              child: _ProviderSelector(
                value: selectedProvider,
                providers: providers,
                isLoading: isLoadingProviders,
                onChanged: onProviderChanged,
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: providerItemIdController,
                decoration: const InputDecoration(
                  labelText: 'Job provider item ID',
                  prefixIcon: Icon(Icons.tag_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: actionJobId == 'new' ? null : onQueueCurrent,
              icon: actionJobId == 'new'
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_task_outlined),
              label: const Text('Queue current ID'),
            ),
            FilledButton.tonalIcon(
              onPressed: isRunningJobs ? null : onRunPending,
              icon: isRunningJobs
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_play_outlined),
              label: const Text('Run queued'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (jobs.isEmpty)
          const _MessageRow(
            message: 'No persistent ingest jobs for this filter.',
            isError: false,
          )
        else
          for (final job in jobs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProviderIngestJobTile(
                job: job,
                isActing: actionJobId == job.id,
                onRun: () => onRun(job),
                onRetry: () => onRetry(job),
                onRefresh: onRefresh,
              ),
            ),
      ],
    );
  }
}

class _ProviderIngestJobRefreshStrip extends StatelessWidget {
  const _ProviderIngestJobRefreshStrip({
    required this.autoRefresh,
    required this.isPolling,
    required this.refreshedAt,
    required this.onAutoRefreshChanged,
    required this.onRefresh,
  });

  final bool autoRefresh;
  final bool isPolling;
  final DateTime? refreshedAt;
  final ValueChanged<bool> onAutoRefreshChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: autoRefresh,
                  onChanged: onAutoRefreshChanged,
                ),
                const SizedBox(width: 6),
                const Text('Auto refresh'),
              ],
            ),
            _MiniChip(label: autoRefresh ? 'active jobs' : 'manual'),
            if (isPolling)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Refreshing jobs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            if (refreshedAt != null)
              _MiniChip(
                  label: 'Last refreshed ${_formatDateTime(refreshedAt!)}'),
            OutlinedButton.icon(
              onPressed: isPolling ? null : onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh jobs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderIngestJobSummaryBar extends StatelessWidget {
  const _ProviderIngestJobSummaryBar({required this.summary});

  final AdminProviderIngestJobSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          icon: Icons.pending_actions_outlined,
          label: '${summary.queued} queued',
        ),
        _StatusChip(
          icon: Icons.sync_outlined,
          label: '${summary.running} running',
        ),
        _StatusChip(
          icon: Icons.error_outline,
          label: '${summary.failed} failed',
        ),
        _StatusChip(
          icon: Icons.check_circle_outline,
          label: '${summary.done} done',
        ),
        if (summary.dueQueued > 0)
          _StatusChip(
            icon: Icons.timer_outlined,
            label: '${summary.dueQueued} due',
          ),
        if (summary.staleRunning > 0)
          _StatusChip(
            icon: Icons.running_with_errors_outlined,
            label: '${summary.staleRunning} stale',
          ),
        if (summary.nextRunAt != null)
          _StatusChip(
            icon: Icons.schedule_outlined,
            label: 'next ${_formatDateTime(summary.nextRunAt!)}',
          ),
        if (summary.latestFailureAt != null)
          _StatusChip(
            icon: Icons.report_problem_outlined,
            label: 'failed ${_formatDateTime(summary.latestFailureAt!)}',
          ),
      ],
    );
  }
}

class _ProviderIngestJobTile extends StatelessWidget {
  const _ProviderIngestJobTile({
    required this.job,
    required this.isActing,
    required this.onRun,
    required this.onRetry,
    required this.onRefresh,
  });

  final AdminProviderIngestJob job;
  final bool isActing;
  final VoidCallback onRun;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  job.isFailed
                      ? Icons.error_outline
                      : job.isDone
                          ? Icons.check_circle_outline
                          : job.isRunning
                              ? Icons.sync_outlined
                              : Icons.pending_actions_outlined,
                  color: job.isFailed ? colorScheme.error : colorScheme.primary,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    job.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _MiniChip(label: job.status),
                _MiniChip(label: '${job.attempts}/${job.maxAttempts} attempts'),
                if (job.nextRunAt != null)
                  _MiniChip(label: 'next ${_formatDateTime(job.nextRunAt!)}'),
                if (job.itemId != null)
                  _MiniChip(label: 'item ${_shortId(job.itemId!)}'),
                if (job.lastError != null && job.lastError!.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      job.lastError!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => _ProviderIngestJobDetailDialog(
                      job: job,
                      isActing: isActing,
                      onRun: onRun,
                      onRetry: onRetry,
                      onRefresh: onRefresh,
                    ),
                  ),
                  icon: const Icon(Icons.timeline_outlined),
                  label: const Text('Details'),
                ),
                if (job.isQueued)
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onRun,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_outlined),
                    label: const Text('Run'),
                  ),
                if (job.isFailed)
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onRetry,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.replay_outlined),
                    label: const Text('Retry'),
                  ),
              ],
            ),
            if (job.isRunning) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ] else if (job.isQueued && job.nextRunAt != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Waiting until ${_formatDateTime(job.nextRunAt!)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
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

class _ProviderIngestJobDetailDialog extends StatelessWidget {
  const _ProviderIngestJobDetailDialog({
    required this.job,
    required this.isActing,
    required this.onRun,
    required this.onRetry,
    required this.onRefresh,
  });

  final AdminProviderIngestJob job;
  final bool isActing;
  final VoidCallback onRun;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Ingest job: ${job.displayTitle}'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(label: job.status),
                  _MiniChip(
                      label: '${job.attempts}/${job.maxAttempts} attempts'),
                  if (job.itemId != null)
                    _MiniChip(label: 'item ${_shortId(job.itemId!)}'),
                  if (job.nextRunAt != null)
                    _MiniChip(label: 'next ${_formatDateTime(job.nextRunAt!)}'),
                ],
              ),
              const SizedBox(height: 12),
              _IngestTimelineRow(
                icon: Icons.key_outlined,
                label: 'Job ID',
                value: job.id,
              ),
              _IngestTimelineRow(
                icon: Icons.hub_outlined,
                label: 'Provider item',
                value: '${job.provider} ${job.providerItemId}',
              ),
              _IngestTimelineRow(
                icon: Icons.info_outline,
                label: 'Current state',
                value: _ingestJobStateDescription(job),
              ),
              _IngestTimelineRow(
                icon: Icons.replay_circle_filled_outlined,
                label: 'Attempts left',
                value:
                    '${_ingestJobAttemptsRemaining(job)} of ${job.maxAttempts}',
              ),
              _IngestTimelineRow(
                icon: Icons.add_task_outlined,
                label: 'Queued',
                value: _formatDateTime(job.createdAt),
              ),
              _IngestTimelineRow(
                icon: Icons.update_outlined,
                label: 'Last update',
                value: _formatDateTime(job.updatedAt),
              ),
              if (job.nextRunAt != null)
                _IngestTimelineRow(
                  icon: Icons.schedule_outlined,
                  label: 'Backoff / next run',
                  value: _formatDateTime(job.nextRunAt!),
                ),
              if (job.itemId != null)
                _IngestTimelineRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Canonical item',
                  value: job.itemId!,
                ),
              if (job.isFailed)
                const _IngestTimelineRow(
                  icon: Icons.error_outline,
                  label: 'Error queue',
                  value: 'persistent failed job',
                ),
              if (job.lastError != null && job.lastError!.isNotEmpty) ...[
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(job.lastError!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onRefresh();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh list'),
        ),
        if (job.isQueued)
          FilledButton.tonalIcon(
            onPressed: isActing
                ? null
                : () {
                    Navigator.of(context).pop();
                    onRun();
                  },
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Run now'),
          ),
        if (job.isFailed)
          FilledButton.tonalIcon(
            onPressed: isActing
                ? null
                : () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Retry'),
          ),
      ],
    );
  }
}

class _IngestTimelineRow extends StatelessWidget {
  const _IngestTimelineRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _AdminAuditLogList extends StatelessWidget {
  const _AdminAuditLogList({required this.logs});

  final List<AdminAuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const _MessageRow(
        message: 'No admin audit events yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final log in logs.take(8))
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
                    Icon(Icons.manage_history_outlined,
                        color: colorScheme.primary),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        log.action,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _MiniChip(label: log.displayActor),
                    _MiniChip(label: log.displayEntity),
                    _MiniChip(label: _formatDateTime(log.createdAt)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Text(
                        log.detailsSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
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

class _ProviderIngestHistoryList extends StatelessWidget {
  const _ProviderIngestHistoryList({
    required this.history,
    required this.retryingHistoryId,
    required this.onRetry,
  });

  final List<AdminProviderIngestHistoryEntry> history;
  final int? retryingHistoryId;
  final ValueChanged<AdminProviderIngestHistoryEntry> onRetry;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const _MessageRow(
        message: 'No provider ingest attempts yet.',
        isError: false,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(8))
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
                      entry.isFailed
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: entry.isFailed
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        entry.displayTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _MiniChip(label: entry.status),
                    _MiniChip(label: '${entry.attempts} attempts'),
                    _MiniChip(label: _formatDateTime(entry.timestamp)),
                    if (entry.itemId != null)
                      _MiniChip(label: 'item ${_shortId(entry.itemId!)}'),
                    if (entry.error != null && entry.error!.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
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
                    if (entry.isFailed)
                      OutlinedButton.icon(
                        onPressed: retryingHistoryId == entry.id
                            ? null
                            : () => onRetry(entry),
                        icon: retryingHistoryId == entry.id
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.replay_outlined),
                        label: const Text('Retry'),
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
            _MiniChip(label: candidate.reason),
            if (candidate.hasProviderConflicts)
              const _MiniChip(label: 'provider conflict'),
            if (candidate.hasCoverConflicts)
              const _MiniChip(label: 'cover conflict'),
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
                  if (provider.allowsImageMirroring)
                    const _MiniChip(label: 'image mirror ok'),
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
    required this.canIngestProvider,
    required this.onIngest,
  });

  final List<ProviderCandidate> results;
  final String? ingestingProviderItemId;
  final bool Function(String provider) canIngestProvider;
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
          canIngest: canIngestProvider(candidate.provider),
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
    required this.canIngest,
    required this.onIngest,
  });

  final ProviderCandidate candidate;
  final bool isIngesting;
  final bool canIngest;
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
          onPressed: isIngesting || !canIngest ? null : onIngest,
          icon: isIngesting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  canIngest
                      ? Icons.download_for_offline_outlined
                      : Icons.search_outlined,
                ),
          label: Text(canIngest ? 'Ingest' : 'Search only'),
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

enum _CanonicalInspectAction { edit, covers }

class _CanonicalItemInspectionDialog extends StatelessWidget {
  const _CanonicalItemInspectionDialog({
    required this.item,
    required this.auditLogs,
  });

  final AdminMetadataItem item;
  final List<AdminAuditLogEntry> auditLogs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dialogWidth =
        (MediaQuery.sizeOf(context).width - 96).clamp(280.0, 820.0).toDouble();
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.fact_check_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Inspect: ${item.displayTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CanonicalItemSummary(item: item, auditLogs: auditLogs),
              if (auditLogs.isEmpty) ...[
                const SizedBox(height: 12),
                const _MessageRow(
                  message: 'No item audit history yet.',
                  isError: false,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(_CanonicalInspectAction.covers),
          icon: const Icon(Icons.image_search_outlined),
          label: const Text('Covers'),
        ),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(_CanonicalInspectAction.edit),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit metadata'),
        ),
      ],
    );
  }
}

class _CanonicalItemSummary extends StatelessWidget {
  const _CanonicalItemSummary({
    required this.item,
    this.created,
    this.auditLogs = const [],
  });

  final AdminMetadataItem item;
  final bool? created;
  final List<AdminAuditLogEntry> auditLogs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final variant = item.primaryVariant;
    final edition = item.primaryEdition;
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
                    if (edition?.physicalFormatLabel != null)
                      _MiniChip(label: edition!.physicalFormatLabel!),
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
                  _ProviderLinksList(links: item.providerLinks),
                ],
                if (item.editions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AdminItemVariantSummary(item: item),
                ],
                if (auditLogs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ItemAuditTimeline(logs: auditLogs),
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

class _CoverUpdate {
  const _CoverUpdate({
    required this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String coverImageUrl;
  final String? thumbnailImageUrl;
}

class _ProviderLinksList extends StatelessWidget {
  const _ProviderLinksList({required this.links});

  final List<AdminProviderLink> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider links', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        for (final link in links.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MiniChip(label: link.provider),
                _MiniChip(label: link.entityType),
                _MiniChip(label: 'ID ${link.providerItemId}'),
                if (link.siteUrl != null) const _MiniChip(label: 'site URL'),
                if (link.apiUrl != null) const _MiniChip(label: 'api URL'),
                if (link.siteUrl != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SelectableText(
                      link.siteUrl!,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CoverInspectionDialog extends StatefulWidget {
  const _CoverInspectionDialog({required this.item});

  final AdminMetadataItem item;

  @override
  State<_CoverInspectionDialog> createState() => _CoverInspectionDialogState();
}

class _CoverInspectionDialogState extends State<_CoverInspectionDialog> {
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  String? _checkMessage;
  bool _isChecking = false;

  AdminMetadataItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _coverController =
        TextEditingController(text: item.primaryVariant?.coverImageUrl ?? '');
    _thumbnailController = TextEditingController(
      text: item.primaryVariant?.thumbnailImageUrl ?? '',
    );
    _coverController.addListener(_urlFieldsChanged);
    _thumbnailController.addListener(_urlFieldsChanged);
  }

  @override
  void dispose() {
    _coverController.removeListener(_urlFieldsChanged);
    _thumbnailController.removeListener(_urlFieldsChanged);
    _coverController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final variants = [
      for (final edition in item.editions) ...edition.variants,
    ];
    return AlertDialog(
      title: Text('Covers: ${item.displayTitle}'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: LibraryCoverImage(
                        title: item.title,
                        itemNumber: item.itemNumber,
                        imageUrl: item.displayCoverUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: LibraryCoverImage(
                        title: item.title,
                        itemNumber: item.itemNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Generated fallback preview',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Used by the client when the provider has no usable cover URL.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _coverController,
                decoration: const InputDecoration(
                  labelText: 'Replacement cover URL',
                  prefixIcon: Icon(Icons.link_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _thumbnailController,
                decoration: const InputDecoration(
                  labelText: 'Replacement thumbnail URL',
                  prefixIcon: Icon(Icons.image_search_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_checkMessage != null) ...[
                const SizedBox(height: 10),
                _MessageRow(
                  message: _checkMessage!,
                  isError: !_checkMessage!.startsWith('URL is reachable'),
                ),
              ],
              const SizedBox(height: 12),
              if (variants.isEmpty)
                const Text('No variants attached to this item.')
              else
                for (final variant in variants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SelectableText(
                          [
                            if (variant.physicalFormatLabel != null)
                              'format: ${variant.physicalFormatLabel}',
                            if (variant.coverImageUrl != null)
                              'cover: ${variant.coverImageUrl}',
                            if (variant.thumbnailImageUrl != null)
                              'thumb: ${variant.thumbnailImageUrl}',
                            if (variant.coverImageUrl == null &&
                                variant.thumbnailImageUrl == null)
                              'no cover URLs',
                            'status: ${variant.coverStatus}',
                            if (variant.coverStorage != null)
                              'storage: ${variant.coverStorage}',
                            if (variant.coverPolicy != null)
                              'policy: ${variant.coverPolicy}',
                          ].join('\n'),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isChecking ? null : _checkCoverUrl,
          icon: _isChecking
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
          label: const Text('Check URL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: _coverController.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _CoverUpdate(
                      coverImageUrl: _coverController.text.trim(),
                      thumbnailImageUrl:
                          _emptyToNull(_thumbnailController.text),
                    ),
                  ),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Replace URL'),
        ),
      ],
    );
  }

  Future<void> _checkCoverUrl() async {
    final url = _coverController.text.trim();
    if (url.isEmpty) {
      setState(() => _checkMessage = 'Enter a cover URL first.');
      return;
    }
    setState(() {
      _isChecking = true;
      _checkMessage = null;
    });
    try {
      await precacheImage(NetworkImage(url), context);
      if (mounted) {
        setState(() => _checkMessage = 'URL is reachable in this client.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _checkMessage = 'URL check failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _urlFieldsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _AdminItemVariantSummary extends StatelessWidget {
  const _AdminItemVariantSummary({required this.item});

  final AdminMetadataItem item;

  @override
  Widget build(BuildContext context) {
    final variants = [
      for (final edition in item.editions)
        for (final variant in edition.variants)
          _EditionVariantPair(edition: edition, variant: variant),
    ];
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variants and cover status',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pair in variants.take(6))
              _VariantStatusCard(edition: pair.edition, variant: pair.variant),
          ],
        ),
      ],
    );
  }
}

class _EditionVariantPair {
  const _EditionVariantPair({required this.edition, required this.variant});

  final AdminEdition edition;
  final AdminVariant variant;
}

class _VariantStatusCard extends StatelessWidget {
  const _VariantStatusCard({
    required this.edition,
    required this.variant,
  });

  final AdminEdition edition;
  final AdminVariant variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCover = variant.coverImageUrl != null ||
        variant.thumbnailImageUrl != null ||
        variant.coverStatus != 'missing';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    hasCover ? Icons.image_outlined : Icons.hide_image_outlined,
                    size: 18,
                    color: hasCover ? colorScheme.primary : colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      variant.name.isEmpty ? edition.title : variant.name,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: variant.coverStatus),
                  if (variant.coverStorage != null)
                    _MiniChip(label: variant.coverStorage!),
                  if (variant.coverPolicy != null)
                    _MiniChip(label: variant.coverPolicy!),
                  if (variant.physicalFormatLabel != null)
                    _MiniChip(label: variant.physicalFormatLabel!),
                  if (variant.barcode != null)
                    _MiniChip(label: variant.barcode!),
                ],
              ),
              if (variant.coverSourceUrl != null) ...[
                const SizedBox(height: 6),
                Text(
                  variant.coverSourceUrl!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemAuditTimeline extends StatelessWidget {
  const _ItemAuditTimeline({required this.logs});

  final List<AdminAuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item audit history',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        for (final log in logs.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.manage_history_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDateTime(log.createdAt)} - ${log.action} by ${log.displayActor} (${log.detailsSummary})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CatalogCorrection {
  const _CatalogCorrection({
    this.title,
    this.itemNumber,
    this.synopsis,
    this.pageCount,
    this.publisher,
    this.releaseDate,
    this.physicalFormat,
    this.variantName,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String? title;
  final String? itemNumber;
  final String? synopsis;
  final int? pageCount;
  final String? publisher;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? variantName;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
}

class _CorrectionPreviewEntry {
  const _CorrectionPreviewEntry({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}

class _MetadataCorrectionDialog extends StatefulWidget {
  const _MetadataCorrectionDialog({
    required this.item,
    required this.physicalFormats,
  });

  final AdminMetadataItem item;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _itemNumberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late String _physicalFormatId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final variant = widget.item.primaryVariant;
    _titleController = TextEditingController(text: widget.item.title);
    _itemNumberController =
        TextEditingController(text: widget.item.itemNumber ?? '');
    _publisherController =
        TextEditingController(text: widget.item.publisher ?? '');
    _barcodeController = TextEditingController(
      text: widget.item.barcode ?? variant?.barcode ?? '',
    );
    _variantController = TextEditingController(text: variant?.name ?? '');
    _pageCountController = TextEditingController(
      text: widget.item.pageCount?.toString() ?? '',
    );
    _releaseDateController = TextEditingController(
      text: widget.item.coverDate == null
          ? ''
          : _formatDate(widget.item.coverDate!),
    );
    _coverController =
        TextEditingController(text: variant?.coverImageUrl ?? '');
    _thumbnailController =
        TextEditingController(text: variant?.thumbnailImageUrl ?? '');
    _synopsisController =
        TextEditingController(text: widget.item.synopsis ?? '');
    final edition = widget.item.primaryEdition;
    _physicalFormatId = edition?.physicalFormat ??
        physicalMediaFormatById(
          edition?.physicalFormatLabel ?? '',
          formats: widget.physicalFormats,
        )?.id ??
        '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNumberController.dispose();
    _publisherController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _pageCountController.dispose();
    _releaseDateController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit metadata: ${widget.item.displayTitle}'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              _correctionField(_titleController, 'Title'),
              _correctionField(_itemNumberController, 'Item number'),
              _correctionField(_publisherController, 'Publisher'),
              _correctionField(_barcodeController, 'Barcode'),
              _correctionField(_variantController, 'Primary variant'),
              _correctionField(_pageCountController, 'Page count',
                  keyboardType: TextInputType.number),
              _correctionField(_releaseDateController, 'Release date'),
              if (widget.physicalFormats.isNotEmpty) _physicalFormatField(),
              _correctionField(_coverController, 'Cover URL'),
              _correctionField(_thumbnailController, 'Thumbnail URL'),
              _correctionField(
                _synopsisController,
                'Synopsis',
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save correction'),
        ),
      ],
    );
  }

  Widget _correctionField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _physicalFormatField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _physicalFormatId,
        decoration: const InputDecoration(
          labelText: 'Physical format',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('No format selected')),
          for (final format in widget.physicalFormats)
            DropdownMenuItem(value: format.id, child: Text(format.label)),
        ],
        onChanged: (value) {
          setState(() {
            _physicalFormatId = value ?? '';
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _error = 'Title is required.';
      });
      return;
    }
    final currentVariantName = widget.item.primaryVariant?.name.trim();
    if (currentVariantName != null &&
        currentVariantName.isNotEmpty &&
        _variantController.text.trim().isEmpty) {
      setState(() {
        _error = 'Primary variant cannot be cleared yet.';
      });
      return;
    }
    final pageCountText = _pageCountController.text.trim();
    final pageCount =
        pageCountText.isEmpty ? null : int.tryParse(pageCountText);
    if (pageCountText.isNotEmpty && pageCount == null) {
      setState(() {
        _error = 'Page count must be a number.';
      });
      return;
    }
    final releaseDateText = _releaseDateController.text.trim();
    final releaseDate =
        releaseDateText.isEmpty ? null : DateTime.tryParse(releaseDateText);
    if (releaseDateText.isNotEmpty && releaseDate == null) {
      setState(() {
        _error = 'Release date must use YYYY-MM-DD.';
      });
      return;
    }
    final correction = _CatalogCorrection(
      title: _emptyToNull(_titleController.text),
      itemNumber: _emptyToNull(_itemNumberController.text),
      publisher: _emptyToNull(_publisherController.text),
      barcode: _emptyToNull(_barcodeController.text),
      physicalFormat: widget.physicalFormats.isNotEmpty
          ? _emptyToNull(_physicalFormatId)
          : null,
      variantName: _emptyToNull(_variantController.text),
      pageCount: pageCount,
      releaseDate: releaseDate,
      coverImageUrl: _emptyToNull(_coverController.text),
      thumbnailImageUrl: _emptyToNull(_thumbnailController.text),
      synopsis: _emptyToNull(_synopsisController.text),
    );
    final changes = _correctionPreview(correction);
    if (changes.isEmpty) {
      setState(() {
        _error = 'Change at least one metadata field before saving.';
      });
      return;
    }
    final confirmed = await _confirmCorrectionPreview(changes);
    if (!mounted || !confirmed) {
      return;
    }
    Navigator.of(context).pop(correction);
  }

  Future<bool> _confirmCorrectionPreview(
    List<_CorrectionPreviewEntry> changes,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Preview metadata correction'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _DestructiveWarning(
                      icon: Icons.fact_check_outlined,
                      message:
                          'This edits canonical catalog metadata and affects every user who sees this item. Review the diff before saving.',
                    ),
                    const SizedBox(height: 12),
                    for (final change in changes)
                      _CorrectionPreviewRow(change: change),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Back to edit'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save correction'),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<_CorrectionPreviewEntry> _correctionPreview(
    _CatalogCorrection correction,
  ) {
    final item = widget.item;
    final variant = item.primaryVariant;
    final edition = item.primaryEdition;
    final changes = <_CorrectionPreviewEntry>[];
    void add(String label, Object? before, Object? after) {
      final beforeText = _previewValue(before);
      final afterText = _previewValue(after);
      if (beforeText == afterText) {
        return;
      }
      changes.add(
        _CorrectionPreviewEntry(
          label: label,
          before: beforeText,
          after: afterText,
        ),
      );
    }

    add('Title', item.title, correction.title);
    add('Item number', item.itemNumber, correction.itemNumber);
    add('Publisher', item.publisher, correction.publisher);
    add('Barcode', item.barcode ?? variant?.barcode, correction.barcode);
    add('Primary variant', variant?.name, correction.variantName);
    add('Page count', item.pageCount, correction.pageCount);
    add('Release date', item.coverDate, correction.releaseDate);
    if (widget.physicalFormats.isNotEmpty) {
      add('Physical format', edition?.physicalFormat,
          correction.physicalFormat);
    }
    add('Cover URL', variant?.coverImageUrl, correction.coverImageUrl);
    add(
      'Thumbnail URL',
      variant?.thumbnailImageUrl,
      correction.thumbnailImageUrl,
    );
    add('Synopsis', item.synopsis, correction.synopsis);
    return changes;
  }

  String _previewValue(Object? value) {
    if (value == null) {
      return '(empty)';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '(empty)' : text;
  }
}

class _DuplicateMergeSelection {
  const _DuplicateMergeSelection({
    required this.targetItemId,
    required this.sourceItemIds,
  });

  final String targetItemId;
  final List<String> sourceItemIds;
}

class _DuplicateMergeReviewDialog extends StatefulWidget {
  const _DuplicateMergeReviewDialog({required this.candidate});

  final AdminDuplicateCandidate candidate;

  @override
  State<_DuplicateMergeReviewDialog> createState() =>
      _DuplicateMergeReviewDialogState();
}

class _DuplicateMergeReviewDialogState
    extends State<_DuplicateMergeReviewDialog> {
  late String _targetItemId;
  late Set<String> _sourceItemIds;
  late final TextEditingController _confirmController;
  bool _typedConfirmationMatches = false;

  @override
  void initState() {
    super.initState();
    _targetItemId = widget.candidate.itemIds.first;
    _sourceItemIds = widget.candidate.itemIds.skip(1).toSet();
    _confirmController = TextEditingController()
      ..addListener(() {
        final matches = _confirmController.text.trim() == 'MERGE';
        if (matches != _typedConfirmationMatches) {
          setState(() {
            _typedConfirmationMatches = matches;
          });
        }
      });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    return AlertDialog(
      title: Text('Merge review: ${candidate.displayTitle}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: candidate.reason),
                  if (candidate.hasProviderConflicts)
                    const _MiniChip(label: 'provider conflict'),
                  if (candidate.hasCoverConflicts)
                    const _MiniChip(label: 'cover conflict'),
                ],
              ),
              const SizedBox(height: 12),
              const _DestructiveWarning(
                icon: Icons.warning_amber_outlined,
                message:
                    'This moves provider links, editions, variants, relationships, and admin history onto the selected target. Source catalog records are removed after merge.',
              ),
              const SizedBox(height: 12),
              for (final itemId in candidate.itemIds)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _sourceItemIds.contains(itemId),
                  enabled: itemId != _targetItemId,
                  title: Text('Source ${_shortId(itemId)}'),
                  subtitle: itemId == _targetItemId
                      ? const Text('Merge target')
                      : null,
                  secondary: IconButton(
                    tooltip: 'Set merge target',
                    onPressed: () {
                      setState(() {
                        _targetItemId = itemId;
                        _sourceItemIds = candidate.itemIds
                            .where((id) => id != itemId)
                            .toSet();
                      });
                    },
                    icon: Icon(
                      itemId == _targetItemId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                  ),
                  onChanged: itemId == _targetItemId
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              _sourceItemIds.add(itemId);
                            } else {
                              _sourceItemIds.remove(itemId);
                            }
                          });
                        },
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Type MERGE to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _sourceItemIds.isEmpty || !_typedConfirmationMatches
              ? null
              : () => Navigator.of(context).pop(
                    _DuplicateMergeSelection(
                      targetItemId: _targetItemId,
                      sourceItemIds: _sourceItemIds.toList(growable: false),
                    ),
                  ),
          icon: const Icon(Icons.merge_type_outlined),
          label: const Text('Merge selected'),
        ),
      ],
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

class _DestructiveWarning extends StatelessWidget {
  const _DestructiveWarning({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.34),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _CorrectionPreviewRow extends StatelessWidget {
  const _CorrectionPreviewRow({required this.change});

  final _CorrectionPreviewEntry change;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                change.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text('Before: ${change.before}'),
              Text('After: ${change.after}'),
            ],
          ),
        ),
      ),
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

String _providerKindLabel(String kind, Map<String, String> labels) {
  final label = labels[kind];
  if (label != null && label.isNotEmpty) {
    return label;
  }
  return switch (kind) {
    'bluray' => 'Blu-ray',
    'boardgame' => 'Board game',
    'tv' => 'TV',
    _ => kind.isEmpty ? kind : '${kind[0].toUpperCase()}${kind.substring(1)}',
  };
}

String _mediaTypeDisplayLabel(CatalogMediaType type) {
  if (type.kind == 'tv') {
    return 'TV';
  }
  return type.pluralLabel.isNotEmpty ? type.pluralLabel : type.kind;
}

int _compareMediaKinds(String left, String right, Map<String, String> labels) {
  return _providerKindLabel(left, labels).compareTo(
    _providerKindLabel(right, labels),
  );
}

String _preferredProvider(
  List<AdminProviderStatus> providers, {
  required String current,
}) {
  if (current.isNotEmpty &&
      providers.any((provider) => provider.name == current)) {
    return current;
  }
  AdminProviderStatus? best;
  for (final provider in providers) {
    if (provider.isConfigured &&
        provider.supportsSearch &&
        provider.supportsIngest) {
      best = provider;
      break;
    }
  }
  best ??= _firstWhereOrNull(providers, (provider) => provider.isConfigured);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsIngest);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsSearch);
  best ??= providers.isEmpty ? null : providers.first;
  return best?.name ?? '';
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
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

int _ingestJobAttemptsRemaining(AdminProviderIngestJob job) {
  final remaining = job.maxAttempts - job.attempts;
  return remaining < 0 ? 0 : remaining;
}

String _ingestJobStateDescription(AdminProviderIngestJob job) {
  return job.status.replaceAll('_', ' ');
}

String _formatMoney(int cents, String? currency) {
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null || currency.isEmpty ? amount : '$amount $currency';
}

String? _emptyToNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
