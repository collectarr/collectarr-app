import 'package:flutter/material.dart';

enum ImportReviewSeverity { info, warning, error }

class ImportReviewItem {
  const ImportReviewItem({
    required this.title,
    required this.description,
    this.trailingLabel,
    this.severity = ImportReviewSeverity.info,
    this.actions = const <ImportReviewAction>[],
  });

  final String title;
  final String description;
  final String? trailingLabel;
  final ImportReviewSeverity severity;
  final List<ImportReviewAction> actions;
}

class ImportReviewAction {
  const ImportReviewAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
}

class ImportReviewPanel extends StatelessWidget {
  const ImportReviewPanel({
    super.key,
    required this.title,
    required this.items,
    this.emptyLabel = 'No items to review.',
    this.onClearAll,
    this.clearAllLabel = 'Clear all',
  });

  final String title;
  final List<ImportReviewItem> items;
  final String emptyLabel;
  final VoidCallback? onClearAll;
  final String clearAllLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.rule_folder_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onClearAll != null && items.isNotEmpty)
                  TextButton(
                    onPressed: onClearAll,
                    child: Text(clearAllLabel),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Text(emptyLabel)
            else
              for (final item in items)
                _ImportReviewItemTile(item: item),
          ],
        ),
      ),
    );
  }
}

class _ImportReviewItemTile extends StatelessWidget {
  const _ImportReviewItemTile({required this.item});

  final ImportReviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = switch (item.severity) {
      ImportReviewSeverity.info => theme.colorScheme.primary,
      ImportReviewSeverity.warning => Colors.orange,
      ImportReviewSeverity.error => theme.colorScheme.error,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: severityColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (item.trailingLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              item.trailingLabel!,
              style: theme.textTheme.labelSmall,
            ),
          ],
          if (item.actions.isNotEmpty) ...[
            const SizedBox(width: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                for (final action in item.actions)
                  action.isPrimary
                      ? FilledButton(
                          onPressed: action.onPressed,
                          child: Text(action.label),
                        )
                      : TextButton(
                          onPressed: action.onPressed,
                          child: Text(action.label),
                        ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
