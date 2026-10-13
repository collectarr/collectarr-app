import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/dev/seeds/music_seed_catalog_details.dart';
import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';

final musicDevSeedContributor = TypedDevSeedKindContributor<MusicLibraryEntry>(
  kind: CatalogMediaKind.music,
  catalogDefaults: DevSeedCatalogDefaults(
    includePublishingDetails: false,
    paperType: null,
    originalLanguage: 'en',
    pageCount: 1,
    coverPriceCents: 1999,
    runtimeMinutes: 0,
    ageRating: 'PG',
    audienceRating: 'All',
    enrichPayload: enrichMusicSeedPayload,
  ),
  catalogItems: musicSeedCatalogItems,
  enrichItem: enrichMusicSeedItem,
  validateCatalog: validateMusicSeedCatalog,
  validateCatalogGraph: validateMusicSeedCatalogGraph,
  validateBarcode: seedValidateStandardBarcode,
  libraryEntriesTyped: musicSeedLibraryEntries,
  libraryEntrySummaryTyped: MusicLibraryEntryProjection.toSummary,
  validateEntryTyped: validateMusicSeedEntry,
  trackingRecords: musicSeedTrackingStates,
);

void enrichMusicSeedPayload(
  CatalogItemDto item,
  Map<String, dynamic> payload,
) {
  payload
    ..clear()
    ..addAll(_canonicalMusicSeedPayload(item));
}

List<String> validateMusicSeedCatalog(CatalogItemDto item) {
  final issues = <String>[];
  final prefix = '${item.kind}/${item.id}';
  final album = MusicCatalogMapper.mapMetadataItemToMusic(item);
  seedRequireText(issues, prefix, 'catalog_number', album.catalogNumber);
  if (album.discs.isEmpty) {
    issues.add('$prefix: discs must contain at least one disc');
  }
  return issues;
}

List<String> validateMusicSeedCatalogGraph(CatalogItemDto item) {
  final issues = <String>[];
  final prefix = '${item.kind}/${item.id}';
  final album = MusicCatalogMapper.mapMetadataItemToMusic(item);
  for (var discIndex = 0; discIndex < album.discs.length; discIndex++) {
    final disc = album.discs[discIndex];
    seedRequireText(issues, prefix, 'discs[$discIndex].id', disc.id.value);
    seedRequirePositiveNumber(
      issues,
      prefix,
      'discs[$discIndex].disc_number',
      disc.discNumber,
    );
    if (disc.tracks.isEmpty) {
      issues.add('$prefix: discs[$discIndex].tracks must not be empty');
    }
    for (var trackIndex = 0; trackIndex < disc.tracks.length; trackIndex++) {
      final track = disc.tracks[trackIndex];
      seedRequireText(
        issues,
        prefix,
        'discs[$discIndex].tracks[$trackIndex].id',
        track.id.value,
      );
      seedRequireText(
        issues,
        prefix,
        'discs[$discIndex].tracks[$trackIndex].position',
        track.position,
      );
      seedRequireText(
        issues,
        prefix,
        'discs[$discIndex].tracks[$trackIndex].title',
        track.title,
      );
    }
  }
  return issues;
}

List<String> validateMusicSeedEntry(MusicLibraryEntry item) {
  final issues = <String>[];
  final prefix = 'music/${item.id}';
  final details = item.personal.details;
  if (details.media.isEmpty) {
    issues.add('$prefix: music.media must not be empty');
  }
  for (final disc in details.media) {
    seedRequireText(
      issues,
      prefix,
      'music.media[${disc.discId}].storage_device',
      disc.storageDevice,
    );
    seedRequireText(
      issues,
      prefix,
      'music.media[${disc.discId}].storage_slot',
      disc.storageSlot,
    );
  }
  return issues;
}

CatalogItemDto enrichMusicSeedItem(CatalogItemDto item) {
  final payload = _canonicalMusicSeedPayload(item);
  payload.remove('id');
  payload.remove('kind');
  return CatalogItemDto.raw(
    id: item.id,
    mediaKind: CatalogMediaKind.music,
    kindData: payload,
  );
}

