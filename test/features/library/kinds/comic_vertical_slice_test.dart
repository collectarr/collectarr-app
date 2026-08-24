import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comic Kind Vertical Slice Tests (C9)', () {
    test(
        'ComicCatalogMetadata and ComicKeyEvent serialize and deserialize full domain fields',
        () {
      final metadata = ComicCatalogMetadata(
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
      final restored = ComicCatalogMetadata.fromJson(json);

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
      const comicMeta = ComicCatalogMetadata(
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

      final shelfEntry = ShelfEntry(
        itemId: 'comic_1',
        catalogItem: const LibraryMetadataItem(
          identity: LibraryItemIdentity(
            id: 'comic_1',
            mediaKind: CatalogMediaKind.comic,
          ),
          common: LibraryCommonMetadata(
            title: 'Amazing Fantasy #15',
          ),
          kindMetadata: comicMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'comic_1',
            kind: 'comic',
            entityType: CatalogEntityType.work,
          ),
          condition: '9.8',
          grade: '9.8',
          details: const ComicOwnedDetails(
            keyComic: true,
            keyReason: '1st Spider-Man',
            keyCategory: '1st Appearance',
            keySeverity: 'Major',
            rawOrSlabbed: 'Slabbed',
            gradingCompany: 'CGC',
            signedBy: 'Stan Lee',
          ),
          updatedAt: DateTime.now(),
        ),
      );

      const projector = ComicWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'comic_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.title, 'Amazing Fantasy #15');
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

      expect(ComicKindSchema.title.getValue(ctx), 'Amazing Fantasy #15');
      expect(ComicKindSchema.writer.getValue(ctx), 'Stan Lee');
      expect(ComicKindSchema.artist.getValue(ctx), 'Steve Ditko');
      expect(ComicKindSchema.coverArtist.getValue(ctx), 'Jack Kirby');
      expect(ComicKindSchema.imprint.getValue(ctx), 'Marvel');
      expect(ComicKindSchema.variant.getValue(ctx), 'Direct');
      expect(ComicKindSchema.pageCount.getValue(ctx), 36);
      expect(ComicKindSchema.grade.getValue(ctx), '9.8');
      expect(ComicKindSchema.keyComic.getValue(ctx), isTrue);
      expect(ComicKindSchema.keyReason.getValue(ctx), '1st Spider-Man');
      expect(ComicKindSchema.gradingCompany.getValue(ctx), 'CGC');
      expect(ComicKindSchema.signedBy.getValue(ctx), 'Stan Lee');
    });

    test(
        'ComicLibraryKindProviderMapper parses ComicVine/GCD envelope into ComicCatalogMetadata',
        () {
      const mapper = ComicLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'comicvine',
          providerItemId: '4000-12345',
          kind: 'comic',
          normalized: const {
            'title': 'Amazing Fantasy #15',
            'series_title': 'Amazing Fantasy',
            'issue_number': '15',
            'publisher': 'Marvel Comics',
            'imprint': 'Marvel',
            'page_count': 36,
            'writers': ['Stan Lee'],
            'artists': ['Steve Ditko'],
            'cover_artists': ['Jack Kirby', 'Steve Ditko'],
            'characters': ['Peter Parker', 'Spider-Man'],
            'is_key_comic': true,
            'key_reason': '1st appearance of Spider-Man',
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<ComicCatalogMetadata>());
      final meta = item.kindMetadata as ComicCatalogMetadata;
      expect(meta.title, 'Amazing Fantasy #15');
      expect(meta.seriesTitle, 'Amazing Fantasy');
      expect(meta.issueNumber, '15');
      expect(meta.writers, contains('Stan Lee'));
      expect(meta.artists, contains('Steve Ditko'));
      expect(meta.isKeyComic, isTrue);
    });
  });
}
