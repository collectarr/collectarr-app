import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_transport_codec.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const anilistCover =
      'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/'
      'bx1-GCsPm7waJ4kS.png';

  test('every kind summary preserves the canonical cover URL', () {
    final cases = <({
      CatalogMediaKind kind,
      String? Function(CatalogItemDto) readSummaryCover,
    })>[
      (
        kind: CatalogMediaKind.anime,
        readSummaryCover: (item) => const AnimeCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.boardgame,
        readSummaryCover: (item) => const BoardGameCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.book,
        readSummaryCover: (item) =>
            const BookCatalogTransportCodec().summarizeTransport(item).imageUrl,
      ),
      (
        kind: CatalogMediaKind.comic,
        readSummaryCover: (item) => const ComicCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.game,
        readSummaryCover: (item) =>
            const GameCatalogTransportCodec().summarizeTransport(item).imageUrl,
      ),
      (
        kind: CatalogMediaKind.manga,
        readSummaryCover: (item) => const MangaCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.movie,
        readSummaryCover: (item) => const MovieCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.music,
        readSummaryCover: (item) => const MusicCatalogTransportCodec()
            .summarizeTransport(item)
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.tv,
        readSummaryCover: (item) =>
            const TvCatalogTransportCodec().summarizeTransport(item).imageUrl,
      ),
    ];

    for (final testCase in cases) {
      final item = testCase.kind == CatalogMediaKind.music
          ? testCatalogItem(
              id: 'cover-${testCase.kind.apiValue}',
              kind: testCase.kind.apiValue,
              title: 'Cover fixture',
              coverImageUrl: anilistCover,
              thumbnailImageUrl: anilistCover,
            )
          : CatalogItemDto.raw(
              id: 'cover-${testCase.kind.apiValue}',
              mediaKind: testCase.kind,
              kindData: {
                'title': 'Cover fixture',
                'cover_image_url': anilistCover,
                'thumbnail_image_url': anilistCover,
              },
            );

      expect(
        testCase.readSummaryCover(item),
        anilistCover,
        reason: '${testCase.kind.apiValue} dropped the cover URL',
      );
    }
  });
}