Map<String, dynamic> _canonicalMusicSeedPayload(CatalogItemDto item) {
  final source = item.kindData;
  final rawDiscs = _maps(source['discs']);
  final discs = [
    for (var discIndex = 0; discIndex < rawDiscs.length; discIndex++)
      _canonicalMusicSeedDisc(item, rawDiscs[discIndex], discIndex),
  ];
  final releaseDate = _seedText(source['release_date']);
  final sortTitle = _seedText(source['sort_title']);
  final subtitle = _seedText(source['subtitle'] ?? source['edition_title']);
  final format = _seedText(source['format'] ?? source['physical_format']);
  final label = _seedText(source['label'] ?? source['publisher']);
  return {
    'id': item.id,
    'kind': CatalogMediaKind.music.apiValue,
    'title': _seedText(source['title']) ?? 'Untitled album',
    if (sortTitle != null) 'sort_title': sortTitle,
    if (subtitle != null) 'subtitle': subtitle,
    if (_seedMusicArtist(item) case final artist?) 'artist': artist,
    if (releaseDate != null) 'release_date': releaseDate,
    if (label != null) 'label': label,
    if (format != null) 'format': format,
    if (_seedText(source['barcode']) case final barcode?) 'barcode': barcode,
    if (_seedText(source['catalog_number']) case final catalogNumber?)
      'catalog_number': catalogNumber,
    if (_seedText(source['country']) case final country?) 'country': country,
    if (source['genres'] is Iterable)
      'genres': List<String>.from(source['genres'] as Iterable),
    if (_seedText(source['cover_image_url']) case final cover?)
      'cover_image_url': cover,
    if (_seedText(source['thumbnail_image_url']) case final thumbnail?)
      'thumbnail_image_url': thumbnail,
    'is_live': source['is_live'] == true,
    if (discs.isNotEmpty) 'discs': discs,
  };
}

Map<String, dynamic> _canonicalMusicSeedDisc(
  CatalogItemDto item,
  Map<String, dynamic> source,
  int index,
) {
  final discNumber = _seedInt(source['disc_number']) ?? index + 1;
  final discId = '${item.id}:disc:$discNumber';
  final tracks = _maps(source['tracks']);
  return {
    'id': discId,
    'disc_number': discNumber,
    if (_seedText(source['title'] ?? source['name']) case final title?)
      'title': title,
    if (_seedText(source['matrix_number_side_a']) case final sideA?)
      'matrix_number_side_a': sideA,
    if (_seedText(source['matrix_number_side_b']) case final sideB?)
      'matrix_number_side_b': sideB,
    'tracks': [
      for (var trackIndex = 0; trackIndex < tracks.length; trackIndex++)
        _canonicalMusicSeedTrack(tracks[trackIndex], discId, trackIndex),
    ],
  };
}

Map<String, dynamic> _canonicalMusicSeedTrack(
  Map<String, dynamic> source,
  String discId,
  int index,
) {
  final durationMs = _seedInt(source['duration_ms']) ??
      (_seedInt(source['duration_seconds'])?.toInt() ?? 0) * 1000;
  return {
    'id': '$discId:track:${index + 1}',
    'position':
        (source['position'] ?? source['track_number'] ?? index + 1).toString(),
    'position_order': _seedInt(source['position_order']) ?? index + 1,
    'title': _seedText(source['title']) ?? 'Track ${index + 1}',
    if (_seedText(source['artist']) case final artist?) 'artist': artist,
    if (durationMs > 0) 'duration_ms': durationMs,
  };
}

