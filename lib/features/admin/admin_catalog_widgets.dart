part of 'admin_page.dart';

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
