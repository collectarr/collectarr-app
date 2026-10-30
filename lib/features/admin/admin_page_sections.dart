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
            statusFilter: _proposalsController.statusFilter,
            isLoading: _proposalsController.isLoading,
            statusMessage: _proposalStatusMessage,
            errorMessage: _proposalErrorMessage,
            onStatusChanged: _changeProposalStatusFilter,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProposalGroupHeading(
                    'Corrections to Core items (${_proposalsController.corrections.length})'),
                if (_proposalsController.corrections.isEmpty)
                  Text(
                      'No ${_proposalsController.statusFilter.toLowerCase()} corrections.')
                else
                  for (final correction in _proposalsController.corrections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdminCorrectionTile(
                        correction: correction,
                        kindLabel: _proposalKindLabel(correction.kind.apiValue),
                        fieldLabels: _proposalsController
                            .correctionLabels(correction.kind),
                        isActing: _proposalActionId == correction.id,
                        onApprove: () =>
                            _decideCorrection(correction, approve: true),
                        onReject: () =>
                            _decideCorrection(correction, approve: false),
                      ),
                    ),
                const SizedBox(height: 16),
                _ProposalGroupHeading(
                    'New items (${_proposalsController.proposals.length})'),
                _proposalsController.proposals.isEmpty
                    ? Text(
                        'No ${_proposalsController.statusFilter.toLowerCase()} new items.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    : _proposedItemTable(proposal),
                                onEdit: () => _editProposalMetadata(proposal),
                                onApprove: () => _approveProposal(proposal),
                                onReject: () => _rejectProposal(proposal),
                              ),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// A new item's fields in the comparison table, against a Core that has
  /// none of them yet.
  Widget _proposedItemTable(AdminMetadataProposal proposal) {
    final labels = _proposalsController
        .correctionLabels(catalogMediaKindFromValue(proposal.kind));
    return MetadataDiffPanel(
      title: 'Proposed item',
      showOnlyDifferences: false,
      countNoun: 'new field',
      localHeader: 'Proposed',
      serverHeader: 'Core now',
      entries: [
        for (final MapEntry(:key, :value) in proposal.catalogItem.entries)
          if (!_proposalInternalKeys.contains(key) &&
              coreValueText(value).isNotEmpty)
            MetadataDiffEntry(
              label: labels[key] ?? _humanFieldKey(key),
              localValue: coreValueText(value),
              serverValue: '',
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

/// Separates corrections from new-item proposals in the Proposals tab.
class _ProposalGroupHeading extends StatelessWidget {
  const _ProposalGroupHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                color: appPalette(context).link,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      );
}

const _proposalInternalKeys = {
  'id',
  'kind',
  'identifiers',
  'thumbnail_image_url'
};

String _humanFieldKey(String key) {
  final words = key.split('_').where((word) => word.isNotEmpty).join(' ');
  return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
}
