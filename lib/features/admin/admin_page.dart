import 'dart:async';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/features/admin/admin_image_cache_panel.dart';
import 'package:collectarr_app/features/admin/admin_users_panel.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
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
part 'admin_dashboard_widgets.dart';
part 'admin_provider_widgets.dart';
part 'admin_shared_widgets.dart';

// Resolved at runtime via appPalette(context).panelRaised
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
    final isAdmin = ref.watch(authControllerProvider).isAdmin;

    final tabs = <Tab>[
      if (isAdmin)
        const Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
      const Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Catalog'),
      const Tab(icon: Icon(Icons.hub_outlined), text: 'Providers'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.history_outlined), text: 'Logs'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.settings_outlined), text: 'System'),
    ];

    final tabViews = <Widget>[
      if (isAdmin) _buildDashboardTab(),
      _buildCatalogTab(context),
      _buildProvidersTab(context, isAdmin: isAdmin),
      if (isAdmin) _buildLogsTab(),
      if (isAdmin) _buildSystemTab(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAdmin ? 'Admin' : 'Manage'),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          surfaceTintColor: Colors.transparent,
          flexibleSpace: LibraryAccentChrome(
            accent: accent,
            animationDuration: animationDuration,
          ),
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }
  // ─── Dashboard tab (admin only) ───
  Widget _buildDashboardTab() {
    return ListView(
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
    );
  }

  // ─── Catalog tab (all users) ───
  Widget _buildCatalogTab(BuildContext context) {
    return ListView(
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
    );
  }

  // ─── Providers tab (all users, ingest jobs admin-only) ───
  Widget _buildProvidersTab(BuildContext context, {required bool isAdmin}) {
    return ListView(
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
        if (isAdmin) ...[
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
      ],
    );
  }

  // ─── Logs tab (admin only) ───
  Widget _buildLogsTab() {
    return ListView(
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
    );
  }

  // ─── System tab (admin only) ───
  Widget _buildSystemTab() {
    return ListView(
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
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'admin',
        message: 'Failed to load media types for admin page.',
        error: error,
        stackTrace: stackTrace,
      );
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