String? _seedMusicArtist(CatalogItemDto item) {
  final explicitArtist = _seedText(item.kindData['artist']);
  if (explicitArtist != null) return explicitArtist;
  final rawCreators = item.payload['creators'];
  final creators = rawCreators is Iterable
      ? rawCreators
          .whereType<Map<Object?, Object?>>()
          .map(Map<String, dynamic>.from)
      : const <Map<String, dynamic>>[];
  for (final creator in creators) {
    final name = creator['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return null;
}

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const <Map<String, dynamic>>[];

String? _seedText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _seedInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString().trim() ?? '');

List<CatalogItemDto> musicSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-music-01',
        kind: CatalogMediaKind.music,
        title: 'The Dark Side of the Moon',
        displayTitle: 'Pink Floyd - The Dark Side of the Moon (1973)',
        publisher: 'Harvest Records / EMI',
        releaseYear: 1973,
        releaseDate: DateTime.utc(1973, 3, 1),
        coverImageUrl:
            'https://coverartarchive.org/release-group/f5093c06-23e3-404f-aeaa-40f72885ee3a/front-500',
        thumbnailImageUrl:
            'https://coverartarchive.org/release-group/f5093c06-23e3-404f-aeaa-40f72885ee3a/front-500',
        editionTitle: '50th Anniversary Remastered 180g Vinyl',
        physicalFormat: 'Vinyl',
        physicalFormatLabel: '180g Gatefold Vinyl LP',
        barcode: '0190295996901',
        variant: '180g Gatefold Vinyl',
        country: 'GB',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'SHVL 804',
          discs: [
            MusicSeedDisc(discNumber: 1, name: 'Vinyl LP (Side 1 & 2)'),
          ],
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Speak to Me',
                durationSeconds: 67,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'Breathe (In the Air)',
                durationSeconds: 169,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'On the Run',
                durationSeconds: 225,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'Time',
                durationSeconds: 413,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'The Great Gig in the Sky',
                durationSeconds: 284,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '6',
                title: 'Money',
                durationSeconds: 382,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Us and Them',
                durationSeconds: 469,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'Any Colour You Like',
                durationSeconds: 205,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'Brain Damage',
                durationSeconds: 228,
                artist: 'Pink Floyd'),
            MusicSeedTrack(
                trackNumber: '10',
                title: 'Eclipse',
                durationSeconds: 123,
                artist: 'Pink Floyd'),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-02',
        kind: CatalogMediaKind.music,
        title: 'Rumours',
        displayTitle: 'Fleetwood Mac - Rumours (1977)',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'BSK 3010',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Second Hand News',
                durationSeconds: 163),
            MusicSeedTrack(
                trackNumber: '2', title: 'Dreams', durationSeconds: 254),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Never Going Back Again',
                durationSeconds: 134),
            MusicSeedTrack(
                trackNumber: '4', title: 'Don\'t Stop', durationSeconds: 191),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Go Your Own Way',
                durationSeconds: 218),
            MusicSeedTrack(
                trackNumber: '6', title: 'Songbird', durationSeconds: 200),
            MusicSeedTrack(
                trackNumber: '7', title: 'The Chain', durationSeconds: 268),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'You Make Loving Fun',
                durationSeconds: 211),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'I Don\'t Want to Know',
                durationSeconds: 195),
            MusicSeedTrack(
                trackNumber: '10', title: 'Oh Daddy', durationSeconds: 234),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Gold Dust Woman',
                durationSeconds: 291),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-03',
        kind: CatalogMediaKind.music,
        title: 'Kind of Blue',
        displayTitle: 'Miles Davis - Kind of Blue (1959)',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'CL 1355',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'So What', durationSeconds: 562),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'Freddie Freeloader',
                durationSeconds: 586),
            MusicSeedTrack(
                trackNumber: '3', title: 'Blue in Green', durationSeconds: 337),
            MusicSeedTrack(
                trackNumber: '4', title: 'All Blues', durationSeconds: 693),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Flamenco Sketches',
                durationSeconds: 566),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-04',
        kind: CatalogMediaKind.music,
        title: 'Thriller',
        displayTitle: 'Michael Jackson - Thriller (1982)',
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
        sortKey: 'michael-jackson-0001',
        creators: [
          {'name': 'Michael Jackson', 'role': 'vocals & songwriter'},
          {'name': 'Quincy Jones', 'role': 'producer'},
          {'name': 'Bruce Swedien', 'role': 'audio engineer'},
          {'name': 'Eddie Van Halen', 'role': 'guitar solo (Beat It)'},
        ],
        genres: ['pop', 'post-disco', 'funk', 'rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'QE 38112',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Wanna Be Startin\' Somethin\'',
                durationSeconds: 363),
            MusicSeedTrack(
                trackNumber: '2', title: 'Baby Be Mine', durationSeconds: 260),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'The Girl Is Mine (with Paul McCartney)',
                durationSeconds: 222),
            MusicSeedTrack(
                trackNumber: '4', title: 'Thriller', durationSeconds: 357),
            MusicSeedTrack(
                trackNumber: '5', title: 'Beat It', durationSeconds: 258),
            MusicSeedTrack(
                trackNumber: '6', title: 'Billie Jean', durationSeconds: 294),
            MusicSeedTrack(
                trackNumber: '7', title: 'Human Nature', durationSeconds: 246),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'P.Y.T. (Pretty Young Thing)',
                durationSeconds: 239),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'The Lady in My Life',
                durationSeconds: 300),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-05',
        kind: CatalogMediaKind.music,
        title: 'Nevermind',
        displayTitle: 'Nirvana - Nevermind (1991)',
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
        sortKey: 'nirvana-0001',
        creators: [
          {'name': 'Nirvana', 'role': 'artist'},
          {'name': 'Kurt Cobain', 'role': 'lead vocals & guitar'},
          {'name': 'Krist Novoselic', 'role': 'bass'},
          {'name': 'Dave Grohl', 'role': 'drums & vocals'},
          {'name': 'Butch Vig', 'role': 'producer'},
        ],
        genres: ['grunge', 'alternative rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'DGC-24425',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Smells Like Teen Spirit',
                durationSeconds: 301),
            MusicSeedTrack(
                trackNumber: '2', title: 'In Bloom', durationSeconds: 254),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Come as You Are',
                durationSeconds: 219),
            MusicSeedTrack(
                trackNumber: '4', title: 'Breed', durationSeconds: 183),
            MusicSeedTrack(
                trackNumber: '5', title: 'Lithium', durationSeconds: 257),
            MusicSeedTrack(
                trackNumber: '6', title: 'Polly', durationSeconds: 177),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Territorial Pissings',
                durationSeconds: 142),
            MusicSeedTrack(
                trackNumber: '8', title: 'Drain You', durationSeconds: 223),
            MusicSeedTrack(
                trackNumber: '9', title: 'Lounge Act', durationSeconds: 156),
            MusicSeedTrack(
                trackNumber: '10', title: 'Stay Away', durationSeconds: 212),
            MusicSeedTrack(
                trackNumber: '11', title: 'On a Plain', durationSeconds: 196),
            MusicSeedTrack(
                trackNumber: '12',
                title: 'Something in the Way',
                durationSeconds: 232),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-06',
        kind: CatalogMediaKind.music,
        title: 'Random Access Memories',
        displayTitle: 'Daft Punk - Random Access Memories (2013)',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: '88883716861',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Give Life Back to Music',
                durationSeconds: 275),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'The Game of Love',
                durationSeconds: 322),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Giorgio by Moroder',
                durationSeconds: 544),
            MusicSeedTrack(
                trackNumber: '4', title: 'Within', durationSeconds: 228),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Instant Crush (feat. Julian Casablancas)',
                durationSeconds: 337),
            MusicSeedTrack(
                trackNumber: '6',
                title: 'Lose Yourself to Dance (feat. Pharrell Williams)',
                durationSeconds: 353),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Touch (feat. Paul Williams)',
                durationSeconds: 498),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'Get Lucky (feat. Pharrell Williams)',
                durationSeconds: 369),
            MusicSeedTrack(
                trackNumber: '9', title: 'Beyond', durationSeconds: 290),
            MusicSeedTrack(
                trackNumber: '10', title: 'Motherboard', durationSeconds: 341),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Fragments of Time (feat. Todd Edwards)',
                durationSeconds: 279),
            MusicSeedTrack(
                trackNumber: '12',
                title: 'Doin\' It Right (feat. Panda Bear)',
                durationSeconds: 251),
            MusicSeedTrack(
                trackNumber: '13', title: 'Contact', durationSeconds: 381),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-07',
        kind: CatalogMediaKind.music,
        title: 'OK Computer',
        displayTitle: 'Radiohead - OK Computer (1997)',
        publisher: 'Parlophone / Capitol',
        releaseYear: 1997,
        releaseDate: DateTime.utc(1997, 5, 21),
        coverImageUrl:
            'https://coverartarchive.org/release-group/b1392450-e666-3926-a536-22c65f834433/front-500',
        thumbnailImageUrl:
            'https://coverartarchive.org/release-group/b1392450-e666-3926-a536-22c65f834433/front-500',
        editionTitle: 'OKNOTOK 1997 2017 Box Set',
        physicalFormat: 'Vinyl',
        barcode: '634904086817',
        country: 'GB',
        sortKey: 'radiohead-0001',
        creators: [
          {'name': 'Radiohead', 'role': 'artist'},
          {'name': 'Thom Yorke', 'role': 'lead vocals & piano'},
          {'name': 'Jonny Greenwood', 'role': 'lead guitar & electronics'},
          {'name': 'Nigel Godrich', 'role': 'producer'},
        ],
        genres: ['alternative rock', 'art rock', 'experimental rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'NODATA 02',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Airbag', durationSeconds: 284),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'Paranoid Android',
                durationSeconds: 383),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Subterranean Homesick Alien',
                durationSeconds: 267),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'Exit Music (For a Film)',
                durationSeconds: 264),
            MusicSeedTrack(
                trackNumber: '5', title: 'Let Down', durationSeconds: 299),
            MusicSeedTrack(
                trackNumber: '6', title: 'Karma Police', durationSeconds: 261),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Fitter Happier',
                durationSeconds: 117),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'Electioneering',
                durationSeconds: 230),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'Climbing Up the Walls',
                durationSeconds: 285),
            MusicSeedTrack(
                trackNumber: '10', title: 'No Surprises', durationSeconds: 228),
            MusicSeedTrack(
                trackNumber: '11', title: 'Lucky', durationSeconds: 259),
            MusicSeedTrack(
                trackNumber: '12', title: 'The Tourist', durationSeconds: 324),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-08',
        kind: CatalogMediaKind.music,
        title: 'To Pimp a Butterfly',
        displayTitle: 'Kendrick Lamar - To Pimp a Butterfly (2015)',
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
        sortKey: 'kendrick-lamar-0001',
        creators: [
          {'name': 'Kendrick Lamar', 'role': 'lead artist & vocals'},
          {'name': 'Thundercat', 'role': 'bass & producer'},
          {'name': 'Kamasi Washington', 'role': 'tenor saxophone'},
          {'name': 'Flying Lotus', 'role': 'producer'},
        ],
        genres: ['conscious hip hop', 'jazz rap', 'funk', 'neo-soul'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'B0022956-01',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Wesley\'s Theory',
                durationSeconds: 287),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'For Free? (Interlude)',
                durationSeconds: 130),
            MusicSeedTrack(
                trackNumber: '3', title: 'King Kunta', durationSeconds: 234),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'Institutionalized',
                durationSeconds: 271),
            MusicSeedTrack(
                trackNumber: '5', title: 'These Walls', durationSeconds: 300),
            MusicSeedTrack(trackNumber: '6', title: 'u', durationSeconds: 268),
            MusicSeedTrack(
                trackNumber: '7', title: 'Alright', durationSeconds: 219),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'For Sale? (Interlude)',
                durationSeconds: 291),
            MusicSeedTrack(
                trackNumber: '9', title: 'Momma', durationSeconds: 283),
            MusicSeedTrack(
                trackNumber: '10',
                title: 'Hood Politics',
                durationSeconds: 283),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'How Much a Dollar Cost',
                durationSeconds: 261),
            MusicSeedTrack(
                trackNumber: '12',
                title: 'Complexion (A Zulu Love)',
                durationSeconds: 263),
            MusicSeedTrack(
                trackNumber: '13',
                title: 'The Blacker the Berry',
                durationSeconds: 328),
            MusicSeedTrack(
                trackNumber: '14',
                title: 'You Ain\'t Gotta Lie (Momma Said)',
                durationSeconds: 241),
            MusicSeedTrack(trackNumber: '15', title: 'i', durationSeconds: 336),
            MusicSeedTrack(
                trackNumber: '16', title: 'Mortal Man', durationSeconds: 727),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-09',
        kind: CatalogMediaKind.music,
        title: 'Abbey Road',
        displayTitle: 'The Beatles - Abbey Road (1969)',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'PCS 7088',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Come Together', durationSeconds: 259),
            MusicSeedTrack(
                trackNumber: '2', title: 'Something', durationSeconds: 182),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Maxwell\'s Silver Hammer',
                durationSeconds: 207),
            MusicSeedTrack(
                trackNumber: '4', title: 'Oh! Darling', durationSeconds: 207),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Octopus\'s Garden',
                durationSeconds: 171),
            MusicSeedTrack(
                trackNumber: '6',
                title: 'I Want You (She\'s So Heavy)',
                durationSeconds: 467),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Here Comes the Sun',
                durationSeconds: 185),
            MusicSeedTrack(
                trackNumber: '8', title: 'Because', durationSeconds: 165),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'You Never Give Me Your Money',
                durationSeconds: 242),
            MusicSeedTrack(
                trackNumber: '10', title: 'Sun King', durationSeconds: 146),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Mean Mr. Mustard',
                durationSeconds: 66),
            MusicSeedTrack(
                trackNumber: '12', title: 'Polythene Pam', durationSeconds: 72),
            MusicSeedTrack(
                trackNumber: '13',
                title: 'She Came In Through the Bathroom Window',
                durationSeconds: 117),
            MusicSeedTrack(
                trackNumber: '14',
                title: 'Golden Slumbers',
                durationSeconds: 91),
            MusicSeedTrack(
                trackNumber: '15',
                title: 'Carry That Weight',
                durationSeconds: 96),
            MusicSeedTrack(
                trackNumber: '16', title: 'The End', durationSeconds: 140),
            MusicSeedTrack(
                trackNumber: '17', title: 'Her Majesty', durationSeconds: 23),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-10',
        kind: CatalogMediaKind.music,
        title: 'Led Zeppelin IV',
        displayTitle: 'Led Zeppelin - Untitled (Led Zeppelin IV) (1971)',
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
        sortKey: 'led-zeppelin-0001',
        creators: [
          {'name': 'Led Zeppelin', 'role': 'artist'},
          {'name': 'Jimmy Page', 'role': 'guitars & producer'},
          {'name': 'Robert Plant', 'role': 'lead vocals'},
          {'name': 'John Paul Jones', 'role': 'bass & keyboards'},
          {'name': 'John Bonham', 'role': 'drums'},
        ],
        genres: ['hard rock', 'heavy metal', 'folk rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'SD 7208',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Black Dog', durationSeconds: 296),
            MusicSeedTrack(
                trackNumber: '2', title: 'Rock and Roll', durationSeconds: 220),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'The Battle of Evermore',
                durationSeconds: 351),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'Stairway to Heaven',
                durationSeconds: 482),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Misty Mountain Hop',
                durationSeconds: 278),
            MusicSeedTrack(
                trackNumber: '6', title: 'Four Sticks', durationSeconds: 284),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Going to California',
                durationSeconds: 211),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'When the Levee Breaks',
                durationSeconds: 427),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-11',
        kind: CatalogMediaKind.music,
        title: 'The Rise and Fall of Ziggy Stardust',
        displayTitle:
            'David Bowie - The Rise and Fall of Ziggy Stardust (1972)',
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
        sortKey: 'david-bowie-0001',
        creators: [
          {'name': 'David Bowie', 'role': 'lead vocals & acoustic guitar'},
          {'name': 'Mick Ronson', 'role': 'lead guitar & piano'},
          {'name': 'Ken Scott', 'role': 'producer'},
        ],
        genres: ['glam rock', 'proto-punk', 'art rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'SF 8287',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Five Years', durationSeconds: 282),
            MusicSeedTrack(
                trackNumber: '2', title: 'Soul Love', durationSeconds: 214),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'Moonage Daydream',
                durationSeconds: 280),
            MusicSeedTrack(
                trackNumber: '4', title: 'Starman', durationSeconds: 250),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'It Ain\'t Easy',
                durationSeconds: 178),
            MusicSeedTrack(
                trackNumber: '6', title: 'Lady Stardust', durationSeconds: 201),
            MusicSeedTrack(
                trackNumber: '7', title: 'Star', durationSeconds: 167),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'Hang On to Yourself',
                durationSeconds: 160),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'Ziggy Stardust',
                durationSeconds: 193),
            MusicSeedTrack(
                trackNumber: '10',
                title: 'Suffragette City',
                durationSeconds: 205),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Rock \'n\' Roll Suicide',
                durationSeconds: 178),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-12',
        kind: CatalogMediaKind.music,
        title: 'A Night at the Opera',
        displayTitle: 'Queen - A Night at the Opera (1975)',
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
        sortKey: 'queen-0001',
        creators: [
          {'name': 'Queen', 'role': 'artist'},
          {'name': 'Freddie Mercury', 'role': 'lead vocals & piano'},
          {'name': 'Brian May', 'role': 'guitars & vocals'},
          {'name': 'Roy Thomas Baker', 'role': 'producer'},
        ],
        genres: ['progressive rock', 'hard rock', 'glam rock', 'opera rock'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'EMTC 103',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'Death on Two Legs (Dedicated to...)',
                durationSeconds: 223),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'Lazing on a Sunday Afternoon',
                durationSeconds: 67),
            MusicSeedTrack(
                trackNumber: '3',
                title: 'I\'m in Love with My Car',
                durationSeconds: 185),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'You\'re My Best Friend',
                durationSeconds: 172),
            MusicSeedTrack(
                trackNumber: '5', title: '\'39', durationSeconds: 211),
            MusicSeedTrack(
                trackNumber: '6', title: 'Sweet Lady', durationSeconds: 243),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'Seaside Rendezvous',
                durationSeconds: 135),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'The Prophet\'s Song',
                durationSeconds: 500),
            MusicSeedTrack(
                trackNumber: '9',
                title: 'Love of My Life',
                durationSeconds: 219),
            MusicSeedTrack(
                trackNumber: '10', title: 'Good Company', durationSeconds: 203),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Bohemian Rhapsody',
                durationSeconds: 355),
            MusicSeedTrack(
                trackNumber: '12',
                title: 'God Save the Queen',
                durationSeconds: 75),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-13',
        kind: CatalogMediaKind.music,
        title: 'Mezzanine',
        displayTitle: 'Massive Attack - Mezzanine (1998)',
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
        sortKey: 'massive-attack-0001',
        creators: [
          {'name': 'Massive Attack', 'role': 'artist'},
          {'name': 'Robert Del Naja (3D)', 'role': 'vocals & programming'},
          {'name': 'Grant Marshall (Daddy G)', 'role': 'vocals'},
          {'name': 'Elizabeth Fraser', 'role': 'guest vocals (Teardrop)'},
        ],
        genres: ['trip hop', 'downtempo', 'electronica', 'dark ambient'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'WBRLP4',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Angel', durationSeconds: 379),
            MusicSeedTrack(
                trackNumber: '2', title: 'Risingson', durationSeconds: 298),
            MusicSeedTrack(
                trackNumber: '3', title: 'Teardrop', durationSeconds: 329),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'Inertia Creeps',
                durationSeconds: 356),
            MusicSeedTrack(
                trackNumber: '5', title: 'Exchange', durationSeconds: 251),
            MusicSeedTrack(
                trackNumber: '6',
                title: 'Dissolved Girl',
                durationSeconds: 367),
            MusicSeedTrack(
                trackNumber: '7', title: 'Man Next Door', durationSeconds: 355),
            MusicSeedTrack(
                trackNumber: '8', title: 'Black Milk', durationSeconds: 381),
            MusicSeedTrack(
                trackNumber: '9', title: 'Mezzanine', durationSeconds: 354),
            MusicSeedTrack(
                trackNumber: '10', title: 'Group Four', durationSeconds: 497),
            MusicSeedTrack(
                trackNumber: '11', title: '(Exchange)', durationSeconds: 254),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-14',
        kind: CatalogMediaKind.music,
        title: 'Dummy',
        displayTitle: 'Portishead - Dummy (1994)',
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
        sortKey: 'portishead-0001',
        creators: [
          {'name': 'Portishead', 'role': 'artist'},
          {'name': 'Beth Gibbons', 'role': 'lead vocals'},
          {'name': 'Geoff Barrow', 'role': 'turntables & drums'},
          {'name': 'Adrian Utley', 'role': 'guitar & bass'},
        ],
        genres: ['trip hop', 'lo-fi', 'electronica'],
        music: const MusicSeedCatalogDetails(
          catalogNumber: '828 553-1',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1', title: 'Mysterons', durationSeconds: 302),
            MusicSeedTrack(
                trackNumber: '2', title: 'Sour Times', durationSeconds: 251),
            MusicSeedTrack(
                trackNumber: '3', title: 'Strangers', durationSeconds: 235),
            MusicSeedTrack(
                trackNumber: '4',
                title: 'It Could Be Sweet',
                durationSeconds: 256),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Wandering Star',
                durationSeconds: 291),
            MusicSeedTrack(
                trackNumber: '6', title: 'It\'s a Fire', durationSeconds: 229),
            MusicSeedTrack(
                trackNumber: '7', title: 'Numb', durationSeconds: 234),
            MusicSeedTrack(
                trackNumber: '8', title: 'Roads', durationSeconds: 302),
            MusicSeedTrack(
                trackNumber: '9', title: 'Pedestal', durationSeconds: 219),
            MusicSeedTrack(
                trackNumber: '10', title: 'Biscuit', durationSeconds: 301),
            MusicSeedTrack(
                trackNumber: '11', title: 'Glory Box', durationSeconds: 306),
          ],
        ),
      ),
      seedCatalogItem(
        id: 'seed-music-15',
        kind: CatalogMediaKind.music,
        title: 'London Calling',
        displayTitle: 'The Clash - London Calling (1979)',
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
        music: const MusicSeedCatalogDetails(
          catalogNumber: 'CBS CLASH 3',
          tracks: [
            MusicSeedTrack(
                trackNumber: '1',
                title: 'London Calling',
                durationSeconds: 199),
            MusicSeedTrack(
                trackNumber: '2',
                title: 'Brand New Cadillac',
                durationSeconds: 128),
            MusicSeedTrack(
                trackNumber: '3', title: 'Jimmy Jazz', durationSeconds: 234),
            MusicSeedTrack(
                trackNumber: '4', title: 'Hateful', durationSeconds: 164),
            MusicSeedTrack(
                trackNumber: '5',
                title: 'Rudie Can\'t Fail',
                durationSeconds: 209),
            MusicSeedTrack(
                trackNumber: '6', title: 'Spanish Bombs', durationSeconds: 198),
            MusicSeedTrack(
                trackNumber: '7',
                title: 'The Right Profile',
                durationSeconds: 234),
            MusicSeedTrack(
                trackNumber: '8',
                title: 'Lost in the Supermarket',
                durationSeconds: 227),
            MusicSeedTrack(
                trackNumber: '9', title: 'Clampdown', durationSeconds: 229),
            MusicSeedTrack(
                trackNumber: '10',
                title: 'The Guns of Brixton',
                durationSeconds: 189),
            MusicSeedTrack(
                trackNumber: '11',
                title: 'Wrong \'Em Boyo',
                durationSeconds: 190),
            MusicSeedTrack(
                trackNumber: '12',
                title: 'Death or Glory',
                durationSeconds: 235),
            MusicSeedTrack(
                trackNumber: '13', title: 'Koka Kola', durationSeconds: 107),
            MusicSeedTrack(
                trackNumber: '14',
                title: 'The Card Cheat',
                durationSeconds: 229),
            MusicSeedTrack(
                trackNumber: '15',
                title: 'Lover\'s Rock',
                durationSeconds: 243),
            MusicSeedTrack(
                trackNumber: '16',
                title: 'Four Horsemen',
                durationSeconds: 175),
            MusicSeedTrack(
                trackNumber: '17',
                title: 'I\'m Not Down',
                durationSeconds: 186),
            MusicSeedTrack(
                trackNumber: '18',
                title: 'Revolution Rock',
                durationSeconds: 333),
            MusicSeedTrack(
                trackNumber: '19',
                title: 'Train in Vain',
                durationSeconds: 181),
          ],
        ),
      ),
    ];

