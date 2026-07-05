import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/providers/volumes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolumesSection extends ConsumerWidget {
  const VolumesSection({
    super.key,
    this.provider,
    this.providerItemId,
    this.itemId,
    this.canHydrateFromCore = false,
    this.kind,
  })  : assert(
          itemId != null || (provider != null && providerItemId != null),
          'Provide itemId or provider + providerItemId.',
        ),
        assert(
          itemId == null || (provider == null && providerItemId == null),
          'Use either itemId or provider + providerItemId.',
        );

  final String? provider;
  final String? providerItemId;
  final String? itemId;
  final bool canHydrateFromCore;
  final String? kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumesAsync = itemId != null
        ? ref.watch(
            itemVolumesProvider(
              (
                itemId: itemId!,
                kind: kind,
                canHydrateFromCore: canHydrateFromCore,
              ),
            ),
          )
        : ref.watch(
            volumesProvider(
              (provider: provider!, providerItemId: providerItemId!),
            ),
          );

    return volumesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (volumes) {
        if (volumes.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Volumes (${volumes.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: volumes.length,
              itemBuilder: (_, index) =>
                  _VolumeTile(volume: volumes[index]),
            ),
          ],
        );
      },
    );
  }
}

class _VolumeTile extends StatefulWidget {
  const _VolumeTile({required this.volume});

  final Season volume;

  @override
  State<_VolumeTile> createState() => _VolumeTileState();
}

class _VolumeTileState extends State<_VolumeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final volume = widget.volume;
    return Column(
      children: [
        ListTile(
          leading: volume.posterUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: volume.posterUrl!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.menu_book),
          title: Text(volume.title),
          subtitle: Text(
            [
              if (volume.episodeCount != null)
                '${volume.episodeCount} chapters',
              if (volume.airDate != null) volume.airDate!,
            ].join(' · '),
          ),
          trailing: volume.episodes.isNotEmpty
              ? Icon(_expanded ? Icons.expand_less : Icons.expand_more)
              : null,
          onTap: volume.episodes.isNotEmpty
              ? () => setState(() => _expanded = !_expanded)
              : null,
        ),
        if (_expanded && volume.episodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: volume.episodes.length,
              itemBuilder: (_, index) =>
                  _ChapterRow(chapter: volume.episodes[index]),
            ),
          ),
      ],
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter});

  final Episode chapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              'Ch. ${chapter.episodeNumber}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (chapter.pageCount != null || chapter.runtimeMinutes != null)
                  Text(
                    '${chapter.pageCount ?? chapter.runtimeMinutes} pages',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
