import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:collectarr_app/features/admin/admin_image_cache_panel.dart';
import 'package:collectarr_app/features/admin/admin_page_data_loader.dart';
import 'package:collectarr_app/features/admin/admin_dashboard_widgets.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/features/admin/admin_kind_labels.dart';
import 'package:collectarr_app/features/admin/admin_proposal_metadata_edit_dialog.dart';
import 'package:collectarr_app/features/admin/controllers/admin_catalog_search_controller.dart';
import 'package:collectarr_app/features/admin/controllers/admin_ingest_jobs_controller.dart';
import 'package:collectarr_app/features/admin/controllers/admin_proposals_controller.dart';
import 'package:collectarr_app/features/admin/widgets/admin_catalog_search_panel.dart';
import 'package:collectarr_app/features/admin/widgets/admin_catalog_item_list.dart';
import 'package:collectarr_app/features/admin/widgets/admin_proposals_panel.dart';
import 'package:collectarr_app/features/admin/widgets/admin_ingest_jobs_panel.dart';
import 'package:collectarr_app/features/admin/widgets/admin_proposal_tile.dart';
import 'package:collectarr_app/features/admin/admin_diagnostics_panel.dart';
import 'package:collectarr_app/features/admin/admin_users_panel.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'admin_item_inspection.dart';
part 'admin_metadata_correction_dialog.dart';
part 'admin_duplicate_merge_dialog.dart';
part 'admin_bundle_correction_dialog.dart';
part 'admin_page_sections.dart';
part 'admin_provider_widgets.dart';
part 'admin_shared_widgets.dart';