List<MusicLibraryEntry> musicSeedLibraryEntries(DateTime now) {
  final metadataById = {
    for (final item in musicSeedCatalogItems())
      item.id: MusicCatalogMapper.mapMetadataItemToMusic(
        enrichMusicSeedItem(item),
      ),
  };

  return [
    for (final itemId in seedIds(CatalogMediaKind.music, 15))
      MusicLibraryEntry(
        id: LibraryEntryId('seed-entry-$itemId'),
        metadata: metadataById[itemId]!,
        sourceCatalogRef: seedCatalogRef(CatalogMediaKind.music, itemId),
        personal: MusicPersonalData(
          isDigital: false,
          condition: 'Mint',
          details: MusicEntryDetails(
            media: [
              MusicEntryDiscDetails(
                discId: '$itemId:disc:1',
                storageDevice: 'Vinyl shelf',
                storageSlot: 'M-${itemId.substring(itemId.length - 2)}',
              ),
            ],
            lastCleanedDate: DateTime.utc(2024, 4, 20),
          ),
          purchaseDate: DateTime.utc(2022, 4, 20),
          pricePaidCents: 3499,
          currency: 'USD',
          personalNotes: '180g Vinyl in antistatic inner sleeve. Clean spin.',
          purchaseStore: 'Local Record Store / Acoustic Sounds',
          collectionStatus: 'collected',
        ),
        createdAt: now.subtract(const Duration(days: 220)),
        updatedAt: now,
      ),
  ];
}

List<TrackingStorageRecord> musicSeedTrackingStates(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        MusicTrackingState(
          id: 'seed-track-music-${seedOrdinal2(i)}',
          libraryEntryRef: seedLibraryEntryRef(
            CatalogMediaKind.music,
            'seed-entry-seed-music-${seedOrdinal2(i)}',
          ),
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
