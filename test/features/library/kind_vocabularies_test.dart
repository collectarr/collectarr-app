import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import '../../support/contracts/concrete_kind_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind-owned vocabularies', () {
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

    test('Game vocabularies cover the reference Main, Value and Personal lists',
        () {
      // As in the reference, the lists hold only the values entries use.
      expect(
          GameVocabularies.all
              .where((vocabulary) => vocabulary.builtIns.isNotEmpty),
          isEmpty);
      expect(
        GameVocabularies.all.map((vocabulary) => vocabulary.key),
        containsAll([
          'game.series',
          'game.developer',
          'game.publisher',
          'game.genre',
          'game.storage_device',
        ]),
      );
      // As in the reference: Edition is free text and Audience Rating is the
      // only rating list.
      expect(GameVocabularies.all.map((vocabulary) => vocabulary.key),
          isNot(anyOf(contains('game.edition'), contains('game.age_rating'))));
    });

    test(
        'Movie vocabularies have packaging, distributor, screen ratio, audio, subtitles',
        () {
      expect(MovieVocabularies.packaging.builtIns, contains('Steelbook'));
      expect(MovieVocabularies.distributor.builtIns,
          contains('Criterion Collection'));
      expect(MovieVocabularies.audio.builtIns, contains('Dolby Atmos'));
      expect(MovieVocabularies.hdr.builtIns, contains('Dolby Vision'));
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
          const ComicCatalogItem(
            title: 'Typed Comic',
            publisher: 'Image Comics',
          ),
        ),
        contains('Image Comics'),
      );
    });

    test('typed projectors preserve nested catalog fields', () {
      expect(
        MovieVocabularies.screenRatio.valuesFrom!(
          const MovieCatalogMetadata(
            title: 'Typed Movie',
            screenRatio: '1.85:1',
          ),
        ),
        contains('1.85:1'),
      );
      expect(
        MusicVocabularies.packaging.valuesFrom!(
          MusicAlbum(
            title: 'Typed Album',
            packaging: 'Digipak',
          ),
        ),
        contains('Digipak'),
      );

      expect(
        GameVocabularies.format.valuesFrom!(
          const GameCatalogMetadata(
            title: 'Typed Game',
            physicalFormatLabel: 'Steam Download',
          ),
        ),
        contains('Steam Download'),
      );
    });

    test('Active kind edit capabilities expose matching vocabulary definitions',
        () {
      for (final kind in releasedLibraryKinds) {
        final runtime = testKindRegistration(kind);
        expect(runtime.kind, kind, reason: 'Runtime for $kind should exist');
        final vocCapability = libraryEditPresentationForKind(kind).vocabularies;
        expect(vocCapability, isNotNull,
            reason: 'Vocabulary capability for $kind should be set');
        expect(vocCapability!.definitions, isNotEmpty,
            reason: 'Definitions for $kind should not be empty');
      }
    });
  });
}
