import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoWorkspaceProgressCard extends ConsumerWidget {
  const VideoWorkspaceProgressCard({
    super.key,
    required this.item,
    required this.child,
    this.maxLines = 2,
  });

  final LibraryProjectionRuntime item;
  final Widget child;
  final int maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary =
        ref.watch(_videoProgressSummaryProvider(item.node.titleItemId));
    final palette = appPalette(context);
    return Stack(
      children: [
        child,
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: summary.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (value) => value.releasedEpisodes == 0
                ? const SizedBox.shrink()
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.surfaceSubtle.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: palette.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class VideoWorkspaceProgressCell extends ConsumerWidget {
  const VideoWorkspaceProgressCell({
    super.key,
    required this.item,
  });

  final LibraryProjectionRuntime item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary =
        ref.watch(_videoProgressSummaryProvider(item.node.titleItemId));
    return summary.when(
      loading: () => const Text(''),
      error: (_, __) => const Text(''),
      data: (value) {
        if (value.releasedEpisodes == 0) {
          return const Text('');
        }
        return LibraryTableCellText(
          '${value.watchedEpisodes}/${value.releasedEpisodes} · ${(value.completionPercent * 100).round()}%',
        );
      },
    );
  }
}

final _videoProgressSummaryProvider =
    FutureProvider.autoDispose.family<VideoProgressSummary, String>(
  (ref, itemId) async {
    final catalogRef = CatalogEntityRef(
      kind: 'tv',
      entityType: CatalogEntityType.work,
      id: itemId,
    );
    final seasons =
        await ref.watch(seasonsByCatalogRefProvider(catalogRef).future);
    final trackedUnits =
        ref.watch(trackingUnitsByCatalogRefProvider(catalogRef));
    final watchSessions =
        ref.watch(watchSessionsByCatalogRefProvider(catalogRef));
    return const VideoProgressPresenter().build(
      seasons: seasons,
      trackedUnits: trackedUnits,
      watchSessions: watchSessions,
    );
  },
);
