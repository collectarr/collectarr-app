import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import '../../../support/builders/catalog_item_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const canonicalCover = 'https://covers.example/large/front-cover.png';

  test('every kind summary preserves the canonical cover URL', () {
    final cases = <({
      CatalogMediaKind kind,
      String? Function(CatalogItemDto) readSummaryCover,
    })>[
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
    ];

    for (final testCase in cases) {
      final item = testCase.kind == CatalogMediaKind.music
          ? testCatalogItem(
              id: 'cover-${testCase.kind.apiValue}',
              kind: testCase.kind.apiValue,
              title: 'Cover fixture',
              coverImageUrl: canonicalCover,
              thumbnailImageUrl: canonicalCover,
            )
          : CatalogItemDto.raw(
              id: 'cover-${testCase.kind.apiValue}',
              mediaKind: testCase.kind,
              kindData: {
                'title': 'Cover fixture',
                'cover_image_url': canonicalCover,
                'thumbnail_image_url': canonicalCover,
              },
            );

      expect(
        testCase.readSummaryCover(item),
        canonicalCover,
        reason: '${testCase.kind.apiValue} dropped the cover URL',
      );
    }
  });
}
