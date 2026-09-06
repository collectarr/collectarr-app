import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';

Iterable<AnimeTrackingUnit> animeSeedTrackingUnits(
  Iterable<CatalogItem> items,
  DateTime now,
) sync* {
  for (final item in items.where((item) => item.kind == 'anime')) {
    final episodes = item.payload['episodes'];
    if (episodes is! List) continue;
    for (final episode in episodes) {
      if (episode is! Map) continue;
      final episodeNumber = _seedAnimeInt(episode['episode_number']);
      if (episodeNumber == null) continue;
      final episodeId = episode['id']?.toString() ??
          'episode-${episodeNumber.toString().padLeft(2, '0')}';
      yield AnimeTrackingUnit(
        id: 'seed-unit-anime-${item.id}-$episodeId',
        targetRef: CatalogEntityRef(
          kind: item.kind,
          entityType: CatalogEntityType.work,
          id: item.id,
        ),
        seasonNumber: 1,
        episodeNumber: episodeNumber,
        completedAt: now.subtract(Duration(days: episodeNumber + 1)),
        updatedAt: now,
      );
    }
  }
}

int? _seedAnimeInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

CatalogItem enrichAnimeSeedItem(CatalogItem item) {
  final episodes = [
    for (var number = 1; number <= 2; number++)
      {
        'id': '${item.id}-episode-${number.toString().padLeft(2, '0')}',
        'kind': 'anime',
        'series_id': item.id,
        'episode_number': number,
        'title': '${item.title} — Episode $number',
        'description': 'Seed episode $number for ${item.title}.',
        'air_date': item.releaseDate
            ?.add(Duration(days: number * 7))
            .toUtc()
            .toIso8601String(),
        'runtime_minutes': item.payload['runtime_minutes'] ?? 24,
        'cover_image_url': item.coverImageUrl,
      },
  ];
  final releases = [
    for (final edition in seedEditionPayloads(item))
      {
        ...edition,
        'id': edition['id']?.toString() ?? '${item.id}-release-01',
        'kind': 'anime',
        'series_id': item.id,
        'release_title': edition['title'] ?? item.editionTitle ?? item.title,
        'format': edition['format'] ?? item.physicalFormat,
        'language': edition['language'] ?? item.payload['language'],
        'region_code': edition['region'] ?? item.payload['country'],
        'release_date': edition['release_date'] ??
            item.releaseDate?.toUtc().toIso8601String(),
        'publisher': edition['publisher'] ?? item.publisher,
        'barcode': edition['barcode'] ?? item.barcode,
        'media_count': item.payload['nr_discs'] ?? 1,
        'audio_tracks': [item.payload['audio_tracks'] ?? 'Japanese'],
        'subtitles': [item.payload['subtitles'] ?? 'English'],
      },
  ];
  return withSeedPayload(item, {
    'episodes': episodes,
    'releases': releases,
  });
}

