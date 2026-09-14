import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy_mapper.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfMangaHierarchyProvider = FutureProvider.autoDispose
    .family<MangaSeriesHierarchy, ({String itemId, bool canHydrateFromCore})>(
  (ref, params) async {
    if (!params.canHydrateFromCore) {
      return const MangaSeriesHierarchy(seriesId: '', seriesTitle: '');
    }
    final api = ref.watch(apiClientProvider);
    final work = await api.getMangaWorkDto(params.itemId);
    final manga = MangaCoreMapper.fromWorkDto(work);
    return MangaHierarchyMapper.fromChapterRows(
      seriesId: manga.id,
      rows: manga.chapters.whereType<Map<Object?, Object?>>().map(
            (chapter) => Map<String, dynamic>.from(chapter),
          ),
    );
  },
);

/// Manga-owned contribution to the generic Collection shelf row.
///
/// Collection supplies only the extension slot and its expanded state. The
/// hierarchy model, provider hydration, and chapter/volume presentation stay
/// inside Manga.
final class MangaCollectionShelfExtension extends StatelessWidget {
  const MangaCollectionShelfExtension({
    required this.itemId,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final String itemId;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  expanded ? 'Hide volumes' : 'Show volumes',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        if (expanded) _MangaShelfVolumesPanel(itemId: itemId),
      ],
    );
  }
}

class _MangaShelfVolumesPanel extends ConsumerWidget {
  const _MangaShelfVolumesPanel({required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumesAsync = ref.watch(
      shelfMangaHierarchyProvider(
        (itemId: itemId, canHydrateFromCore: true),
      ),
    );
    return volumesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Could not load volumes',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      data: (hierarchy) {
        final volumes = hierarchy.volumes;
        if (volumes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No volumes available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: volumes
                .map((volume) => _MangaShelfVolumeTile(volume: volume))
                .toList(),
          ),
        );
      },
    );
  }
}

class _MangaShelfVolumeTile extends StatefulWidget {
  const _MangaShelfVolumeTile({required this.volume});

  final MangaVolumeHierarchyNode volume;

  @override
  State<_MangaShelfVolumeTile> createState() => _MangaShelfVolumeTileState();
}

class _MangaShelfVolumeTileState extends State<_MangaShelfVolumeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final volume = widget.volume;
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.menu_book, size: 20),
          title: Text(
            volume.title ?? 'Volume ${volume.volumeNumber}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            [
              if (volume.chapterCount != null)
                '${volume.chapterCount} chapters',
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: volume.chapters.isNotEmpty
              ? Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                )
              : null,
          onTap: volume.chapters.isNotEmpty
              ? () => setState(() => _expanded = !_expanded)
              : null,
        ),
        if (_expanded && volume.chapters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 8, bottom: 4),
            child: Column(
              children: volume.chapters
                  .map((chapter) => _MangaShelfChapterRow(chapter: chapter))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _MangaShelfChapterRow extends StatelessWidget {
  const _MangaShelfChapterRow({required this.chapter});

  final MangaChapterHierarchyNode chapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              'Ch. ${chapter.chapterNumber}',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              chapter.title ?? 'Chapter ${chapter.chapterNumber}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chapter.pageCount != null)
            Text(
              '${chapter.pageCount}p',
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}
