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
          isLoadingKinds: _isLoadingKinds,
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
              ),
            ],
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
