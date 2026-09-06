import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PR 2: Kind-Owned Vocabularies Verification', () {
    test(
        'Comic vocabularies have built-ins for grading, page quality, key categories, publisher',
        () {
      expect(ComicVocabularies.grade.builtIns, contains('9.8 Near Mint/Mint'));
      expect(ComicVocabularies.grade.builtIns, contains('9.6 Near Mint+'));
      expect(ComicVocabularies.pageQuality.builtIns, contains('White'));
      expect(ComicVocabularies.pageQuality.builtIns,
          contains('Off-White to White'));
      expect(
          ComicVocabularies.keyCategory.builtIns, contains('1st appearance'));
      expect(ComicVocabularies.keyCategory.builtIns, contains('Origin'));
      expect(ComicVocabularies.publisher.builtIns, contains('Marvel Comics'));
      expect(ComicVocabularies.publisher.builtIns, contains('DC Comics'));
      expect(ComicVocabularies.all.length, 10);
    });

    test(
        'Game vocabularies have platform, region, edition, age rating, condition',
        () {
      expect(GameVocabularies.platform.builtIns, contains('PlayStation 5'));
      expect(GameVocabularies.platform.builtIns, contains('Nintendo Switch'));
      expect(
          GameVocabularies.region.builtIns, contains('NTSC-U/C (US/Canada)'));
      expect(GameVocabularies.ageRating.builtIns, contains('ESRB: Teen (T)'));
      expect(GameVocabularies.condition.builtIns,
          contains('Complete in Box (CIB)'));
      expect(GameVocabularies.all.length, 5);
    });

    test(
        'Movie & TV vocabularies have packaging, distributor, screen ratio, audio, subtitles',
        () {
      expect(MovieVocabularies.packaging.builtIns, contains('Steelbook'));
      expect(MovieVocabularies.distributor.builtIns,
          contains('Criterion Collection'));
      expect(MovieVocabularies.audio.builtIns, contains('Dolby Atmos'));
      expect(MovieVocabularies.hdr.builtIns, contains('Dolby Vision'));

      expect(TvVocabularies.network.builtIns, contains('HBO'));
      expect(TvVocabularies.packaging.builtIns,
          contains('Complete Series Box Set'));
    });

    test(
        'Anime & Manga vocabularies have demographic, studio, serialization, format',
        () {
      expect(AnimeVocabularies.demographic.builtIns, contains('Shounen'));
      expect(AnimeVocabularies.studio.builtIns, contains('Kyoto Animation'));
      expect(MangaVocabularies.serialization.builtIns,
          contains('Weekly Shonen Jump'));
      expect(MangaVocabularies.publisher.builtIns, contains('VIZ Media'));
    });

    test('Book, Music, and BoardGame vocabularies are properly registered', () {
      expect(BookVocabularies.publisher.builtIns,
          contains('Penguin Random House'));
      expect(BookVocabularies.binding.builtIns, contains('First Edition'));

      expect(MusicVocabularies.format.builtIns, contains('Vinyl (12" LP)'));
      expect(MusicVocabularies.packaging.builtIns,
          contains('Standard Jewel Case'));

      expect(BoardGameVocabularies.publisher.builtIns,
          contains('Fantasy Flight Games'));
      expect(BoardGameVocabularies.category.builtIns,
          contains('Worker Placement'));
    });

    test('typed catalog projectors reject metadata from another kind', () {
      final projector = ComicVocabularies.publisher.valuesFrom;

      expect(projector, isNotNull);
      expect(projector!(const Object()), isEmpty);
      expect(
        projector(
          const ComicMedia(
            title: 'Typed Comic',
            publisher: 'Image Comics',
          ),
        ),
        contains('Image Comics'),
      );
    });

    test('typed projectors preserve nested catalog fields', () {
      expect(
        MovieVocabularies.distributor.valuesFrom!(
          const MovieCatalogMetadata(
            title: 'Typed Movie',
            distributor: 'Criterion Collection',
          ),
        ),
        contains('Criterion Collection'),
      );
      expect(
        MusicVocabularies.packaging.valuesFrom!(
          const MusicCatalogMetadata(
            title: 'Typed Album',
            packaging: 'Digipak',
          ),
        ),
        contains('Digipak'),
      );
      expect(
        TvVocabularies.screenRatio.valuesFrom!(
          const TvSeriesMetadata(
            title: 'Typed Series',
            screenRatio: '1.78:1 (16:9)',
          ),
        ),
        contains('1.78:1 (16:9)'),
      );
      expect(
        GameVocabularies.edition.valuesFrom!(
          const GameCatalogMetadata(
            title: 'Typed Game',
            physicalFormatLabel: 'Collector Edition',
          ),
        ),
        contains('Collector Edition'),
      );
    });

    test('All 9 kind edit capabilities expose matching vocabulary definitions',
        () {
      final kinds = [
        CatalogMediaKind.comic,
        CatalogMediaKind.game,
        CatalogMediaKind.movie,
        CatalogMediaKind.tv,
        CatalogMediaKind.anime,
        CatalogMediaKind.manga,
        CatalogMediaKind.book,
        CatalogMediaKind.music,
        CatalogMediaKind.boardgame,
      ];

      for (final kind in kinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        expect(runtime.kind, kind, reason: 'Runtime for $kind should exist');
        final vocCapability = runtime.edit.vocabularies;
        expect(vocCapability, isNotNull,
            reason: 'Vocabulary capability for $kind should be set');
        expect(vocCapability!.definitions, isNotEmpty,
            reason: 'Definitions for $kind should not be empty');
      }
    });
  });
}
