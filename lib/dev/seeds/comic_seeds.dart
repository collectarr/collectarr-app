import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/seed_helpers.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';

List<CatalogItem> comicSeedCatalogItems() => [
      seedCatalogItem(
        id: 'seed-comic-01',
        kind: 'comic',
        title: 'Saga',
        displayTitle: 'Saga #1',
        synopsis:
            'When two soldiers from opposite sides of a never-ending galactic war fall in love, they risk everything to bring a fragile new life into a dangerous old universe.',
        publisher: 'Image Comics',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 3, 14),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781607066019-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781607066019-L.jpg',
        editionTitle: 'First Printing Single Issue',
        physicalFormat: 'Single Issue',
        physicalFormatLabel: 'Floppy Comic Book',
        barcode: '70985301254200111',
        variant: 'Direct Market Edition',
        country: 'US',
        language: 'en',
        ageRating: 'Mature',
        sortKey: 'saga-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-saga',
          seriesTitle: 'Saga',
          volumeName: 'Saga',
          volumeNumber: '1',
          volumeStartYear: 2012,
          tags: 'sci-fi, space opera, fantasy, romance',
        ),
        publishing: const CatalogPublishingDetailsDto(
          pageCount: 44,
          coverPriceCents: 299,
          currency: 'USD',
          imprint: 'Image',
        ),
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Fiona Staples', 'role': 'artist & cover artist'},
        ],
        characters: [
          'Alana',
          'Marko',
          'Hazel',
          'The Will',
          'Lying Cat',
          'Prince Robot IV'
        ],
        storyArcs: ['Chapter One'],
        genres: ['sci-fi', 'fantasy', 'space opera'],
        editions: [
          CatalogEdition(
            id: 'seed-ed-saga-01-first',
            title: 'Saga #1 (First Printing)',
            format: 'Single Issue',
            publisher: 'Image Comics',
            releaseDate: DateTime.utc(2012, 3, 14),
            variants: [
              CatalogVariant(
                id: 'seed-var-saga-01-dm',
                name: 'Direct Market Cover A',
                variantType: 'physical',
                barcode: '70985301254200111',
                coverPriceCents: 299,
                currency: 'USD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      seedCatalogItem(
        id: 'seed-comic-02',
        kind: 'comic',
        title: 'Saga',
        displayTitle: 'Saga #2',
        synopsis:
            'Star-crossed lovers Marko and Alana must find a way to escape the planet Cleave with their newborn child, while bounty hunters converge on their location.',
        publisher: 'Image Comics',
        releaseYear: 2012,
        releaseDate: DateTime.utc(2012, 4, 11),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781607066019-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781607066019-L.jpg',
        editionTitle: 'Single Issue',
        physicalFormat: 'Single Issue',
        barcode: '70985301254200211',
        itemNumber: '2',
        sortKey: 'saga-0002',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-saga',
          seriesTitle: 'Saga',
          volumeNumber: '1',
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 299, currency: 'USD'),
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Fiona Staples', 'role': 'artist'},
        ],
        characters: ['Alana', 'Marko', 'The Will', 'Izabel'],
        genres: ['sci-fi', 'space opera'],
      ),
      seedCatalogItem(
        id: 'seed-comic-03',
        kind: 'comic',
        title: 'Watchmen',
        displayTitle: 'Watchmen #1: At Midnight, All the Agents...',
        synopsis:
            'The murder of the Comedian sends the masked vigilante Rorschach into an investigation that uncovers a conspiracy to discredit and kill all former active superheroes.',
        publisher: 'DC Comics',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 9, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780930289232-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780930289232-L.jpg',
        editionTitle: 'Single Issue #1',
        physicalFormat: 'Single Issue',
        barcode: '061101100114',
        country: 'US',
        language: 'en',
        ageRating: 'Mature',
        sortKey: 'watchmen-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-watchmen',
          seriesTitle: 'Watchmen',
          volumeName: 'Watchmen',
          volumeNumber: '1',
          volumeStartYear: 1986,
          tags: 'superhero deconstruction, cold war, alternate history',
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 36, coverPriceCents: 150, currency: 'USD'),
        creators: [
          {'name': 'Alan Moore', 'role': 'writer'},
          {'name': 'Dave Gibbons', 'role': 'artist & letterer'},
          {'name': 'John Higgins', 'role': 'colorist'},
        ],
        characters: [
          'Rorschach',
          'Nite Owl II (Dan Dreiberg)',
          'Doctor Manhattan',
          'Silk Spectre II',
          'Ozymandias',
          'The Comedian'
        ],
        storyArcs: ['Who Watches the Watchmen?'],
        genres: ['superhero', 'mystery', 'psychological thriller'],
      ),
      seedCatalogItem(
        id: 'seed-comic-04',
        kind: 'comic',
        title: 'The Dark Knight Returns',
        displayTitle: 'The Dark Knight Returns #1: The Dark Knight Returns',
        synopsis:
            'Ten years after retiring as Batman, fifty-five-year-old Bruce Wayne returns to the cape and cowl to save a crumbling Gotham from the ruthless Mutant Gang.',
        publisher: 'DC Comics',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 2, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781563893421-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781563893421-L.jpg',
        editionTitle: 'Prestige Format Issue #1',
        physicalFormat: 'Prestige Format',
        barcode: '061101100213',
        country: 'US',
        language: 'en',
        sortKey: 'dark-knight-returns-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-dkr',
          seriesTitle: 'The Dark Knight Returns',
          volumeName: 'The Dark Knight Returns',
          volumeNumber: '1',
          volumeStartYear: 1986,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 52, coverPriceCents: 295, currency: 'USD'),
        creators: [
          {'name': 'Frank Miller', 'role': 'writer & penciller'},
          {'name': 'Klaus Janson', 'role': 'inker'},
          {'name': 'Lynn Varley', 'role': 'colorist'},
        ],
        characters: [
          'Bruce Wayne (Batman)',
          'Carrie Kelley (Robin)',
          'Jim Gordon',
          'Two-Face',
          'The Mutant Leader'
        ],
        genres: ['superhero', 'dystopian', 'action'],
      ),
      seedCatalogItem(
        id: 'seed-comic-05',
        kind: 'comic',
        title: 'Batman: Year One',
        displayTitle: 'Batman #404: Year One - Chapter One',
        synopsis:
            'Lieutenant James Gordon arrives in the corrupt city of Gotham, while billionaire Bruce Wayne returns from abroad to begin his mission against crime.',
        publisher: 'DC Comics',
        releaseYear: 1987,
        releaseDate: DateTime.utc(1987, 2, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401207526-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401207526-L.jpg',
        editionTitle: 'Single Issue #404',
        physicalFormat: 'Single Issue',
        barcode: '070989301004',
        country: 'US',
        language: 'en',
        sortKey: 'batman-year-one-0001',
        itemNumber: '404',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 75, currency: 'USD'),
        creators: [
          {'name': 'Frank Miller', 'role': 'writer'},
          {'name': 'David Mazzucchelli', 'role': 'penciller & inker'},
          {'name': 'Richmond Lewis', 'role': 'colorist'},
        ],
        characters: [
          'Bruce Wayne',
          'James Gordon',
          'Selina Kyle',
          'Carmine Falcone',
          'Sarah Essen'
        ],
        genres: ['crime', 'neo-noir', 'superhero origin'],
      ),
      seedCatalogItem(
        id: 'seed-comic-06',
        kind: 'comic',
        title: 'Invincible',
        displayTitle: 'Invincible #1',
        synopsis:
            'Mark Grayson is just a normal high school senior whose father happens to be Omni-Man, the most powerful superhero on the planet. When Mark inherits his own powers, his life transforms.',
        publisher: 'Image Comics / Skybound',
        releaseYear: 2003,
        releaseDate: DateTime.utc(2003, 1, 22),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781582405001-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781582405001-L.jpg',
        editionTitle: 'First Printing Single Issue',
        physicalFormat: 'Single Issue',
        barcode: '70985300101000111',
        country: 'US',
        language: 'en',
        sortKey: 'invincible-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-invincible',
          seriesTitle: 'Invincible',
          volumeName: 'Invincible',
          volumeNumber: '1',
          volumeStartYear: 2003,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 295, currency: 'USD'),
        creators: [
          {'name': 'Robert Kirkman', 'role': 'writer'},
          {'name': 'Cory Walker', 'role': 'artist'},
          {'name': 'Bill Crabtree', 'role': 'colorist'},
        ],
        characters: [
          'Mark Grayson (Invincible)',
          'Nolan Grayson (Omni-Man)',
          'Debbie Grayson',
          'Atom Eve'
        ],
        genres: ['superhero', 'action', 'coming-of-age'],
      ),
      seedCatalogItem(
        id: 'seed-comic-07',
        kind: 'comic',
        title: 'The Sandman',
        displayTitle: 'The Sandman #1: Sleep of the Just',
        synopsis:
            'Occultist Roderick Burgess captures Dream of the Endless in a dark magic ritual intended for Death. Held prisoner for seventy years, Morpheus finally escapes to rebuild his crumbling realm.',
        publisher: 'DC Comics / Vertigo',
        releaseYear: 1989,
        releaseDate: DateTime.utc(1989, 1, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401227838-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401227838-L.jpg',
        editionTitle: 'Single Issue #1',
        physicalFormat: 'Single Issue',
        barcode: '070989301059',
        country: 'US',
        language: 'en',
        sortKey: 'sandman-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-sandman',
          seriesTitle: 'The Sandman',
          volumeName: 'Preludes & Nocturnes',
          volumeNumber: '1',
          volumeStartYear: 1989,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 40, coverPriceCents: 150, currency: 'USD'),
        creators: [
          {'name': 'Neil Gaiman', 'role': 'writer'},
          {'name': 'Sam Kieth', 'role': 'penciller'},
          {'name': 'Mike Dringenberg', 'role': 'inker'},
          {'name': 'Dave McKean', 'role': 'cover artist'},
        ],
        characters: [
          'Dream (Morpheus)',
          'Death',
          'Roderick Burgess',
          'Alex Burgess'
        ],
        genres: ['dark fantasy', 'mythology', 'horror', 'supernatural'],
      ),
      seedCatalogItem(
        id: 'seed-comic-08',
        kind: 'comic',
        title: 'Kingdom Come',
        displayTitle: 'Kingdom Come #1: Strange Visitor',
        synopsis:
            'In a near future where irresponsible new-generation meta-humans cause catastrophic destruction, an aging Superman comes out of exile to restore order.',
        publisher: 'DC Comics',
        releaseYear: 1996,
        releaseDate: DateTime.utc(1996, 5, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401220341-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401220341-L.jpg',
        editionTitle: 'Prestige Format Issue #1',
        physicalFormat: 'Prestige Format',
        barcode: '761941205632',
        country: 'US',
        language: 'en',
        sortKey: 'kingdom-come-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 52, coverPriceCents: 495, currency: 'USD'),
        creators: [
          {'name': 'Mark Waid', 'role': 'writer'},
          {'name': 'Alex Ross', 'role': 'painter & co-plotter'},
        ],
        characters: [
          'Superman',
          'Batman',
          'Wonder Woman',
          'Norman McCay',
          'The Spectre',
          'Magog'
        ],
        genres: ['superhero', 'alternate future', 'epic drama'],
      ),
      seedCatalogItem(
        id: 'seed-comic-09',
        kind: 'comic',
        title: 'All-Star Superman',
        displayTitle: 'All-Star Superman #1: Faster...',
        synopsis:
            'After rescuing a scientific exploration on the sun, Superman discovers that his cellular structure has been fatally irradiated, leaving him with one year to live.',
        publisher: 'DC Comics',
        releaseYear: 2005,
        releaseDate: DateTime.utc(2005, 11, 23),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401232375-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401232375-L.jpg',
        editionTitle: 'Single Issue #1',
        physicalFormat: 'Single Issue',
        barcode: '761941249766',
        country: 'US',
        language: 'en',
        sortKey: 'all-star-superman-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 299, currency: 'USD'),
        creators: [
          {'name': 'Grant Morrison', 'role': 'writer'},
          {'name': 'Frank Quitely', 'role': 'penciller & inker'},
          {'name': 'Jamie Grant', 'role': 'colorist'},
        ],
        characters: [
          'Superman / Clark Kent',
          'Lois Lane',
          'Lex Luthor',
          'Jimmy Olsen'
        ],
        genres: ['superhero', 'sci-fi', 'mythological'],
      ),
      seedCatalogItem(
        id: 'seed-comic-10',
        kind: 'comic',
        title: 'Spider-Man: Kraven\'s Last Hunt',
        displayTitle: 'The Amazing Spider-Man #293: Kraven\'s Last Hunt Part 2',
        synopsis:
            'Kraven the Hunter tracks down Spider-Man, defeats him, buries him alive, and assumes his identity to prove himself superior to his greatest rival.',
        publisher: 'Marvel Comics',
        releaseYear: 1987,
        releaseDate: DateTime.utc(1987, 10, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785134503-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785134503-L.jpg',
        editionTitle: 'Single Issue #293',
        physicalFormat: 'Single Issue',
        barcode: '071486024570',
        country: 'US',
        language: 'en',
        sortKey: 'kravens-last-hunt-0001',
        itemNumber: '293',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 75, currency: 'USD'),
        creators: [
          {'name': 'J.M. DeMatteis', 'role': 'writer'},
          {'name': 'Mike Zeck', 'role': 'penciller'},
          {'name': 'Bob McLeod', 'role': 'inker'},
        ],
        characters: [
          'Peter Parker (Spider-Man)',
          'Sergei Kravinoff (Kraven the Hunter)',
          'Mary Jane Watson',
          'Vermin'
        ],
        storyArcs: ['Kraven\'s Last Hunt'],
        genres: ['psychological thriller', 'superhero', 'tragedy'],
      ),
      seedCatalogItem(
        id: 'seed-comic-11',
        kind: 'comic',
        title: 'Hellboy: Seed of Destruction',
        displayTitle: 'Hellboy: Seed of Destruction #1',
        synopsis:
            'Hellboy and the Bureau for Paranormal Research and Defense investigate the Cavendish mansion in New England, uncovering sinister secrets tied to Hellboy\'s mystical origin.',
        publisher: 'Dark Horse Comics',
        releaseYear: 1994,
        releaseDate: DateTime.utc(1994, 3, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781593079109-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781593079109-L.jpg',
        editionTitle: 'Single Issue #1',
        physicalFormat: 'Single Issue',
        barcode: '761568940015',
        country: 'US',
        language: 'en',
        sortKey: 'hellboy-0001',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'seed-series-hellboy',
          seriesTitle: 'Hellboy',
          volumeName: 'Seed of Destruction',
          volumeNumber: '1',
          volumeStartYear: 1994,
        ),
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 250, currency: 'USD'),
        creators: [
          {'name': 'Mike Mignola', 'role': 'writer & artist'},
          {'name': 'John Byrne', 'role': 'script'},
          {'name': 'Mark Chiarello', 'role': 'colorist'},
        ],
        characters: [
          'Hellboy',
          'Abe Sapien',
          'Liz Sherman',
          'Grigori Rasputin'
        ],
        genres: ['gothic horror', 'occult detective', 'superhero'],
      ),
      seedCatalogItem(
        id: 'seed-comic-12',
        kind: 'comic',
        title: 'Preacher',
        displayTitle: 'Preacher #1: Gone to Texas',
        synopsis:
            'Small-town Texas preacher Jesse Custer is possessed by a runaway entity called Genesis, giving him the power to command obedience with the Word of God.',
        publisher: 'DC Comics / Vertigo',
        releaseYear: 1995,
        releaseDate: DateTime.utc(1995, 4, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401222741-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401222741-L.jpg',
        editionTitle: 'Single Issue #1',
        physicalFormat: 'Single Issue',
        barcode: '761941202877',
        country: 'US',
        language: 'en',
        ageRating: 'Mature',
        sortKey: 'preacher-0001',
        itemNumber: '1',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 36, coverPriceCents: 195, currency: 'USD'),
        creators: [
          {'name': 'Garth Ennis', 'role': 'writer'},
          {'name': 'Steve Dillon', 'role': 'artist'},
          {'name': 'Glenn Fabry', 'role': 'cover artist'},
        ],
        characters: [
          'Jesse Custer',
          'Tulip O\'Hare',
          'Proinsias Cassidy',
          'The Saint of Killers'
        ],
        genres: ['southern gothic', 'dark fantasy', 'black comedy'],
      ),
      seedCatalogItem(
        id: 'seed-comic-13',
        kind: 'comic',
        title: 'Daredevil: Born Again',
        displayTitle: 'Daredevil #227: Apocalypse',
        synopsis:
            'Karen Page sells the secret identity of Daredevil for a hit of heroin. The information reaches Wilson Fisk, the Kingpin, who systematically strips Matt Murdock of everything he loves.',
        publisher: 'Marvel Comics',
        releaseYear: 1986,
        releaseDate: DateTime.utc(1986, 2, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785134817-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785134817-L.jpg',
        editionTitle: 'Single Issue #227',
        physicalFormat: 'Single Issue',
        barcode: '071486024549',
        country: 'US',
        language: 'en',
        sortKey: 'daredevil-born-again-0001',
        itemNumber: '227',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 75, currency: 'USD'),
        creators: [
          {'name': 'Frank Miller', 'role': 'writer'},
          {'name': 'David Mazzucchelli', 'role': 'penciller & inker'},
          {'name': 'Christie Scheele', 'role': 'colorist'},
        ],
        characters: [
          'Matt Murdock (Daredevil)',
          'Wilson Fisk (The Kingpin)',
          'Karen Page',
          'Foggy Nelson'
        ],
        storyArcs: ['Born Again'],
        genres: ['crime noir', 'superhero', 'tragedy'],
      ),
      seedCatalogItem(
        id: 'seed-comic-14',
        kind: 'comic',
        title: 'X-Men: Days of Future Past',
        displayTitle: 'The Uncanny X-Men #141: Days of Future Past',
        synopsis:
            'In a nightmarish future where mutants are hunted to extinction by Sentinels, an adult Kate Pryde projects her consciousness back to her teenage self in 1980 to stop the assassination that triggered it.',
        publisher: 'Marvel Comics',
        releaseYear: 1981,
        releaseDate: DateTime.utc(1981, 1, 1),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785115601-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9780785115601-L.jpg',
        editionTitle: 'Single Issue #141',
        physicalFormat: 'Single Issue',
        barcode: '071486024617',
        country: 'US',
        language: 'en',
        sortKey: 'xmen-dofp-0001',
        itemNumber: '141',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 32, coverPriceCents: 50, currency: 'USD'),
        creators: [
          {'name': 'Chris Claremont', 'role': 'writer'},
          {'name': 'John Byrne', 'role': 'penciller & co-plotter'},
          {'name': 'Terry Austin', 'role': 'inker'},
        ],
        characters: [
          'Kitty Pryde',
          'Wolverine (Logan)',
          'Storm',
          'Magneto',
          'Mystique',
          'Sentinels'
        ],
        storyArcs: ['Days of Future Past'],
        genres: ['superhero', 'sci-fi', 'dystopian time travel'],
      ),
      seedCatalogItem(
        id: 'seed-comic-15',
        kind: 'comic',
        title: 'Batman: The Killing Joke',
        displayTitle: 'Batman: The Killing Joke (Prestige One-Shot)',
        synopsis:
            'The Joker escapes Arkham Asylum and shoots Barbara Gordon in an attempt to drive Commissioner Jim Gordon insane, proving that one bad day can turn any ordinary man into a lunatic.',
        publisher: 'DC Comics',
        releaseYear: 1988,
        releaseDate: DateTime.utc(1988, 3, 29),
        coverImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401216672-L.jpg',
        thumbnailImageUrl:
            'https://covers.openlibrary.org/b/isbn/9781401216672-L.jpg',
        editionTitle: 'Deluxe Edition Hardcover',
        physicalFormat: 'Hardcover',
        barcode: '9781401216672',
        country: 'US',
        language: 'en',
        sortKey: 'killing-joke-0001',
        publishing: const CatalogPublishingDetailsDto(
            pageCount: 64, coverPriceCents: 1799, currency: 'USD'),
        creators: [
          {'name': 'Alan Moore', 'role': 'writer'},
          {'name': 'Brian Bolland', 'role': 'artist & recolorist'},
        ],
        characters: [
          'Bruce Wayne (Batman)',
          'The Joker',
          'Jim Gordon',
          'Barbara Gordon'
        ],
        genres: ['psychological thriller', 'superhero', 'crime noir'],
      ),
    ];

