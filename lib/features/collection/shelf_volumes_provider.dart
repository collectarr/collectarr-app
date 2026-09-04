import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy_mapper.dart';
import 'package:collectarr_app/state/api_provider.dart';
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
