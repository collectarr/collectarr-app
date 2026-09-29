part of 'admin_page.dart';

extension _AdminPageSections on _AdminPageState {
  Widget _buildCatalogTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminCatalogSearchPanel(
          queryController: _catalogQueryController,
          kind: _catalogSearchController.kindFilter,
          kinds: _catalogKindOptions(),
          kindLabels: _catalogKindLabels(),
          isLoadingKinds: _isLoadingMediaTypes,
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
        if (_inspectErrorMessage != null) ...[
          const SizedBox(height: 12),
          AdminMessageRow(
            message: _inspectErrorMessage!,
            isError: true,
          ),
        ],
      ],
    );
  }

  Widget _buildProposalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
            isLoading: _proposalsController.isLoading,
            statusMessage: _proposalStatusMessage,
            errorMessage: _proposalErrorMessage,
            onStatusChanged: _changeProposalStatusFilter,
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
                            kindLabel: _proposalKindLabel(
                              proposal.kind,
                            ),
                            payloadPreview: proposal.catalogItem.isEmpty
                                ? null
                                : _ProposalPayloadPreview(
                                    kind: catalogMediaKindFromValue(
                                      proposal.kind,
                                    ),
                                    payload: Map<String, Object?>.from(
                                      proposal.catalogItem,
                                    ),
                                  ),
                            onEdit: () => _editProposalMetadata(proposal),
                            onApprove: () => _approveProposal(proposal),
                            onReject: () => _rejectProposal(proposal),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
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
          icon: Icons.monitor_heart_outlined,
          title: 'Diagnostics',
          child: const AdminDiagnosticsPanel(),
        ),
      ],
    );
  }
}
