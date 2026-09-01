import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/ui/library_info_chip.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_relation_strip.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/loading_indicator.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _comicSeriesDetailProvider = FutureProvider.autoDispose
    .family<_ComicSeriesDetailData, String>((ref, seriesId) async {
  final api = ref.watch(apiClientProvider);
  final series = await api.getSeries(seriesId);
  final items = await api.getSeriesItems(seriesId);
  final relations = await api.getSeriesRelations(seriesId);
  return _ComicSeriesDetailData(
    series: series,
    items: items,
    relations: relations,
  );
});

class ComicSeriesDetailPage extends ConsumerWidget {
  const ComicSeriesDetailPage({
    super.key,
    required this.seriesId,
    required this.seriesTitle,
  });

  final String seriesId;
  final String seriesTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_comicSeriesDetailProvider(seriesId));
    return Scaffold(
      appBar: AppBar(
        title: Text(seriesTitle),
      ),
      body: detail.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, _) => AppErrorCard(
          message: error.toString(),
          onRetry: () => ref.invalidate(_comicSeriesDetailProvider(seriesId)),
        ),
        data: (data) => _ComicSeriesDetailBody(data: data),
      ),
    );
  }
}

class _ComicSeriesDetailData {
  const _ComicSeriesDetailData({
    required this.series,
    required this.items,
    required this.relations,
  });

  final Map<String, dynamic> series;
  final List<Map<String, dynamic>> items;
  final List<LibraryRelationNode> relations;
}

class _ComicSeriesDetailBody extends ConsumerWidget {
  const _ComicSeriesDetailBody({required this.data});

  final _ComicSeriesDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedItemIds = ref.watch(collectionByCatalogItemProvider);
    final series = data.series;
    final description = series['description']?.toString();
    final itemCount =
        (series['item_count'] as num?)?.toInt() ?? data.items.length;
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
            LibraryInfoChip(
              icon: Icons.auto_stories_outlined,
              label: '$itemCount items',
            ),
            LibraryInfoChip(
              icon: Icons.layers_outlined,
              label: '$volumeCount volumes',
            ),
            if (status != null && status.trim().isNotEmpty)
              LibraryInfoChip(
                icon: Icons.timeline_outlined,
                label: status,
              ),
            if (country != null && country.trim().isNotEmpty)
              LibraryInfoChip(
                icon: Icons.public_outlined,
                label: country,
              ),
            if (language != null && language.trim().isNotEmpty)
              LibraryInfoChip(
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
          LibraryRelationStrip(
            title: 'Related Series',
            relations: data.relations,
            onRelationTap: (relation) {
              if (relation.targetKind.trim().toLowerCase() != 'comic') {
                return;
              }
              context.push(
                '/comic/series/${Uri.encodeComponent(relation.targetId)}?title=${Uri.encodeQueryComponent(relation.targetTitle)}',
              );
            },
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
            if (data.items.isNotEmpty)
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
                        : appPalette(context).textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
          ],
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final missingNumbers =
              _computeMissingIssues(data.items, ownedItemIds);
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
                      for (final number in missingNumbers.take(20))
                        _MissingIssueChip(label: '#$number'),
                      if (missingNumbers.length > 20)
                        _MissingIssueChip(
                            label: '+${missingNumbers.length - 20} more'),
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
            _ComicSeriesItemTile(
              item: item,
              isOwned: ownedItemIds.containsKey(item['id']?.toString()),
            ),
      ],
    );
  }
}

class _MissingIssueChip extends StatelessWidget {
  const _MissingIssueChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x22FF9800),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF9800),
        ),
      ),
    );
  }
}

class _ComicSeriesItemTile extends StatelessWidget {
  const _ComicSeriesItemTile({required this.item, required this.isOwned});

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
                ? ColoredBox(
                    color: appPalette(context)
                        .surfaceSubtle
                        .withValues(alpha: 0.82),
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 18),
                  )
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: appPalette(context)
                          .surfaceSubtle
                          .withValues(alpha: 0.82),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: appPalette(context)
                          .surfaceSubtle
                          .withValues(alpha: 0.82),
                      child: const Icon(Icons.broken_image_outlined, size: 18),
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
            : Icon(
                Icons.circle_outlined,
                color: appPalette(context).textMuted,
                size: 20,
              ),
      ),
    );
  }
}

final _issueNumberRegExp = RegExp(r'^\s*(\d+)');

List<int> _computeMissingIssues(
  List<dynamic> items,
  Map<String, OwnedItem> ownedItemIds,
) {
  final ownedNumbers = <int>{};
  final allNumbers = <int>{};
  for (final item in items) {
    if (item is! Map) continue;
    final numberString = item['item_number']?.toString();
    if (numberString == null) continue;
    final match = _issueNumberRegExp.firstMatch(numberString);
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
  if (sorted.last - sorted.first > 5000) return const [];
  final missing = <int>[];
  for (var number = sorted.first; number <= sorted.last; number++) {
    if (!ownedNumbers.contains(number) && allNumbers.contains(number)) {
      missing.add(number);
      if (missing.length > 1000) break;
    }
  }
  return missing;
}
