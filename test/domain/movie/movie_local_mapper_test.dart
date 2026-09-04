import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Movie media, release, and disc',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = MovieMedia(
      id: const MovieMediaId('movie-1'),
      title: 'The Matrix',
      sortTitle: 'Matrix, The',
      description: 'A hacker discovers the nature of reality.',
      releaseDate: DateTime.utc(1999, 3, 31),
      originalLanguage: 'en',
      ageRating: 'R',
      audienceRating: '8.7',
      runtimeMinutes: 136,
      subtitle: 'The One',
      characterAppearances: const [
        MovieCharacterAppearance(
          id: 'appearance-1',
          characterId: 'character-1',
          characterName: 'Neo',
          role: 'protagonist',
        ),
      ],
      contributions: const [
        MovieContributor(
          id: 'contribution-1',
          name: 'Lana Wachowski',
          role: 'director',
        ),
      ],
      externalLinks: const [
        MovieExternalLink(id: 'link-1', url: 'https://example.com/matrix'),
      ],
      identifiers: const [
        MovieIdentifier(
          id: 'identifier-1',
          identifierType: 'tmdb',
          value: '603',
          isPrimary: true,
        ),
      ],
      trailerUrls: const [
        MovieTrailerLink(
          id: 'trailer-1',
          url: 'https://example.com/trailer',
        ),
      ],
      rawPayload: const {'source': 'core', 'cover_image_url': 'cover.jpg'},
    );
    final release = MovieRelease(
      id: const MovieReleaseId('release-1'),
      title: '4K Collector Edition',
      workId: 'movie-1',
      coverImageKey: 'cover-key',
      coverImageUrl: 'release.jpg',
      description: 'Collector release.',
      distributor: 'Warner Home Video',
      externalLinks: const [
        MovieExternalLink(url: 'https://example.com/release'),
      ],
      format: '4K UHD',
      language: 'en',
      media: const [
        MovieReleaseMedia(
          id: MovieReleaseMediaId('media-1'),
          releaseId: 'release-1',
          mediaNumber: 1,
          mediaType: 'disc',
          numDiscs: 2,
          audioTracks: 'Dolby Atmos',
          subtitles: 'English, Spanish',
        ),
      ],
      region: 'US',
      releaseDate: DateTime.utc(2018, 5, 22),
      trailerUrls: const [MovieTrailerLink(url: 'release-trailer')],
      rawPayload: const {'source': 'core'},
    );

    await db.into(db.movieMediaRows).insert(MovieLocalMapper.toMediaRow(media));
    await db.into(db.movieReleaseRows).insert(
          MovieLocalMapper.toReleaseRow(media.id, release),
        );

    final restored = MovieLocalMapper.fromMediaRow(
      await db.select(db.movieMediaRows).getSingle(),
      releases: [
        MovieLocalMapper.fromReleaseRow(
          await db.select(db.movieReleaseRows).getSingle(),
        ),
      ],
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.releaseDate?.toUtc(), media.releaseDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(restored.ageRating, media.ageRating);
    expect(restored.audienceRating, media.audienceRating);
    expect(restored.runtimeMinutes, media.runtimeMinutes);
    expect(restored.characterAppearances.single.characterName, 'Neo');
    expect(restored.contributions.single.name, 'Lana Wachowski');
    expect(restored.externalLinks.single.url, 'https://example.com/matrix');
    expect(restored.identifiers.single.value, '603');
    expect(restored.trailerUrls.single.url, 'https://example.com/trailer');
    expect(restored.rawPayload, media.rawPayload);
    expect(restored.releases, hasLength(1));

    final restoredRelease = restored.releases.single;
    expect(restoredRelease.typedId, release.typedId);
    expect(restoredRelease.title, release.title);
    expect(restoredRelease.workId, release.workId);
    expect(restoredRelease.coverImageKey, release.coverImageKey);
    expect(restoredRelease.coverImageUrl, release.coverImageUrl);
    expect(restoredRelease.distributor, release.distributor);
    expect(restoredRelease.externalLinks.single.url,
        'https://example.com/release');
    expect(restoredRelease.format, release.format);
    expect(restoredRelease.media.single.typedId,
        const MovieReleaseMediaId('media-1'));
    expect(restoredRelease.media.single.numDiscs, 2);
    expect(restoredRelease.rawPayload, release.rawPayload);
  });

  test('round trips all Movie owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = MovieOwnedDetails(
      features: 'Director commentary',
      hdrFormats: ['HDR10', 'Dolby Vision'],
      boxSetId: 'box-1',
      boxSetName: 'The Matrix Collection',
      region: 'A',
      packaging: 'SteelBook',
      distributor: 'Warner Home Video',
    );

    await db.into(db.movieOwnedDetailsRows).insert(
          MovieLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = MovieLocalMapper.fromOwnedDetailsRow(
      await db.select(db.movieOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
    expect(restored.features, details.features);
    expect(restored.hdrFormats, details.hdrFormats);
    expect(restored.boxSetId, details.boxSetId);
    expect(restored.boxSetName, details.boxSetName);
    expect(restored.region, details.region);
    expect(restored.packaging, details.packaging);
    expect(restored.distributor, details.distributor);
  });

  test('requires persisted Movie identities', () {
    expect(
      () => MovieLocalMapper.toMediaRow(
        const MovieMedia(id: MovieMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => MovieLocalMapper.toReleaseRow(
        const MovieMediaId('movie-1'),
        const MovieRelease(id: MovieReleaseId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => MovieLocalMapper.toOwnedDetailsRow('', const MovieOwnedDetails()),
      throwsStateError,
    );
  });
}