// Resolved at runtime via appPalette(context).panelRaised
const _kAdminDialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.zero,
);

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  void _refresh(VoidCallback fn) => setState(fn);

  late final _catalogSearchController = AdminCatalogSearchController(
    formatError: _adminErrorMessage,
  );
  late final _ingestJobsController = AdminIngestJobsController(
    formatError: _adminErrorMessage,
  );
  late final _proposalsController = AdminProposalsController(
    formatError: _adminErrorMessage,
  );

  final _catalogQueryController = TextEditingController();
  final _queryController = TextEditingController();
  final _providerItemIdController = TextEditingController();
  final _jobProviderItemIdController = TextEditingController();
  final _ingestJobQueryController = TextEditingController();
  var _mediaTypes = const <CatalogMediaType>[];
  var _providers = const <AdminProviderStatus>[];
  AdminCatalogSummary? _summary;
  AdminNormalizedMetadataDriftReport? _normalizedMetadataDrift;
  SharedMetadataContractDrift? _metadataContractDrift;
  AdminImageCacheStats? _dashboardImageCacheStats;
  AdminSearchStatus? _searchStatus;
  AdminSearchReindexResult? _lastReindex;
  var _searchHistory = const <AdminSearchHistoryEntry>[];
  var _auditLogs = const <AdminAuditLogEntry>[];
  var _proposalHistory = const <AdminAuditLogEntry>[];
  var _releaseMappingRules = const <AdminReleaseMediaMappingRule>[];
  AdminMetadataProposalSummary? _dashboardProposalSummary;
  static const _ingestPollInterval = Duration(seconds: 15);
  Timer? _ingestPollTimer;
  var _duplicates = const <AdminDuplicateCandidate>[];
  var _results = const <ProviderSearchResult>[];
  var _selectedProvider = '';
  String? _selectedProviderKindFilter;
  AdminProviderIngestResult? _lastIngest;
  String? _statusMessage;
  String? _errorMessage;
  String? _dashboardErrorMessage;
  String? _inspectErrorMessage;
  String? _duplicateStatusMessage;
  String? _duplicateErrorMessage;
  String? _proposalStatusMessage;
  String? _proposalErrorMessage;
  String? _releaseRulesStatusMessage;
  String? _releaseRulesErrorMessage;
  bool _isLoadingDashboard = false;
  bool _isReindexing = false;
  bool _isLoadingProviders = false;
  bool _isRunningJobs = false;
  bool _autoRefreshIngestJobs = true;
  bool _isSearching = false;
  bool _isDirectIngesting = false;
  bool _isLoadingReleaseMappingRules = false;
  bool _showProviderMediaResults = true;
  bool _showProviderReleaseResults = true;
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
    _catalogSearchController.addListener(_onFlowControllerChanged);
    _ingestJobsController.addListener(_onFlowControllerChanged);
    _proposalsController.addListener(_onFlowControllerChanged);
    _loadDashboard();
    _loadMediaTypes();
    _loadProviders();
    _loadProposalData();
    _restartIngestPolling();
  }

  @override
  void dispose() {
    _ingestPollTimer?.cancel();
    _catalogSearchController.dispose();
    _ingestJobsController.dispose();
    _proposalsController.dispose();
    _catalogQueryController.dispose();
    _queryController.dispose();
    _providerItemIdController.dispose();
    _jobProviderItemIdController.dispose();
    _ingestJobQueryController.dispose();
    super.dispose();
  }

  void _onFlowControllerChanged() {
    if (mounted) setState(() {});
  }

  bool _isProviderReleaseCandidate(ProviderSearchResult candidate) {
    return candidate.searchRole.isCollectibleRelease;
  }

  List<ProviderSearchResult> _visibleProviderResults() {
    if (_showProviderMediaResults && _showProviderReleaseResults) {
      return _results;
    }
    return _results.where((candidate) {
      final isRelease = _isProviderReleaseCandidate(candidate);
      return isRelease
          ? _showProviderReleaseResults
          : _showProviderMediaResults;
    }).toList(growable: false);
  }

  void _prefillFromActiveProposal() {
    final activeId = _activeProposalId;
    if (activeId == null || activeId.isEmpty) {
      setState(() {
        _errorMessage = 'No active proposal selected for prefill.';
      });
      return;
    }
    AdminMetadataProposal? proposal;
    for (final entry in _proposalsController.proposals) {
      if (entry.id == activeId) {
        proposal = entry;
        break;
      }
    }
    if (proposal == null) {
      setState(() {
        _errorMessage = 'Active proposal is no longer available.';
      });
      return;
    }
    final activeProposal = proposal;
    final searchableProviders = _providerOptions();
    final kindFromPayload =
        activeProposal.metadataPayload?['kind']?.toString().trim();
    final resolvedKind = kindFromPayload != null && kindFromPayload.isNotEmpty
        ? kindFromPayload
        : _selectedProviderKindFilter;
    final query = activeProposal.query.trim().isEmpty
        ? activeProposal.displayTitle
        : activeProposal.query;
    setState(() {
      if (searchableProviders
          .any((entry) => entry.name == activeProposal.provider)) {
        _selectedProvider = activeProposal.provider;
      }
      _selectedProviderKindFilter = resolvedKind;
      _queryController.text = query;
      _providerItemIdController.text =
          activeProposal.providerItemId?.trim() ?? '';
      _statusMessage = 'Prefilled from active proposal.';
      _errorMessage = null;
    });
  }

  Future<void> _loadReleaseMappingRules({bool showErrors = true}) async {
    setState(() {
      _isLoadingReleaseMappingRules = true;
      _releaseRulesErrorMessage = null;
    });
    try {
      final rows = await AdminPageDataLoader(
        ref.read(apiClientProvider),
      ).loadReleaseMappingRules();
      if (!mounted) return;
      setState(() {
        _releaseMappingRules = rows;
        _isLoadingReleaseMappingRules = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingReleaseMappingRules = false;
        if (showErrors) {
          _releaseRulesErrorMessage = 'Failed to load mapping rules: $error';
        }
      });
    }
  }

  Future<void> _showCreateReleaseMappingRuleDialog() async {
    final result = await showDialog<_ReleaseMappingRuleFormResult>(
      context: context,
      builder: (context) => _ReleaseMappingRuleDialog(
        providers: _providerOptions()
            .map((entry) => entry.name)
            .toList(growable: false),
        kinds: _providerKindOptions(forSearch: true),
        kindLabels: _catalogKindLabels(),
      ),
    );
    if (result == null) {
      return;
    }
    try {
      await ref.read(apiClientProvider).adminCreateReleaseMediaMappingRule(
            payload: AdminReleaseMediaMappingRuleUpsert(
              provider: result.provider,
              releaseType: result.releaseType,
              targetKind: result.targetKind,
              priority: result.priority,
              isActive: result.isActive,
              notes: result.notes,
            ),
          );
      if (!mounted) return;
      setState(() {
        _releaseRulesStatusMessage = 'Release mapping rule created.';
        _releaseRulesErrorMessage = null;
      });
      await _loadReleaseMappingRules();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _releaseRulesErrorMessage = 'Failed to create mapping rule: $error';
      });
    }
  }

  Future<void> _showEditReleaseMappingRuleDialog(
    AdminReleaseMediaMappingRule rule,
  ) async {
    final result = await showDialog<_ReleaseMappingRuleFormResult>(
      context: context,
      builder: (context) => _ReleaseMappingRuleDialog(
        providers: _providerOptions()
            .map((entry) => entry.name)
            .toList(growable: false),
        kinds: _providerKindOptions(forSearch: true),
        kindLabels: _catalogKindLabels(),
        initialProvider: rule.provider,
        initialReleaseType: rule.releaseType,
        initialTargetKind: rule.targetKind,
        initialPriority: rule.priority,
        initialIsActive: rule.isActive,
        initialNotes: rule.notes,
      ),
    );
    if (result == null) {
      return;
    }
    try {
      await ref.read(apiClientProvider).adminUpdateReleaseMediaMappingRule(
            ruleId: rule.id,
            payload: AdminReleaseMediaMappingRuleUpsert(
              provider: result.provider,
              releaseType: result.releaseType,
              targetKind: result.targetKind,
              priority: result.priority,
              isActive: result.isActive,
              notes: result.notes,
            ),
          );
      if (!mounted) return;
      setState(() {
        _releaseRulesStatusMessage = 'Release mapping rule updated.';
        _releaseRulesErrorMessage = null;
      });
      await _loadReleaseMappingRules();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _releaseRulesErrorMessage = 'Failed to update mapping rule: $error';
      });
    }
  }

  Future<void> _deleteReleaseMappingRule(
      AdminReleaseMediaMappingRule rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: const Text('Delete mapping rule?'),
        content: Text('Delete "${rule.releaseType} -> ${rule.targetKind}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(apiClientProvider).adminDeleteReleaseMediaMappingRule(
            ruleId: rule.id,
          );
      if (!mounted) return;
      setState(() {
        _releaseRulesStatusMessage = 'Release mapping rule deleted.';
        _releaseRulesErrorMessage = null;
      });
      await _loadReleaseMappingRules();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _releaseRulesErrorMessage = 'Failed to delete mapping rule: $error';
      });
    }
  }

  Future<void> _applyRulePrefillDefaults() async {
    final source = _activeProposalId != null
        ? 'proposal'
        : (_ingestJobsController.history.isNotEmpty
            ? 'ingest_history'
            : 'manual');
    try {
      final resolved =
          await ref.read(apiClientProvider).adminResolveProviderPrefill(
                source: source,
                provider:
                    _selectedProvider.trim().isEmpty ? null : _selectedProvider,
                kind: _selectedProviderKindFilter,
                query: _queryController.text,
                providerItemId: _providerItemIdController.text,
                proposalId: source == 'proposal' ? _activeProposalId : null,
                ingestHistoryId: source == 'ingest_history'
                    ? _ingestJobsController.history.first.id
                    : null,
              );
      if (!mounted) return;
      final providerOptions = _providerOptions();
      setState(() {
        if (resolved.provider != null &&
            providerOptions.any((entry) => entry.name == resolved.provider)) {
          _selectedProvider = resolved.provider!;
        }
        if (resolved.kind != null) {
          _selectedProviderKindFilter = resolved.kind;
        }
        if (resolved.query != null) {
          _queryController.text = resolved.query!;
        }
        if (resolved.providerItemId != null) {
          _providerItemIdController.text = resolved.providerItemId!;
        }
        _statusMessage = resolved.notes.isEmpty
            ? 'Applied centralized prefill defaults.'
            : resolved.notes.join(' \u2022 ');
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to apply rule defaults: $error';
      });
    }
  }

  void _prefillFromLatestIngest() {
    if (_ingestJobsController.history.isEmpty) {
      setState(() {
        _errorMessage = 'No ingest history available for prefill.';
      });
      return;
    }
    final entry = _ingestJobsController.history.first;
    final ingestProviders = _providerOptions(forIngest: true);
    setState(() {
      if (ingestProviders.any((provider) => provider.name == entry.provider)) {
        _selectedProvider = entry.provider;
      }
      _providerItemIdController.text = entry.providerItemId;
      _queryController.text = '';
      _statusMessage =
          'Prefilled provider and item ID from latest ingest history entry.';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    final isAdmin = ref.watch(authControllerProvider).isAdmin;

    final tabs = <Tab>[
      if (isAdmin)
        const Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Stats'),
      const Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Catalog'),
      const Tab(icon: Icon(Icons.hub_outlined), text: 'Providers'),
      if (isAdmin) const Tab(icon: Icon(Icons.history_outlined), text: 'Logs'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.settings_outlined), text: 'System'),
    ];

    final tabViews = <Widget>[
      if (isAdmin) _buildDashboardTab(),
      if (isAdmin) _buildStatsTab(),
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
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs,
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }

  // ─── Dashboard tab (admin only) ───
  Widget _buildDashboardTab() {
    return AdminDashboardTab(
      isReindexing: _isReindexing,
      isLoadingDashboard: _isLoadingDashboard,
      db: ref.read(localDatabaseProvider),
      summary: _summary,
      searchStatus: _searchStatus,
      lastReindex: _lastReindex,
      configuredProviders: _configuredProviderCount(),
      registeredProviders: _providers.length,
      selectedProviderLabel: _selectedProviderLabel(),
      lastIngest: _lastIngest,
      normalizedMetadataDrift: _normalizedMetadataDrift,
      metadataContractDrift: _metadataContractDrift,
      dashboardErrorMessage: _dashboardErrorMessage,
      proposalSummary: _dashboardProposalSummary,
      proposalHistory: _proposalHistory,
      onReindexSearch: _reindexSearch,
      onRefreshDashboard: _loadDashboard,
    );
  }

  Widget _buildStatsTab() {
    return AdminStatsTab(
      isLoadingDashboard: _isLoadingDashboard,
      summary: _summary,
      imageCacheStats: _dashboardImageCacheStats,
      dashboardErrorMessage: _dashboardErrorMessage,
      onRefreshDashboard: _loadDashboard,
    );
  }

  // ─── Catalog tab (all users) ───

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardErrorMessage = null;
    });
    try {
      final ingestJobQuery = _ingestJobQueryController.text.trim();
      final dashboard = await AdminPageDataLoader(
        ref.read(apiClientProvider),
      ).loadDashboard(
        ingestJobStatus: _ingestJobsController.statusFilter,
        ingestJobProvider: _ingestJobsController.providerFilter,
        ingestJobQuery: ingestJobQuery.isEmpty ? null : ingestJobQuery,
      );
      final contractDrift =
          compareSharedContractWithManifest(dashboard.normalizedManifest);
      if (!mounted) {
        return;
      }
      _ingestJobsController.acceptDashboard(dashboard);
      setState(() {
        _summary = dashboard.summary;
        _normalizedMetadataDrift = dashboard.normalizedMetadataDrift;
        _metadataContractDrift = contractDrift;
        _dashboardImageCacheStats = dashboard.imageCacheStats;
        _searchStatus = dashboard.searchStatus;
        _searchHistory = dashboard.searchHistory;
        _auditLogs = dashboard.auditLogs;
        _dashboardProposalSummary = dashboard.proposalSummary;
        _proposalHistory = dashboard.proposalHistory;
        _duplicates = dashboard.duplicateCandidates;
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
    if (_isLoadingDashboard) {
      return;
    }
    if (!silent) setState(() => _errorMessage = null);
    final query = _ingestJobQueryController.text.trim();
    await _ingestJobsController.refresh(
      ref.read(apiClientProvider),
      query: query.isEmpty ? null : query,
      silent: silent,
    );
    if (!mounted || silent) return;
    setState(() => _errorMessage = _ingestJobsController.errorMessage);
  }

  Future<void> _loadProposalData() async {
    _proposalErrorMessage = null;
    await _proposalsController.load(ref.read(apiClientProvider));
    if (!mounted) return;
    if (_proposalsController.errorMessage != null) {
      setState(() => _proposalErrorMessage = _proposalsController.errorMessage);
    }
  }

  void _restartIngestPolling() {
    _ingestPollTimer?.cancel();
    if (!_autoRefreshIngestJobs) {
      return;
    }
    _ingestPollTimer = Timer.periodic(_ingestPollInterval, (_) {
      if (!_ingestJobsController.hasPollableJobs ||
          _ingestJobsController.isLoading ||
          _isLoadingDashboard) {
        return;
      }
      unawaited(_refreshIngestJobs(silent: true));
    });
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
      final result = await _ingestJobsController.retryHistory(
        ref.read(apiClientProvider),
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
    await _catalogSearchController.search(
      ref.read(apiClientProvider),
      query: _catalogQueryController.text,
    );
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
      final metadataFields = await _adminMetadataFields(fresh);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastIngest = null;
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(
        fresh,
        auditLogs,
        const <BundleReleaseSummary>[],
        metadataFields,
      );
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
    List<LibraryAdminCorrectionField> metadataFields,
  ) async {
    final result = await showDialog<_CanonicalInspectResult>(
      context: context,
      builder: (context) => _CanonicalItemInspectionDialog(
        item: item,
        auditLogs: auditLogs,
        bundleReleases: bundleReleases,
        metadataFields: metadataFields,
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

  Future<List<LibraryAdminCorrectionField>> _adminMetadataFields(
    AdminMetadataItem item,
  ) async {
    try {
      final fieldSchema = await ref
          .read(apiClientProvider)
          .metadataFieldSchema(editableOnly: true);
      final kind = catalogMediaKindFromApiValue(item.kind);
      final contributor = libraryAdminContributorForKind(kind);
      if (contributor == null) return const [];
      return adminCorrectionFieldsForKind(
        schema: fieldSchema,
        kind: kind,
        contributor: contributor,
      );
    } catch (_) {
      // Inspection remains available if the optional field schema is down.
      return const [];
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
        _catalogSearchController.statusMessage = null;
        _catalogSearchController.errorMessage = null;
      });
      await api.adminUpdateBundleRelease(
        bundleReleaseId: bundleReleaseId,
        correction: correction,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogSearchController.statusMessage =
            'Bundle release correction saved.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _showMetadataCorrectionDialog(AdminMetadataItem item) async {
    final kind = catalogMediaKindFromApiValue(item.kind);
    final contributor = libraryAdminContributorForKind(kind);
    if (contributor == null) {
      setState(() {
        _catalogSearchController.errorMessage =
            'No Admin correction fields are registered for this kind.';
      });
      return;
    }
    late final MetadataFieldSchema fieldSchema;
    try {
      fieldSchema = await ref.read(apiClientProvider).metadataFieldSchema(
            editableOnly: true,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
      return;
    }
    if (!mounted) return;
    final correctionFields = adminCorrectionFieldsForKind(
      schema: fieldSchema,
      kind: kind,
      contributor: contributor,
    );
    if (correctionFields.isEmpty) {
      setState(() {
        _catalogSearchController.errorMessage =
            'Core did not return editable canonical fields for this kind.';
      });
      return;
    }
    final physicalFormats = physicalMediaFormatsForKind(
      _mediaTypes.isEmpty ? fallbackMediaCatalog : _mediaTypes,
      kind,
    );
    final correction = await showDialog<_MetadataCorrectionResult>(
      context: context,
      builder: (context) => _MetadataCorrectionDialog(
        item: item,
        fields: correctionFields,
        physicalFormats: physicalFormats,
      ),
    );
    if (correction == null || !mounted) return;

    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogSearchController.statusMessage = null;
      _catalogSearchController.errorMessage = null;
      _inspectErrorMessage = null;
    });
    try {
      AdminMetadataItem? updated;
      final api = ref.read(apiClientProvider);
      final writer = LibraryAdminCorrectionWriter(
        updateCatalogFields: (fields) async {
          updated = await api.adminUpdateCatalogItemFields(
            kind: item.kind,
            id: item.id,
            fields: fields,
          );
        },
        updateRelatedFields: (relatedEntityId, fields) async {
          await api.adminUpdateSeriesFields(
            seriesId: relatedEntityId,
            fields: fields,
          );
        },
      );
      final catalogFields = <String, Object?>{};
      for (final field in correction.changedFields) {
        final value = correction.values.read(field.key);
        final save = field.save;
        if (save == null) {
          catalogFields[field.key] = value;
        } else {
          await save(item, value, writer);
        }
      }
      if (catalogFields.isNotEmpty) {
        await writer.updateCatalogFields(catalogFields);
      }
      if (!mounted) return;
      setState(() {
        _updatingCatalogItemId = null;
        _lastIngest = null;
        _catalogSearchController.statusMessage = 'Metadata correction saved.';
        if (updated != null) {
          _catalogSearchController.replaceItem(updated!);
        }
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _showCoverInspectionDialog(AdminMetadataItem item) async {
    final contributor = libraryAdminContributorForKind(
      catalogMediaKindFromApiValue(item.kind),
    );
    if (contributor == null) return;
    final update = await showDialog<_CoverUpdate>(
      context: context,
      builder: (context) => _CoverInspectionDialog(item: item),
    );
    if (update == null || !mounted) {
      return;
    }
    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogSearchController.statusMessage = null;
      _catalogSearchController.errorMessage = null;
    });
    try {
      final updated =
          await ref.read(apiClientProvider).adminUpdateCatalogItemFields(
                kind: item.kind,
                id: item.id,
                fields: contributor.serializeCoverCorrection(
                  coverImageUrl: update.coverImageUrl,
                  thumbnailImageUrl: update.thumbnailImageUrl,
                ),
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.replaceItem(updated);
        _catalogSearchController.statusMessage = 'Cover URL updated.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
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
      await _ingestJobsController.queue(
        ref.read(apiClientProvider),
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
      final result = await _ingestJobsController.runPending(
        ref.read(apiClientProvider),
        limit: 5,
      );
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
      final updated = await _ingestJobsController.runJob(
        ref.read(apiClientProvider),
        jobId: job.id,
        retry: retry,
      );
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
    _ingestJobsController.setFilters(
      status: status == null || status.isEmpty ? null : status,
      provider: _ingestJobsController.providerFilter,
    );
    unawaited(_refreshIngestJobs());
  }

  void _changeIngestJobProviderFilter(String? provider) {
    _ingestJobsController.setFilters(
      status: _ingestJobsController.statusFilter,
      provider: provider == null || provider.isEmpty ? null : provider,
    );
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
      await _showCanonicalItemInspectionDialog(
        item,
        auditLogs,
        const <BundleReleaseSummary>[],
        await _adminMetadataFields(item),
      );
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
          builder: (context) => AccentAlertDialog(
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
      final providers = await AdminPageDataLoader(
        ref.read(apiClientProvider),
      ).loadProviders();
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
            (row) => ProviderSearchResult.fromJson(
              row,
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
    final confirmed = await _confirmProposalApproval(
      proposal,
      linked: false,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _proposalActionId = proposal.id;
      _proposalErrorMessage = null;
      _proposalStatusMessage = null;
    });
    try {
      final result = await _proposalsController.approve(
        ref.read(apiClientProvider),
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
      setState(() {
        _proposalErrorMessage =
            'Linked approval requires a provider item id on the proposal.';
      });
      return;
    }
    final confirmed = await _confirmProposalApproval(
      proposal,
      linked: true,
      providerItemId: providerItemId,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _approveProposalWithProviderItem(
      proposalId: proposal.id,
      provider: proposal.provider,
      providerItemId: providerItemId,
      successMessage: 'Proposal approved with linked provider item.',
    );
  }

  Future<bool> _confirmProposalApproval(
    AdminMetadataProposal proposal, {
    required bool linked,
    String? providerItemId,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text(linked ? 'Approve linked proposal?' : 'Approve proposal?'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                proposal.displayTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text('Provider: ${proposal.provider}'),
              if (providerItemId != null && providerItemId.isNotEmpty)
                Text('Provider item id: $providerItemId'),
              const SizedBox(height: 10),
              Text(
                linked
                    ? 'This will ingest the linked provider item and mark the proposal as approved.'
                    : 'This will ingest provider metadata and mark the proposal as approved.',
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.task_alt_outlined),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _approveProposalWithCandidate(
      ProviderSearchResult candidate) async {
    final proposalId = _activeProposalId;
    if (proposalId == null || proposalId.isEmpty) {
      return;
    }
    final proposal = _proposalsController.proposals
        .where((row) => row.id == proposalId)
        .firstOrNull;
    final confirmed = await _confirmProposalApproval(
      proposal ??
          AdminMetadataProposal(
            id: proposalId,
            provider: candidate.provider,
            query: _queryController.text.trim(),
            title: _activeProposalTitle,
            status: 'pending',
          ),
      linked: true,
      providerItemId: candidate.providerItemId,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _approveProposalWithProviderItem(
      proposalId: proposalId,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      kind: candidate.kind.apiValue,
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
      final result = await _proposalsController.approveWithProviderItem(
        ref.read(apiClientProvider),
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
      await _proposalsController.reject(
        ref.read(apiClientProvider),
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

  Future<void> _ingestProviderItem(ProviderSearchResult candidate) async {
    await _ingestProvider(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      kind: candidate.kind.apiValue,
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
      unawaited(_loadDashboard());
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
        initialShowMediaResults: _showProviderMediaResults,
        initialShowReleaseResults: _showProviderReleaseResults,
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
      _showProviderMediaResults = request.showMediaResults;
      _showProviderReleaseResults = request.showReleaseResults;
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

  void _editProposalMetadata(AdminMetadataProposal proposal) {
    unawaited(_editProposalMetadataAsync(proposal));
  }

  Future<void> _editProposalMetadataAsync(
      AdminMetadataProposal proposal) async {
    final result = await showDialog<AdminProposalMetadataEditResult>(
      context: context,
      builder: (context) => AdminProposalMetadataEditDialog(proposal: proposal),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _proposalActionId = proposal.id;
      _proposalErrorMessage = null;
      _proposalStatusMessage = null;
    });
    try {
      final updated = await _proposalsController.update(
        ref.read(apiClientProvider),
        proposalId: proposal.id,
        query: result.query,
        providerItemId: result.providerItemId,
        title: result.title,
        summary: result.summary,
        imageUrl: result.imageUrl,
        metadataPayload: result.metadataPayload,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _proposalActionId = null;
        _proposalStatusMessage = 'Proposal metadata updated.';
        _proposalsController.replaceProposal(updated);
        if (_activeProposalId == updated.id) {
          _activeProposalTitle = updated.displayTitle;
          _providerItemIdController.text = updated.providerItemId ?? '';
          _queryController.text = updated.query.trim().isEmpty
              ? updated.displayTitle
              : updated.query;
        }
      });
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
        nextValue == _proposalsController.statusFilter) {
      return;
    }
    setState(() {
      _proposalsController.statusFilter = nextValue;
      _proposalStatusMessage = null;
      _proposalErrorMessage = null;
    });
    unawaited(_loadProposalData());
  }

  void _changeProposalProviderFilter(String? value) {
    final nextValue =
        value == null || value.trim().isEmpty ? null : value.trim();
    if (nextValue == _proposalsController.providerFilter) {
      return;
    }
    setState(() {
      _proposalsController.providerFilter = nextValue;
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
      ..sort((left, right) => compareAdminMediaKinds(left, right, labels));
  }

  Map<String, String> _catalogKindLabels() {
    return {
      for (final type in _mediaTypes)
        if (type.kind.isNotEmpty) type.kind: adminMediaTypeDisplayLabel(type),
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