List<CatalogItem> animeSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-anime-01',
        kind: 'anime',
        title: 'Cowboy Bebop',
        displayTitle: 'Cowboy Bebop: The Complete Series',
        synopsis:
            'In 2071, roughly fifty years after an accident with a hyperspace gateway made the Earth almost uninhabitable, humanity has colonized most of the rocky planets and moons of the Solar System. Spike Spiegel and Jet Black hunt bounties aboard the spaceship Bebop.',
        publisher: 'Sunrise / Bandai Visual',
        releaseYear: 1998,
        releaseDate: DateTime.utc(1998, 4, 3),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/4iZ4a41iU4w1Y91z963e6B026vP.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/4iZ4a41iU4w1Y91z963e6B026vP.jpg',
        editionTitle: 'Collector\'s Edition Blu-ray Box',
        physicalFormat: 'Blu-ray',
        barcode: '704400015502',
        variant: 'Vinyl Art Box Set',
        country: 'JP',
        language: 'ja',
        ageRating: '16+',
        sortKey: 'cowboy-bebop-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 5,
          screenRatio: '1.33:1 (4:3 Original)',
          audioTracks: 'Japanese LPCM 2.0, English Dolby TrueHD 5.1',
          subtitles: 'English, French',
        ),
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 6999,
          currency: 'USD',
          imprint: 'Funimation / Crunchyroll',
        ),
        creators: [
          {'name': 'Shinichiro Watanabe', 'role': 'director'},
          {'name': 'Keiko Nobumoto', 'role': 'writer'},
          {'name': 'Yoko Kanno', 'role': 'composer'},
          {'name': 'Toshihiro Kawamoto', 'role': 'character design'},
        ],
        characters: [
          'Spike Spiegel',
          'Faye Valentine',
          'Jet Black',
          'Edward Wong',
          'Ein'
        ],
        storyArcs: ['Vicious & Julia Saga'],
        genres: ['space western', 'sci-fi', 'neo-noir', 'action'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-bebop-bd',
            title: 'Complete Series 25th Anniversary Blu-ray',
            format: 'Blu-ray',
            publisher: 'Crunchyroll',
            releaseDate: DateTime.utc(2023, 4, 4),
            discs: const [
              CatalogDiscDto(discNumber: 1, name: 'Sessions 1-7'),
              CatalogDiscDto(discNumber: 2, name: 'Sessions 8-14'),
              CatalogDiscDto(discNumber: 3, name: 'Sessions 15-20'),
              CatalogDiscDto(
                  discNumber: 4, name: 'Sessions 21-26 (The Real Folk Blues)'),
              CatalogDiscDto(discNumber: 5, name: 'Bonus Features & Session 0'),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-anime-02',
        kind: 'anime',
        title: 'Fullmetal Alchemist: Brotherhood',
        displayTitle: 'Fullmetal Alchemist: Brotherhood - Complete Collection',
        synopsis:
            'Two brothers search for a Philosopher\'s Stone after an attempt to revive their deceased mother goes wrong and leaves them in damaged physical forms.',
        publisher: 'Bones / Aniplex',
        releaseYear: 2009,
        releaseDate: DateTime.utc(2009, 4, 5),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/5ZFUEOULaVml7p19UpFSp62YSSV.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/5ZFUEOULaVml7p19UpFSp62YSSV.jpg',
        editionTitle: 'Complete Series Blu-ray Box Set',
        physicalFormat: 'Blu-ray',
        barcode: '816546022013',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'fma-brotherhood-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 10,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese Dolby TrueHD 2.0, English Dolby TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Hiromu Arakawa', 'role': 'original creator'},
          {'name': 'Yasuhiro Irie', 'role': 'director'},
          {'name': 'Akira Senju', 'role': 'composer'},
        ],
        characters: [
          'Edward Elric',
          'Alphonse Elric',
          'Roy Mustang',
          'Riza Hawkeye',
          'Winry Rockbell'
        ],
        genres: ['shonen', 'fantasy', 'adventure', 'military'],
      ),
      seedCatalogItem(
        id: 'seed-anime-03',
        kind: 'anime',
        title: 'Steins;Gate',
        displayTitle: 'Steins;Gate: The Complete Series',
        synopsis:
            'An eccentric scientist and his ragtag group of friends accidentally discover a way to send text messages to the past, triggering a battle for the fate of humanity against a secret organization.',
        publisher: 'White Fox',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 4, 6),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/5p2eNqG67G1Z1Xz78u5t4w6k.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/5p2eNqG67G1Z1Xz78u5t4w6k.jpg',
        editionTitle: 'Limited Edition Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '704400021480',
        country: 'JP',
        language: 'ja',
        ageRating: '16+',
        sortKey: 'steins-gate-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 4,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English Dolby TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Hiroshi Hamasaki', 'role': 'director'},
          {'name': 'Chiyomaru Shikura', 'role': 'concept'},
          {'name': 'Jukki Hanada', 'role': 'writer'},
        ],
        characters: [
          'Rintaro Okabe',
          'Kurisu Makise',
          'Mayuri Shiina',
          'Itaru Hashida',
          'Suzuha Amane'
        ],
        genres: ['sci-fi', 'psychological thriller', 'time travel'],
      ),
      seedCatalogItem(
        id: 'seed-anime-04',
        kind: 'anime',
        title: 'Attack on Titan',
        displayTitle: 'Attack on Titan: The Final Season',
        synopsis:
            'After his hometown is destroyed and his mother is killed, young Eren Jaeger vows to cleanse the earth of the giant humanoid Titans that have brought humanity to the brink of extinction.',
        publisher: 'Wit Studio / MAPPA / Pony Canyon',
        releaseYear: 2013,
        releaseDate: DateTime.utc(2013, 4, 7),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/hTP1DtLGFamjfu8WqjnuQdP1n4i.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/hTP1DtLGFamjfu8WqjnuQdP1n4i.jpg',
        editionTitle: 'Collector\'s Edition Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '704400035821',
        country: 'JP',
        language: 'ja',
        ageRating: '18+',
        sortKey: 'attack-on-titan-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 8,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English DTS-HD MA 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Hajime Isayama', 'role': 'original creator'},
          {'name': 'Tetsuro Araki', 'role': 'director'},
          {'name': 'Hiroyuki Sawano', 'role': 'composer'},
        ],
        characters: [
          'Eren Yeager',
          'Mikasa Ackerman',
          'Armin Arlert',
          'Levi Ackerman',
          'Erwin Smith'
        ],
        genres: ['dark fantasy', 'post-apocalyptic', 'action', 'military'],
      ),
      seedCatalogItem(
        id: 'seed-anime-05',
        kind: 'anime',
        title: 'Mob Psycho 100',
        displayTitle: 'Mob Psycho 100: Complete Seasons 1-3',
        synopsis:
            'A psychic middle schooler tries to live a normal life and keep his growing, volatile emotional powers under control, even as trouble continually finds him.',
        publisher: 'Bones / Warner Bros. Japan',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 7, 12),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/geCRq2p40Z519c9918wZ6Xq.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/geCRq2p40Z519c9918wZ6Xq.jpg',
        editionTitle: 'Complete Collection Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '704400048128',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'mob-psycho-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 6,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'ONE', 'role': 'original creator'},
          {'name': 'Yuzuru Tachikawa', 'role': 'director'},
          {'name': 'Kenji Kawai', 'role': 'composer'},
        ],
        characters: [
          'Shigeo Kageyama (Mob)',
          'Arataka Reigen',
          'Dimple',
          'Ritsu Kageyama',
          'Teruki Hanazawa'
        ],
        genres: ['comedy', 'supernatural', 'action', 'coming-of-age'],
      ),
      seedCatalogItem(
        id: 'seed-anime-06',
        kind: 'anime',
        title: 'Vinland Saga',
        displayTitle: 'Vinland Saga: Season 1 & 2',
        synopsis:
            'Thorfinn pursues a journey with his father\'s killer in order to take revenge and end that life in a duel, as an entangling war for the crown of England erupts.',
        publisher: 'Wit Studio / MAPPA / Twin Engine',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 7, 7),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/9PfobgXj6G89k8p6p1z.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/9PfobgXj6G89k8p6p1z.jpg',
        editionTitle: 'Collector\'s Edition Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '700100000060',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-MA',
        sortKey: 'vinland-saga-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 4,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English DTS-HD MA 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Makoto Yukimura', 'role': 'original creator'},
          {'name': 'Shuhei Yabuta', 'role': 'director'},
          {'name': 'Yutaka Yamada', 'role': 'composer'},
        ],
        characters: ['Thorfinn', 'Askeladd', 'Canute', 'Thorkell', 'Einar'],
        genres: ['historical', 'action', 'adventure', 'epic drama'],
      ),
      seedCatalogItem(
        id: 'seed-anime-07',
        kind: 'anime',
        title: 'Jujutsu Kaisen',
        displayTitle: 'Jujutsu Kaisen: Shibuya Incident',
        synopsis:
            'A boy swallows a cursed talisman - the finger of a demon - and becomes cursed himself. He enters a shaman\'s school to be able to locate the demon\'s other body parts and thus exorcise himself.',
        publisher: 'MAPPA / Toho Animation',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 10, 3),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/fHpPHV5V89s9Zz6t18.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/fHpPHV5V89s9Zz6t18.jpg',
        editionTitle: 'Season 1 & 2 Limited Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '700100000077',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'jujutsu-kaisen-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 6,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English DTS-HD MA 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Gege Akutami', 'role': 'original creator'},
          {'name': 'Sunghoo Park', 'role': 'director'},
          {'name': 'Hiroaki Tsutsumi', 'role': 'composer'},
        ],
        characters: [
          'Yuji Itadori',
          'Satoru Gojo',
          'Megumi Fushiguro',
          'Nobara Kugisaki',
          'Ryomen Sukuna'
        ],
        genres: ['dark fantasy', 'supernatural', 'action'],
      ),
      seedCatalogItem(
        id: 'seed-anime-08',
        kind: 'anime',
        title: 'Frieren: Beyond Journey\'s End',
        displayTitle: 'Frieren: Beyond Journey\'s End (Sousou no Frieren)',
        synopsis:
            'An elf and her fellow adventurers have defeated the Demon King in a ten-year quest and restored peace to the land. As an elf with a lifespan of over a thousand years, Frieren promises to visit them again in half a century.',
        publisher: 'Madhouse / Toho Animation',
        releaseYear: 2023,
        releaseDate: DateTime.utc(2023, 9, 29),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/dqZENchTd7lp5zht7BdlqM7RBhD.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/dqZENchTd7lp5zht7BdlqM7RBhD.jpg',
        editionTitle: 'Volume 1-7 Collector\'s BD Box',
        physicalFormat: 'Blu-ray',
        barcode: '700100000084',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'frieren-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 7,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Kanehito Yamada', 'role': 'writer'},
          {'name': 'Tsukasa Abe', 'role': 'illustrator'},
          {'name': 'Keiichiro Saito', 'role': 'director'},
          {'name': 'Evan Call', 'role': 'composer'},
        ],
        characters: ['Frieren', 'Fern', 'Stark', 'Himmel', 'Heiter', 'Eisen'],
        genres: ['fantasy', 'adventure', 'drama', 'slice of life'],
      ),
      seedCatalogItem(
        id: 'seed-anime-09',
        kind: 'anime',
        title: 'Neon Genesis Evangelion',
        displayTitle: 'Neon Genesis Evangelion: The Complete Series',
        synopsis:
            'A teenage boy finds himself recruited by his estranged father into an elite team of pilots battling giant extraterrestrial beings threatening Tokyo-3.',
        publisher: 'Gainax / Studio Khara / King Records',
        releaseYear: 1995,
        releaseDate: DateTime.utc(1995, 10, 4),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/fcC0Zc9f28sL89g58s.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/fcC0Zc9f28sL89g58s.jpg',
        editionTitle: 'Ultimate Edition Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '826663223019',
        variant: 'Ultimate Edition',
        country: 'JP',
        language: 'ja',
        ageRating: '16+',
        sortKey: 'evangelion-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 8,
          screenRatio: '1.33:1',
          audioTracks: 'Japanese LPCM 5.1, English 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Hideaki Anno', 'role': 'director'},
          {'name': 'Shiro Sagisu', 'role': 'composer'},
          {'name': 'Yoshiyuki Sadamoto', 'role': 'character design'},
        ],
        characters: [
          'Shinji Ikari',
          'Rei Ayanami',
          'Asuka Langley Soryu',
          'Misato Katsuragi',
          'Gendo Ikari'
        ],
        genres: ['mecha', 'psychological drama', 'apocalyptic'],
      ),
      seedCatalogItem(
        id: 'seed-anime-10',
        kind: 'anime',
        title: 'Death Note',
        displayTitle: 'Death Note: The Complete Series',
        synopsis:
            'An intelligent high school student goes on a secret crusade to eliminate criminals from the world after discovering a notebook capable of killing anyone whose name is written into it.',
        publisher: 'Madhouse / Nippon Television',
        releaseYear: 2006,
        releaseDate: DateTime.utc(2006, 10, 4),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/iigTJJskR1vE0Vb8.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/iigTJJskR1vE0Vb8.jpg',
        editionTitle: 'Omega Edition Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '782009244677',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'death-note-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 23,
          nrDiscs: 5,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English DTS-HD MA 2.0',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Tsugumi Ohba', 'role': 'original creator'},
          {'name': 'Takeshi Obata', 'role': 'original illustrator'},
          {'name': 'Tetsuro Araki', 'role': 'director'},
        ],
        characters: [
          'Light Yagami (Kira)',
          'L Lawliet',
          'Ryuk',
          'Misa Amane',
          'Near'
        ],
        genres: ['psychological thriller', 'supernatural', 'mystery'],
      ),
      seedCatalogItem(
        id: 'seed-anime-11',
        kind: 'anime',
        title: 'Cyberpunk: Edgerunners',
        displayTitle: 'Cyberpunk: Edgerunners (Miniseries)',
        synopsis:
            'A street kid trying to survive in a technology and body modification-obsessed city of the future. Having everything to lose, he chooses to stay alive by becoming an edgerunner: a mercenary outlaw also known as a cyberpunk.',
        publisher: 'Studio Trigger / CD Projekt Red / Netflix',
        releaseYear: 2022,
        releaseDate: DateTime.utc(2022, 9, 13),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/7jswLzmi1Vv4vP.jpg',
        thumbnailImageUrl: 'https://image.tmdb.org/t/p/w500/7jswLzmi1Vv4vP.jpg',
        editionTitle: 'Official Sound & Vision Collection',
        physicalFormat: 'Blu-ray',
        barcode: '700100000114',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-MA',
        sortKey: 'cyberpunk-edgerunners-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 2,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese Dolby Atmos, English 5.1',
          subtitles: 'English, Japanese, Spanish',
        ),
        creators: [
          {'name': 'Hiroyuki Imaishi', 'role': 'director'},
          {'name': 'Masahiko Otsuka', 'role': 'writer'},
          {'name': 'Akira Yamaoka', 'role': 'composer'},
        ],
        characters: ['David Martinez', 'Lucy', 'Rebecca', 'Maine', 'Faraday'],
        genres: ['cyberpunk', 'action', 'sci-fi', 'tragedy'],
      ),
      seedCatalogItem(
        id: 'seed-anime-12',
        kind: 'anime',
        title: 'Demon Slayer: Kimetsu no Yaiba',
        displayTitle: 'Demon Slayer: Mugen Train Arc',
        synopsis:
            'A family is attacked by demons and only two members survive - Tanjiro and his sister Nezuko, who is turning into a demon herself. Tanjiro sets out to become a demon slayer to avenge his family and cure his sister.',
        publisher: 'Ufotable / Aniplex',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 4, 6),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/wrCVHnrZQ.jpg',
        thumbnailImageUrl: 'https://image.tmdb.org/t/p/w500/wrCVHnrZQ.jpg',
        editionTitle: 'Limited Edition Blu-ray Box',
        physicalFormat: 'Blu-ray',
        barcode: '700100000121',
        country: 'JP',
        language: 'ja',
        ageRating: '16+',
        sortKey: 'demon-slayer-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 6,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Koyoharu Gotouge', 'role': 'original creator'},
          {'name': 'Haruo Sotozaki', 'role': 'director'},
          {'name': 'Yuki Kajiura', 'role': 'composer'},
          {'name': 'Go Shiina', 'role': 'composer'},
        ],
        characters: [
          'Tanjiro Kamado',
          'Nezuko Kamado',
          'Zenitsu Agatsuma',
          'Inosuke Hashibira',
          'Kyojuro Rengoku'
        ],
        genres: ['dark fantasy', 'action', 'historical'],
      ),
      seedCatalogItem(
        id: 'seed-anime-13',
        kind: 'anime',
        title: 'Hunter x Hunter',
        displayTitle: 'Hunter x Hunter (2011): Complete Series',
        synopsis:
            'Gon Freecss aspires to become a Hunter, an exceptional being capable of greatness. With his friends and his potential, he seeks out his father, who left him when he was younger.',
        publisher: 'Madhouse / Nippon Television',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 10, 2),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/ucmpFdWzwh59syuvR1b.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/ucmpFdWzwh59syuvR1b.jpg',
        editionTitle: 'Chimera Ant Arc Collector\'s Box',
        physicalFormat: 'Blu-ray',
        barcode: '700100000138',
        country: 'JP',
        language: 'ja',
        ageRating: 'TV-14',
        sortKey: 'hunter-x-hunter-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 23,
          nrDiscs: 14,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Yoshihiro Togashi', 'role': 'original creator'},
          {'name': 'Hiroshi Koujina', 'role': 'director'},
          {'name': 'Yoshihisa Hirano', 'role': 'composer'},
        ],
        characters: [
          'Gon Freecss',
          'Killua Zoldyck',
          'Kurapika',
          'Leorio Paradinight',
          'Hisoka Morow',
          'Mereum'
        ],
        genres: ['adventure', 'fantasy', 'martial arts'],
      ),
      seedCatalogItem(
        id: 'seed-anime-14',
        kind: 'anime',
        title: 'Monster',
        displayTitle: 'Monster: The Complete Collection',
        synopsis:
            'A brilliant neurosurgeon in Germany has his life turned upside down after choosing to operate on an orphaned boy who turns out to be a charismatic, cold-blooded psychopath.',
        publisher: 'Madhouse / VAP',
        releaseYear: 2004,
        releaseDate: DateTime.utc(2004, 4, 7),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/5vH4s7c1V2Yh50rK.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/5vH4s7c1V2Yh50rK.jpg',
        editionTitle: 'Complete Series HD Remaster',
        physicalFormat: 'Blu-ray',
        barcode: '700100000145',
        country: 'JP',
        language: 'ja',
        ageRating: '18+',
        sortKey: 'monster-anime-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 8,
          screenRatio: '1.33:1',
          audioTracks: 'Japanese LPCM 2.0, English 2.0',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Naoki Urasawa', 'role': 'original creator'},
          {'name': 'Masayuki Kojima', 'role': 'director'},
          {'name': 'Kuniaki Haishima', 'role': 'composer'},
        ],
        characters: [
          'Dr. Kenzo Tenma',
          'Johan Liebert',
          'Anna Liebert (Nina Fortner)',
          'Inspector Heinrich Lunge'
        ],
        genres: ['psychological thriller', 'mystery', 'drama'],
      ),
      seedCatalogItem(
        id: 'seed-anime-15',
        kind: 'anime',
        title: 'Chainsaw Man',
        displayTitle: 'Chainsaw Man: Season 1',
        synopsis:
            'Denji is a teenage boy living with a Chainsaw Devil named Pochita. Due to the debt his father left behind, he has been living a rock-bottom life while harvesting devil corpses with Pochita.',
        publisher: 'MAPPA',
        releaseYear: 2022,
        releaseDate: DateTime.utc(2022, 10, 12),
        coverImageUrl: 'https://image.tmdb.org/t/p/w500/npdB6eFz44nz5.jpg',
        thumbnailImageUrl: 'https://image.tmdb.org/t/p/w500/npdB6eFz44nz5.jpg',
        editionTitle: 'Season 1 Limited Steelbook',
        physicalFormat: 'Blu-ray',
        barcode: '700100000152',
        country: 'JP',
        language: 'ja',
        ageRating: '18+',
        sortKey: 'chainsaw-man-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 24,
          nrDiscs: 2,
          screenRatio: '1.78:1',
          audioTracks: 'Japanese LPCM 2.0, English TrueHD 5.1',
          subtitles: 'English',
        ),
        creators: [
          {'name': 'Tatsuki Fujimoto', 'role': 'original creator'},
          {'name': 'Ryu Nakayama', 'role': 'director'},
          {'name': 'Kensuke Ushio', 'role': 'composer'},
        ],
        characters: ['Denji', 'Makima', 'Power', 'Aki Hayakawa', 'Pochita'],
        genres: ['dark fantasy', 'action', 'supernatural', 'black comedy'],
      ),
    ];

List<OwnedItem> animeSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('anime', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 180)),
          updatedAt: now,
          isDigital: false,
          condition: 'Mint',
          details: const AnimeOwnedDetails(
            features: 'Artbook, soundtrack CD, bonus episodes',
            hdrFormats: ['HDR10'],
            boxSetName: 'Collector Edition Box',
            region: 'Region A/B',
            packaging: 'Rigid slipcase',
            distributor: 'Crunchyroll',
          ),
          purchaseDate: DateTime.utc(2023, 3, 15),
          pricePaidCents: 5999,
          currency: 'USD',
          personalNotes:
              'Import Japanese/English collector\'s edition with artbook.',
          quantity: 1,
          purchaseStore: 'RightStuf / Crunchyroll Store',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> animeSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-anime-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-anime-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-anime-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 12
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2023, 4, 1),
          finishedAt: i <= 12 ? DateTime.utc(2023, 5, 1) : null,
          timesCompleted: i <= 4 ? 3 : 1,
          notes: i == 1 ? 'Soundtrack by Yoko Kanno is immortal.' : null,
          updatedAt: now,
        ),
    ];
