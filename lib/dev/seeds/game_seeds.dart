import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';

CatalogItem enrichGameSeedItem(CatalogItem item) {
  final platforms = item.payload['platforms'];
  final primaryPlatform = platforms is List && platforms.isNotEmpty
      ? platforms.first.toString()
      : item.physicalFormat ?? 'PC';
  final releases = [
    for (final edition in seedEditionPayloads(item))
      {
        ...edition,
        'id': edition['id']?.toString() ?? '${item.id}-release-01',
        'kind': 'game',
        'work_id': item.id,
        'release_title': edition['title'] ?? item.editionTitle ?? item.title,
        'platform': edition['platform'] ?? primaryPlatform,
        'release_date': edition['release_date'] ??
            item.releaseDate?.toUtc().toIso8601String(),
        'region_code': edition['region_code'] ??
            edition['region'] ??
            item.payload['country'],
        'format': edition['format'] ?? item.physicalFormat,
        'publisher': edition['publisher'] ?? item.publisher,
        'catalog_number': edition['catalog_number'] ?? 'SEED-${item.id}',
        'release_status': edition['release_status'] ?? 'released',
        'language': edition['language'] ?? item.payload['language'],
        'barcode': edition['barcode'] ?? item.barcode,
        'cover_image_url': edition['cover_image_url'] ?? item.coverImageUrl,
      },
  ];
  return withSeedPayload(item, {'releases': releases});
}

