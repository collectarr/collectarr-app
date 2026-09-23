part of 'admin_page.dart';

extension _AdminPageSections on _AdminPageState {
  Widget _buildCatalogTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminCatalogSearchPanel(
          queryController: _catalogQueryController,
          kind: _catalogSearchController.kindFilter,
          kinds: _providerKindOptions(forSearch: true),
          kindLabels: _catalogKindLabels(),
          isLoadingKinds: _isLoadingProviders,
          isSearching: _catalogSearchController.isSearching,
          statusMessage: _catalogSearchController.statusMessage,
          errorMessage: _catalogSearchController.errorMessage,
          onKindChanged: (value) {
            _catalogSearchController.kindFilter = value;
          },
          onSearch: _searchCatalog,
          results: AdminCatalogItemList(
            items: _catalogSearchController.items,
            hasSearched: _catalogSearchController.hasSearched,
            inspectingItemId: _inspectingItemId,
            updatingItemId: _updatingCatalogItemId,
            onInspect: _inspectCatalogItem,
            onEdit: _showMetadataCorrectionDialog,
            onInspectCovers: _showCoverInspectionDialog,
          ),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.join_inner_outlined,
          title: 'Duplicate candidates',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_duplicateStatusMessage != null ||
                  _duplicateErrorMessage != null) ...[
                AdminMessageRow(
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
        if (_lastIngest != null || _inspectErrorMessage != null) ...[
          const SizedBox(height: 12),
          AdminPanel(
            icon: Icons.fact_check_outlined,
            title: 'Canonical item inspector',
            child: _inspectErrorMessage != null
                ? AdminMessageRow(
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

  Widget _buildProvidersTab(BuildContext context, {required bool isAdmin}) {
    final visibleProviderResults = _visibleProviderResults();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminPanel(
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
        AdminPanel(
          icon: Icons.pending_actions_outlined,
          title: 'Metadata proposals',
          trailing: IconButton(
            tooltip: 'Refresh proposals',
            onPressed:
                _proposalsController.isLoading ? null : _loadProposalData,
            icon: _proposalsController.isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          child: AdminProposalsPanel(
            summary: _proposalsController.summary,
            statusFilter: _proposalsController.statusFilter,
            providerFilter: _proposalsController.providerFilter,
            providers: _providers,
            isLoading: _proposalsController.isLoading,
            activeProposalTitle: _activeProposalTitle,
            statusMessage: _proposalStatusMessage,
            errorMessage: _proposalErrorMessage,
            onStatusChanged: _changeProposalStatusFilter,
            onProviderChanged: _changeProposalProviderFilter,
            onClearReview: _clearActiveProposal,
            content: _proposalsController.proposals.isEmpty
                ? Text(
                    'No ${_proposalsController.statusFilter.toLowerCase()} proposals found.')
                : Column(
                    children: [
                      for (final proposal in _proposalsController.proposals)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminProposalTile(
                            proposal: proposal,
                            isActing: _proposalActionId == proposal.id,
                            canApproveLinkedItem:
                                _providerSupportsIngest(proposal.provider),
                            kindLabel: _proposalKindLabel(
                              inferAdminProposalKind(
                                proposal.provider,
                                proposal.metadataPayload,
                              ),
                            ),
                            payloadPreview:
                                (proposal.metadataPayload ?? JsonMap()).isEmpty
                                    ? null
                                    : _ProposalPayloadPreview(
                                        kind: catalogMediaKindFromValue(
                                          inferAdminProposalKind(
                                            proposal.provider,
                                            proposal.metadataPayload,
                                          ),
                                        ),
                                        payload: Map<String, Object?>.from(
                                          proposal.metadataPayload!,
                                        ),
                                      ),
                            onReview: () => _reviewProposal(proposal),
                            onEdit: () => _editProposalMetadata(proposal),
                            onApprove: () => _approveProposal(proposal),
                            onApproveLinked: () =>
                                _approveProposalWithLinkedItem(proposal),
                            onReject: () => _rejectProposal(proposal),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        AdminPanel(
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
                      label: adminProviderKindLabel(
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
                    onPressed: _activeProposalId == null
                        ? null
                        : _prefillFromActiveProposal,
                    icon: const Icon(Icons.history_toggle_off_outlined),
                    label: const Text('Prefill from active proposal'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _ingestJobsController.history.isEmpty
                        ? null
                        : _prefillFromLatestIngest,
                    icon: const Icon(Icons.playlist_add_check_circle_outlined),
                    label: const Text('Prefill from latest ingest'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _results.isEmpty
                        ? null
                        : () {
                            _refresh(() {
                              _results = const <ProviderSearchResult>[];
                              _statusMessage = null;
                              _errorMessage = null;
                            });
                          },
                    icon: const Icon(Icons.layers_clear_outlined),
                    label: const Text('Clear results'),
                  ),
                ],
              ),
              if (_statusMessage != null || _errorMessage != null) ...[
                const SizedBox(height: 12),
                AdminMessageRow(
                  message: _errorMessage ?? _statusMessage!,
                  isError: _errorMessage != null,
                ),
              ],
              const SizedBox(height: 12),
              AdminProviderEntityScopeToggles(
                showMediaResults: _showProviderMediaResults,
                showReleaseResults: _showProviderReleaseResults,
                onShowMediaResultsChanged: (value) {
                  if (!value && !_showProviderReleaseResults) {
                    return;
                  }
                  _refresh(() {
                    _showProviderMediaResults = value;
                  });
                },
                onShowReleaseResultsChanged: (value) {
                  if (!value && !_showProviderMediaResults) {
                    return;
                  }
                  _refresh(() {
                    _showProviderReleaseResults = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _ProviderResultsList(
                results: visibleProviderResults,
                ingestingProviderItemId: _ingestingProviderItemId,
                canIngestProvider: _providerSupportsIngest,
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
          AdminPanel(
            icon: Icons.rule_folder_outlined,
            title: 'Mapping & prefill rules',
            child: _ReleaseMappingRulesPanel(
              rules: _releaseMappingRules,
              kindLabels: _catalogKindLabels(),
              isLoading: _isLoadingReleaseMappingRules,
              statusMessage: _releaseRulesStatusMessage,
              errorMessage: _releaseRulesErrorMessage,
              onRefresh: () =>
                  unawaited(_loadReleaseMappingRules(showErrors: true)),
              onAdd: _showCreateReleaseMappingRuleDialog,
              onEdit: (rule) =>
                  unawaited(_showEditReleaseMappingRuleDialog(rule)),
              onDelete: (rule) => unawaited(_deleteReleaseMappingRule(rule)),
              onApplyDefaults: () => unawaited(_applyRulePrefillDefaults()),
            ),
          ),
        ],
        if (isAdmin) ...[
          const SizedBox(height: 12),
          AdminPanel(
            icon: Icons.queue_outlined,
            title: 'Provider ingest jobs',
            trailing: IconButton(
              tooltip: 'Refresh ingest jobs',
              onPressed: _ingestJobsController.isLoading
                  ? null
                  : () => unawaited(_refreshIngestJobs()),
              icon: _ingestJobsController.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
            child: AdminIngestJobsPanel(
              jobs: _ingestJobsController.jobs,
              summary: _ingestJobsController.summary,
              autoRefresh: _autoRefreshIngestJobs,
              isPolling: _ingestJobsController.isLoading,
              refreshedAt: _ingestJobsController.refreshedAt,
              statusFilter: _ingestJobsController.statusFilter,
              providerFilter: _ingestJobsController.providerFilter,
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
              onShowDetails: (job) => showDialog<void>(
                context: context,
                builder: (context) => _ProviderIngestJobDetailDialog(
                  job: job,
                  isActing: _jobActionId == job.id,
                  onRun: () => _runIngestJob(job),
                  onRetry: () => _retryIngestJob(job),
                  onRefresh: () => unawaited(_refreshIngestJobs()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdminPanel(
            icon: Icons.report_problem_outlined,
            title: 'Provider ingest history',
            child: _ProviderIngestHistoryList(
              history: _ingestJobsController.history,
              retryingHistoryId: _retryingHistoryId,
              onRetry: _retryIngestHistory,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminPanel(
          icon: Icons.history_outlined,
          title: 'Search index history',
          child: _SearchHistoryList(history: _searchHistory),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.manage_history_outlined,
          title: 'Admin audit log',
          child: _AdminAuditLogList(logs: _auditLogs),
        ),
      ],
    );
  }

  Widget _buildSystemTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminPanel(
          icon: Icons.account_tree_outlined,
          title: 'Collection schema',
          child: CollectionSchemaManagementPanel(
            db: ref.read(localDatabaseProvider),
          ),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.people_outline,
          title: 'User management',
          child: const AdminUsersPanel(),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.image_outlined,
          title: 'Image cache',
          child: const AdminImageCachePanel(),
        ),
        const SizedBox(height: 12),
        AdminPanel(
          icon: Icons.monitor_heart_outlined,
          title: 'Diagnostics',
          child: const AdminDiagnosticsPanel(),
        ),
      ],
    );
  }
}
