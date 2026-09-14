import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_transport_codec.dart';
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
            .summarize(
              const AnimeCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.boardgame,
        readSummaryCover: (item) => const BoardGameCatalogTransportCodec()
            .summarize(
              const BoardGameCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.book,
        readSummaryCover: (item) => const BookCatalogTransportCodec()
            .summarize(
              const BookCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.comic,
        readSummaryCover: (item) => const ComicCatalogTransportCodec()
            .summarize(
              const ComicCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.game,
        readSummaryCover: (item) => const GameCatalogTransportCodec()
            .summarize(
              const GameCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.manga,
        readSummaryCover: (item) => const MangaCatalogTransportCodec()
            .summarize(
              const MangaCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.movie,
        readSummaryCover: (item) => const MovieCatalogTransportCodec()
            .summarize(
              const MovieCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.music,
        readSummaryCover: (item) => const MusicCatalogTransportCodec()
            .summarize(
              const MusicCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
      (
        kind: CatalogMediaKind.tv,
        readSummaryCover: (item) => const TvCatalogTransportCodec()
            .summarize(
              const TvCatalogTransportCodec().decode(item),
            )
            .imageUrl,
      ),
    ];

    for (final testCase in cases) {
      final item = CatalogItemDto.raw(
        id: 'cover-${testCase.kind.apiValue}',
        mediaKind: testCase.kind,
        common: const CatalogCommonDto(
          title: 'Cover fixture',
          coverImageUrl: anilistCover,
          thumbnailImageUrl: anilistCover,
        ),
      );

      expect(
        testCase.readSummaryCover(item),
        anilistCover,
        reason: '${testCase.kind.apiValue} dropped the cover URL',
      );
    }
  });
}
