import 'dart:async';

import 'package:collectarr_app/features/admin/admin_image_cache_panel.dart';
import 'package:collectarr_app/features/admin/admin_users_panel.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'admin_item_inspection.dart';
part 'admin_metadata_correction_dialog.dart';
part 'admin_duplicate_merge_dialog.dart';
part 'admin_bundle_correction_dialog.dart';

const _kAdminDropdownColor = kAppPanelRaised;
const _kAdminDialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(3)),
);

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
  var _proposalHistory = const <AdminAuditLogEntry>[];
  var _ingestHistory = const <AdminProviderIngestHistoryEntry>[];
  var _ingestJobs = const <AdminProviderIngestJob>[];
  var _proposals = const <AdminMetadataProposal>[];
  AdminProviderIngestJobSummary? _ingestJobSummary;
  AdminMetadataProposalSummary? _dashboardProposalSummary;
  AdminMetadataProposalSummary? _proposalSummary;
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
  String _proposalStatusFilter = 'pending';
  String? _proposalProviderFilter;
  AdminProviderIngestResult? _lastIngest;
  String? _statusMessage;
  String? _errorMessage;
  String? _dashboardErrorMessage;
  String? _catalogStatusMessage;
  String? _catalogErrorMessage;
  String? _inspectErrorMessage;
  String? _duplicateStatusMessage;
  String? _duplicateErrorMessage;
  String? _proposalStatusMessage;
  String? _proposalErrorMessage;
  bool _isLoadingDashboard = false;
  bool _isReindexing = false;
  bool _isLoadingProviders = false;
  bool _isSearchingCatalog = false;
  bool _hasSearchedCatalog = false;
  bool _isRunningJobs = false;
  bool _isPollingIngestJobs = false;
  bool _autoRefreshIngestJobs = true;
  bool _isSearching = false;
  bool _isDirectIngesting = false;
  bool _isLoadingProposals = false;
  String? _inspectingItemId;
  String? _updatingCatalogItemId;
  String? _duplicateActionItemId;
  String? _ingestingProviderItemId;
  String? _jobActionId;
  String? _proposalActionId;
  String? _activeProposalId;
  String? _activeProposalTitle;
  int? _retryingHistoryId;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadMediaTypes();
    _loadProviders();
    _loadProposalData();
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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          surfaceTintColor: Colors.transparent,
          flexibleSpace: LibraryAccentChrome(
            accent: accent,
            animationDuration: animationDuration,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Catalog'),
              Tab(icon: Icon(Icons.hub_outlined), text: 'Providers'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Logs'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'System'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ─── Dashboard ───
            ListView(
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
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.manage_search_outlined),
                      ),
                      IconButton(
                        tooltip: 'Refresh dashboard',
                        onPressed:
                            _isLoadingDashboard ? null : _loadDashboard,
                        icon: _isLoadingDashboard
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
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
                  icon: Icons.pending_actions_outlined,
                  title: 'Metadata proposal activity',
                  child: _DashboardProposalActivity(
                    summary: _dashboardProposalSummary,
                    history: _proposalHistory,
                    errorMessage: _dashboardErrorMessage,
                  ),
                ),
              ],
            ),
            // ─── Catalog ───
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AdminPanel(
                  icon: Icons.inventory_2_outlined,
                  title: 'Catalog search',
                  trailing: IconButton(
                    tooltip: 'Search catalog',
                    onPressed:
                        _isSearchingCatalog ? null : _searchCatalog,
                    icon: _isSearchingCatalog
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
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
                                    value == null || value.isEmpty
                                        ? null
                                        : value;
                              });
                            },
                          );
                          final queryField = TextField(
                            controller: _catalogQueryController,
                            decoration: const InputDecoration(
                              labelText: 'Find catalog items',
                              hintText: 'Search by title, number, or provider ID',
                              prefixIcon:
                                  Icon(Icons.manage_search_outlined),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _searchCatalog(),
                          );
                          final searchButton = FilledButton.icon(
                            onPressed: _isSearchingCatalog
                                ? null
                                : _searchCatalog,
                            icon: _isSearchingCatalog
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            label: const Text('Search'),
                          );
                          if (constraints.maxWidth < 640) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 180, child: kindField),
                              const SizedBox(width: 12),
                              Expanded(child: queryField),
                              const SizedBox(width: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4),
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
                          message: _catalogErrorMessage ??
                              _catalogStatusMessage!,
                          isError: _catalogErrorMessage != null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _CatalogItemList(
                        items: _catalogItems,
                        hasSearched: _hasSearchedCatalog,
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
                  icon: Icons.join_inner_outlined,
                  title: 'Duplicate candidates',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_duplicateStatusMessage != null ||
                          _duplicateErrorMessage != null) ...[
                        _MessageRow(
                          message: _duplicateErrorMessage ??
                              _duplicateStatusMessage!,
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
                if (_lastIngest != null ||
                    _inspectErrorMessage != null) ...[
                  const SizedBox(height: 12),
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
                ],
              ],
            ),
            // ─── Providers ───
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AdminPanel(
                  icon: Icons.hub_outlined,
                  title: 'Provider status',
                  trailing: IconButton(
                    tooltip: 'Refresh providers',
                    onPressed:
                        _isLoadingProviders ? null : _loadProviders,
                    icon: _isLoadingProviders
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                  child: _ProviderStatusList(providers: _providers),
                ),
                const SizedBox(height: 12),
                _AdminPanel(
                  icon: Icons.pending_actions_outlined,
                  title: 'Metadata proposals',
                  trailing: IconButton(
                    tooltip: 'Refresh proposals',
                    onPressed: _isLoadingProposals ? null : _loadProposalData,
                    icon: _isLoadingProposals
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                  child: _MetadataProposalPanel(
                    summary: _proposalSummary,
                    proposals: _proposals,
                    statusFilter: _proposalStatusFilter,
                    providerFilter: _proposalProviderFilter,
                    providers: _providers,
                    isLoading: _isLoadingProposals,
                    actingProposalId: _proposalActionId,
                    activeProposalTitle: _activeProposalTitle,
                    statusMessage: _proposalStatusMessage,
                    errorMessage: _proposalErrorMessage,
                    onStatusChanged: _changeProposalStatusFilter,
                    onProviderChanged: _changeProposalProviderFilter,
                    onReview: _reviewProposal,
                    onApprove: _approveProposal,
                    onApproveLinked: _approveProposalWithLinkedItem,
                    onReject: _rejectProposal,
                    onClearReview: _clearActiveProposal,
                    canApproveLinkedItem: _providerSupportsIngest,
                  ),
                ),
                const SizedBox(height: 12),
                _AdminPanel(
                  icon: Icons.travel_explore_outlined,
                  title: 'Add from provider',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose a category first, then open the guided add dialog to search a provider or ingest a known provider ID. Search results and proposal review stay below.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedProviderKindFilter != null)
                            _MiniChip(
                              label: _providerKindLabel(
                                _selectedProviderKindFilter!,
                                _catalogKindLabels(),
                              ),
                            ),
                          if (_selectedProvider.isNotEmpty)
                            _MiniChip(label: _selectedProviderLabel()),
                          if (_activeProposalTitle != null)
                            _MiniChip(label: 'Reviewing $_activeProposalTitle'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _isLoadingProviders ||
                                    _isSearching ||
                                    _isDirectIngesting
                                ? null
                                : _showProviderAddDialog,
                            icon: _isSearching || _isDirectIngesting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_circle_outline),
                            label: const Text('Open add dialog'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _results.isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      _results = const <ProviderCandidate>[];
                                      _statusMessage = null;
                                      _errorMessage = null;
                                    });
                                  },
                            icon: const Icon(Icons.layers_clear_outlined),
                            label: const Text('Clear results'),
                          ),
                        ],
                      ),
                      if (_statusMessage != null ||
                          _errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _MessageRow(
                          message:
                              _errorMessage ?? _statusMessage!,
                          isError: _errorMessage != null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ProviderResultsList(
                        results: _results,
                        ingestingProviderItemId:
                            _ingestingProviderItemId,
                        canIngestProvider:
                            _providerSupportsIngest,
                        activeProposalId: _activeProposalId,
                        activeProposalTitle: _activeProposalTitle,
                        onApproveProposal: _approveProposalWithCandidate,
                        onIngest: _ingestProviderItem,
                      ),
                    ],
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
                        : () =>
                            unawaited(_refreshIngestJobs()),
                    icon: _isPollingIngestJobs
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
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
                    providers:
                        _providerOptions(forIngest: true),
                    isLoadingProviders: _isLoadingProviders,
                    providerItemIdController:
                        _jobProviderItemIdController,
                    queryController:
                        _ingestJobQueryController,
                    isRunningJobs: _isRunningJobs,
                    actionJobId: _jobActionId,
                    onProviderChanged:
                        _changeSelectedProvider,
                    onAutoRefreshChanged:
                        _changeIngestJobAutoRefresh,
                    onStatusFilterChanged:
                        _changeIngestJobStatusFilter,
                    onProviderFilterChanged:
                        _changeIngestJobProviderFilter,
                    onApplyFilters: () =>
                        unawaited(_refreshIngestJobs()),
                    onRefresh: () =>
                        unawaited(_refreshIngestJobs()),
                    onQueueCurrent:
                        _queueCurrentProviderItemId,
                    onRunPending: _runPendingIngestJobs,
                    onRun: _runIngestJob,
                    onRetry: _retryIngestJob,
                  ),
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
              ],
            ),
            // ─── Logs ───
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AdminPanel(
                  icon: Icons.history_outlined,
                  title: 'Search index history',
                  child:
                      _SearchHistoryList(history: _searchHistory),
                ),
                const SizedBox(height: 12),
                _AdminPanel(
                  icon: Icons.manage_history_outlined,
                  title: 'Admin audit log',
                  child: _AdminAuditLogList(logs: _auditLogs),
                ),
              ],
            ),
            // ─── System ───
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AdminPanel(
                  icon: Icons.account_tree_outlined,
                  title: 'Collection schema',
                  child: CollectionSchemaManagementPanel(
                    db: ref.read(localDatabaseProvider),
                  ),
                ),
                const SizedBox(height: 12),
                _AdminPanel(
                  icon: Icons.people_outline,
                  title: 'User management',
                  child: const AdminUsersPanel(),
                ),
                const SizedBox(height: 12),
                _AdminPanel(
                  icon: Icons.image_outlined,
                  title: 'Image cache',
                  child: const AdminImageCachePanel(),
                ),
              ],
            ),
          ],
        ),
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
      final ingestJobQuery = _ingestJobQueryController.text.trim();
      final results = await Future.wait<Object>([
        api.adminCatalogSummary(),
        api.adminSearchStatus(),
        api.adminSearchHistory(),
        api.adminAuditLogs(limit: 8),
        api.adminMetadataProposalSummary(),
        api.adminAuditLogs(entityType: 'metadata_proposal', limit: 6),
        api.adminProviderIngestHistory(),
        api.adminProviderIngestJobSummary(),
        api.adminProviderIngestJobs(
          status: _ingestJobStatusFilter,
          provider: _ingestJobProviderFilter,
          query: ingestJobQuery.isEmpty ? null : ingestJobQuery,
          limit: 8,
        ),
        api.adminDuplicateCandidates(limit: 5),
      ]);
      final summary = results[0] as AdminCatalogSummary;
      final searchStatus = results[1] as AdminSearchStatus;
      final searchHistory = results[2] as List<AdminSearchHistoryEntry>;
      final auditLogs = results[3] as List<AdminAuditLogEntry>;
      final proposalSummary = results[4] as AdminMetadataProposalSummary;
      final proposalHistory = results[5] as List<AdminAuditLogEntry>;
      final ingestHistory = results[6] as List<AdminProviderIngestHistoryEntry>;
      final ingestJobSummary = results[7] as AdminProviderIngestJobSummary;
      final ingestJobs = results[8] as List<AdminProviderIngestJob>;
      final duplicates = results[9] as List<AdminDuplicateCandidate>;
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _searchStatus = searchStatus;
        _searchHistory = searchHistory;
        _auditLogs = auditLogs;
        _dashboardProposalSummary = proposalSummary;
        _proposalHistory = proposalHistory;
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

  Future<void> _loadProposalData() async {
    setState(() {
      _isLoadingProposals = true;
      _proposalErrorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final results = await Future.wait<Object>([
        api.adminMetadataProposalSummary(),
        api.adminMetadataProposals(
          status: _proposalStatusFilter,
          provider: _proposalProviderFilter,
        ),
      ]);
      final summary = results[0] as AdminMetadataProposalSummary;
      final proposals = results[1] as List<AdminMetadataProposal>;
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalSummary = summary;
        _proposals = proposals;
        _isLoadingProposals = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingProposals = false;
        _proposalErrorMessage = _adminErrorMessage(error);
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
    final query = _catalogQueryController.text.trim();
    final kind = _catalogKindFilter;
    if (query.isEmpty && (kind == null || kind.isEmpty)) {
      setState(() {
        _catalogItems = const <AdminMetadataItem>[];
        _hasSearchedCatalog = false;
        _isSearchingCatalog = false;
        _catalogErrorMessage = null;
        _catalogStatusMessage =
            'Enter a title or choose a category before searching the catalog.';
      });
      return;
    }
    setState(() {
      _isSearchingCatalog = true;
      _hasSearchedCatalog = true;
      _catalogStatusMessage = null;
      _catalogErrorMessage = null;
    });
    try {
      final items = await ref.read(apiClientProvider).adminCatalogItems(
            query: query,
            kind: kind,
            limit: 12,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogItems = items;
        _isSearchingCatalog = false;
        _catalogStatusMessage = items.isEmpty
            ? 'No catalog items matched the current search.'
            : '${items.length} catalog items found.';
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
      final api = ref.read(apiClientProvider);
      final fresh = await api.adminGetMetadataItem(
        kind: item.kind,
        id: item.id,
      );
      final auditLogs = await api.adminAuditLogs(
        entityType: 'item',
        entityId: item.id,
        limit: 8,
      );
      final bundleReleases = await api.getItemBundleReleases(item.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = null;
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(fresh, auditLogs, bundleReleases);
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
    List<BundleReleaseSummary> bundleReleases,
  ) async {
    final result = await showDialog<_CanonicalInspectResult>(
      context: context,
      builder: (context) => _CanonicalItemInspectionDialog(
        item: item,
        auditLogs: auditLogs,
        bundleReleases: bundleReleases,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    if (result.bundleReleaseId != null) {
      await _showBundleCorrectionDialog(result.bundleReleaseId!);
      await _inspectCatalogItem(item);
      return;
    }
    switch (result.action) {
      case _CanonicalInspectAction.edit:
        await _showMetadataCorrectionDialog(item);
        await _inspectCatalogItem(item);
      case _CanonicalInspectAction.covers:
        await _showCoverInspectionDialog(item);
        await _inspectCatalogItem(item);
      case null:
        return;
    }
  }

  Future<void> _showBundleCorrectionDialog(String bundleReleaseId) async {
    try {
      final api = ref.read(apiClientProvider);
      final bundle = await api.getBundleRelease(bundleReleaseId);
      if (!mounted) {
        return;
      }
      final correction = await showDialog<AdminBundleReleaseCorrection>(
        context: context,
        builder: (context) => _BundleReleaseCorrectionDialog(bundle: bundle),
      );
      if (correction == null || !mounted) {
        return;
      }
      setState(() {
        _catalogStatusMessage = null;
        _catalogErrorMessage = null;
      });
      await api.adminUpdateBundleRelease(
        bundleReleaseId: bundleReleaseId,
        correction: correction,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogStatusMessage = 'Bundle release correction saved.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogErrorMessage = _adminErrorMessage(error);
      });
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
    final explicitFields = _catalogCorrectionExplicitFields(item, correction);
    final originalSeriesTags = _normalizedAdminTags(item.series?.tags);
    final editedSeriesTags = _normalizedAdminTags(correction.seriesTags);
    final seriesTagsChanged = !listEquals(originalSeriesTags, editedSeriesTags);
    if (explicitFields.isEmpty && !seriesTagsChanged) {
      setState(() {
        _catalogErrorMessage =
            'Change at least one persisted metadata field before saving.';
      });
      return;
    }
    final confirmed = await _confirmMetadataCorrectionPreview(
      _catalogCorrectionPreview(item, correction),
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogStatusMessage = null;
      _catalogErrorMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      AdminMetadataItem? updated;
      if (explicitFields.isNotEmpty) {
        updated = await ref.read(apiClientProvider).adminUpdateCatalogItem(
              kind: item.kind,
              id: item.id,
              title: correction.title,
              itemNumber: correction.itemNumber,
              synopsis: correction.synopsis,
              editionTitle: correction.editionTitle,
              pageCount: correction.pageCount,
              runtimeMinutes: correction.runtimeMinutes,
              publisher: correction.publisher,
              releaseDate: correction.releaseDate,
              imprint: correction.imprint,
              subtitle: correction.subtitle,
              seriesGroup: correction.seriesGroup,
              country: correction.country,
              language: correction.language,
              ageRating: correction.ageRating,
              catalogNumber: correction.catalogNumber,
              releaseStatus: correction.releaseStatus,
              physicalFormat: correction.physicalFormat,
              variantName: correction.variantName,
              barcode: correction.barcode,
              coverImageUrl: correction.coverImageUrl,
              thumbnailImageUrl: correction.thumbnailImageUrl,
              explicitFields: explicitFields,
            );
      }
      if (seriesTagsChanged) {
        final seriesId = item.series?.seriesId;
        if (seriesId == null || seriesId.isEmpty) {
          throw StateError(
            'This item has no series id, so series tags cannot be saved.',
          );
        }
        await ref.read(apiClientProvider).adminUpdateSeriesTags(
              seriesId: seriesId,
              tags: editedSeriesTags,
            );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _lastIngest = null;
        _catalogStatusMessage = 'Metadata correction saved.';
        if (updated != null) {
          _catalogItems = [
            for (final row in _catalogItems)
              row.id == updated.id ? updated : row,
          ];
        }
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

  Set<String> _catalogCorrectionExplicitFields(
    AdminMetadataItem item,
    _CatalogCorrection correction,
  ) {
    final edition = item.primaryEdition;
    final variant = item.primaryVariant;
    final fields = <String>{};
    void addField(String key, Object? before, Object? after) {
      if (before != after) {
        fields.add(key);
      }
    }

    addField('title', item.title, correction.title);
    addField('item_number', item.itemNumber, correction.itemNumber);
    addField('synopsis', item.synopsis, correction.synopsis);
    addField('edition_title', edition?.title, correction.editionTitle);
    addField('page_count', item.publishing?.pageCount, correction.pageCount);
    addField('runtime_minutes', item.video?.runtimeMinutes, correction.runtimeMinutes);
    addField(
      'publisher',
      edition?.publisher ?? item.publisher,
      correction.publisher,
    );
    addField('release_date', edition?.releaseDate ?? item.coverDate, correction.releaseDate);
    addField('imprint', item.publishing?.imprint, correction.imprint);
    addField('subtitle', item.publishing?.subtitle, correction.subtitle);
    addField('series_group', item.publishing?.seriesGroup, correction.seriesGroup);
    addField('country', item.country, correction.country);
    addField('language', item.language, correction.language);
    addField('age_rating', item.ageRating, correction.ageRating);
    addField('catalog_number', item.music?.catalogNumber, correction.catalogNumber);
    addField('release_status', item.music?.releaseStatus, correction.releaseStatus);
    if (correction.physicalFormat != null &&
        edition?.physicalFormat != correction.physicalFormat) {
      fields.add('physical_format');
    }
    addField('variant_name', variant?.name, correction.variantName);
    addField('barcode', variant?.barcode ?? item.barcode, correction.barcode);
    addField('cover_image_url', variant?.coverImageUrl, correction.coverImageUrl);
    addField(
      'thumbnail_image_url',
      variant?.thumbnailImageUrl,
      correction.thumbnailImageUrl,
    );
    return fields;
  }

  List<_CorrectionPreviewEntry> _catalogCorrectionPreview(
    AdminMetadataItem item,
    _CatalogCorrection correction,
  ) {
    final edition = item.primaryEdition;
    final variant = item.primaryVariant;
    final changes = <_CorrectionPreviewEntry>[];

    void add(String label, Object? before, Object? after) {
      final beforeText = _previewCorrectionValue(before);
      final afterText = _previewCorrectionValue(after);
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
    add('Publisher', edition?.publisher ?? item.publisher, correction.publisher);
    add('Edition title', edition?.title, correction.editionTitle);
    add('Barcode', variant?.barcode ?? item.barcode, correction.barcode);
    add('Primary variant', variant?.name, correction.variantName);
    add('Page count', item.publishing?.pageCount, correction.pageCount);
    add('Runtime', item.video?.runtimeMinutes, correction.runtimeMinutes);
    add('Release date', edition?.releaseDate ?? item.coverDate, correction.releaseDate);
    add('Imprint', item.publishing?.imprint, correction.imprint);
    add('Subtitle', item.publishing?.subtitle, correction.subtitle);
    add('Series group', item.publishing?.seriesGroup, correction.seriesGroup);
    add('Country', item.country, correction.country);
    add('Language', item.language, correction.language);
    add('Age rating', item.ageRating, correction.ageRating);
    add('Catalog number', item.music?.catalogNumber, correction.catalogNumber);
    add('Release status', item.music?.releaseStatus, correction.releaseStatus);
    add('Physical format', edition?.physicalFormat, correction.physicalFormat);
    add('Cover URL', variant?.coverImageUrl, correction.coverImageUrl);
    add('Thumbnail URL', variant?.thumbnailImageUrl, correction.thumbnailImageUrl);
    add('Synopsis', item.synopsis, correction.synopsis);
    add(
      'Series tags',
      _normalizedAdminTags(item.series?.tags).join(', '),
      _normalizedAdminTags(correction.seriesTags).join(', '),
    );
    return changes;
  }

  List<String> _normalizedAdminTags(List<String>? tags) {
    return (tags ?? const <String>[])
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Future<bool> _confirmMetadataCorrectionPreview(
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

  String _previewCorrectionValue(Object? value) {
    if (value == null) {
      return '(empty)';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '(empty)' : text;
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
      final bundleReleases =
          await ref.read(apiClientProvider).getItemBundleReleases(itemId);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = null;
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(item, auditLogs, bundleReleases);
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

  Future<void> _approveProposal(AdminMetadataProposal proposal) async {
    setState(() {
      _proposalActionId = proposal.id;
      _proposalErrorMessage = null;
      _proposalStatusMessage = null;
    });
    try {
      final result = await ref.read(apiClientProvider).adminApproveMetadataProposal(
            proposalId: proposal.id,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _lastIngest = result;
        _proposalStatusMessage = 'Proposal approved and ingested.';
        if (_activeProposalId == proposal.id) {
          _activeProposalId = null;
          _activeProposalTitle = null;
        }
      });
      await _loadProposalData();
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _proposalErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _approveProposalWithLinkedItem(
    AdminMetadataProposal proposal,
  ) async {
    final providerItemId = proposal.providerItemId?.trim();
    if (providerItemId == null || providerItemId.isEmpty) {
      return;
    }
    await _approveProposalWithProviderItem(
      proposalId: proposal.id,
      provider: proposal.provider,
      providerItemId: providerItemId,
      successMessage: 'Proposal approved with linked provider item.',
    );
  }

  Future<void> _approveProposalWithCandidate(ProviderCandidate candidate) async {
    final proposalId = _activeProposalId;
    if (proposalId == null || proposalId.isEmpty) {
      return;
    }
    await _approveProposalWithProviderItem(
      proposalId: proposalId,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      kind: candidate.kind,
      successMessage: 'Proposal approved with selected provider item.',
    );
  }

  Future<void> _approveProposalWithProviderItem({
    required String proposalId,
    required String provider,
    required String providerItemId,
    String? kind,
    required String successMessage,
  }) async {
    setState(() {
      _proposalActionId = proposalId;
      _ingestingProviderItemId = providerItemId;
      _proposalErrorMessage = null;
      _proposalStatusMessage = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .adminApproveMetadataProposalWithProviderItem(
            proposalId: proposalId,
            provider: provider,
            providerItemId: providerItemId,
            kind: kind,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _ingestingProviderItemId = null;
        _lastIngest = result;
        _proposalStatusMessage = successMessage;
        if (_activeProposalId == proposalId) {
          _activeProposalId = null;
          _activeProposalTitle = null;
        }
      });
      await _loadProposalData();
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _ingestingProviderItemId = null;
        _proposalErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _rejectProposal(AdminMetadataProposal proposal) async {
    setState(() {
      _proposalActionId = proposal.id;
      _proposalErrorMessage = null;
      _proposalStatusMessage = null;
    });
    try {
      await ref.read(apiClientProvider).adminRejectMetadataProposal(
            proposalId: proposal.id,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _proposalStatusMessage = 'Proposal rejected.';
        if (_activeProposalId == proposal.id) {
          _activeProposalId = null;
          _activeProposalTitle = null;
        }
      });
      await _loadProposalData();
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _proposalErrorMessage = _adminErrorMessage(error);
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
      kind: candidate.kind,
    );
  }

  Future<void> _ingestProvider({
    required String provider,
    required String providerItemId,
    String? kind,
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
            kind: kind ?? _selectedProviderKind(),
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

  Future<void> _showProviderAddDialog() async {
    final request = await showDialog<_ProviderAddRequest>(
      context: context,
      builder: (context) => _ProviderAddDialog(
        providers: _providers,
        kinds: _providerKindOptions(forSearch: true),
        kindLabels: _catalogKindLabels(),
        initialKind: _selectedProviderKindFilter,
        initialProvider: _selectedProvider,
        initialQuery: _queryController.text,
        initialProviderItemId: _providerItemIdController.text,
      ),
    );
    if (request == null || !mounted) {
      return;
    }
    setState(() {
      _selectedProviderKindFilter = request.kind;
      _selectedProvider = request.provider;
      _queryController.text = request.query ?? '';
      _providerItemIdController.text = request.providerItemId ?? '';
      _errorMessage = null;
      _statusMessage = null;
    });
    switch (request.mode) {
      case _ProviderAddMode.search:
        await _searchProvider();
      case _ProviderAddMode.direct:
        await _ingestProviderItemId();
    }
  }

  int _configuredProviderCount() {
    return _providers.where((provider) => provider.isConfigured).length;
  }

  void _reviewProposal(AdminMetadataProposal proposal) {
    final searchableProviders = _providerOptions();
    final canSearchWithProvider = searchableProviders.any(
      (provider) => provider.name == proposal.provider,
    );
    setState(() {
      if (canSearchWithProvider) {
        _selectedProvider = proposal.provider;
      }
      _queryController.text = proposal.query.trim().isEmpty
          ? proposal.displayTitle
          : proposal.query;
      _providerItemIdController.text = proposal.providerItemId ?? '';
      _activeProposalId = proposal.id;
      _activeProposalTitle = proposal.displayTitle;
      _proposalStatusMessage = canSearchWithProvider
          ? 'Provider search prepared from proposal.'
          : 'Proposal pinned. Choose a searchable provider to continue review.';
      _proposalErrorMessage = null;
      _statusMessage = null;
      _errorMessage = null;
    });
    if (canSearchWithProvider) {
      unawaited(_searchProvider());
    }
  }

  void _clearActiveProposal() {
    setState(() {
      _activeProposalId = null;
      _activeProposalTitle = null;
      _proposalStatusMessage = 'Proposal review cleared.';
      _proposalErrorMessage = null;
    });
  }

  void _changeProposalStatusFilter(String? value) {
    final nextValue = value?.trim();
    if (nextValue == null ||
        nextValue.isEmpty ||
        nextValue == _proposalStatusFilter) {
      return;
    }
    setState(() {
      _proposalStatusFilter = nextValue;
      _proposalStatusMessage = null;
      _proposalErrorMessage = null;
    });
    unawaited(_loadProposalData());
  }

  void _changeProposalProviderFilter(String? value) {
    final nextValue = value == null || value.trim().isEmpty ? null : value.trim();
    if (nextValue == _proposalProviderFilter) {
      return;
    }
    setState(() {
      _proposalProviderFilter = nextValue;
      _proposalStatusMessage = null;
      _proposalErrorMessage = null;
    });
    unawaited(_loadProposalData());
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Providers ──
        _DashboardSection(
          title: 'Providers',
          children: [
            _StatusChip(
              icon: Icons.extension_outlined,
              label: '$configuredProviders live',
            ),
            _StatusChip(
              icon: Icons.manage_search_outlined,
              label: '$registeredProviders registered',
            ),
            _StatusChip(
              icon: Icons.source_outlined,
              label: selectedProviderLabel,
            ),
          ],
        ),
        if (summary != null) ...[
          const SizedBox(height: 12),
          // ── Catalog ──
          _DashboardSection(
            title: 'Catalog',
            children: [
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
            ],
          ),
          const SizedBox(height: 12),
          // ── Coverage ──
          _DashboardSection(
            title: 'Coverage',
            children: [
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
            ],
          ),
          const SizedBox(height: 12),
          // ── Ingests ──
          _DashboardSection(
            title: 'Ingests',
            children: [
              _StatusChip(
                icon: Icons.join_inner_outlined,
                label: '${summary.duplicateCandidateGroups} duplicate groups',
              ),
              _StatusChip(
                icon: summary.providerIngestFailures == 0
                    ? Icons.download_done_outlined
                    : Icons.error_outline,
                label: '${summary.providerIngestFailures} failures',
              ),
              _StatusChip(
                icon: Icons.download_for_offline_outlined,
                label: '${summary.providerIngestSuccesses} ok',
              ),
              _StatusChip(
                icon: Icons.pending_actions_outlined,
                label: '${summary.pendingProposals} pending',
              ),
              if (lastIngest != null)
                _StatusChip(
                  icon: lastIngest!.created
                      ? Icons.add_circle_outline
                      : Icons.fact_check_outlined,
                  label: lastIngest!.created ? 'Last: new' : 'Last: exists',
                ),
            ],
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: _StatusChip(
              icon: Icons.hourglass_empty,
              label: 'Catalog metrics loading',
            ),
          ),
        const SizedBox(height: 12),
        // ── Search ──
        _DashboardSection(
          title: 'Search index',
          children: [
            if (searchStatus == null)
              const _StatusChip(
                icon: Icons.manage_search_outlined,
                label: 'Loading…',
              )
            else
              _StatusChip(
                icon: searchStatus.ok
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                label: searchStatus.ok
                    ? '${searchStatus.documentCount ?? '-'} docs'
                    : 'Unavailable',
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
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _StatusChip(icon: Icons.error_outline, label: errorMessage!),
        ],
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}

class _DashboardProposalActivity extends StatelessWidget {
  const _DashboardProposalActivity({
    required this.summary,
    required this.history,
    required this.errorMessage,
  });

  final AdminMetadataProposalSummary? summary;
  final List<AdminAuditLogEntry> history;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && summary == null && history.isEmpty) {
      return _MessageRow(message: errorMessage!, isError: true);
    }
    final recentApprovals = history
        .where((entry) => entry.action.contains('metadata_proposal.approve'))
        .length;
    final recentRejections = history
        .where((entry) => entry.action.contains('metadata_proposal.reject'))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardSection(
          title: 'Backlog',
          children: [
            _StatusChip(
              icon: Icons.pending_actions_outlined,
              label: '${summary?.pending ?? 0} pending',
            ),
            _StatusChip(
              icon: Icons.task_alt_outlined,
              label: '${summary?.approved ?? 0} approved',
            ),
            _StatusChip(
              icon: Icons.block_outlined,
              label: '${summary?.rejected ?? 0} rejected',
            ),
            _StatusChip(
              icon: Icons.insights_outlined,
              label: '${summary?.total ?? 0} total',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DashboardSection(
          title: 'Recent trend',
          children: [
            _StatusChip(
              icon: Icons.trending_up_outlined,
              label: '$recentApprovals recent approve',
            ),
            _StatusChip(
              icon: Icons.trending_down_outlined,
              label: '$recentRejections recent reject',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const _MessageRow(
            message: 'No proposal review activity recorded yet.',
            isError: false,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            entry.action.contains('reject')
                                ? Icons.block_outlined
                                : Icons.task_alt_outlined,
                          ),
                          Text(
                            _proposalAuditActionLabel(entry.action),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          _MiniChip(label: entry.actorEmail ?? 'unknown actor'),
                          _MiniChip(label: _formatDateTime(entry.createdAt)),
                          if ((entry.entityId?.isNotEmpty ?? false))
                            _MiniChip(label: _shortId(entry.entityId!)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
      dropdownColor: _kAdminDropdownColor,
      borderRadius: kAppMenuBorderRadius,
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
      dropdownColor: _kAdminDropdownColor,
      borderRadius: kAppMenuBorderRadius,
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
    required this.hasSearched,
    required this.inspectingItemId,
    required this.updatingItemId,
    required this.onInspect,
    required this.onEdit,
    required this.onInspectCovers,
  });

  final List<AdminMetadataItem> items;
  final bool hasSearched;
  final String? inspectingItemId;
  final String? updatingItemId;
  final ValueChanged<AdminMetadataItem> onInspect;
  final ValueChanged<AdminMetadataItem> onEdit;
  final ValueChanged<AdminMetadataItem> onInspectCovers;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _MessageRow(
        message: hasSearched
            ? 'No catalog items matched the current search.'
            : 'Search by title or choose a category to load catalog results.',
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
                dropdownColor: _kAdminDropdownColor,
                borderRadius: kAppMenuBorderRadius,
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
                dropdownColor: _kAdminDropdownColor,
                borderRadius: kAppMenuBorderRadius,
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
            _MiniChip(label: '${candidate.duplicateScore}% match'),
            _MiniChip(label: candidate.reason),
            if (candidate.hasProviderConflicts)
              const _MiniChip(label: 'provider conflict'),
            if (candidate.hasCoverConflicts)
              const _MiniChip(label: 'cover conflict'),
            if (candidate.preferredTargetItemId != null)
              _MiniChip(
                label: 'Target ${_shortId(candidate.preferredTargetItemId!)}',
              ),
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
    required this.onApproveProposal,
    required this.onIngest,
    this.activeProposalId,
    this.activeProposalTitle,
  });

  final List<ProviderCandidate> results;
  final String? ingestingProviderItemId;
  final bool Function(String provider) canIngestProvider;
  final ValueChanged<ProviderCandidate> onApproveProposal;
  final ValueChanged<ProviderCandidate> onIngest;
  final String? activeProposalId;
  final String? activeProposalTitle;

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
          activeProposalId: activeProposalId,
          activeProposalTitle: activeProposalTitle,
          onApproveProposal: () => onApproveProposal(candidate),
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
    required this.onApproveProposal,
    required this.onIngest,
    this.activeProposalId,
    this.activeProposalTitle,
  });

  final ProviderCandidate candidate;
  final bool isIngesting;
  final bool canIngest;
  final VoidCallback onApproveProposal;
  final VoidCallback onIngest;
  final String? activeProposalId;
  final String? activeProposalTitle;

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
                _MiniChip(label: 'Provider match'),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              candidate.providerItemId,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
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
        final proposalButton = activeProposalId == null
            ? null
            : FilledButton.icon(
                onPressed: isIngesting || !canIngest ? null : onApproveProposal,
                icon: isIngesting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.task_alt_outlined),
                label: const Text('Approve proposal'),
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
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (proposalButton != null) proposalButton,
                            button,
                          ],
                        ),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (proposalButton != null) proposalButton,
                          button,
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _MetadataProposalPanel extends StatelessWidget {
  const _MetadataProposalPanel({
    required this.summary,
    required this.proposals,
    required this.statusFilter,
    required this.providerFilter,
    required this.providers,
    required this.isLoading,
    required this.actingProposalId,
    required this.activeProposalTitle,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.onProviderChanged,
    required this.onReview,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
    required this.onClearReview,
    required this.canApproveLinkedItem,
  });

  final AdminMetadataProposalSummary? summary;
  final List<AdminMetadataProposal> proposals;
  final String statusFilter;
  final String? providerFilter;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final String? actingProposalId;
  final String? activeProposalTitle;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<AdminMetadataProposal> onReview;
  final ValueChanged<AdminMetadataProposal> onApprove;
  final ValueChanged<AdminMetadataProposal> onApproveLinked;
  final ValueChanged<AdminMetadataProposal> onReject;
  final VoidCallback onClearReview;
  final bool Function(String provider) canApproveLinkedItem;

  @override
  Widget build(BuildContext context) {
    final providerOptions = [
      const DropdownMenuItem<String>(value: '', child: Text('All providers')),
      for (final provider in providers)
        DropdownMenuItem<String>(
          value: provider.name,
          child: Text(provider.displayName),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: Icons.pending_actions_outlined,
              label: '${summary?.pending ?? 0} pending',
            ),
            _StatusChip(
              icon: Icons.task_alt_outlined,
              label: '${summary?.approved ?? 0} approved',
            ),
            _StatusChip(
              icon: Icons.block_outlined,
              label: '${summary?.rejected ?? 0} rejected',
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final statusField = DropdownButtonFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: onStatusChanged,
            );
            final providerField = DropdownButtonFormField<String>(
              initialValue: providerFilter ?? '',
              decoration: const InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(),
              ),
              items: providerOptions,
              onChanged: onProviderChanged,
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  statusField,
                  const SizedBox(height: 12),
                  providerField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: statusField),
                const SizedBox(width: 12),
                Expanded(child: providerField),
              ],
            );
          },
        ),
        if (activeProposalTitle != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.travel_explore_outlined),
                  Text('Reviewing proposal: $activeProposalTitle'),
                  OutlinedButton.icon(
                    onPressed: onClearReview,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Clear review'),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (statusMessage != null || errorMessage != null) ...[
          const SizedBox(height: 12),
          _MessageRow(
            message: errorMessage ?? statusMessage!,
            isError: errorMessage != null,
          ),
        ],
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (proposals.isEmpty)
          _MessageRow(
            message: 'No ${statusFilter.toLowerCase()} proposals found.',
            isError: false,
          )
        else
          Column(
            children: [
              for (final proposal in proposals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MetadataProposalTile(
                    proposal: proposal,
                    isActing: actingProposalId == proposal.id,
                    canApproveLinkedItem: canApproveLinkedItem(proposal.provider),
                    onReview: () => onReview(proposal),
                    onApprove: () => onApprove(proposal),
                    onApproveLinked: () => onApproveLinked(proposal),
                    onReject: () => onReject(proposal),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MetadataProposalTile extends StatelessWidget {
  const _MetadataProposalTile({
    required this.proposal,
    required this.isActing,
    required this.canApproveLinkedItem,
    required this.onReview,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
  });

  final AdminMetadataProposal proposal;
  final bool isActing;
  final bool canApproveLinkedItem;
  final VoidCallback onReview;
  final VoidCallback onApprove;
  final VoidCallback onApproveLinked;
  final VoidCallback onReject;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  proposal.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _MiniChip(label: proposal.provider),
                _MiniChip(label: proposal.status),
                if (proposal.providerItemId != null &&
                    proposal.providerItemId!.isNotEmpty)
                  _MiniChip(label: 'ID ${proposal.providerItemId}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proposal.query,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (proposal.summary != null && proposal.summary!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                proposal.summary!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (proposal.isPending) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onReview,
                    icon: const Icon(Icons.travel_explore_outlined),
                    label: const Text('Review in search'),
                  ),
                  if ((proposal.providerItemId?.isNotEmpty ?? false) &&
                      canApproveLinkedItem)
                    FilledButton.tonalIcon(
                      onPressed: isActing ? null : onApproveLinked,
                      icon: isActing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link_outlined),
                      label: const Text('Approve linked ID'),
                    ),
                  FilledButton.icon(
                    onPressed: isActing ? null : onApprove,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.task_alt_outlined),
                    label: const Text('Approve'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onReject,
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ProviderAddMode { search, direct }

class _ProviderAddRequest {
  const _ProviderAddRequest({
    required this.mode,
    required this.kind,
    required this.provider,
    this.query,
    this.providerItemId,
  });

  final _ProviderAddMode mode;
  final String? kind;
  final String provider;
  final String? query;
  final String? providerItemId;
}

class _ProviderAddDialog extends StatefulWidget {
  const _ProviderAddDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialKind,
    this.initialProvider,
    this.initialQuery,
    this.initialProviderItemId,
  });

  final List<AdminProviderStatus> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialKind;
  final String? initialProvider;
  final String? initialQuery;
  final String? initialProviderItemId;

  @override
  State<_ProviderAddDialog> createState() => _ProviderAddDialogState();
}

class _ProviderAddDialogState extends State<_ProviderAddDialog> {
  late _ProviderAddMode _mode;
  late String? _selectedKind;
  late String _selectedProvider;
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = _ProviderAddMode.search;
    _selectedKind = widget.initialKind;
    _selectedProvider = widget.initialProvider ?? '';
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _providerItemIdController = TextEditingController(
      text: widget.initialProviderItemId ?? '',
    );
    _syncSelectedProvider();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    super.dispose();
  }

  List<AdminProviderStatus> get _availableProviders {
    return [
      for (final provider in widget.providers)
        if ((_mode == _ProviderAddMode.search
                ? provider.supportsSearch
                : provider.supportsIngest) &&
            (_selectedKind == null || provider.effectiveKinds.contains(_selectedKind)))
          provider,
    ];
  }

  void _syncSelectedProvider() {
    final providers = _availableProviders;
    if (providers.any((provider) => provider.name == _selectedProvider)) {
      return;
    }
    _selectedProvider = providers.isEmpty ? '' : providers.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = _mode == _ProviderAddMode.search
        ? 'Search provider'
        : 'Add to catalog';
    return AlertDialog(
      shape: _kAdminDialogShape,
      title: const Text('Add metadata from provider'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              SegmentedButton<_ProviderAddMode>(
                segments: const [
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.search,
                    icon: Icon(Icons.manage_search_outlined),
                    label: Text('Search first'),
                  ),
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.direct,
                    icon: Icon(Icons.download_for_offline_outlined),
                    label: Text('Known ID'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 16),
              _ProviderKindSelector(
                value: _selectedKind,
                kinds: widget.kinds,
                kindLabels: widget.kindLabels,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedKind = value == null || value.isEmpty ? null : value;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 12),
              _ProviderSelector(
                value: _selectedProvider,
                providers: _availableProviders,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value?.trim() ?? '';
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                _mode == _ProviderAddMode.search
                    ? 'Search for candidates inside the selected category before creating anything in the canonical catalog.'
                    : 'Use a known provider item ID when you already know the exact external record you want to ingest.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (_mode == _ProviderAddMode.search)
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Provider query',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                )
              else
                TextField(
                  controller: _providerItemIdController,
                  decoration: const InputDecoration(
                    labelText: 'Provider item ID',
                    prefixIcon: Icon(Icons.tag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
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
          onPressed: _submit,
          icon: Icon(
            _mode == _ProviderAddMode.search
                ? Icons.manage_search_outlined
                : Icons.download_for_offline_outlined,
          ),
          label: Text(actionLabel),
        ),
      ],
    );
  }

  void _submit() {
    final kind = _selectedKind?.trim();
    if (kind == null || kind.isEmpty) {
      setState(() {
        _error = 'Choose a media category first.';
      });
      return;
    }
    if (_selectedProvider.trim().isEmpty) {
      setState(() {
        _error = 'Choose a provider.';
      });
      return;
    }
    if (_mode == _ProviderAddMode.search) {
      final query = _queryController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _error = 'Enter a provider query.';
        });
        return;
      }
      Navigator.of(context).pop(
        _ProviderAddRequest(
          mode: _mode,
          kind: kind,
          provider: _selectedProvider,
          query: query,
        ),
      );
      return;
    }
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _error = 'Enter a provider item ID.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ProviderAddRequest(
        mode: _mode,
        kind: kind,
        provider: _selectedProvider,
        providerItemId: providerItemId,
      ),
    );
  }
}

class _CatalogCorrection {
  const _CatalogCorrection({
    this.title,
    this.itemNumber,
    this.synopsis,
    this.editionTitle,
    this.pageCount,
    this.runtimeMinutes,
    this.publisher,
    this.releaseDate,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.country,
    this.language,
    this.ageRating,
    this.catalogNumber,
    this.releaseStatus,
    this.physicalFormat,
    this.variantName,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.seriesTags,
  });

  final String? title;
  final String? itemNumber;
  final String? synopsis;
  final String? editionTitle;
  final int? pageCount;
  final int? runtimeMinutes;
  final String? publisher;
  final DateTime? releaseDate;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? physicalFormat;
  final String? variantName;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String>? seriesTags;
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

String _proposalAuditActionLabel(String action) {
  return switch (action) {
    'metadata_proposal.approve' => 'Approved proposal',
    'metadata_proposal.approve_provider' => 'Approved via provider',
    'metadata_proposal.reject' => 'Rejected proposal',
    _ => action,
  };
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