List<CatalogItem> gameSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-game-01',
        kind: 'game',
        title: 'The Witcher 3: Wild Hunt',
        displayTitle: 'The Witcher 3: Wild Hunt - Complete Edition',
        synopsis:
            'You are Geralt of Rivia, mercenary monster slayer. Before you stands a war-torn, monster-infested continent you can explore at will. Your current contract? Tracking down Ciri — the Child of Prophecy, a living weapon that can alter the shape of the world.',
        publisher: 'CD Projekt Red',
        releaseYear: 2015,
        releaseDate: DateTime.utc(2015, 5, 19),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/292030/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/292030/library_600x900.jpg',
        editionTitle: 'Complete Edition',
        physicalFormat: 'PS5',
        physicalFormatLabel: 'PlayStation 5 Disc',
        barcode: '850024479326',
        variant: 'Next-Gen Complete Edition',
        country: 'PL',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'witcher-3-0001',
        platforms: const [
          'PC',
          'PlayStation 5',
          'Xbox Series X',
          'Nintendo Switch'
        ],
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-witcher',
          seriesTitle: 'The Witcher Series',
          volumeName: 'The Witcher 3',
          volumeNumber: '3',
          volumeStartYear: 2007,
          tags: 'rpg, open world, dark fantasy',
        ),
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 4999,
          currency: 'USD',
          imprint: 'CD Projekt',
        ),
        creators: [
          {'name': 'Konrad Tomaszkiewicz', 'role': 'game director'},
          {'name': 'Marcin Blacha', 'role': 'lead writer'},
          {'name': 'Marcin Przybyłowicz', 'role': 'composer'},
        ],
        characters: [
          'Geralt of Rivia',
          'Ciri (Cirilla)',
          'Yennefer of Vengerberg',
          'Triss Merigold',
          'Dandelion'
        ],
        genres: ['action RPG', 'open world', 'dark fantasy'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-witcher-ps5',
            title: 'Complete Edition PS5',
            format: 'PlayStation 5',
            publisher: 'CD Projekt Red',
            releaseDate: DateTime.utc(2022, 12, 14),
            variants: [
              CatalogVariant(
                id: 'seed-var-witcher-ps5',
                name: 'Physical Disc Edition',
                variantType: 'physical',
                barcode: '850024479326',
                coverPriceCents: 3999,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-game-02',
        kind: 'game',
        title: 'Elden Ring',
        displayTitle: 'Elden Ring',
        synopsis:
            'A vast world where open fields with a variety of situations and huge dungeons with complex and three-dimensional designs are seamlessly connected. Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring.',
        publisher: 'Bandai Namco Entertainment / FromSoftware',
        releaseYear: 2022,
        releaseDate: DateTime.utc(2022, 2, 25),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/library_600x900.jpg',
        editionTitle: 'Collector\'s Edition',
        physicalFormat: 'PS5',
        barcode: '722674128506',
        country: 'JP',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'elden-ring-0001',
        platforms: const [
          'PC',
          'PlayStation 5',
          'PlayStation 4',
          'Xbox Series X'
        ],
        creators: [
          {'name': 'Hidetaka Miyazaki', 'role': 'director'},
          {'name': 'George R.R. Martin', 'role': 'worldbuilding'},
          {'name': 'Yuka Kitamura', 'role': 'composer'},
        ],
        characters: [
          'Tarnished',
          'Melina',
          'Ranni the Witch',
          'Malenia, Blade of Miquella',
          'General Radahn'
        ],
        genres: ['action RPG', 'souls-like', 'dark fantasy', 'open world'],
      ),
      seedCatalogItem(
        id: 'seed-game-03',
        kind: 'game',
        title: 'Red Dead Redemption 2',
        displayTitle: 'Red Dead Redemption 2',
        synopsis:
            'America, 1899. Arthur Morgan and the Van der Linde gang are outlaws on the run. With federal agents and the best bounty hunters in the nation massing on their heels, the gang must rob, steal and fight their way across the rugged heartland of America.',
        publisher: 'Rockstar Games',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 10, 26),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1174180/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1174180/library_600x900.jpg',
        editionTitle: 'Special Edition',
        physicalFormat: 'PS4',
        barcode: '710425470325',
        country: 'US',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'red-dead-0002',
        platforms: const ['PC', 'PlayStation 4', 'Xbox One'],
        creators: [
          {'name': 'Dan Houser', 'role': 'lead writer'},
          {'name': 'Woody Jackson', 'role': 'composer'},
          {'name': 'Roger Clark', 'role': 'actor (Arthur Morgan)'},
        ],
        characters: [
          'Arthur Morgan',
          'Dutch van der Linde',
          'John Marston',
          'Sadie Adler',
          'Micah Bell'
        ],
        genres: ['action-adventure', 'western', 'open world'],
      ),
      seedCatalogItem(
        id: 'seed-game-04',
        kind: 'game',
        title: 'Cyberpunk 2077',
        displayTitle: 'Cyberpunk 2077: Phantom Liberty',
        synopsis:
            'Cyberpunk 2077 is an open-world, action-adventure RPG set in the megalopolis of Night City, where you play as a cyberpunk mercenary wrapped up in a do-or-die fight for survival.',
        publisher: 'CD Projekt Red',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 12, 10),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/library_600x900.jpg',
        editionTitle: 'Ultimate Edition',
        physicalFormat: 'PC',
        barcode: '850024479500',
        country: 'PL',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'cyberpunk-2077-0001',
        platforms: const ['PC', 'PlayStation 5', 'Xbox Series X'],
        creators: [
          {'name': 'Gabe Amatangelo', 'role': 'game director'},
          {'name': 'Mike Pondsmith', 'role': 'original creator'},
          {'name': 'Keanu Reeves', 'role': 'actor (Johnny Silverhand)'},
          {'name': 'Idris Elba', 'role': 'actor (Solomon Reed)'},
        ],
        characters: [
          'V',
          'Johnny Silverhand',
          'Judy Alvarez',
          'Panam Palmer',
          'Songbird'
        ],
        genres: ['action RPG', 'cyberpunk', 'open world', 'sci-fi'],
      ),
      seedCatalogItem(
        id: 'seed-game-05',
        kind: 'game',
        title: 'Baldur\'s Gate 3',
        displayTitle: 'Baldur\'s Gate 3',
        synopsis:
            'Gather your party and return to the Forgotten Realms in a tale of fellowship and betrayal, sacrifice and survival, and the lure of absolute power. Mysterious abilities are awakening inside you, drawn from a mind flayer parasite planted in your brain.',
        publisher: 'Larian Studios',
        releaseYear: 2023,
        releaseDate: DateTime.utc(2023, 8, 3),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1086940/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1086940/library_600x900.jpg',
        editionTitle: 'Deluxe Physical Edition',
        physicalFormat: 'PS5',
        barcode: '5407008130008',
        country: 'BE',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'baldurs-gate-0003',
        platforms: const ['PC', 'PlayStation 5', 'Xbox Series X', 'macOS'],
        creators: [
          {'name': 'Swen Vincke', 'role': 'game director'},
          {'name': 'Borislav Slavov', 'role': 'composer'},
          {'name': 'Neil Newbon', 'role': 'actor (Astarion)'},
        ],
        characters: [
          'Astarion',
          'Shadowheart',
          'Gale',
          'Lae\'zel',
          'Karlach',
          'Wyll'
        ],
        genres: ['CRPG', 'turn-based fantasy', 'dungeons & dragons'],
      ),
      seedCatalogItem(
        id: 'seed-game-06',
        kind: 'game',
        title: 'Portal 2',
        displayTitle: 'Portal 2',
        synopsis:
            'The sequel to the groundbreaking 2007 title, Portal 2 draws from the award-winning formula of innovative gameplay, story, and music that earned the original over 70 industry accolades.',
        publisher: 'Valve',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 4, 19),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/620/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/620/library_600x900.jpg',
        editionTitle: 'Retail Edition',
        physicalFormat: 'PC',
        barcode: '014633195828',
        country: 'US',
        language: 'en',
        ageRating: 'E10+ (Everyone 10+)',
        sortKey: 'portal-0002',
        platforms: const ['PC', 'Nintendo Switch', 'PlayStation 3', 'Xbox 360'],
        creators: [
          {'name': 'Erik Wolpaw', 'role': 'writer'},
          {'name': 'Chet Faliszek', 'role': 'writer'},
          {'name': 'Ellen McLain', 'role': 'voice (GLaDOS)'},
          {'name': 'Stephen Merchant', 'role': 'voice (Wheatley)'},
        ],
        characters: [
          'Chell',
          'GLaDOS',
          'Wheatley',
          'Cave Johnson',
          'Atlas',
          'P-Body'
        ],
        genres: ['puzzle-platformer', 'comedy', 'sci-fi'],
      ),
      seedCatalogItem(
        id: 'seed-game-07',
        kind: 'game',
        title: 'Hollow Knight',
        displayTitle: 'Hollow Knight',
        synopsis:
            'Forge your own path in Hollow Knight! An epic action adventure through a vast ruined kingdom of insects and heroes. Explore twisting caverns, battle tainted creatures and befriend bizarre bugs.',
        publisher: 'Team Cherry',
        releaseYear: 2017,
        releaseDate: DateTime.utc(2017, 2, 24),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/367520/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/367520/library_600x900.jpg',
        editionTitle: 'Collector\'s Edition',
        physicalFormat: 'Switch',
        barcode: '819976023308',
        country: 'AU',
        language: 'en',
        ageRating: 'E10+',
        sortKey: 'hollow-knight-0001',
        platforms: const ['PC', 'Nintendo Switch', 'PlayStation 4', 'Xbox One'],
        creators: [
          {'name': 'Ari Gibson', 'role': 'art & design'},
          {'name': 'William Pellen', 'role': 'design & code'},
          {'name': 'Christopher Larkin', 'role': 'composer'},
        ],
        characters: [
          'The Knight',
          'Hornet',
          'Quirrel',
          'Cornifer',
          'The Hollow Knight'
        ],
        genres: [
          'metroidvania',
          'soulslike',
          'action-adventure',
          '2D platformer'
        ],
      ),
      seedCatalogItem(
        id: 'seed-game-08',
        kind: 'game',
        title: 'Half-Life 2',
        displayTitle: 'Half-Life 2: 20th Anniversary Edition',
        synopsis:
            'By taking the suspense, challenge and visceral charge of the original, and adding startling new realism and responsiveness, Half-Life 2 opens the door to a world where the player\'s presence affects everything around him.',
        publisher: 'Valve',
        releaseYear: 2004,
        releaseDate: DateTime.utc(2004, 11, 16),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/220/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/220/library_600x900.jpg',
        editionTitle: 'Collector\'s Tin Box',
        physicalFormat: 'PC',
        barcode: '020626721530',
        country: 'US',
        language: 'en',
        ageRating: 'M',
        sortKey: 'half-life-0002',
        platforms: const ['PC', 'Xbox'],
        creators: [
          {'name': 'Gabe Newell', 'role': 'producer'},
          {'name': 'Marc Laidlaw', 'role': 'writer'},
          {'name': 'Kelly Bailey', 'role': 'composer'},
        ],
        characters: [
          'Gordon Freeman',
          'Alyx Vance',
          'Barney Calhoun',
          'G-Man',
          'Dr. Eli Vance'
        ],
        genres: ['first-person shooter', 'sci-fi', 'physics puzzle'],
      ),
      seedCatalogItem(
        id: 'seed-game-09',
        kind: 'game',
        title: 'God of War',
        displayTitle: 'God of War (2018)',
        synopsis:
            'His vengeance against the Gods of Olympus years behind him, Kratos now lives as a man in the realm of Norse Gods and monsters. It is in this harsh, unforgiving world that he must fight to survive... and teach his son to do the same.',
        publisher: 'PlayStation PC LLC / Sony Interactive',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 4, 20),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1593500/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1593500/library_600x900.jpg',
        editionTitle: 'Steelbook Launch Edition',
        physicalFormat: 'PS4',
        barcode: '711719506072',
        country: 'US',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'god-of-war-0001',
        platforms: const ['PC', 'PlayStation 4', 'PlayStation 5'],
        creators: [
          {'name': 'Cory Barlog', 'role': 'game director'},
          {'name': 'Bear McCreary', 'role': 'composer'},
          {'name': 'Christopher Judge', 'role': 'actor (Kratos)'},
          {'name': 'Sunny Suljic', 'role': 'actor (Atreus)'},
        ],
        characters: ['Kratos', 'Atreus (Loki)', 'Mimir', 'Freya', 'Baldur'],
        genres: ['action-adventure', 'mythology', 'hack and slash'],
      ),
      seedCatalogItem(
        id: 'seed-game-10',
        kind: 'game',
        title: 'Doom Eternal',
        displayTitle: 'DOOM Eternal: Deluxe Edition',
        synopsis:
            'Hell\'s armies have invaded Earth. Become the Slayer in an epic single-player campaign to conquer demons across dimensions and stop the final destruction of humanity. The only thing they fear... is you.',
        publisher: 'Bethesda Softworks / id Software',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 3, 20),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/782330/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/782330/library_600x900.jpg',
        editionTitle: 'Deluxe Edition',
        physicalFormat: 'PC',
        barcode: '093155173774',
        country: 'US',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'doom-eternal-0001',
        platforms: const [
          'PC',
          'PlayStation 5',
          'PlayStation 4',
          'Xbox Series X',
          'Nintendo Switch'
        ],
        creators: [
          {'name': 'Hugo Martin', 'role': 'creative director'},
          {'name': 'Marty Stratton', 'role': 'executive producer'},
          {'name': 'Mick Gordon', 'role': 'composer'},
        ],
        characters: [
          'DOOM Slayer',
          'Samuel Hayden',
          'VEGA',
          'Khan Maykr',
          'Marauder'
        ],
        genres: ['first-person shooter', 'action', 'sci-fi horror'],
      ),
      seedCatalogItem(
        id: 'seed-game-11',
        kind: 'game',
        title: 'Disco Elysium',
        displayTitle: 'Disco Elysium: The Final Cut',
        synopsis:
            'A groundbreaking role-playing game. You’re a detective with a unique skill system at your disposal and a whole city to carve your path across. Interrogate unforgettable characters, crack murders, or take bribes.',
        publisher: 'ZA/UM',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 10, 15),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/632470/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/632470/library_600x900.jpg',
        editionTitle: 'Collector\'s Edition',
        physicalFormat: 'Switch',
        barcode: '811949033338',
        country: 'EE',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'disco-elysium-0001',
        platforms: const [
          'PC',
          'PlayStation 5',
          'Xbox Series X',
          'Nintendo Switch'
        ],
        creators: [
          {'name': 'Robert Kurvitz', 'role': 'lead designer & writer'},
          {'name': 'Aleksander Rostov', 'role': 'art director'},
          {'name': 'British Sea Power', 'role': 'soundtrack'},
        ],
        characters: [
          'Harrier "Harry" Du Bois',
          'Kim Kitsuragi',
          'Klaasje',
          'Evrart Claire',
          'Titus Hardie'
        ],
        genres: ['RPG', 'narrative detective', 'psychological'],
      ),
      seedCatalogItem(
        id: 'seed-game-12',
        kind: 'game',
        title: 'Hades',
        displayTitle: 'Hades',
        synopsis:
            'Defy the god of the dead as you hack and slash out of the Underworld in this rogue-like dungeon crawler from the creators of Bastion, Transistor, and Pyre.',
        publisher: 'Supergiant Games',
        releaseYear: 2020,
        releaseDate: DateTime.utc(2020, 9, 17),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900.jpg',
        editionTitle: 'Physical Edition w/ Artbook',
        physicalFormat: 'Switch',
        barcode: '850024479005',
        country: 'US',
        language: 'en',
        ageRating: 'T (Teen)',
        sortKey: 'hades-0001',
        platforms: const [
          'PC',
          'Nintendo Switch',
          'PlayStation 5',
          'Xbox Series X'
        ],
        creators: [
          {'name': 'Greg Kasavin', 'role': 'writer & designer'},
          {'name': 'Amir Rao', 'role': 'studio director'},
          {'name': 'Jen Zee', 'role': 'art director'},
          {'name': 'Darren Korb', 'role': 'composer & audio director'},
        ],
        characters: [
          'Zagreus',
          'Hades',
          'Nyx',
          'Megaera',
          'Achilles',
          'Thanatos'
        ],
        genres: ['roguelite', 'action RPG', 'greek mythology'],
      ),
      seedCatalogItem(
        id: 'seed-game-13',
        kind: 'game',
        title: 'Grand Theft Auto V',
        displayTitle: 'Grand Theft Auto V',
        synopsis:
            'When a young street hustler, a retired bank robber and a terrifying psychopath land themselves in trouble, they must pull off a series of dangerous heists to survive in a city in which they can trust nobody.',
        publisher: 'Rockstar Games',
        releaseYear: 2013,
        releaseDate: DateTime.utc(2013, 9, 17),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/271590/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/271590/library_600x900.jpg',
        editionTitle: 'Premium Edition',
        physicalFormat: 'PS5',
        barcode: '710425577888',
        country: 'US',
        language: 'en',
        ageRating: 'M (Mature 17+)',
        sortKey: 'gta-0005',
        platforms: const [
          'PC',
          'PlayStation 5',
          'Xbox Series X',
          'PlayStation 4'
        ],
        creators: [
          {'name': 'Leslie Benzies', 'role': 'producer'},
          {'name': 'Dan Houser', 'role': 'writer'},
        ],
        characters: [
          'Michael De Santa',
          'Franklin Clinton',
          'Trevor Philips',
          'Lester Crest'
        ],
        genres: ['action-adventure', 'open world', 'crime satire'],
      ),
      seedCatalogItem(
        id: 'seed-game-14',
        kind: 'game',
        title: 'Dark Souls III',
        displayTitle: 'Dark Souls III: The Fire Fades Edition',
        synopsis:
            'As fires fade and the world falls into ruin, journey into a universe filled with more colossal enemies and environments. Players will be immersed into a world of epic atmosphere and darkness through faster gameplay and amplified combat intensity.',
        publisher: 'Bandai Namco / FromSoftware',
        releaseYear: 2016,
        releaseDate: DateTime.utc(2016, 3, 24),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/374320/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/374320/library_600x900.jpg',
        editionTitle: 'The Fire Fades Complete Edition',
        physicalFormat: 'PS4',
        barcode: '722674121286',
        country: 'JP',
        language: 'en',
        ageRating: 'M',
        sortKey: 'dark-souls-0003',
        platforms: const ['PC', 'PlayStation 4', 'Xbox One'],
        creators: [
          {'name': 'Hidetaka Miyazaki', 'role': 'director'},
          {'name': 'Yuka Kitamura', 'role': 'composer'},
        ],
        characters: [
          'Ashen One',
          'Fire Keeper',
          'Lothric & Lorian',
          'Soul of Cinder',
          'Sister Friede'
        ],
        genres: ['action RPG', 'souls-like', 'dark fantasy'],
      ),
      seedCatalogItem(
        id: 'seed-game-15',
        kind: 'game',
        title: 'Monster Hunter: World',
        displayTitle: 'Monster Hunter: World - Iceborne Master Edition',
        synopsis:
            'Welcome to a new world! In Monster Hunter: World, the latest installment in the series, you can enjoy the ultimate hunting experience, using everything at your disposal to hunt monsters in a new world teeming with surprises and excitement.',
        publisher: 'Capcom',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 1, 26),
        coverImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/582010/library_600x900.jpg',
        thumbnailImageUrl:
            'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/582010/library_600x900.jpg',
        editionTitle: 'Master Edition Steelbook',
        physicalFormat: 'PS4',
        barcode: '013388560639',
        country: 'JP',
        language: 'en',
        ageRating: 'T',
        sortKey: 'monster-hunter-0001',
        platforms: const ['PC', 'PlayStation 4', 'Xbox One'],
        creators: [
          {'name': 'Ryozo Tsujimoto', 'role': 'producer'},
          {'name': 'Yuya Tokuda', 'role': 'director'},
          {'name': 'Kaname Fujioka', 'role': 'executive director'},
        ],
        characters: [
          'The Hunter',
          'The Handler',
          'Field Team Leader',
          'Commander'
        ],
        genres: ['action RPG', 'hunting', 'co-op multiplayer'],
      ),
    ];

List<OwnedItem> gameSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('game', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 200)),
          updatedAt: now,
          isDigital: false,
          condition: 'Mint',
          purchaseDate: DateTime.utc(2022, 11, 15),
          pricePaidCents: 5999,
          currency: 'USD',
          personalNotes: 'Physical launch edition on disc.',
          quantity: 1,
          rating: 10,
          readStatus: 'completed',
          startedAt: DateTime.utc(2022, 11, 20),
          finishedAt: DateTime.utc(2023, 1, 15),
          purchaseStore: 'PlayStation Direct / Steam',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> gameSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-game-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-game-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-game-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 10
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2022, 11, 20),
          finishedAt: i <= 10 ? DateTime.utc(2023, 1, 15) : null,
          timesCompleted: 1,
          updatedAt: now,
        ),
    ];
