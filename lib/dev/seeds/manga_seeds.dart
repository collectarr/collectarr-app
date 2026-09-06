import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';

Iterable<MangaTrackingUnit> mangaSeedTrackingUnits(
  Iterable<CatalogItem> items,
  DateTime now,
) sync* {
  for (final item in items.where((item) => item.kind == 'manga')) {
    final chapters = item.payload['chapters'];
    final chapter =
        chapters is List && chapters.isNotEmpty ? chapters.first : null;
    final chapterMap = chapter is Map ? chapter : const <String, dynamic>{};
    final volumeNumber = _seedMangaInt(
      chapterMap['volume_number'] ?? item.payload['volume_number'],
    );
    final chapterNumber = _seedMangaInt(chapterMap['chapter_number']) ?? 1;
    final chapterId = chapterMap['id']?.toString() ?? 'chapter-01';
    yield MangaTrackingUnit(
      id: 'seed-unit-manga-${item.id}-$chapterId',
      targetRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      volumeNumber: volumeNumber,
      chapterNumber: chapterNumber,
      completedAt: now.subtract(const Duration(days: 3)),
      updatedAt: now,
    );
  }
}

int? _seedMangaInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

CatalogItem enrichMangaSeedItem(CatalogItem item) {
  return withSeedPayload(item, {
    'chapters': [
      {
        'id': '${item.id}-chapter-01',
        'kind': 'manga',
        'series_id': item.id,
        'volume_number': int.tryParse(item.itemNumber ?? '') ?? 1,
        'chapter_number': 1,
        'title': '${item.title} — Chapter 1',
        'release_date': item.releaseDate?.toUtc().toIso8601String(),
      },
    ],
  });
}

