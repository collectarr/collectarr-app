import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryArcDetailPage extends ConsumerStatefulWidget {
  const StoryArcDetailPage({
    super.key,
    required this.storyArcName,
  });

  final String storyArcName;

  @override
  ConsumerState<StoryArcDetailPage> createState() =>
      _StoryArcDetailPageState();
}

class _StoryArcDetailPageState extends ConsumerState<StoryArcDetailPage> {
  late Future<_StoryArcDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_StoryArcDetailData> _load() async {
    final api = ref.read(apiClientProvider);
    final results = await api.searchStoryArcs(
      query: widget.storyArcName,
      limit: 12,
    );
    if (results.isEmpty) {
      throw StateError('No story arc metadata found for ${widget.storyArcName}.');
    }
    final storyArc = _pickBestStoryArc(results, widget.storyArcName);
    final items = await api.getStoryArcItems(storyArc['id'].toString());
    return _StoryArcDetailData(
      storyArc: storyArc,
      items: items,
      alternatives: results,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyArcName),
      ),
      body: FutureBuilder<_StoryArcDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StoryArcDetailError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          return _StoryArcDetailBody(data: snapshot.data!);
        },
      ),
    );
  }
}

class _StoryArcDetailData {
  const _StoryArcDetailData({
    required this.storyArc,
    required this.items,
    required this.alternatives,
  });

  final Map<String, dynamic> storyArc;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> alternatives;
}

class _StoryArcDetailBody extends StatelessWidget {
  const _StoryArcDetailBody({required this.data});

  final _StoryArcDetailData data;

  @override
  Widget build(BuildContext context) {
    final storyArc = data.storyArc;
    final description = storyArc['description']?.toString();
    final publisher = storyArc['publisher']?.toString();
    final itemCount = (storyArc['item_count'] as num?)?.toInt() ?? data.items.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          storyArc['name']?.toString() ?? 'Story Arc',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StoryArcStatChip(
              icon: Icons.auto_stories_outlined,
              label: '$itemCount items',
            ),
            if (publisher != null && publisher.trim().isNotEmpty)
              _StoryArcStatChip(
                icon: Icons.business_outlined,
                label: publisher,
              ),
          ],
        ),
        if (description != null && description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
        const SizedBox(height: 20),
        Text(
          'Items in Arc',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (data.items.isEmpty)
          const Text('No story arc items were returned by Collectarr Core.')
        else
          for (final item in data.items)
            _StoryArcItemTile(item: item),
      ],
    );
  }
}

class _StoryArcItemTile extends StatelessWidget {
  const _StoryArcItemTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Untitled';
    final series = item['series_title']?.toString();
    final volume = item['volume_name']?.toString();
    final itemNumber = item['item_number']?.toString();
    final coverUrl = item['cover_image_url']?.toString();
    final subtitle = [
      if (series != null && series.trim().isNotEmpty) series,
      if (volume != null && volume.trim().isNotEmpty) volume,
      if (itemNumber != null && itemNumber.trim().isNotEmpty) '#$itemNumber',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 42,
            height: 56,
            child: coverUrl == null || coverUrl.trim().isEmpty
                ? const ColoredBox(
                    color: Color(0x22000000),
                    child: Icon(Icons.image_not_supported_outlined, size: 18),
                  )
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: Color(0x22000000),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Color(0x22000000),
                      child: Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
          ),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _StoryArcStatChip extends StatelessWidget {
  const _StoryArcStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _StoryArcDetailError extends StatelessWidget {
  const _StoryArcDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _pickBestStoryArc(
  List<Map<String, dynamic>> results,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  for (final result in results) {
    final name = result['name']?.toString().trim().toLowerCase();
    if (name == normalizedQuery) {
      return result;
    }
  }
  return results.first;
}