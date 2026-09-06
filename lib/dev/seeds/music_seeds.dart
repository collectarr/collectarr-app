import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

CatalogItem enrichMusicSeedItem(CatalogItem item) {
  final music = item.payload['music'];
  final musicPayload =
      music is Map ? Map<String, dynamic>.from(music) : <String, dynamic>{};
  final rawTracks = musicPayload['tracks'];
  final mediaId = '${item.id}-media-01';
  final tracks = rawTracks is List && rawTracks.isNotEmpty
      ? [
          for (var index = 0; index < rawTracks.length; index++)
            _musicSeedTrack(rawTracks[index], item, mediaId, index),
        ]
      : [
          _musicSeedTrack(
            {'title': '${item.title} — Track 1', 'track_number': '1'},
            item,
            mediaId,
            0,
          ),
        ];
  final media = [
    {
      'id': mediaId,
      'kind': 'music',
      'release_id': item.id,
      'media_number': 1,
      'media_type': item.physicalFormat ?? 'Digital',
      'title': item.editionTitle ?? item.title,
      'track_count': tracks.length,
      'tracks': tracks,
      'media_condition': 'excellent',
      'packaging': item.physicalFormatLabel,
      'sound_type': 'stereo',
      'spars': 'none',
      'rpm': 33,
      'vinyl_color': 'black',
      'vinyl_weight': '180g',
    },
  ];
  return withSeedPayload(item, {
    'media': media,
    'track_count': tracks.length,
  });
}

Map<String, dynamic> _musicSeedTrack(
  Object? raw,
  CatalogItem item,
  String mediaId,
  int index,
) {
  final source =
      raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
  final durationSeconds = source['duration_seconds'];
  final trackNumber = (index + 1).toString().padLeft(2, '0');
  return {
    ...source,
    'id': '$mediaId-track-$trackNumber',
    'kind': 'music',
    'media_id': mediaId,
    'position': source['position'] ?? source['track_number'] ?? index + 1,
    'title': source['title'] ?? '${item.title} — Track ${index + 1}',
    if (durationSeconds is num) 'duration_ms': durationSeconds * 1000,
    'composition': source['composition'] ?? item.title,
    'instrument': source['instrument'] ?? 'ensemble',
  };
}

