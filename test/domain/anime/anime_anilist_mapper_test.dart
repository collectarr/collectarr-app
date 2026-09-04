import 'package:collectarr_app/features/library/kinds/anime/data/providers/anilist/anime_anilist_integration.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/providers/anilist/anime_anilist_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/anilist/models/anilist_media.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps native AniList anime data into a typed AnimeMedia graph', () {
    final media = AniListMedia(
      id: 123,
      idMal: 456,
      siteUrl: 'https://anilist.co/anime/123',
      type: 'ANIME',
      title: const AniListTitle(
        english: 'Frieren: Beyond Journey\'s End',
        romaji: 'Sousou no Frieren',
        native: '葬送のフリーレン',
      ),
      description: '<b>An elf mage</b> and her companions.',
      format: 'TV',
      status: 'FINISHED',
      episodes: 28,
      duration: 24,
      startDate: const AniListDate(year: 2023, month: 9, day: 29),
      coverImage: const AniListCoverImage(
        large: 'https://cdn/frieren-large.jpg',
      ),
      genres: const ['Adventure', 'Fantasy'],
      staff: const [
        AniListStaffCredit(
          role: 'Director',
          name: 'Keiichiro Saito',
          siteUrl: 'https://anilist.co/staff/1',
        ),
      ],
      characters: const [
        AniListCharacterCredit(
          role: 'Main',
          name: 'Frieren',
          siteUrl: 'https://anilist.co/character/1',
        ),
      ],
    );

    final anime = AnimeAniListMapper.fromNative(media);

    expect(anime.id.value, 'anime:123');
    expect(anime.title, 'Frieren: Beyond Journey\'s End');
    expect(anime.animeType, 'TV');
    expect(anime.status, 'FINISHED');
    expect(anime.episodeCount, 28);
    expect(anime.originalAirDate, DateTime.utc(2023, 9, 29));
    expect(anime.coverImageUrl, 'https://cdn/frieren-large.jpg');
    expect(anime.contributions.single.name, 'Keiichiro Saito');
    expect(anime.characterAppearances.single.characterName, 'Frieren');
    expect(anime.rawPayload['provider_ids'], {
      'anilist': '123',
      'mal': '456',
    });
    expect(anime.description, 'An elf mage and her companions.');
  });

  test('maps an AniList envelope and falls back to its image list', () {
    final envelope = NormalizedProviderEnvelopeV1(
      provider: 'anilist',
      providerItemId: 'anime:999',
      kind: 'anime',
      normalized: const {
        'title': 'A Place Further Than the Universe',
        'anime_type': 'TV',
        'episode_count': 13,
      },
      images: const [
        ProviderImageRef(provider: 'anilist', url: 'https://cdn/cover.jpg'),
      ],
      provenance: const ProviderProvenance(fetchedAt: ''),
      attribution: const ProviderAttribution(required: true),
    );

    final anime = AnimeAniListIntegration().mapEnvelope(envelope);
    expect(anime.id.value, 'anime:999');
    expect(anime.title, 'A Place Further Than the Universe');
    expect(anime.episodeCount, 13);
    expect(anime.coverImageUrl, 'https://cdn/cover.jpg');
  });

  test('rejects Manga data at the Anime AniList boundary', () {
    expect(
      () => AnimeAniListMapper.fromNative(
        const AniListMedia(id: 42, type: 'MANGA'),
      ),
      throwsStateError,
    );
    expect(
      () => AnimeAniListMapper.fromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'anilist',
          providerItemId: 'manga:42',
          kind: 'manga',
          normalized: const {'title': 'Wrong kind'},
          images: const [],
          provenance: const ProviderProvenance(fetchedAt: ''),
          attribution: const ProviderAttribution(required: false),
        ),
      ),
      throwsStateError,
    );
  });
}
