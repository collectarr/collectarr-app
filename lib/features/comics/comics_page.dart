import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/comic_detail_page.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsPage extends ConsumerStatefulWidget {
  const ComicsPage({super.key});

  @override
  ConsumerState<ComicsPage> createState() => _ComicsPageState();
}

class _ComicsPageState extends ConsumerState<ComicsPage> {
  String query = 'spider-man';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(comicsSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comics'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            onPressed: () {},
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Scan barcode',
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => setState(() => query = value.trim()),
            ),
          ),
          Expanded(
            child: results.when(
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: Text(item.title),
                    subtitle: Text(item.itemNumber == null ? item.kind : '#${item.itemNumber}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ComicDetailPage(item: item)),
                      );
                    },
                    trailing: IconButton(
                      tooltip: 'Add to collection',
                      onPressed: () async {
                        await ref.read(collectionMutationsProvider).addItem(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added or queued for sync')),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  );
                },
              ),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
