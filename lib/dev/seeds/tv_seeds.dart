import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';

CatalogItem enrichTvSeedItem(CatalogItem item) {
  final seasonId = '${item.id}-season-01';
  final episodes = [
    for (var number = 1; number <= 2; number++)
      {
        'id': '${item.id}-episode-${number.toString().padLeft(2, '0')}',
        'series_id': item.id,
        'season_id': seasonId,
        'season_number': 1,
        'episode_number': number,
        'episode_title': '${item.title} — Episode $number',
        'description': 'Seed episode $number for ${item.title}.',
        'air_date': item.releaseDate
            ?.add(Duration(days: number * 7))
            .toUtc()
            .toIso8601String(),
        'runtime_minutes': item.payload['runtime_minutes'] ?? 42,
        'cover_image_url': item.coverImageUrl,
      },
  ];
  final releaseId = '${item.id}-release-01';
  final mediaId = '$releaseId-media-01';
  final releases = [
    {
      'id': releaseId,
      'kind': 'tv',
      'series_id': item.id,
      'title': item.editionTitle ?? '${item.title} Complete Series',
      'format': item.physicalFormat,
      'region_code': item.payload['country'],
      'release_date': item.releaseDate?.toUtc().toIso8601String(),
      'publisher': item.publisher,
      'sku': item.barcode,
      'episode_count': episodes.length,
      'season_count': 1,
      'runtime_minutes': item.payload['runtime_minutes'] ?? 42,
      'language_audio': [item.payload['audio_tracks'] ?? 'English'],
      'language_subtitles': [item.payload['subtitles'] ?? 'English'],
      'content_rating': item.payload['age_rating'],
      'media': [
        {
          'id': mediaId,
          'release_id': releaseId,
          'media_number': 1,
          'media_type': item.physicalFormat,
          'title': item.title,
          'episode_count': episodes.length,
          'runtime_minutes': item.payload['runtime_minutes'] ?? 42,
          'region_code': item.payload['country'],
          'color': item.payload['color'],
          'audio_tracks': item.payload['audio_tracks'],
          'subtitles': item.payload['subtitles'],
          'layers': item.payload['layers'],
          'episodes': episodes,
        },
      ],
    },
  ];
  final enriched = withSeedPayload(item, {
    'seasons': [
      {
        'id': seasonId,
        'series_id': item.id,
        'season_number': 1,
        'title': 'Season 1',
        'description': 'Seed season for ${item.title}.',
        'air_date': item.releaseDate?.toUtc().toIso8601String(),
        'episode_count': episodes.length,
        'cover_image_url': item.coverImageUrl,
        'episodes': episodes,
      },
    ],
    'releases': releases,
  });
  return enriched;
}