List<CatalogItem> mangaSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-manga-01',
        kind: 'manga',
        title: 'Berserk',
        displayTitle: 'Berserk Deluxe Edition Vol. 1',
        synopsis:
            'Guts, a former mercenary now known as the "Black Swordsman," is out for revenge against his former commander Griffith, who sacrificed his comrades to demons to become a godlike being.',
        publisher: 'Hakusensha / Dark Horse Manga',
        releaseYear: 1989,
        releaseDate: DateTime.utc(1990, 11, 26),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781506711980-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781506711980-L.jpg',
        editionTitle: 'Deluxe Edition Hardcover 1',
        physicalFormat: 'Hardcover',
        physicalFormatLabel: 'Deluxe Edition Hardcover',
        barcode: '9781506711980',
        variant: 'Deluxe Leatherette',
        country: 'JP',
        language: 'ja',
        ageRating: '18+',
        sortKey: 'berserk-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-berserk',
          seriesTitle: 'Berserk',
          volumeName: 'Berserk Deluxe',
          volumeNumber: '1',
          volumeStartYear: 1989,
          tags: 'dark fantasy, epic, seinen, grimdark',
        ),
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 696,
          coverPriceCents: 4999,
          currency: 'USD',
          imprint: 'Dark Horse Manga',
        ),
        creators: [
          {'name': 'Kentaro Miura', 'role': 'writer & illustrator'},
        ],
        characters: ['Guts', 'Griffith', 'Casca', 'Puck', 'Nosferatu Zodd'],
        storyArcs: ['The Black Swordsman Arc', 'Golden Age Arc'],
        genres: ['dark fantasy', 'sword and sorcery', 'action', 'tragedy'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-berserk-deluxe-01',
            title: 'Berserk Deluxe Volume 1',
            format: 'Hardcover',
            publisher: 'Dark Horse Manga',
            isbn: '9781506711980',
            releaseDate: DateTime.utc(2019, 3, 26),
            variants: [
              CatalogVariant(
                id: 'seed-var-berserk-deluxe-01',
                name: 'Leatherette Foil Stamped',
                variantType: 'physical',
                isbn: '9781506711980',
                coverPriceCents: 4999,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-manga-02',
        kind: 'manga',
        title: 'Monster',
        displayTitle: 'Monster: The Perfect Edition Vol. 1',
        synopsis:
            'Dr. Kenzo Tenma is a renowned Japanese brain surgeon working in Düsseldorf. When he disobeys his hospital director\'s orders to operate on a critically wounded boy rather than the city\'s mayor, his career unravels.',
        publisher: 'Shogakukan / Viz Media',
        releaseYear: 1994,
        releaseDate: DateTime.utc(1994, 12, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421569062-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421569062-L.jpg',
        editionTitle: 'The Perfect Edition Vol. 1',
        physicalFormat: 'Trade Paperback',
        barcode: '9781421569062',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'monster-manga-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-monster',
          seriesTitle: 'Monster',
          volumeName: 'The Perfect Edition',
          volumeNumber: '1',
          volumeStartYear: 1994,
        ),
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 424,
          coverPriceCents: 1999,
          currency: 'USD',
          imprint: 'Viz Signature',
        ),
        creators: [
          {'name': 'Naoki Urasawa', 'role': 'writer & illustrator'},
        ],
        characters: [
          'Dr. Kenzo Tenma',
          'Johan Liebert',
          'Anna Liebert',
          'Inspector Heinrich Lunge'
        ],
        genres: ['psychological thriller', 'mystery', 'suspense'],
      ),
      seedCatalogItem(
        id: 'seed-manga-03',
        kind: 'manga',
        title: 'Vagabond',
        displayTitle: 'Vagabond (VIZBIG Edition) Vol. 1',
        synopsis:
            'Shinmen Takezo is an untamed youth who desires nothing more than to walk the path of the sword and become invincible under the sun, inspired by the historical life of Miyamoto Musashi.',
        publisher: 'Kodansha / Viz Media',
        releaseYear: 1998,
        releaseDate: DateTime.utc(1998, 3, 23),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421520544-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421520544-L.jpg',
        editionTitle: 'VIZBIG Edition Vol. 1',
        physicalFormat: 'Trade Paperback',
        barcode: '9781421520544',
        variant: 'VIZBIG 3-in-1',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'vagabond-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-vagabond',
          seriesTitle: 'Vagabond',
          volumeName: 'VIZBIG Edition',
          volumeNumber: '1',
          volumeStartYear: 1998,
        ),
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 728,
          coverPriceCents: 1999,
          currency: 'USD',
          imprint: 'Viz Signature',
        ),
        creators: [
          {'name': 'Takehiko Inoue', 'role': 'writer & illustrator'},
          {'name': 'Eiji Yoshikawa', 'role': 'original novel'},
        ],
        characters: [
          'Miyamoto Musashi (Shinmen Takezo)',
          'Sasaki Kojiro',
          'Matahachi Hon\'iden',
          'Otsu'
        ],
        genres: ['historical', 'martial arts', 'seinen', 'philosophy'],
      ),
      seedCatalogItem(
        id: 'seed-manga-04',
        kind: 'manga',
        title: '20th Century Boys',
        displayTitle: '20th Century Boys: The Perfect Edition Vol. 1',
        synopsis:
            'Kenji Endo is a manager of a convenience store who finds himself caught up in a mysterious cult led by a man known only as "Friend", who seems to be enacting a plan from Kenji\'s childhood notebook.',
        publisher: 'Shogakukan / Viz Media',
        releaseYear: 1999,
        releaseDate: DateTime.utc(1999, 1, 29),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421599618-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421599618-L.jpg',
        editionTitle: 'The Perfect Edition Vol. 1',
        physicalFormat: 'Trade Paperback',
        barcode: '9781421599618',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen+',
        sortKey: '20th-century-boys-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 416,
          coverPriceCents: 1999,
          currency: 'USD',
          imprint: 'Viz Signature',
        ),
        creators: [
          {'name': 'Naoki Urasawa', 'role': 'writer & illustrator'},
        ],
        characters: [
          'Kenji Endo',
          'Friend',
          'Kanna Endo',
          'Otcho',
          'Yoshitsune'
        ],
        genres: ['mystery', 'sci-fi', 'conspiracy', 'seinen'],
      ),
      seedCatalogItem(
        id: 'seed-manga-05',
        kind: 'manga',
        title: 'Pluto',
        displayTitle: 'Pluto: Urasawa x Tezuka Vol. 1',
        synopsis:
            'In an ideal world where man and robots co-exist, someone or something has destroyed the powerful Swiss robot Montblanc. Europol detective Gesicht is sent to investigate.',
        publisher: 'Shogakukan / Viz Media',
        releaseYear: 2003,
        releaseDate: DateTime.utc(2003, 9, 9),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421519180-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421519180-L.jpg',
        editionTitle: 'Standard Edition Vol. 1',
        physicalFormat: 'Paperback',
        barcode: '9781421519180',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen+',
        sortKey: 'pluto-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 200, coverPriceCents: 1299, currency: 'USD'),
        creators: [
          {'name': 'Naoki Urasawa', 'role': 'artist'},
          {'name': 'Osamu Tezuka', 'role': 'original creator (Astro Boy)'},
        ],
        characters: ['Gesicht', 'Atom', 'Uran', 'Dr. Tenma', 'Brau 1589'],
        genres: ['sci-fi', 'mystery', 'neo-noir'],
      ),
      seedCatalogItem(
        id: 'seed-manga-06',
        kind: 'manga',
        title: 'Chainsaw Man',
        displayTitle: 'Chainsaw Man Vol. 1',
        synopsis:
            'Denji is a young man who works as a Devil Hunter with Pochita, the "Chainsaw Devil." When a debt collector betrays him, he makes a contract with Pochita and is reborn as Chainsaw Man.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 12, 3),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974709939-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974709939-L.jpg',
        editionTitle: 'Tankobon Vol. 1: Dog & Chainsaw',
        physicalFormat: 'Tankobon',
        barcode: '9781974709939',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'chainsaw-man-manga-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 192, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'Tatsuki Fujimoto', 'role': 'writer & illustrator'},
        ],
        characters: ['Denji', 'Makima', 'Power', 'Aki Hayakawa'],
        genres: ['dark fantasy', 'action', 'comedy'],
      ),
      seedCatalogItem(
        id: 'seed-manga-07',
        kind: 'manga',
        title: 'One Piece',
        displayTitle: 'One Piece Vol. 1: Romance Dawn',
        synopsis:
            'Monkey D. Luffy refuses to let anyone or anything stand in the way of his quest to become the king of all pirates with the powers of the Gum-Gum Fruit.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 1997,
        releaseDate: DateTime.utc(1997, 7, 22),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781569319017-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781569319017-L.jpg',
        editionTitle: 'Volume 1: Romance Dawn',
        physicalFormat: 'Tankobon',
        barcode: '9781569319017',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen',
        sortKey: 'one-piece-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 208, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'Eiichiro Oda', 'role': 'writer & illustrator'},
        ],
        characters: ['Monkey D. Luffy', 'Roronoa Zoro', 'Nami', 'Shanks'],
        genres: ['adventure', 'fantasy', 'action', 'shonen'],
      ),
      seedCatalogItem(
        id: 'seed-manga-08',
        kind: 'manga',
        title: 'Fullmetal Alchemist',
        displayTitle: 'Fullmetal Alchemist: Fullmetal Edition Vol. 1',
        synopsis:
            'In an alchemy-based world, two brothers pay a terrible price for attempting human transmutation. Edward Elric equips automail limbs and seeks the mythical Philosopher\'s Stone.',
        publisher: 'Square Enix / Viz Media',
        releaseYear: 2001,
        releaseDate: DateTime.utc(2001, 7, 12),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421599779-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421599779-L.jpg',
        editionTitle: 'Fullmetal Edition Hardcover 1',
        physicalFormat: 'Hardcover',
        barcode: '9781421599779',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen',
        sortKey: 'fullmetal-alchemist-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 280, coverPriceCents: 1999, currency: 'USD'),
        creators: [
          {'name': 'Hiromu Arakawa', 'role': 'writer & illustrator'},
        ],
        characters: ['Edward Elric', 'Alphonse Elric', 'Roy Mustang'],
        genres: ['fantasy', 'adventure', 'steampunk'],
      ),
      seedCatalogItem(
        id: 'seed-manga-09',
        kind: 'manga',
        title: 'Death Note',
        displayTitle: 'Death Note: Black Edition Vol. 1',
        synopsis:
            'Light Yagami finds a notebook that grants the power to kill anyone whose name is written in it. When he decides to cleanse the world of criminals, a genius detective known as L opposes him.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 2003,
        releaseDate: DateTime.utc(2003, 12, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421539645-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421539645-L.jpg',
        editionTitle: 'Black Edition Vol. 1 (Omnibus)',
        physicalFormat: 'Trade Paperback',
        barcode: '9781421539645',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen+',
        sortKey: 'death-note-manga-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 384, coverPriceCents: 1499, currency: 'USD'),
        creators: [
          {'name': 'Tsugumi Ohba', 'role': 'writer'},
          {'name': 'Takeshi Obata', 'role': 'illustrator'},
        ],
        characters: ['Light Yagami', 'L Lawliet', 'Ryuk'],
        genres: ['psychological thriller', 'mystery', 'supernatural'],
      ),
      seedCatalogItem(
        id: 'seed-manga-10',
        kind: 'manga',
        title: 'Vinland Saga',
        displayTitle: 'Vinland Saga Book 1',
        synopsis:
            'Raised by Vikings who murdered his family, young Thorfinn dreams of a land across the western ocean called Vinland, free of war and slavery.',
        publisher: 'Kodansha Comics',
        releaseYear: 2005,
        releaseDate: DateTime.utc(2005, 4, 13),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781612624204-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781612624204-L.jpg',
        editionTitle: 'Deluxe Hardcover Edition 1',
        physicalFormat: 'Hardcover',
        barcode: '9781612624204',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'vinland-saga-manga-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 464, coverPriceCents: 2299, currency: 'USD'),
        creators: [
          {'name': 'Makoto Yukimura', 'role': 'writer & illustrator'},
        ],
        characters: ['Thorfinn', 'Askeladd', 'Thors'],
        genres: ['historical fiction', 'epic', 'action'],
      ),
      seedCatalogItem(
        id: 'seed-manga-11',
        kind: 'manga',
        title: 'Tokyo Ghoul',
        displayTitle: 'Tokyo Ghoul Vol. 1',
        synopsis:
            'College student Ken Kaneki barely survives a deadly encounter with Rize Kamishiro, a woman who reveals herself as a ghoul. After receiving an organ transplant from her, he becomes half-ghoul.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 2011,
        releaseDate: DateTime.utc(2011, 9, 8),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421580364-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421580364-L.jpg',
        editionTitle: 'Standard Tankobon Vol. 1',
        physicalFormat: 'Tankobon',
        barcode: '9781421580364',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'tokyo-ghoul-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 224, coverPriceCents: 1299, currency: 'USD'),
        creators: [
          {'name': 'Sui Ishida', 'role': 'writer & illustrator'},
        ],
        characters: ['Ken Kaneki', 'Touka Kirishima', 'Rize Kamishiro'],
        genres: ['dark fantasy', 'horror', 'supernatural'],
      ),
      seedCatalogItem(
        id: 'seed-manga-12',
        kind: 'manga',
        title: 'Jujutsu Kaisen',
        displayTitle: 'Jujutsu Kaisen Vol. 1: Ryomen Sukuna',
        synopsis:
            'To save his friends from cursed spirits, high schooler Yuji Itadori swallows the decayed finger of Ryomen Sukuna and absorbs a terrifying curse.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 3, 5),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974710027-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974710027-L.jpg',
        editionTitle: 'Volume 1: Ryomen Sukuna',
        physicalFormat: 'Tankobon',
        barcode: '9781974710027',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen+',
        sortKey: 'jujutsu-kaisen-manga-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 192, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'Gege Akutami', 'role': 'writer & illustrator'},
        ],
        characters: ['Yuji Itadori', 'Megumi Fushiguro', 'Satoru Gojo'],
        genres: ['dark fantasy', 'action', 'supernatural'],
      ),
      seedCatalogItem(
        id: 'seed-manga-13',
        kind: 'manga',
        title: 'Spy x Family',
        displayTitle: 'Spy x Family Vol. 1',
        synopsis:
            'Master spy "Twilight" must disguise himself as a family man named Loid Forger to investigate a political leader. Unbeknownst to him, his adopted daughter is a telepath and his fake wife is a lethal assassin.',
        publisher: 'Shueisha / Viz Media',
        releaseYear: 2019,
        releaseDate: DateTime.utc(2019, 3, 25),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974715466-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781974715466-L.jpg',
        editionTitle: 'Volume 1',
        physicalFormat: 'Tankobon',
        barcode: '9781974715466',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen',
        sortKey: 'spy-family-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 216, coverPriceCents: 999, currency: 'USD'),
        creators: [
          {'name': 'Tatsuya Endo', 'role': 'writer & illustrator'},
        ],
        characters: [
          'Loid Forger (Twilight)',
          'Yor Forger (Thorn Princess)',
          'Anya Forger'
        ],
        genres: ['action comedy', 'espionage', 'slice of life'],
      ),
      seedCatalogItem(
        id: 'seed-manga-14',
        kind: 'manga',
        title: 'Dorohedoro',
        displayTitle: 'Dorohedoro Vol. 1',
        synopsis:
            'In a city known as "The Hole," sorcerers practice dark magic on the populace. Caiman, a man cursed with a reptile head and total amnesia, hunts sorcerers alongside his friend Nikaido to find who cursed him.',
        publisher: 'Shogakukan / Viz Media',
        releaseYear: 2000,
        releaseDate: DateTime.utc(2000, 11, 30),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421533636-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781421533636-L.jpg',
        editionTitle: 'Volume 1',
        physicalFormat: 'Trade Paperback',
        barcode: '9781421533636',
        country: 'JP',
        language: 'ja',
        ageRating: 'Mature',
        sortKey: 'dorohedoro-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 224, coverPriceCents: 1299, currency: 'USD'),
        creators: [
          {'name': 'Q Hayashida', 'role': 'writer & illustrator'},
        ],
        characters: ['Caiman', 'Nikaido', 'En', 'Shin', 'Noi'],
        genres: ['dark fantasy', 'body horror', 'black comedy', 'cyberpunk'],
      ),
      seedCatalogItem(
        id: 'seed-manga-15',
        kind: 'manga',
        title: 'Blue Lock',
        displayTitle: 'Blue Lock Vol. 1',
        synopsis:
            'After a disastrous elimination in the 2018 World Cup, Japan\'s soccer association creates the Blue Lock: a prison-like training facility where 300 high school strikers compete against each other to create the ultimate egoist striker.',
        publisher: 'Kodansha Comics',
        releaseYear: 2018,
        releaseDate: DateTime.utc(2018, 8, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781646516544-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781646516544-L.jpg',
        editionTitle: 'Volume 1',
        physicalFormat: 'Tankobon',
        barcode: '9781646516544',
        country: 'JP',
        language: 'ja',
        ageRating: 'Teen+',
        sortKey: 'blue-lock-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 208, coverPriceCents: 1299, currency: 'USD'),
        creators: [
          {'name': 'Muneyuki Kaneshiro', 'role': 'writer'},
          {'name': 'Yusuke Nomura', 'role': 'illustrator'},
        ],
        characters: [
          'Yoichi Isagi',
          'Meguru Bachira',
          'Rensuke Kunigami',
          'Hyoma Chigiri',
          'Jinpachi Ego'
        ],
        genres: ['sports', 'thriller', 'psychological'],
      ),
    ];

