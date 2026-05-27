import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/loading_indicator.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _seriesDetailProvider =
    FutureProvider.autoDispose.family<_SeriesDetailData, String>((ref, seriesId) async {
  final api = ref.watch(apiClientProvider);
  final series = await api.getSeries(seriesId);
  final items = await api.getSeriesItems(seriesId);
  final relations = await api.getSeriesRelations(seriesId);
  return _SeriesDetailData(
    series: series,
    items: items,
    relations: relations,
  );
});

class SeriesDetailPage extends ConsumerWidget {
  const SeriesDetailPage({
    super.key,
    required this.seriesId,
    required this.seriesTitle,
  });

  final String seriesId;
  final String seriesTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_seriesDetailProvider(seriesId));
    return Scaffold(
      appBar: AppBar(
        title: Text(seriesTitle),
      ),
      body: detail.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, _) => AppErrorCard(
          message: error.toString(),
          onRetry: () => ref.invalidate(_seriesDetailProvider(seriesId)),
        ),
        data: (data) => _SeriesDetailBody(data: data),
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

class _SeriesDetailBody extends ConsumerWidget {
  const _SeriesDetailBody({required this.data});

  final _SeriesDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedItemIds = ref.watch(collectionByCatalogItemProvider);
    final series = data.series;
    final description = series['description']?.toString();
    final itemCount = (series['item_count'] as num?)?.toInt() ?? data.items.length;
    final volumeCount = (series['volume_count'] as num?)?.toInt() ?? 0;
    final status = series['status']?.toString();
    final country = series['country']?.toString();
    final language = series['language']?.toString();
    final tags = (series['tags'] as List<dynamic>? ?? const <dynamic>[])
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);

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
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
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
        Row(
          children: [
            Text(
              'Series Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            if (data.items.isNotEmpty) ...[
              Builder(builder: (context) {
                final ownedCount = data.items.where((item) {
                  final id = item['id']?.toString();
                  return id != null && ownedItemIds.containsKey(id);
                }).length;
                return Text(
                  '$ownedCount / ${data.items.length} owned',
                  style: TextStyle(
                    fontSize: 12,
                    color: ownedCount == data.items.length
                        ? kAppAccent
                        : kAppTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final missingNumbers = _computeMissingIssues(data.items, ownedItemIds);
          if (missingNumbers.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x18FF9800),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x44FF9800)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: Color(0xFFFF9800)),
                      const SizedBox(width: 6),
                      Text(
                        '${missingNumbers.length} missing issue${missingNumbers.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final n in missingNumbers.take(20))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x22FF9800),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '#$n',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      if (missingNumbers.length > 20)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x22FF9800),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${missingNumbers.length - 20} more',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (data.items.isEmpty)
          const Text('No catalog items were returned for this series.')
        else
          for (final item in data.items)
            _SeriesItemTile(
              item: item,
              isOwned: ownedItemIds.containsKey(item['id']?.toString()),
            ),
      ],
    );
  }
}

class _SeriesItemTile extends StatelessWidget {
  const _SeriesItemTile({required this.item, required this.isOwned});

  final Map<String, dynamic> item;
  final bool isOwned;

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
        trailing: isOwned
            ? const Icon(Icons.check_circle, color: kAppAccent, size: 20)
            : const Icon(Icons.circle_outlined, color: kAppTextMuted, size: 20),
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

/// Computes missing issue numbers between the min and max owned issues.
List<int> _computeMissingIssues(
  List<Map<String, dynamic>> items,
  Map<String, OwnedItem> ownedItemIds,
) {
  final ownedNumbers = <int>{};
  final allNumbers = <int>{};
  for (final item in items) {
    final numberStr = item['item_number']?.toString();
    if (numberStr == null) continue;
    final match = RegExp(r'^\s*(\d+)').firstMatch(numberStr);
    final number = match == null ? null : int.tryParse(match.group(1)!);
    if (number == null) continue;
    allNumbers.add(number);
    final id = item['id']?.toString();
    if (id != null && ownedItemIds.containsKey(id)) {
      ownedNumbers.add(number);
    }
  }
  if (ownedNumbers.length < 2) return const [];
  final sorted = ownedNumbers.toList()..sort();
  final missing = <int>[];
  for (var n = sorted.first; n <= sorted.last; n++) {
    if (!ownedNumbers.contains(n) && allNumbers.contains(n)) {
      missing.add(n);
    }
  }
  return missing;
}