List<CatalogItem> tvSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-tv-01',
        kind: 'tv',
        title: 'Breaking Bad',
        displayTitle: 'Breaking Bad: The Complete Series',
        synopsis:
            'A chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine with a former student in order to secure his family\'s future.',
        publisher: 'Sony Pictures Television / AMC',
        releaseYear: 2008,
        releaseDate: DateTime.utc(2008, 1, 20),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg',
        editionTitle: 'The Complete Series Collector\'s Edition',
        physicalFormat: 'Blu-ray',
        barcode: '043396434035',
        variant: 'Collector Barrel Set',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'breaking-bad-0001',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-breaking-bad',
          seriesTitle: 'Breaking Bad Universe',
          volumeName: 'Breaking Bad',
          volumeNumber: '1',
          volumeStartYear: 2008,
          tags: 'drama, crime, thriller, prestige tv',
        ),
        video: const VideoCatalogDetails(
          runtimeMinutes: 47,
          nrDiscs: 16,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1, French DD 5.1, German DD 5.1',
          subtitles: 'English SDH, French, German, Spanish',
        ),
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 15999,
          currency: 'USD',
          imprint: 'Sony Pictures Home Entertainment',
        ),
        creators: [
          {'name': 'Vince Gilligan', 'role': 'creator'},
          {'name': 'Bryan Cranston', 'role': 'actor'},
          {'name': 'Aaron Paul', 'role': 'actor'},
          {'name': 'Giancarlo Esposito', 'role': 'actor'},
          {'name': 'Dave Porter', 'role': 'composer'},
        ],
        characters: [
          'Walter White',
          'Jesse Pinkman',
          'Gus Fring',
          'Hank Schrader',
          'Saul Goodman'
        ],
        storyArcs: ['Heisenberg Rise and Fall'],
        genres: ['crime', 'drama', 'thriller'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-bb-barrel',
            title: 'Complete Series Money Barrel Collector\'s Edition',
            format: 'Blu-ray',
            publisher: 'Sony Pictures',
            releaseDate: DateTime.utc(2013, 11, 26),
            region: 'Region A',
            discs: const [
              CatalogDiscDto(discNumber: 1, name: 'Season 1 (Episodes 1-7)'),
              CatalogDiscDto(discNumber: 2, name: 'Season 2 (Episodes 1-7)'),
              CatalogDiscDto(discNumber: 3, name: 'Season 2 (Episodes 8-13)'),
              CatalogDiscDto(discNumber: 4, name: 'Season 3 (Episodes 1-7)'),
              CatalogDiscDto(discNumber: 5, name: 'Season 3 (Episodes 8-13)'),
              CatalogDiscDto(discNumber: 6, name: 'Season 4 (Episodes 1-7)'),
              CatalogDiscDto(discNumber: 7, name: 'Season 4 (Episodes 8-13)'),
              CatalogDiscDto(discNumber: 8, name: 'Season 5 Part 1'),
              CatalogDiscDto(
                  discNumber: 9, name: 'Season 5 Part 2 (Final Episodes)'),
              CatalogDiscDto(
                  discNumber: 10, name: 'Bonus: No Half Measures Documentary'),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-tv-02',
        kind: 'tv',
        title: 'Better Call Saul',
        displayTitle: 'Better Call Saul: The Complete Series',
        synopsis:
            'The trials and tribulations of criminal lawyer Jimmy McGill in the years leading up to his fateful run-in with Walter White and Jesse Pinkman.',
        publisher: 'Sony Pictures Television / AMC',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 2, 8),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/fC2HDm5t0kHjUmYIMBYVZsugpyj.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/fC2HDm5t0kHjUmYIMBYVZsugpyj.jpg',
        editionTitle: 'Complete Series Blu-ray Box',
        physicalFormat: 'Blu-ray',
        barcode: '043396583924',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'better-call-saul-0001',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-breaking-bad',
          seriesTitle: 'Breaking Bad Universe',
          volumeName: 'Better Call Saul',
          volumeNumber: '2',
          volumeStartYear: 2015,
        ),
        video: const VideoCatalogDetails(
          runtimeMinutes: 50,
          nrDiscs: 19,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, French, Spanish',
        ),
        creators: [
          {'name': 'Vince Gilligan', 'role': 'creator'},
          {'name': 'Peter Gould', 'role': 'creator'},
          {'name': 'Bob Odenkirk', 'role': 'actor'},
          {'name': 'Rhea Seehorn', 'role': 'actor'},
          {'name': 'Michael McKean', 'role': 'actor'},
        ],
        characters: [
          'Jimmy McGill',
          'Kim Wexler',
          'Chuck McGill',
          'Mike Ehrmantraut',
          'Lalo Salamanca'
        ],
        genres: ['crime', 'legal drama', 'tragedy'],
      ),
      seedCatalogItem(
        id: 'seed-tv-03',
        kind: 'tv',
        title: 'The Wire',
        displayTitle: 'The Wire: The Complete Series',
        synopsis:
            'The Baltimore drug scene, as seen through the eyes of drug dealers and law enforcement, exploring the systemic institutional decay across police, politics, schools, and media.',
        publisher: 'HBO',
        releaseYear: 2002,
        releaseDate: DateTime.utc(2002, 6, 2),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/4lbclFySvugI51fwsyxBTOm4DqK.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/4lbclFySvugI51fwsyxBTOm4DqK.jpg',
        editionTitle: 'The Complete Series Remastered Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '883929452033',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'the-wire-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 58,
          nrDiscs: 20,
          screenRatio: '1.78:1 (16:9 Full HD Remaster)',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, French, Spanish, Danish',
        ),
        creators: [
          {'name': 'David Simon', 'role': 'creator'},
          {'name': 'Ed Burns', 'role': 'writer'},
          {'name': 'Dominic West', 'role': 'actor'},
          {'name': 'Idris Elba', 'role': 'actor'},
          {'name': 'Michael K. Williams', 'role': 'actor'},
        ],
        characters: [
          'Jimmy McNulty',
          'Stringer Bell',
          'Omar Little',
          'Bunk Moreland',
          'Avon Barksdale'
        ],
        genres: ['crime', 'drama', 'police procedural'],
      ),
      seedCatalogItem(
        id: 'seed-tv-04',
        kind: 'tv',
        title: 'Chernobyl',
        displayTitle: 'Chernobyl (Miniseries)',
        synopsis:
            'In April 1986, an explosion at the Chernobyl nuclear power plant in the Union of Soviet Socialist Republics becomes one of the world\'s worst man-made catastrophes.',
        publisher: 'HBO',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 5, 6),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/hlLXt2tOPT6RRnjiUmoxyG1LTFi.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/hlLXt2tOPT6RRnjiUmoxyG1LTFi.jpg',
        editionTitle: '4K Ultra HD Steelbook',
        physicalFormat: '4K UHD',
        barcode: '883929729869',
        variant: 'Steelbook 4K',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'chernobyl-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 65,
          nrDiscs: 2,
          screenRatio: '2.00:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, French, Spanish, German',
        ),
        creators: [
          {'name': 'Craig Mazin', 'role': 'creator'},
          {'name': 'Johan Renck', 'role': 'director'},
          {'name': 'Jared Harris', 'role': 'actor'},
          {'name': 'Stellan Skarsgård', 'role': 'actor'},
          {'name': 'Emily Watson', 'role': 'actor'},
          {'name': 'Hildur Guðnadóttir', 'role': 'composer'},
        ],
        characters: [
          'Valery Legasov',
          'Boris Shcherbina',
          'Ulana Khomyuk',
          'Vasily Ignatenko'
        ],
        genres: ['drama', 'history', 'thriller'],
      ),
      seedCatalogItem(
        id: 'seed-tv-05',
        kind: 'tv',
        title: 'True Detective',
        displayTitle: 'True Detective: Season 1',
        synopsis:
            'Seasonal anthology series in which police investigations unearth the personal and professional secrets of those involved, both within and outside the law.',
        publisher: 'HBO',
        releaseYear: 2014,
        releaseDate: DateTime.utc(2014, 1, 12),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/cuV2O5cf5KmyxDURdHHiAVpTa5t.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/cuV2O5cf5KmyxDURdHHiAVpTa5t.jpg',
        editionTitle: 'Season 1 Collector\'s Blu-ray',
        physicalFormat: 'Blu-ray',
        barcode: '883929413287',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'true-detective-0001',
        itemNumber: '1',
        video: const VideoCatalogDetails(
          runtimeMinutes: 58,
          nrDiscs: 3,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, Spanish',
        ),
        creators: [
          {'name': 'Nic Pizzolatto', 'role': 'creator'},
          {'name': 'Cary Joji Fukunaga', 'role': 'director'},
          {'name': 'Matthew McConaughey', 'role': 'actor'},
          {'name': 'Woody Harrelson', 'role': 'actor'},
          {'name': 'T Bone Burnett', 'role': 'composer'},
        ],
        characters: ['Rust Cohle', 'Marty Hart', 'Maggie Hart'],
        genres: ['crime', 'mystery', 'southern gothic', 'drama'],
      ),
      seedCatalogItem(
        id: 'seed-tv-06',
        kind: 'tv',
        title: 'Mindhunter',
        displayTitle: 'Mindhunter: Complete Series',
        synopsis:
            'In the late 1970s, two FBI agents expand criminal science by delving into the psychology of murder and getting uneasily close to all-too-real monsters.',
        publisher: 'Netflix',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 10, 13),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/fbKE87mojpIETWepSbD5Qt741d7.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/fbKE87mojpIETWepSbD5Qt741d7.jpg',
        editionTitle: 'Digital Master 4K HDR',
        physicalFormat: 'Blu-ray',
        barcode: '700200000069',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'mindhunter-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 54,
          nrDiscs: 4,
          screenRatio: '2.20:1',
          audioTracks: 'English Dolby Atmos, 5.1',
          subtitles: 'English, French, German, Spanish',
        ),
        creators: [
          {'name': 'Joe Penhall', 'role': 'creator'},
          {'name': 'David Fincher', 'role': 'director'},
          {'name': 'Jonathan Groff', 'role': 'actor'},
          {'name': 'Holt McCallany', 'role': 'actor'},
          {'name': 'Anna Torv', 'role': 'actor'},
          {'name': 'Cameron Britton', 'role': 'actor'},
        ],
        characters: ['Holden Ford', 'Bill Tench', 'Wendy Carr', 'Ed Kemper'],
        genres: ['crime', 'drama', 'psychological thriller'],
      ),
      seedCatalogItem(
        id: 'seed-tv-07',
        kind: 'tv',
        title: 'Severance',
        displayTitle: 'Severance: Season 1',
        synopsis:
            'Mark leads a team of office workers whose memories have been surgically divided between their work and personal lives. When a mysterious colleague appears outside of work, it begins a journey to discover the truth about their jobs.',
        publisher: 'Apple TV+',
        releaseYear: 2022,
        releaseDate: DateTime.utc(2022, 2, 18),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        editionTitle: 'Season 1 4K UHD Master',
        physicalFormat: '4K UHD',
        barcode: '700200000076',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'severance-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 52,
          nrDiscs: 2,
          screenRatio: '2.39:1',
          audioTracks: 'English Dolby Atmos',
          subtitles: 'English SDH, Spanish, French',
        ),
        creators: [
          {'name': 'Dan Erickson', 'role': 'creator'},
          {'name': 'Ben Stiller', 'role': 'director'},
          {'name': 'Adam Scott', 'role': 'actor'},
          {'name': 'Patricia Arquette', 'role': 'actor'},
          {'name': 'John Turturro', 'role': 'actor'},
          {'name': 'Christopher Walken', 'role': 'actor'},
        ],
        characters: [
          'Mark Scout',
          'Helly R.',
          'Irving Bailiff',
          'Dylan George',
          'Harmony Cobel'
        ],
        genres: ['sci-fi', 'mystery', 'psychological thriller'],
      ),
      seedCatalogItem(
        id: 'seed-tv-08',
        kind: 'tv',
        title: 'The Last of Us',
        displayTitle: 'The Last of Us: Season 1',
        synopsis:
            'After a global pandemic destroys civilization, a hardened survivor takes charge of a 14-year-old girl who may be humanity\'s last hope.',
        publisher: 'HBO',
        releaseYear: 2023,
        releaseDate: DateTime.utc(2023, 1, 15),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/uKvVjK0B1XYumIuOQIIGtfURTG7.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/uKvVjK0B1XYumIuOQIIGtfURTG7.jpg',
        editionTitle: 'Season 1 4K Ultra HD Steelbook',
        physicalFormat: '4K UHD',
        barcode: '883929801893',
        variant: 'Steelbook',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'last-of-us-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 60,
          nrDiscs: 4,
          screenRatio: '1.78:1',
          audioTracks: 'English Dolby Atmos, French DD 5.1',
          subtitles: 'English SDH, French, Spanish',
        ),
        creators: [
          {'name': 'Craig Mazin', 'role': 'creator'},
          {'name': 'Neil Druckmann', 'role': 'creator'},
          {'name': 'Pedro Pascal', 'role': 'actor'},
          {'name': 'Bella Ramsey', 'role': 'actor'},
          {'name': 'Gustavo Santaolalla', 'role': 'composer'},
        ],
        characters: ['Joel Miller', 'Ellie Williams', 'Tess', 'Tommy', 'Bill'],
        genres: ['post-apocalyptic', 'drama', 'action', 'adventure'],
      ),
      seedCatalogItem(
        id: 'seed-tv-09',
        kind: 'tv',
        title: 'Fargo',
        displayTitle: 'Fargo: Year 1',
        synopsis:
            'Anthology series inspired by the 1996 film, chronicling deception, intrigue and murder in and around frozen Minnesota.',
        publisher: 'FX / MGM',
        releaseYear: 2014,
        releaseDate: DateTime.utc(2014, 4, 15),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/6UQ04c10u63gC0pC48rMh8m5j11.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/6UQ04c10u63gC0pC48rMh8m5j11.jpg',
        editionTitle: 'Year 1 Blu-ray Edition',
        physicalFormat: 'Blu-ray',
        barcode: '024543977537',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'fargo-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 55,
          nrDiscs: 3,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, Spanish',
        ),
        creators: [
          {'name': 'Noah Hawley', 'role': 'creator'},
          {'name': 'Billy Bob Thornton', 'role': 'actor'},
          {'name': 'Martin Freeman', 'role': 'actor'},
          {'name': 'Allison Tolman', 'role': 'actor'},
        ],
        characters: [
          'Lorne Malvo',
          'Lester Nygaard',
          'Molly Solverson',
          'Gus Grimly'
        ],
        genres: ['crime', 'dark comedy', 'thriller'],
      ),
      seedCatalogItem(
        id: 'seed-tv-10',
        kind: 'tv',
        title: 'Dark',
        displayTitle: 'Dark: The Complete Cycle',
        synopsis:
            'A family saga with a supernatural twist, set in a German town where the disappearance of two young children exposes the relationships among four families across multiple generations.',
        publisher: 'Netflix',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 12, 1),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/apbrbWs8M9lyOpJYU5WXrpFbk1Z.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/apbrbWs8M9lyOpJYU5WXrpFbk1Z.jpg',
        editionTitle: 'Complete Trilogy Master 4K',
        physicalFormat: 'Blu-ray',
        barcode: '700200000106',
        country: 'DE',
        language: 'de',
        ageRating: 'TV-MA',
        sortKey: 'dark-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 56,
          nrDiscs: 6,
          screenRatio: '2.00:1',
          audioTracks: 'German Dolby Atmos, English 5.1',
          subtitles: 'German, English, French, Spanish',
        ),
        creators: [
          {'name': 'Baran bo Odar', 'role': 'creator'},
          {'name': 'Jantje Friese', 'role': 'creator'},
          {'name': 'Louis Hofmann', 'role': 'actor'},
          {'name': 'Ben Frost', 'role': 'composer'},
        ],
        characters: [
          'Jonas Kahnwald',
          'Martha Nielsen',
          'Ulrich Nielsen',
          'Claudia Tiedemann'
        ],
        genres: ['sci-fi', 'mystery', 'time travel', 'drama'],
      ),
      seedCatalogItem(
        id: 'seed-tv-11',
        kind: 'tv',
        title: 'Succession',
        displayTitle: 'Succession: The Complete Series',
        synopsis:
            'The Roy family is known for controlling the biggest media and entertainment company in the world. However, their world changes when their aging father steps down from the company.',
        publisher: 'HBO',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 6, 3),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/7duYsN6i7w99GMjW8Pz6j0pW49Z.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/7duYsN6i7w99GMjW8Pz6j0pW49Z.jpg',
        editionTitle: 'The Complete Series Blu-ray Box',
        physicalFormat: 'Blu-ray',
        barcode: '883929806492',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'succession-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 62,
          nrDiscs: 12,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, Spanish',
        ),
        creators: [
          {'name': 'Jesse Armstrong', 'role': 'creator'},
          {'name': 'Brian Cox', 'role': 'actor'},
          {'name': 'Jeremy Strong', 'role': 'actor'},
          {'name': 'Sarah Snook', 'role': 'actor'},
          {'name': 'Kieran Culkin', 'role': 'actor'},
          {'name': 'Nicholas Britell', 'role': 'composer'},
        ],
        characters: [
          'Logan Roy',
          'Kendall Roy',
          'Shiv Roy',
          'Roman Roy',
          'Tom Wambsgans'
        ],
        genres: ['satire', 'drama', 'corporate thriller'],
      ),
      seedCatalogItem(
        id: 'seed-tv-12',
        kind: 'tv',
        title: 'Arcane',
        displayTitle: 'Arcane: League of Legends - Season 1',
        synopsis:
            'Set in the utopian region of Piltover and the oppressed underground of Zaun, the story follows the origins of two iconic League champions-and the power that will tear them apart.',
        publisher: 'Riot Games / Fortiche / Netflix',
        releaseYear: 2021,
        releaseDate: DateTime.utc(2021, 11, 6),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/abf31395j9z6gY03s19F680B1qJ.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/abf31395j9z6gY03s19F680B1qJ.jpg',
        editionTitle: 'Collector\'s 4K UHD Steelbook Set',
        physicalFormat: '4K UHD',
        barcode: '826663248920',
        variant: 'Collector\'s Steelbook',
        country: 'US',
        language: 'en',
        ageRating: 'TV-14',
        sortKey: 'arcane-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 42,
          nrDiscs: 3,
          screenRatio: '2.39:1',
          audioTracks: 'English Dolby Atmos, French DD 5.1, Japanese DD 5.1',
          subtitles: 'English SDH, French, Spanish, Japanese',
        ),
        creators: [
          {'name': 'Christian Linke', 'role': 'creator'},
          {'name': 'Alex Yee', 'role': 'creator'},
          {'name': 'Hailee Steinfeld', 'role': 'actor'},
          {'name': 'Ella Purnell', 'role': 'actor'},
        ],
        characters: [
          'Vi',
          'Jinx / Powder',
          'Caitlyn Kiramman',
          'Jayce Talis',
          'Viktor',
          'Silco'
        ],
        genres: ['animation', 'action', 'sci-fi', 'fantasy'],
      ),
      seedCatalogItem(
        id: 'seed-tv-13',
        kind: 'tv',
        title: 'Stranger Things',
        displayTitle: 'Stranger Things: Season 1',
        synopsis:
            'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
        publisher: 'Netflix',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 7, 15),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
        editionTitle: 'VHS Style Collector\'s 4K UHD',
        physicalFormat: '4K UHD',
        barcode: '191329048382',
        variant: 'VHS Box Packaging',
        country: 'US',
        language: 'en',
        ageRating: 'TV-14',
        sortKey: 'stranger-things-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 51,
          nrDiscs: 4,
          screenRatio: '2.00:1',
          audioTracks: 'English Dolby Atmos, 5.1',
          subtitles: 'English SDH, Spanish',
        ),
        creators: [
          {'name': 'The Duffer Brothers', 'role': 'creator'},
          {'name': 'Millie Bobby Brown', 'role': 'actor'},
          {'name': 'David Harbour', 'role': 'actor'},
          {'name': 'Winona Ryder', 'role': 'actor'},
        ],
        characters: [
          'Eleven',
          'Mike Wheeler',
          'Jim Hopper',
          'Dustin Henderson',
          'Joyce Byers'
        ],
        genres: ['sci-fi', 'horror', 'mystery', 'drama'],
      ),
      seedCatalogItem(
        id: 'seed-tv-14',
        kind: 'tv',
        title: 'Band of Brothers',
        displayTitle: 'Band of Brothers (Miniseries)',
        synopsis:
            'The story of Easy Company of the U.S. Army 101st Airborne Division and their mission in World War II Europe, from Operation Overlord to V-J Day.',
        publisher: 'HBO',
        releaseYear: 2001,
        releaseDate: DateTime.utc(2001, 9, 9),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/z4gU9H4w199xZ8v16Z48x8p6m.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/z4gU9H4w199xZ8v16Z48x8p6m.jpg',
        editionTitle: 'Tin Box Commemorative Blu-ray Set',
        physicalFormat: 'Blu-ray',
        barcode: '883929013890',
        variant: 'Embossed Tin Box',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'band-of-brothers-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 60,
          nrDiscs: 6,
          screenRatio: '1.78:1',
          audioTracks: 'English DTS-HD MA 5.1',
          subtitles: 'English SDH, French, Spanish',
        ),
        creators: [
          {'name': 'Tom Hanks', 'role': 'creator'},
          {'name': 'Steven Spielberg', 'role': 'creator'},
          {'name': 'Damian Lewis', 'role': 'actor'},
          {'name': 'Ron Livingston', 'role': 'actor'},
          {'name': 'Michael Kamen', 'role': 'composer'},
        ],
        characters: [
          'Major Richard Winters',
          'Captain Lewis Nixon',
          'Carwood Lipton',
          'Donald Malarkey'
        ],
        genres: ['war', 'history', 'drama'],
      ),
      seedCatalogItem(
        id: 'seed-tv-15',
        kind: 'tv',
        title: 'Game of Thrones',
        displayTitle: 'Game of Thrones: The Complete Collection',
        synopsis:
            'Nine noble families fight for control over the lands of Westeros, while an ancient enemy returns after being dormant for millennia.',
        publisher: 'HBO',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 4, 17),
        coverImageUrl:
            'https://image.tmdb.org/t/p/w500/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
        thumbnailImageUrl:
            'https://image.tmdb.org/t/p/w500/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
        editionTitle: 'Complete Series 4K Ultra HD Box Set',
        physicalFormat: '4K UHD',
        barcode: '883929703494',
        country: 'US',
        language: 'en',
        ageRating: 'TV-MA',
        sortKey: 'game-of-thrones-0001',
        video: const VideoCatalogDetails(
          runtimeMinutes: 58,
          nrDiscs: 30,
          screenRatio: '1.78:1',
          audioTracks: 'English Dolby Atmos, Dolby TrueHD 7.1',
          subtitles: 'English SDH, French, Spanish, German',
        ),
        creators: [
          {'name': 'David Benioff', 'role': 'creator'},
          {'name': 'D.B. Weiss', 'role': 'creator'},
          {'name': 'George R.R. Martin', 'role': 'writer'},
          {'name': 'Peter Dinklage', 'role': 'actor'},
          {'name': 'Emilia Clarke', 'role': 'actor'},
          {'name': 'Kit Harington', 'role': 'actor'},
          {'name': 'Ramin Djawadi', 'role': 'composer'},
        ],
        characters: [
          'Tyrion Lannister',
          'Daenerys Targaryen',
          'Jon Snow',
          'Arya Stark',
          'Cersei Lannister'
        ],
        genres: ['fantasy', 'drama', 'action', 'adventure'],
      ),
    ];

