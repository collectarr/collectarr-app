import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_provider_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Comic Kind Vertical Slice Tests (C9)', () {
    test('Comic Add projection builds typed metadata from Core payload', () {
      final providerCandidate = CatalogSearchCandidate.fromItem(
        CatalogItemDto.raw(
          id: 'comic-300',
          mediaKind: CatalogMediaKind.comic,
          common: const CatalogCommonDto(title: 'Spider-Man'),
          payload: const {
            'issue_number': '300',
            'publisher': 'Marvel Comics',
          },
        ),
      );

      final candidate = comicCatalogTransportFromCoreItem(providerCandidate);
      final metadata = candidate.kindCapability
          .mapTransport((transport) => transport.kindMetadata);

      expect(metadata, isA<ComicMedia>());
      final comic = metadata as ComicMedia;
      expect(comic.title, 'Spider-Man');
      expect(comic.issueNumber, '300');
      expect(comic.publisher, 'Marvel Comics');
    });

    test(
        'ComicMedia and ComicKeyEvent serialize and deserialize full domain fields',
        () {
      final metadata = ComicMedia(
        title: 'Amazing Fantasy #15',
        seriesTitle: 'Amazing Fantasy',
        issueNumber: '15',
        publisher: 'Marvel Comics',
        imprint: 'Marvel',
        releaseDate: DateTime(1962, 8, 10),
        coverDate: DateTime(1962, 8, 1),
        pageCount: 36,
        genres: const ['Superhero', 'Action'],
        writers: const ['Stan Lee'],
        artists: const ['Steve Ditko'],
        inkers: const ['Steve Ditko'],
        colorists: const ['Stan Goldberg'],
        letterers: const ['Artie Simek'],
        editors: const ['Stan Lee'],
        coverArtists: const ['Jack Kirby', 'Steve Ditko'],
        characters: const [
          'Peter Parker',
          'Spider-Man',
          'Aunt May',
          'Uncle Ben'
        ],
        storyArcs: const ['Spider-Man!'],
        isKeyComic: true,
        keyReason: '1st appearance & origin of Spider-Man (Peter Parker)',
        keyEvents: const [
          ComicKeyEvent(
            type: ComicKeyEventType.firstAppearance,
            characterOrSubject: 'Spider-Man (Peter Parker)',
            description: 'First appearance of Spider-Man',
          ),
          ComicKeyEvent(
            type: ComicKeyEventType.origin,
            characterOrSubject: 'Spider-Man',
            description: 'Origin of Spider-Man',
          ),
        ],
        variant: 'Direct Edition',
        barcode: '759606012345',
      );

      final json = metadata.toJson();
      final restored = ComicMedia.fromJson(json);

      expect(restored.title, 'Amazing Fantasy #15');
      expect(restored.seriesTitle, 'Amazing Fantasy');
      expect(restored.issueNumber, '15');
      expect(restored.publisher, 'Marvel Comics');
      expect(restored.pageCount, 36);
      expect(restored.writers.first, 'Stan Lee');
      expect(restored.artists.first, 'Steve Ditko');
      expect(restored.coverArtists, contains('Jack Kirby'));
      expect(restored.characters, contains('Peter Parker'));
      expect(restored.isKeyComic, isTrue);
      expect(restored.keyReason, contains('1st appearance'));
      expect(restored.keyEvents.length, 2);
      expect(restored.keyEvents.first.type, ComicKeyEventType.firstAppearance);
    });

    test('ComicWorkspaceProjector projects metadata and schema fields', () {
      const comicMeta = ComicMedia(
        title: 'Amazing Fantasy #15',
        seriesTitle: 'Amazing Fantasy',
        issueNumber: '15',
        publisher: 'Marvel Comics',
        imprint: 'Marvel',
        pageCount: 36,
        writers: ['Stan Lee'],
        artists: ['Steve Ditko'],
        coverArtists: ['Jack Kirby'],
        variant: 'Direct',
      );

      final owned = testOwnedItem(
        id: 'owned_1',
        catalogRef: const CatalogEntityRef(
          id: 'comic_1',
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('work'),
        ),
        condition: '9.8',
        grade: '9.8',
        keyComic: true,
        keyReason: '1st Spider-Man',
        keyCategory: '1st Appearance',
        keySeverity: 'Major',
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        signedBy: 'Stan Lee',
        updatedAt: DateTime.now(),
      );
      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'comic_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: LibraryItemIdentity(
            id: 'comic_1',
            mediaKind: CatalogMediaKind.comic,
          ),
          kindMetadata: comicMeta,
        ).asShelfCatalogItem),
        ownedSummary: testOwnedSummary(owned),
        ownedItemDispatch: testComicOwnedItemDispatchFrom(
          ComicOwnedItem.fromJson(owned.toJson()),
        ),
      );

      const projector = ComicWorkspaceProjector();
      const node = LibraryWorkRef(
        workId: 'comic_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.comic.title, 'Amazing Fantasy #15');
      expect(dto.ownedItem?.id.value, 'owned_1');
      expect(dto.ownedItem?.condition, '9.8');
      expect(dto.ownedItem?.details.keyComic, isTrue);
      expect(dto.ownedItem?.details.gradingCompany, 'CGC');
      expect(dto.writer, 'Stan Lee');
      expect(dto.artist, 'Steve Ditko');
      expect(dto.coverArtist, 'Jack Kirby');
      expect(dto.imprint, 'Marvel');
      expect(dto.variant, 'Direct');
      expect(dto.pageCount, 36);

      final ctx = LibraryProjectionContext<ComicWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(
          ComicWorkWorkspaceFields.title.getValue(ctx), 'Amazing Fantasy #15');
      expect(ComicWorkWorkspaceFields.writer.getValue(ctx), 'Stan Lee');
      expect(ComicWorkWorkspaceFields.artist.getValue(ctx), 'Steve Ditko');
      expect(ComicWorkWorkspaceFields.coverArtist.getValue(ctx), 'Jack Kirby');
      expect(ComicWorkWorkspaceFields.imprint.getValue(ctx), 'Marvel');
      expect(ComicReleaseWorkspaceFields.variant.getValue(ctx), 'Direct');
      expect(ComicWorkWorkspaceFields.pageCount.getValue(ctx), 36);
      expect(ComicCopyWorkspaceFields.grade.getValue(ctx), '9.8');
      expect(ComicCopyWorkspaceFields.keyComic.getValue(ctx), isTrue);
      expect(
          ComicCopyWorkspaceFields.keyReason.getValue(ctx), '1st Spider-Man');
      expect(ComicCopyWorkspaceFields.gradingCompany.getValue(ctx), 'CGC');
      expect(ComicCopyWorkspaceFields.signedBy.getValue(ctx), 'Stan Lee');
    });

    test('Comic edit draft initializes and saves without generic bridge', () {
      const comic = ComicMedia(
        title: 'Saga #1',
        issueNumber: '1',
        publisher: 'Image Comics',
        country: 'US',
        language: 'en',
        ageRating: 'Mature',
        crossover: 'None',
        genres: ['Sci-Fi', 'Fantasy'],
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'writer'},
          {'name': 'Fiona Staples', 'role': 'artist'},
        ],
        characters: ['Alana', 'Marko'],
        storyArcs: ['Volume 1'],
        links: [
          ComicLink(
            url: 'https://example.com/saga-1',
            title: 'Image Page',
            kind: 'external',
          ),
        ],
      );

      final metadata = ComicMedia.fromJson(comic.toJson());
      final item = CatalogItemDto(
        identity: const LibraryItemIdentity(
          id: 'comic-edit-1',
          mediaKind: CatalogMediaKind.comic,
        ),
        kindMetadata: metadata,
      );

      final itemMeta = item.kindMetadata as ComicMedia;
      expect(itemMeta.issueNumber, '1');
      expect(itemMeta.publisher, 'Image Comics');
      expect(itemMeta.country, 'US');
      expect(itemMeta.language, 'en');
      expect(itemMeta.ageRating, 'Mature');
      expect(itemMeta.links.first.url, 'https://example.com/saga-1');

      final roundTripJson = item.toSyncPayload();
      expect(roundTripJson['issue_number'], '1');
      expect(roundTripJson['country'], 'US');
      expect(roundTripJson['language'], 'en');
      expect(roundTripJson['age_rating'], 'Mature');
    });
  });
}
