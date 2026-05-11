import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicDetailPage extends ConsumerWidget {
  const ComicDetailPage({required this.item, super.key});

  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.menu_book, size: 64)),
            ),
          ),
          const SizedBox(height: 16),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          if (item.itemNumber != null) Text('#${item.itemNumber}'),
          if (item.synopsis != null) ...[
            const SizedBox(height: 12),
            Text(item.synopsis!),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(collectionMutationsProvider).addItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added or queued for sync')),
                );
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add to collection'),
          ),
        ],
      ),
    );
  }
}
