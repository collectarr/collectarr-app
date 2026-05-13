import 'package:flutter/material.dart';

class ComicsEmptyState extends StatelessWidget {
  const ComicsEmptyState({super.key, required this.onAddComic});

  final VoidCallback onAddComic;

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
                'Your local comics shelf is empty',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add comics from Collectarr Core or scan a barcode to save them in this device database.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
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