List<CatalogItem> musicSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-music-01',
        kind: 'music',
        title: 'The Dark Side of the Moon',
        displayTitle: 'Pink Floyd - The Dark Side of the Moon (1973)',
        synopsis:
            'The eighth studio album by the English rock band Pink Floyd, released on 1 March 1973. A concept album that explores themes such as conflict, greed, time, death, and mental illness.',
        publisher: 'Harvest Records / EMI',
        releaseYear: 1973,
        releaseDate: DateTime.utc(1973, 3, 1),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png',
        editionTitle: '50th Anniversary Remastered 180g Vinyl',
        physicalFormat: 'Vinyl',
        physicalFormatLabel: '180g Gatefold Vinyl LP',
        barcode: '0190295996901',
        variant: '180g Gatefold Vinyl',
        country: 'GB',
        language: 'en',
        sortKey: 'pink-floyd-0001',
        creators: [
          {'name': 'Pink Floyd', 'role': 'artist'},
          {'name': 'David Gilmour', 'role': 'guitar & vocals'},
          {'name': 'Roger Waters', 'role': 'bass & lyrics'},
          {'name': 'Richard Wright', 'role': 'keyboards'},
          {'name': 'Nick Mason', 'role': 'drums'},
          {'name': 'Alan Parsons', 'role': 'engineer'},
        ],
        genres: ['progressive rock', 'psychedelic rock', 'art rock'],
        music: const MusicCatalogDetails(
          trackCount: 10,
          catalogNumber: 'SHVL 804',
          releaseStatus: 'Official',
          discs: [
            CatalogDiscDto(discNumber: 1, name: 'Vinyl LP (Side 1 & 2)'),
          ],
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Speak to Me',
                durationSeconds: 67,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'Breathe (In the Air)',
                durationSeconds: 169,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'On the Run',
                durationSeconds: 225,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'Time',
                durationSeconds: 413,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'The Great Gig in the Sky',
                durationSeconds: 284,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '6',
                title: 'Money',
                durationSeconds: 382,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Us and Them',
                durationSeconds: 469,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'Any Colour You Like',
                durationSeconds: 205,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'Brain Damage',
                durationSeconds: 228,
                artist: 'Pink Floyd'),
            CatalogTrackDto(
                trackNumber: '10',
                title: 'Eclipse',
                durationSeconds: 123,
                artist: 'Pink Floyd'),
          ],
        ),
        editions: [
          CatalogEdition(
            id: 'seed-ed-dsotm-vinyl-50',
            title: '50th Anniversary Remaster 180g Vinyl',
            format: 'Vinyl',
            publisher: 'Pink Floyd Records',
            releaseDate: DateTime.utc(2023, 3, 24),
            variants: [
              CatalogVariant(
                id: 'seed-var-dsotm-vinyl-50',
                name: 'Gatefold 180g LP + Posters & Stickers',
                variantType: 'physical',
                barcode: '0190295996901',
                coverPriceCents: 3499,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-music-02',
        kind: 'music',
        title: 'Rumours',
        displayTitle: 'Fleetwood Mac - Rumours (1977)',
        synopsis:
            'The eleventh studio album by British-American rock band Fleetwood Mac, recorded amidst the romantic unraveling of all four band members.',
        publisher: 'Warner Bros. Records',
        releaseYear: 1977,
        releaseDate: DateTime.utc(1977, 2, 4),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/f/fb/FMacRumours.PNG',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/f/fb/FMacRumours.PNG',
        editionTitle: 'Remastered Audiophile Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '081227970901',
        country: 'US',
        language: 'en',
        sortKey: 'fleetwood-mac-0001',
        creators: [
          {'name': 'Fleetwood Mac', 'role': 'artist'},
          {'name': 'Stevie Nicks', 'role': 'vocals'},
          {'name': 'Lindsey Buckingham', 'role': 'guitar & vocals'},
          {'name': 'Christine McVie', 'role': 'keyboards & vocals'},
          {'name': 'Mick Fleetwood', 'role': 'drums'},
          {'name': 'John McVie', 'role': 'bass'},
        ],
        genres: ['soft rock', 'pop rock', 'classic rock'],
        music: const MusicCatalogDetails(
          trackCount: 11,
          catalogNumber: 'BSK 3010',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Second Hand News',
                durationSeconds: 163),
            CatalogTrackDto(
                trackNumber: '2', title: 'Dreams', durationSeconds: 254),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Never Going Back Again',
                durationSeconds: 134),
            CatalogTrackDto(
                trackNumber: '4', title: 'Don\'t Stop', durationSeconds: 191),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Go Your Own Way',
                durationSeconds: 218),
            CatalogTrackDto(
                trackNumber: '6', title: 'Songbird', durationSeconds: 200),
            CatalogTrackDto(
                trackNumber: '7', title: 'The Chain', durationSeconds: 268),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'You Make Loving Fun',
                durationSeconds: 211),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'I Don\'t Want to Know',
                durationSeconds: 195),
            CatalogTrackDto(
                trackNumber: '10', title: 'Oh Daddy', durationSeconds: 234),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Gold Dust Woman',
                durationSeconds: 291),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-03',
        kind: 'music',
        title: 'Kind of Blue',
        displayTitle: 'Miles Davis - Kind of Blue (1959)',
        synopsis:
            'Recorded at Columbia\'s 30th Street Studio in New York City, Kind of Blue is widely regarded as the greatest and most influential jazz album of all time.',
        publisher: 'Columbia Records',
        releaseYear: 1959,
        releaseDate: DateTime.utc(1959, 8, 17),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/9c/MilesDavisKindofBlue.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/9c/MilesDavisKindofBlue.jpg',
        editionTitle: 'Mono Mastered Vinyl LP',
        physicalFormat: 'Vinyl',
        barcode: '886973355213',
        country: 'US',
        language: 'en',
        sortKey: 'miles-davis-0001',
        creators: [
          {'name': 'Miles Davis', 'role': 'trumpet & bandleader'},
          {'name': 'John Coltrane', 'role': 'tenor saxophone'},
          {'name': 'Bill Evans', 'role': 'piano'},
          {'name': 'Cannonball Adderley', 'role': 'alto saxophone'},
          {'name': 'Paul Chambers', 'role': 'bass'},
          {'name': 'Jimmy Cobb', 'role': 'drums'},
        ],
        genres: ['modal jazz', 'cool jazz'],
        music: const MusicCatalogDetails(
          trackCount: 5,
          catalogNumber: 'CL 1355',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'So What', durationSeconds: 562),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'Freddie Freeloader',
                durationSeconds: 586),
            CatalogTrackDto(
                trackNumber: '3', title: 'Blue in Green', durationSeconds: 337),
            CatalogTrackDto(
                trackNumber: '4', title: 'All Blues', durationSeconds: 693),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Flamenco Sketches',
                durationSeconds: 566),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-04',
        kind: 'music',
        title: 'Thriller',
        displayTitle: 'Michael Jackson - Thriller (1982)',
        synopsis:
            'The sixth studio album by American singer Michael Jackson, produced by Quincy Jones. It became the best-selling album of all time worldwide.',
        publisher: 'Epic Records',
        releaseYear: 1982,
        releaseDate: DateTime.utc(1982, 11, 30),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png',
        editionTitle: 'Thriller 40th Anniversary SACD',
        physicalFormat: 'SACD',
        barcode: '196587345624',
        country: 'US',
        language: 'en',
        sortKey: 'michael-jackson-0001',
        creators: [
          {'name': 'Michael Jackson', 'role': 'vocals & songwriter'},
          {'name': 'Quincy Jones', 'role': 'producer'},
          {'name': 'Bruce Swedien', 'role': 'audio engineer'},
          {'name': 'Eddie Van Halen', 'role': 'guitar solo (Beat It)'},
        ],
        genres: ['pop', 'post-disco', 'funk', 'rock'],
        music: const MusicCatalogDetails(
          trackCount: 9,
          catalogNumber: 'QE 38112',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Wanna Be Startin\' Somethin\'',
                durationSeconds: 363),
            CatalogTrackDto(
                trackNumber: '2', title: 'Baby Be Mine', durationSeconds: 260),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'The Girl Is Mine (with Paul McCartney)',
                durationSeconds: 222),
            CatalogTrackDto(
                trackNumber: '4', title: 'Thriller', durationSeconds: 357),
            CatalogTrackDto(
                trackNumber: '5', title: 'Beat It', durationSeconds: 258),
            CatalogTrackDto(
                trackNumber: '6', title: 'Billie Jean', durationSeconds: 294),
            CatalogTrackDto(
                trackNumber: '7', title: 'Human Nature', durationSeconds: 246),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'P.Y.T. (Pretty Young Thing)',
                durationSeconds: 239),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'The Lady in My Life',
                durationSeconds: 300),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-05',
        kind: 'music',
        title: 'Nevermind',
        displayTitle: 'Nirvana - Nevermind (1991)',
        synopsis:
            'Produced by Butch Vig, Nevermind brought Pacific Northwest grunge rock to mainstream global popularity and altered the landscape of modern rock.',
        publisher: 'DGC Records / Geffen',
        releaseYear: 1991,
        releaseDate: DateTime.utc(1991, 9, 24),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg',
        editionTitle: '30th Anniversary 180g Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '602438517558',
        country: 'US',
        language: 'en',
        sortKey: 'nirvana-0001',
        creators: [
          {'name': 'Nirvana', 'role': 'artist'},
          {'name': 'Kurt Cobain', 'role': 'lead vocals & guitar'},
          {'name': 'Krist Novoselic', 'role': 'bass'},
          {'name': 'Dave Grohl', 'role': 'drums & vocals'},
          {'name': 'Butch Vig', 'role': 'producer'},
        ],
        genres: ['grunge', 'alternative rock'],
        music: const MusicCatalogDetails(
          trackCount: 12,
          catalogNumber: 'DGC-24425',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Smells Like Teen Spirit',
                durationSeconds: 301),
            CatalogTrackDto(
                trackNumber: '2', title: 'In Bloom', durationSeconds: 254),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Come as You Are',
                durationSeconds: 219),
            CatalogTrackDto(
                trackNumber: '4', title: 'Breed', durationSeconds: 183),
            CatalogTrackDto(
                trackNumber: '5', title: 'Lithium', durationSeconds: 257),
            CatalogTrackDto(
                trackNumber: '6', title: 'Polly', durationSeconds: 177),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Territorial Pissings',
                durationSeconds: 142),
            CatalogTrackDto(
                trackNumber: '8', title: 'Drain You', durationSeconds: 223),
            CatalogTrackDto(
                trackNumber: '9', title: 'Lounge Act', durationSeconds: 156),
            CatalogTrackDto(
                trackNumber: '10', title: 'Stay Away', durationSeconds: 212),
            CatalogTrackDto(
                trackNumber: '11', title: 'On a Plain', durationSeconds: 196),
            CatalogTrackDto(
                trackNumber: '12',
                title: 'Something in the Way',
                durationSeconds: 232),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-06',
        kind: 'music',
        title: 'Random Access Memories',
        displayTitle: 'Daft Punk - Random Access Memories (2013)',
        synopsis:
            'The fourth and final studio album by French electronic duo Daft Punk, celebrating late 1970s and early 1980s American music through live instrumentation and analog recording.',
        publisher: 'Daft Life / Columbia Records',
        releaseYear: 2013,
        releaseDate: DateTime.utc(2013, 5, 17),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg',
        editionTitle: '10th Anniversary 3xLP Vinyl Edition',
        physicalFormat: 'Vinyl',
        barcode: '196587737313',
        country: 'FR',
        language: 'en',
        sortKey: 'daft-punk-0001',
        creators: [
          {'name': 'Daft Punk', 'role': 'artist & producer'},
          {'name': 'Thomas Bangalter', 'role': 'synths & vocoder'},
          {'name': 'Guy-Manuel de Homem-Christo', 'role': 'synths & vocoder'},
          {'name': 'Giorgio Moroder', 'role': 'guest artist'},
          {'name': 'Nile Rodgers', 'role': 'guitar'},
          {'name': 'Pharrell Williams', 'role': 'vocals'},
        ],
        genres: ['disco', 'electronic', 'funk', 'synth-pop'],
        music: const MusicCatalogDetails(
          trackCount: 13,
          catalogNumber: '88883716861',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Give Life Back to Music',
                durationSeconds: 275),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'The Game of Love',
                durationSeconds: 322),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Giorgio by Moroder',
                durationSeconds: 544),
            CatalogTrackDto(
                trackNumber: '4', title: 'Within', durationSeconds: 228),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Instant Crush (feat. Julian Casablancas)',
                durationSeconds: 337),
            CatalogTrackDto(
                trackNumber: '6',
                title: 'Lose Yourself to Dance (feat. Pharrell Williams)',
                durationSeconds: 353),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Touch (feat. Paul Williams)',
                durationSeconds: 498),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'Get Lucky (feat. Pharrell Williams)',
                durationSeconds: 369),
            CatalogTrackDto(
                trackNumber: '9', title: 'Beyond', durationSeconds: 290),
            CatalogTrackDto(
                trackNumber: '10', title: 'Motherboard', durationSeconds: 341),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Fragments of Time (feat. Todd Edwards)',
                durationSeconds: 279),
            CatalogTrackDto(
                trackNumber: '12',
                title: 'Doin\' It Right (feat. Panda Bear)',
                durationSeconds: 251),
            CatalogTrackDto(
                trackNumber: '13', title: 'Contact', durationSeconds: 381),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-07',
        kind: 'music',
        title: 'OK Computer',
        displayTitle: 'Radiohead - OK Computer (1997)',
        synopsis:
            'Radiohead\'s third studio album, depicting a world beset by rampant consumerism, social alienation, emotional isolation, and political malaise.',
        publisher: 'Parlophone / Capitol',
        releaseYear: 1997,
        releaseDate: DateTime.utc(1997, 5, 21),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/b/ba/Radioheadokcomputer.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/b/ba/Radioheadokcomputer.png',
        editionTitle: 'OKNOTOK 1997 2017 Box Set',
        physicalFormat: 'Vinyl',
        barcode: '634904086817',
        country: 'GB',
        language: 'en',
        sortKey: 'radiohead-0001',
        creators: [
          {'name': 'Radiohead', 'role': 'artist'},
          {'name': 'Thom Yorke', 'role': 'lead vocals & piano'},
          {'name': 'Jonny Greenwood', 'role': 'lead guitar & electronics'},
          {'name': 'Nigel Godrich', 'role': 'producer'},
        ],
        genres: ['alternative rock', 'art rock', 'experimental rock'],
        music: const MusicCatalogDetails(
          trackCount: 12,
          catalogNumber: 'NODATA 02',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Airbag', durationSeconds: 284),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'Paranoid Android',
                durationSeconds: 383),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Subterranean Homesick Alien',
                durationSeconds: 267),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'Exit Music (For a Film)',
                durationSeconds: 264),
            CatalogTrackDto(
                trackNumber: '5', title: 'Let Down', durationSeconds: 299),
            CatalogTrackDto(
                trackNumber: '6', title: 'Karma Police', durationSeconds: 261),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Fitter Happier',
                durationSeconds: 117),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'Electioneering',
                durationSeconds: 230),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'Climbing Up the Walls',
                durationSeconds: 285),
            CatalogTrackDto(
                trackNumber: '10', title: 'No Surprises', durationSeconds: 228),
            CatalogTrackDto(
                trackNumber: '11', title: 'Lucky', durationSeconds: 259),
            CatalogTrackDto(
                trackNumber: '12', title: 'The Tourist', durationSeconds: 324),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-08',
        kind: 'music',
        title: 'To Pimp a Butterfly',
        displayTitle: 'Kendrick Lamar - To Pimp a Butterfly (2015)',
        synopsis:
            'The third studio album by American rapper Kendrick Lamar, incorporating musical styles such as jazz, funk, soul, and spoken word into a searing exploration of race and personal identity.',
        publisher: 'Top Dawg Entertainment / Aftermath / Interscope',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 3, 15),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/f/f6/Kendrick_Lamar_-_To_Pimp_a_Butterfly.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/f/f6/Kendrick_Lamar_-_To_Pimp_a_Butterfly.png',
        editionTitle: '2xLP Gatefold Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '0602547311009',
        country: 'US',
        language: 'en',
        sortKey: 'kendrick-lamar-0001',
        creators: [
          {'name': 'Kendrick Lamar', 'role': 'lead artist & vocals'},
          {'name': 'Thundercat', 'role': 'bass & producer'},
          {'name': 'Kamasi Washington', 'role': 'tenor saxophone'},
          {'name': 'Flying Lotus', 'role': 'producer'},
        ],
        genres: ['conscious hip hop', 'jazz rap', 'funk', 'neo-soul'],
        music: const MusicCatalogDetails(
          trackCount: 16,
          catalogNumber: 'B0022956-01',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Wesley\'s Theory',
                durationSeconds: 287),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'For Free? (Interlude)',
                durationSeconds: 130),
            CatalogTrackDto(
                trackNumber: '3', title: 'King Kunta', durationSeconds: 234),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'Institutionalized',
                durationSeconds: 271),
            CatalogTrackDto(
                trackNumber: '5', title: 'These Walls', durationSeconds: 300),
            CatalogTrackDto(trackNumber: '6', title: 'u', durationSeconds: 268),
            CatalogTrackDto(
                trackNumber: '7', title: 'Alright', durationSeconds: 219),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'For Sale? (Interlude)',
                durationSeconds: 291),
            CatalogTrackDto(
                trackNumber: '9', title: 'Momma', durationSeconds: 283),
            CatalogTrackDto(
                trackNumber: '10',
                title: 'Hood Politics',
                durationSeconds: 283),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'How Much a Dollar Cost',
                durationSeconds: 261),
            CatalogTrackDto(
                trackNumber: '12',
                title: 'Complexion (A Zulu Love)',
                durationSeconds: 263),
            CatalogTrackDto(
                trackNumber: '13',
                title: 'The Blacker the Berry',
                durationSeconds: 328),
            CatalogTrackDto(
                trackNumber: '14',
                title: 'You Ain\'t Gotta Lie (Momma Said)',
                durationSeconds: 241),
            CatalogTrackDto(
                trackNumber: '15', title: 'i', durationSeconds: 336),
            CatalogTrackDto(
                trackNumber: '16', title: 'Mortal Man', durationSeconds: 727),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-09',
        kind: 'music',
        title: 'Abbey Road',
        displayTitle: 'The Beatles - Abbey Road (1969)',
        synopsis:
            'The eleventh studio album by the English rock band the Beatles, featuring the iconic side-two medley and famous zebra crossing cover photograph.',
        publisher: 'Apple Records / EMI',
        releaseYear: 1969,
        releaseDate: DateTime.utc(1969, 9, 26),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg',
        editionTitle: '50th Anniversary 180g Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '0602577915123',
        country: 'GB',
        language: 'en',
        sortKey: 'beatles-0001',
        creators: [
          {'name': 'The Beatles', 'role': 'artist'},
          {'name': 'John Lennon', 'role': 'vocals & guitar'},
          {'name': 'Paul McCartney', 'role': 'vocals & bass'},
          {'name': 'George Harrison', 'role': 'lead guitar'},
          {'name': 'Ringo Starr', 'role': 'drums'},
          {'name': 'George Martin', 'role': 'producer'},
        ],
        genres: ['rock', 'pop rock', 'psychedelic rock'],
        music: const MusicCatalogDetails(
          trackCount: 17,
          catalogNumber: 'PCS 7088',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Come Together', durationSeconds: 259),
            CatalogTrackDto(
                trackNumber: '2', title: 'Something', durationSeconds: 182),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Maxwell\'s Silver Hammer',
                durationSeconds: 207),
            CatalogTrackDto(
                trackNumber: '4', title: 'Oh! Darling', durationSeconds: 207),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Octopus\'s Garden',
                durationSeconds: 171),
            CatalogTrackDto(
                trackNumber: '6',
                title: 'I Want You (She\'s So Heavy)',
                durationSeconds: 467),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Here Comes the Sun',
                durationSeconds: 185),
            CatalogTrackDto(
                trackNumber: '8', title: 'Because', durationSeconds: 165),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'You Never Give Me Your Money',
                durationSeconds: 242),
            CatalogTrackDto(
                trackNumber: '10', title: 'Sun King', durationSeconds: 146),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Mean Mr. Mustard',
                durationSeconds: 66),
            CatalogTrackDto(
                trackNumber: '12', title: 'Polythene Pam', durationSeconds: 72),
            CatalogTrackDto(
                trackNumber: '13',
                title: 'She Came In Through the Bathroom Window',
                durationSeconds: 117),
            CatalogTrackDto(
                trackNumber: '14',
                title: 'Golden Slumbers',
                durationSeconds: 91),
            CatalogTrackDto(
                trackNumber: '15',
                title: 'Carry That Weight',
                durationSeconds: 96),
            CatalogTrackDto(
                trackNumber: '16', title: 'The End', durationSeconds: 140),
            CatalogTrackDto(
                trackNumber: '17', title: 'Her Majesty', durationSeconds: 23),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-10',
        kind: 'music',
        title: 'Led Zeppelin IV',
        displayTitle: 'Led Zeppelin - Untitled (Led Zeppelin IV) (1971)',
        synopsis:
            'The untitled fourth studio album by English rock band Led Zeppelin, commonly known as Led Zeppelin IV, featuring the landmark song "Stairway to Heaven".',
        publisher: 'Atlantic Records',
        releaseYear: 1971,
        releaseDate: DateTime.utc(1971, 11, 8),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/2/26/Led_Zeppelin_-_Led_Zeppelin_IV.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/2/26/Led_Zeppelin_-_Led_Zeppelin_IV.jpg',
        editionTitle: 'Remastered 180g Vinyl LP',
        physicalFormat: 'Vinyl',
        barcode: '081227965778',
        country: 'GB',
        language: 'en',
        sortKey: 'led-zeppelin-0001',
        creators: [
          {'name': 'Led Zeppelin', 'role': 'artist'},
          {'name': 'Jimmy Page', 'role': 'guitars & producer'},
          {'name': 'Robert Plant', 'role': 'lead vocals'},
          {'name': 'John Paul Jones', 'role': 'bass & keyboards'},
          {'name': 'John Bonham', 'role': 'drums'},
        ],
        genres: ['hard rock', 'heavy metal', 'folk rock'],
        music: const MusicCatalogDetails(
          trackCount: 8,
          catalogNumber: 'SD 7208',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Black Dog', durationSeconds: 296),
            CatalogTrackDto(
                trackNumber: '2', title: 'Rock and Roll', durationSeconds: 220),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'The Battle of Evermore',
                durationSeconds: 351),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'Stairway to Heaven',
                durationSeconds: 482),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Misty Mountain Hop',
                durationSeconds: 278),
            CatalogTrackDto(
                trackNumber: '6', title: 'Four Sticks', durationSeconds: 284),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Going to California',
                durationSeconds: 211),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'When the Levee Breaks',
                durationSeconds: 427),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-11',
        kind: 'music',
        title: 'The Rise and Fall of Ziggy Stardust',
        displayTitle:
            'David Bowie - The Rise and Fall of Ziggy Stardust (1972)',
        synopsis:
            'David Bowie\'s groundbreaking glam rock concept album telling the story of Ziggy Stardust, an androgynous alien rock star acting as a messenger for human salvation.',
        publisher: 'RCA Records / Parlophone',
        releaseYear: 1972,
        releaseDate: DateTime.utc(1972, 6, 16),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/0/01/ZiggyStardust.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/0/01/ZiggyStardust.jpg',
        editionTitle: '50th Anniversary Half-Speed Mastered Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '0190296726804',
        country: 'GB',
        language: 'en',
        sortKey: 'david-bowie-0001',
        creators: [
          {'name': 'David Bowie', 'role': 'lead vocals & acoustic guitar'},
          {'name': 'Mick Ronson', 'role': 'lead guitar & piano'},
          {'name': 'Ken Scott', 'role': 'producer'},
        ],
        genres: ['glam rock', 'proto-punk', 'art rock'],
        music: const MusicCatalogDetails(
          trackCount: 11,
          catalogNumber: 'SF 8287',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Five Years', durationSeconds: 282),
            CatalogTrackDto(
                trackNumber: '2', title: 'Soul Love', durationSeconds: 214),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'Moonage Daydream',
                durationSeconds: 280),
            CatalogTrackDto(
                trackNumber: '4', title: 'Starman', durationSeconds: 250),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'It Ain\'t Easy',
                durationSeconds: 178),
            CatalogTrackDto(
                trackNumber: '6', title: 'Lady Stardust', durationSeconds: 201),
            CatalogTrackDto(
                trackNumber: '7', title: 'Star', durationSeconds: 167),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'Hang On to Yourself',
                durationSeconds: 160),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'Ziggy Stardust',
                durationSeconds: 193),
            CatalogTrackDto(
                trackNumber: '10',
                title: 'Suffragette City',
                durationSeconds: 205),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Rock \'n\' Roll Suicide',
                durationSeconds: 178),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-12',
        kind: 'music',
        title: 'A Night at the Opera',
        displayTitle: 'Queen - A Night at the Opera (1975)',
        synopsis:
            'The fourth studio album by British rock band Queen, named after the Marx Brothers\' film and featuring the operatic multi-tracked epic "Bohemian Rhapsody".',
        publisher: 'EMI / Hollywood Records',
        releaseYear: 1975,
        releaseDate: DateTime.utc(1975, 11, 21),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png',
        editionTitle: 'Half-Speed Mastered 180g Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '0050087332211',
        country: 'GB',
        language: 'en',
        sortKey: 'queen-0001',
        creators: [
          {'name': 'Queen', 'role': 'artist'},
          {'name': 'Freddie Mercury', 'role': 'lead vocals & piano'},
          {'name': 'Brian May', 'role': 'guitars & vocals'},
          {'name': 'Roy Thomas Baker', 'role': 'producer'},
        ],
        genres: ['progressive rock', 'hard rock', 'glam rock', 'opera rock'],
        music: const MusicCatalogDetails(
          trackCount: 12,
          catalogNumber: 'EMTC 103',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'Death on Two Legs (Dedicated to...)',
                durationSeconds: 223),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'Lazing on a Sunday Afternoon',
                durationSeconds: 67),
            CatalogTrackDto(
                trackNumber: '3',
                title: 'I\'m in Love with My Car',
                durationSeconds: 185),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'You\'re My Best Friend',
                durationSeconds: 172),
            CatalogTrackDto(
                trackNumber: '5', title: '\'39', durationSeconds: 211),
            CatalogTrackDto(
                trackNumber: '6', title: 'Sweet Lady', durationSeconds: 243),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'Seaside Rendezvous',
                durationSeconds: 135),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'The Prophet\'s Song',
                durationSeconds: 500),
            CatalogTrackDto(
                trackNumber: '9',
                title: 'Love of My Life',
                durationSeconds: 219),
            CatalogTrackDto(
                trackNumber: '10', title: 'Good Company', durationSeconds: 203),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Bohemian Rhapsody',
                durationSeconds: 355),
            CatalogTrackDto(
                trackNumber: '12',
                title: 'God Save the Queen',
                durationSeconds: 75),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-13',
        kind: 'music',
        title: 'Mezzanine',
        displayTitle: 'Massive Attack - Mezzanine (1998)',
        synopsis:
            'The third studio album by English electronic music group Massive Attack, known for its dark, brooding sound palette blending trip hop with dub, electronica, and post-punk.',
        publisher: 'Circa / Virgin Records',
        releaseYear: 1998,
        releaseDate: DateTime.utc(1998, 4, 20),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/e/e9/Massive_Attack_-_Mezzanine.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/e/e9/Massive_Attack_-_Mezzanine.png',
        editionTitle: '20th Anniversary 180g 2xLP Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '0602567479703',
        country: 'GB',
        language: 'en',
        sortKey: 'massive-attack-0001',
        creators: [
          {'name': 'Massive Attack', 'role': 'artist'},
          {'name': 'Robert Del Naja (3D)', 'role': 'vocals & programming'},
          {'name': 'Grant Marshall (Daddy G)', 'role': 'vocals'},
          {'name': 'Elizabeth Fraser', 'role': 'guest vocals (Teardrop)'},
        ],
        genres: ['trip hop', 'downtempo', 'electronica', 'dark ambient'],
        music: const MusicCatalogDetails(
          trackCount: 11,
          catalogNumber: 'WBRLP4',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Angel', durationSeconds: 379),
            CatalogTrackDto(
                trackNumber: '2', title: 'Risingson', durationSeconds: 298),
            CatalogTrackDto(
                trackNumber: '3', title: 'Teardrop', durationSeconds: 329),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'Inertia Creeps',
                durationSeconds: 356),
            CatalogTrackDto(
                trackNumber: '5', title: 'Exchange', durationSeconds: 251),
            CatalogTrackDto(
                trackNumber: '6',
                title: 'Dissolved Girl',
                durationSeconds: 367),
            CatalogTrackDto(
                trackNumber: '7', title: 'Man Next Door', durationSeconds: 355),
            CatalogTrackDto(
                trackNumber: '8', title: 'Black Milk', durationSeconds: 381),
            CatalogTrackDto(
                trackNumber: '9', title: 'Mezzanine', durationSeconds: 354),
            CatalogTrackDto(
                trackNumber: '10', title: 'Group Four', durationSeconds: 497),
            CatalogTrackDto(
                trackNumber: '11', title: '(Exchange)', durationSeconds: 254),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-14',
        kind: 'music',
        title: 'Dummy',
        displayTitle: 'Portishead - Dummy (1994)',
        synopsis:
            'The debut studio album by English band Portishead, which won the 1995 Mercury Music Prize and defined the Bristol sound of 1990s trip hop.',
        publisher: 'Go! Beat Records',
        releaseYear: 1994,
        releaseDate: DateTime.utc(1994, 8, 22),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/90/Portishead_-_Dummy.png',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/90/Portishead_-_Dummy.png',
        editionTitle: 'Audiophile Vinyl Edition',
        physicalFormat: 'Vinyl',
        barcode: '042282855312',
        country: 'GB',
        language: 'en',
        sortKey: 'portishead-0001',
        creators: [
          {'name': 'Portishead', 'role': 'artist'},
          {'name': 'Beth Gibbons', 'role': 'lead vocals'},
          {'name': 'Geoff Barrow', 'role': 'turntables & drums'},
          {'name': 'Adrian Utley', 'role': 'guitar & bass'},
        ],
        genres: ['trip hop', 'lo-fi', 'electronica'],
        music: const MusicCatalogDetails(
          trackCount: 11,
          catalogNumber: '828 553-1',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1', title: 'Mysterons', durationSeconds: 302),
            CatalogTrackDto(
                trackNumber: '2', title: 'Sour Times', durationSeconds: 251),
            CatalogTrackDto(
                trackNumber: '3', title: 'Strangers', durationSeconds: 235),
            CatalogTrackDto(
                trackNumber: '4',
                title: 'It Could Be Sweet',
                durationSeconds: 256),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Wandering Star',
                durationSeconds: 291),
            CatalogTrackDto(
                trackNumber: '6', title: 'It\'s a Fire', durationSeconds: 229),
            CatalogTrackDto(
                trackNumber: '7', title: 'Numb', durationSeconds: 234),
            CatalogTrackDto(
                trackNumber: '8', title: 'Roads', durationSeconds: 302),
            CatalogTrackDto(
                trackNumber: '9', title: 'Pedestal', durationSeconds: 219),
            CatalogTrackDto(
                trackNumber: '10', title: 'Biscuit', durationSeconds: 301),
            CatalogTrackDto(
                trackNumber: '11', title: 'Glory Box', durationSeconds: 306),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-15',
        kind: 'music',
        title: 'London Calling',
        displayTitle: 'The Clash - London Calling (1979)',
        synopsis:
            'The third studio album by English rock band the Clash, blending punk rock with reggae, ska, rockabilly, and soul, and featuring Pennie Smith\'s iconic bass-smashing cover photograph.',
        publisher: 'CBS Records',
        releaseYear: 1979,
        releaseDate: DateTime.utc(1979, 12, 14),
        coverImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/0/00/TheClashLondonCallingalbumcover.jpg',
        thumbnailImageUrl:
            'https://upload.wikimedia.org/wikipedia/en/0/00/TheClashLondonCallingalbumcover.jpg',
        editionTitle: 'Legacy Edition 2xLP Vinyl',
        physicalFormat: 'Vinyl',
        barcode: '888751127012',
        country: 'GB',
        language: 'en',
        sortKey: 'the-clash-0001',
        creators: [
          {'name': 'The Clash', 'role': 'artist'},
          {'name': 'Joe Strummer', 'role': 'lead vocals & rhythm guitar'},
          {'name': 'Mick Jones', 'role': 'lead guitar & vocals'},
          {'name': 'Paul Simonon', 'role': 'bass'},
          {'name': 'Topper Headon', 'role': 'drums'},
          {'name': 'Guy Stevens', 'role': 'producer'},
        ],
        genres: ['punk rock', 'post-punk', 'ska', 'reggae rock'],
        music: const MusicCatalogDetails(
          trackCount: 19,
          catalogNumber: 'CBS CLASH 3',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrackDto(
                trackNumber: '1',
                title: 'London Calling',
                durationSeconds: 199),
            CatalogTrackDto(
                trackNumber: '2',
                title: 'Brand New Cadillac',
                durationSeconds: 128),
            CatalogTrackDto(
                trackNumber: '3', title: 'Jimmy Jazz', durationSeconds: 234),
            CatalogTrackDto(
                trackNumber: '4', title: 'Hateful', durationSeconds: 164),
            CatalogTrackDto(
                trackNumber: '5',
                title: 'Rudie Can\'t Fail',
                durationSeconds: 209),
            CatalogTrackDto(
                trackNumber: '6', title: 'Spanish Bombs', durationSeconds: 198),
            CatalogTrackDto(
                trackNumber: '7',
                title: 'The Right Profile',
                durationSeconds: 234),
            CatalogTrackDto(
                trackNumber: '8',
                title: 'Lost in the Supermarket',
                durationSeconds: 227),
            CatalogTrackDto(
                trackNumber: '9', title: 'Clampdown', durationSeconds: 229),
            CatalogTrackDto(
                trackNumber: '10',
                title: 'The Guns of Brixton',
                durationSeconds: 189),
            CatalogTrackDto(
                trackNumber: '11',
                title: 'Wrong \'Em Boyo',
                durationSeconds: 190),
            CatalogTrackDto(
                trackNumber: '12',
                title: 'Death or Glory',
                durationSeconds: 235),
            CatalogTrackDto(
                trackNumber: '13', title: 'Koka Kola', durationSeconds: 107),
            CatalogTrackDto(
                trackNumber: '14',
                title: 'The Card Cheat',
                durationSeconds: 229),
            CatalogTrackDto(
                trackNumber: '15',
                title: 'Lover\'s Rock',
                durationSeconds: 243),
            CatalogTrackDto(
                trackNumber: '16',
                title: 'Four Horsemen',
                durationSeconds: 175),
            CatalogTrackDto(
                trackNumber: '17',
                title: 'I\'m Not Down',
                durationSeconds: 186),
            CatalogTrackDto(
                trackNumber: '18',
                title: 'Revolution Rock',
                durationSeconds: 333),
            CatalogTrackDto(
                trackNumber: '19',
                title: 'Train in Vain',
                durationSeconds: 181),
          ],
        ),
      ),
    ];

List<OwnedItem> musicSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('music', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 220)),
          updatedAt: now,
          isDigital: false,
          condition: 'Mint',
          details: MusicOwnedDetails(
            storageDevice: 'Vinyl shelf',
            storageSlot: 'M-${itemId.substring(itemId.length - 2)}',
            lastCleanedDate: DateTime.utc(2024, 4, 20),
            matrixRunouts: [
              MusicMatrixRunout(
                side: 'A',
                runoutText: 'SEED-${itemId.toUpperCase()}-A',
              ),
            ],
          ),
          purchaseDate: DateTime.utc(2022, 4, 20),
          pricePaidCents: 3499,
          currency: 'USD',
          personalNotes: '180g Vinyl in antistatic inner sleeve. Clean spin.',
          quantity: 1,
          purchaseStore: 'Local Record Store / Acoustic Sounds',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> musicSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-music-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-music-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-music-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: MediaTrackingStatus.completed,
          rating: 10,
          startedAt: DateTime.utc(2022, 4, 21),
          finishedAt: DateTime.utc(2022, 4, 21),
          timesCompleted: 10 + (i * 2),
          notes: 'Listened on audiophile stereo system.',
          updatedAt: now,
        ),
    ];