List<OwnedItem> comicSeedOwnedItems(DateTime now) => [
      for (final itemId in seedIds('comic', 15))
        OwnedItem(
          id: 'seed-owned-$itemId',
          catalogRef: seedCatalogRef(itemId),
          createdAt: now.subtract(const Duration(days: 260)),
          updatedAt: now,
          isDigital: false,
          condition: 'Near Mint',
          grade: '9.8',
          purchaseDate: DateTime.utc(2022, 7, 1),
          pricePaidCents: 4999,
          currency: 'USD',
          personalNotes:
              'Bagged & boarded in mylar with acid-free backing board.',
          quantity: 1,
          rating: 10,
          readStatus: 'completed',
          startedAt: DateTime.utc(2022, 7, 5),
          finishedAt: DateTime.utc(2022, 7, 5),
          purchaseStore: 'Midtown Comics',
          collectionStatus: 'collected',
        ),
    ];

List<TrackingEntry> comicSeedTrackingEntries(DateTime now) => [
      for (var i = 1; i <= 15; i++)
        TrackingEntry(
          id: 'seed-track-comic-${seedOrdinal2(i)}',
          catalogRef: seedCatalogRef('seed-comic-${seedOrdinal2(i)}'),
          ownedItemId: 'seed-owned-seed-comic-${seedOrdinal2(i)}',
          sourceType: TrackingSourceType.physical,
          status: i <= 12
              ? MediaTrackingStatus.completed
              : MediaTrackingStatus.inProgress,
          rating: 9 + (i % 2),
          startedAt: DateTime.utc(2022, 7, 1),
          finishedAt: i <= 12 ? DateTime.utc(2022, 7, 2) : null,
          timesCompleted: 1,
          updatedAt: now,
        ),
    ];