List<OwnedItem> mangaSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('manga', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 210)),
          updatedAt: now,
          isDigital: false,
          condition: 'Mint',
          details: const MangaOwnedDetails(
            grading: MangaGradingDetails(
              rawOrSlabbed: 'Slabbed',
              gradingCompany: 'CGC',
              graderNotes: 'White pages; clean spine and corners.',
              labelType: 'Modern',
              customLabel: 'Deluxe creator edition',
              pageQuality: 'White pages',
              certificationNumber: 'CGC-MANGA-0001',
            ),
            signature: MangaSignatureDetails(signedBy: 'Takehiko Inoue'),
            obiStripPresent: true,
            slipcoverPresent: true,
            dustJacketPresent: true,
            dustJacketCondition: 'Excellent',
            boxSetOuterCondition: 'Very good',
            insertsPresent: true,
            printing: '1st Print',
            localizedEdition: 'VIZ Media',
          ),
          purchaseDate: DateTime.utc(2022, 9, 1),
          pricePaidCents: 1999,
          currency: 'USD',
          personalNotes: 'Physical volume with dust jacket.',
          quantity: 1,
          purchaseStore: 'Barnes & Noble',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> mangaSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-manga-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-manga-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-manga-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 11
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2022, 9, 1),
          finishedAt: i <= 11 ? DateTime.utc(2022, 9, 10) : null,
          timesCompleted: 1,
          updatedAt: now,
        ),
    ];
