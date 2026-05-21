import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeriesDetailPage extends ConsumerStatefulWidget {
  const SeriesDetailPage({
    super.key,
    required this.seriesId,
    required this.seriesTitle,
  });

  final String seriesId;
  final String seriesTitle;

  @override
  ConsumerState<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends ConsumerState<SeriesDetailPage> {
  late Future<_SeriesDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SeriesDetailData> _load() async {
    final api = ref.read(apiClientProvider);
    final series = await api.getSeries(widget.seriesId);
    final items = await api.getSeriesItems(widget.seriesId);
    final relations = await api.getSeriesRelations(widget.seriesId);
    return _SeriesDetailData(
      series: series,
      items: items,
      relations: relations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seriesTitle),
      ),
      body: FutureBuilder<_SeriesDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _SeriesDetailError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          return _SeriesDetailBody(data: snapshot.data!);
        },
      ),
    );
  }
}

class _SeriesDetailData {
  const _SeriesDetailData({
    required this.series,
    required this.items,
    required this.relations,
  });

  final Map<String, dynamic> series;
  final List<Map<String, dynamic>> items;
  final List<SeriesRelation> relations;
}

class _SeriesDetailBody extends StatelessWidget {
  const _SeriesDetailBody({required this.data});

  final _SeriesDetailData data;

  @override
  Widget build(BuildContext context) {
    final series = data.series;
    final description = series['description']?.toString();
    final itemCount = (series['item_count'] as num?)?.toInt() ?? data.items.length;
    final volumeCount = (series['volume_count'] as num?)?.toInt() ?? 0;
    final status = series['status']?.toString();
    final country = series['country']?.toString();
    final language = series['language']?.toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          series['title']?.toString() ?? 'Series',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SeriesStatChip(
              icon: Icons.auto_stories_outlined,
              label: '$itemCount items',
            ),
            _SeriesStatChip(
              icon: Icons.layers_outlined,
              label: '$volumeCount volumes',
            ),
            if (status != null && status.trim().isNotEmpty)
              _SeriesStatChip(
                icon: Icons.timeline_outlined,
                label: status,
              ),
            if (country != null && country.trim().isNotEmpty)
              _SeriesStatChip(
                icon: Icons.public_outlined,
                label: country,
              ),
            if (language != null && language.trim().isNotEmpty)
              _SeriesStatChip(
                icon: Icons.translate_outlined,
                label: language,
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
        if (data.relations.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Related Series',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.relations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _SeriesRelationCard(relation: data.relations[index]),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Series Items',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (data.items.isEmpty)
          const Text('No catalog items were returned for this series.')
        else
          for (final item in data.items) _SeriesItemTile(item: item),
      ],
    );
  }
}

class _SeriesItemTile extends StatelessWidget {
  const _SeriesItemTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Untitled';
    final volume = item['volume_name']?.toString();
    final volumeNumber = item['volume_number']?.toString();
    final itemNumber = item['item_number']?.toString();
    final coverUrl = item['cover_image_url']?.toString();
    final subtitle = [
      if (volume != null && volume.trim().isNotEmpty) volume,
      if (volumeNumber != null && volumeNumber.trim().isNotEmpty)
        'Vol. $volumeNumber',
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

class _SeriesRelationCard extends StatelessWidget {
  const _SeriesRelationCard({required this.relation});

  final SeriesRelation relation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 84,
              height: 84,
              child: relation.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: relation.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0x22000000),
                        child: Icon(Icons.image, size: 30),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0x22000000),
                        child: Icon(Icons.broken_image_outlined, size: 30),
                      ),
                    )
                  : const ColoredBox(
                      color: Color(0x22000000),
                      child: Icon(Icons.collections_bookmark_outlined, size: 30),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            relation.relationLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            relation.targetSeriesTitle,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SeriesStatChip extends StatelessWidget {
  const _SeriesStatChip({
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

class _SeriesDetailError extends StatelessWidget {
  const _SeriesDetailError({
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