List<OwnedItem> tvSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('tv', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 280)),
          updatedAt: now,
          isDigital: false,
          condition: 'Near Mint',
          details: const TvOwnedDetails(
            features: 'Commentary, deleted scenes, making-of documentary',
            hdrFormats: ['HDR10', 'Dolby Vision'],
            boxSetName: 'Complete Series Box Set',
            region: 'Region Free',
            packaging: 'Collector box',
            distributor: 'Warner Bros. Home Entertainment',
          ),
          purchaseDate: DateTime.utc(2022, 5, 10),
          pricePaidCents: 4999,
          currency: 'USD',
          personalNotes: 'Complete box set in pristine condition.',
          quantity: 1,
          rating: 9,
          readStatus: 'completed',
          startedAt: DateTime.utc(2022, 5, 15),
          finishedAt: DateTime.utc(2022, 6, 20),
          purchaseStore: 'Amazon',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> tvSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-tv-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-tv-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-tv-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 10
              ? MediaTrackingStatus.completed
              : (i <= 13
                  ? MediaTrackingStatus.inProgress
                  : MediaTrackingStatus.planned),
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2022, 6, 1),
          finishedAt: i <= 10 ? DateTime.utc(2022, 8, 15) : null,
          timesCompleted: i <= 5 ? 2 : 1,
          notes: i == 1 ? 'Best drama series ever written.' : null,
          updatedAt: now,
        ),
    ];
