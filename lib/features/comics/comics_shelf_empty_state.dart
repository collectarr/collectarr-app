import 'package:flutter/material.dart';

class ComicsEmptyState extends StatelessWidget {
  const ComicsEmptyState({
    super.key,
    required this.onAddComic,
    this.hasActiveFilter = false,
    this.onClearFilter,
  });

  final VoidCallback onAddComic;
  final bool hasActiveFilter;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                hasActiveFilter
                    ? 'No matching comics'
                    : 'Your local comics shelf is empty',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                hasActiveFilter
                    ? 'Clear filters to return to your local shelf.'
                    : 'Search Core via GCD, Comic Vine, scan a barcode, or add a manual local item.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (hasActiveFilter)
                OutlinedButton.icon(
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear filter'),
                )
              else
                FilledButton.icon(
                  onPressed: onAddComic,
                  icon: const Icon(Icons.add),
                  label: const Text('Add from Collectarr Core'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
