part of 'admin_page.dart';

// Catalog and audit widgets.

class _SearchHistoryList extends StatelessWidget {
  const _SearchHistoryList({required this.history});

  final List<AdminSearchHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const AdminMessageRow(
        message: 'No search reindex runs yet.',
        isError: false,
      );
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in history.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outlineVariant),
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
                      color: entry.ok ? colors.primary : colors.error,
                    ),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _MiniChip(label: entry.indexName),
                    _MiniChip(label: '${entry.indexedDocuments} docs'),
                    if (entry.error?.isNotEmpty == true)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          entry.error!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colors.error),
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

class _AdminAuditLogList extends StatelessWidget {
  const _AdminAuditLogList({required this.logs});

  final List<AdminAuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const AdminMessageRow(
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

class _DuplicateCandidateList extends StatelessWidget {
  const _DuplicateCandidateList({
    required this.candidates,
    required this.inspectingItemId,
    required this.actionItemId,
    required this.onInspect,
    required this.onIgnore,
  });

  final List<AdminDuplicateCandidate> candidates;
  final String? inspectingItemId;
  final String? actionItemId;
  final ValueChanged<AdminDuplicateCandidate> onInspect;
  final ValueChanged<AdminDuplicateCandidate> onIgnore;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const AdminMessageRow(
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
  });

  final AdminDuplicateCandidate candidate;
  final bool isInspecting;
  final bool isActing;
  final VoidCallback onInspect;
  final VoidCallback onIgnore;

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
            if (candidate.hasCoverConflicts)
              const _MiniChip(label: 'cover conflict'),
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
          ],
        ),
      ),
    );
  }
}
