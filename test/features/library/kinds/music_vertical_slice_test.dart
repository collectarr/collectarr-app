import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/contracts/music_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
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
  group('Music Kind Vertical Slice Tests (C6)', () {
    test(
        'MusicCatalogMetadata and ListeningSession serialize and deserialize full domain fields',
        () {
      final metadata = MusicCatalogMetadata(
        title: 'The Dark Side of the Moon',
        artist: 'Pink Floyd',
        originalReleaseDate: DateTime(1973, 3, 1),
        studio: 'Abbey Road Studios',
        genres: const ['Progressive Rock', 'Psychedelic Rock'],
        releases: [
          MusicReleaseMetadata(
            id: 'rel_1',
            title: 'The Dark Side of the Moon (Vinyl, LP, Remastered)',
            catalogNumber: 'SHVL 804',
            format: 'Vinyl',
            country: 'UK',
            mediaOrDiscCount: 1,
            barcode: '5099902987613',
            label: 'Harvest',
            releaseDate: DateTime(1973, 3, 24),
            tracks: const [
              MusicTrackMetadata(
                disc: 1,
                side: 'A',
                number: '1',
                title: 'Speak to Me',
                durationSeconds: 65,
              ),
              MusicTrackMetadata(
                disc: 1,
                side: 'A',
                number: '2',
                title: 'Breathe (In the Air)',
                durationSeconds: 169,
              ),
            ],
          ),
        ],
      );

      final json = metadata.toJson();
      final restored = MusicCatalogMetadata.fromJson(json);

      expect(restored.title, 'The Dark Side of the Moon');
      expect(restored.artist, 'Pink Floyd');
      expect(restored.studio, 'Abbey Road Studios');
      expect(restored.releases.first.catalogNumber, 'SHVL 804');
      expect(restored.releases.first.format, 'Vinyl');
      expect(restored.releases.first.country, 'UK');
      expect(restored.releases.first.tracks.length, 2);
      expect(restored.releases.first.tracks.first.title, 'Speak to Me');

      final session = ListeningSession(
        id: 'sess_1',
        itemId: 'music_1',
        releaseId: 'rel_1',
        listenedAt: DateTime(2026, 8, 20, 21, 30),
        location: 'Living Room Turntable',
        notes: 'Sound quality is stellar.',
      );

      final sessionJson = session.toJson();
      final restoredSession = ListeningSession.fromJson(sessionJson);
      expect(restoredSession.id, 'sess_1');
      expect(restoredSession.location, 'Living Room Turntable');
      expect(restoredSession.notes, 'Sound quality is stellar.');

      final stats = MusicListeningStats.fromSessions([session]);
      expect(stats.listenCount, 1);
      expect(stats.lastListened, session.listenedAt);
    });

    test('MusicWorkspaceProjector projects metadata and schema fields', () {
      final musicMeta = MusicCatalogMetadata(
        title: 'Abbey Road',
        artist: 'The Beatles',
        releases: [
          MusicReleaseMetadata(
            id: 'rel_ar',
            title: 'Abbey Road (LP)',
            catalogNumber: 'PCS 7088',
            format: 'Vinyl',
            country: 'UK',
            mediaOrDiscCount: 1,
            barcode: '0094638246817',
            tracks: const [
              MusicTrackMetadata(number: '1', title: 'Come Together'),
              MusicTrackMetadata(number: '2', title: 'Something'),
            ],
          ),
        ],
      );

      final shelfEntry = ShelfEntry(
        itemId: 'music_1',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'music_1',
            mediaKind: CatalogMediaKind.music,
          ),
          common: const LibraryCommonMetadata(
            title: 'Abbey Road',
          ),
          kindMetadata: musicMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'music_1',
            kind: 'music',
            entityType: CatalogEntityType.work,
          ),
          condition: 'Near Mint',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = MusicWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'music_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.title, 'Abbey Road');
      expect(dto.artist, 'The Beatles');
      expect(dto.catalogNumber, 'PCS 7088');
      expect(dto.format, 'Vinyl');
      expect(dto.country, 'UK');
      expect(dto.discCount, 1);
      expect(dto.trackCount, 2);

      final ctx = LibraryProjectionContext<MusicWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(MusicKindSchema.title.getValue(ctx), 'Abbey Road');
      expect(MusicKindSchema.artist.getValue(ctx), 'The Beatles');
      expect(MusicKindSchema.catalogNumber.getValue(ctx), 'PCS 7088');
      expect(MusicKindSchema.format.getValue(ctx), 'Vinyl');
      expect(MusicKindSchema.country.getValue(ctx), 'UK');
      expect(MusicKindSchema.discCount.getValue(ctx), 1);
      expect(MusicKindSchema.trackCount.getValue(ctx), 2);
    });

    test(
        'MusicLibraryKindProviderMapper parses MusicBrainz envelope into MusicCatalogMetadata',
        () {
      const mapper = MusicLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'musicbrainz',
          providerItemId: 'mb_123',
          kind: 'music',
          normalized: const {
            'title': 'Abbey Road',
            'artist': 'The Beatles',
            'publisher': 'Apple Records',
            'releases': [
              {
                'id': 'rel_1',
                'title': 'Abbey Road',
                'catalog_number': 'PCS 7088',
                'format': 'Vinyl',
                'country': 'UK',
                'media_or_disc_count': 1,
              }
            ],
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<MusicCatalogMetadata>());
      final meta = item.kindMetadata as MusicCatalogMetadata;
      expect(meta.title, 'Abbey Road');
      expect(meta.artist, 'The Beatles');
      expect(meta.releases.first.catalogNumber, 'PCS 7088');
      expect(meta.releases.first.format, 'Vinyl');
    });

    test('MusicCatalog and MusicEntry round-trip and preserve all kind fields',
        () {
      final catalog = MusicCatalog.fromJson({
        'id': 'music_dsotm',
        'kind': 'music',
        'title': 'The Dark Side of the Moon',
        'artist': 'Pink Floyd',
        'original_release_date': '1973-03-01T00:00:00.000Z',
        'studio': 'Abbey Road Studios',
        'is_live': false,
        'genres': ['Progressive Rock', 'Psychedelic Rock'],
        'credits': [
          {'name': 'Alan Parsons', 'role': 'Engineer'}
        ],
        'releases': [
          {
            'id': 'rel_1',
            'title': 'The Dark Side of the Moon (Vinyl)',
            'catalog_number': 'SHVL 804',
            'format': 'Vinyl',
            'country': 'UK',
            'media_or_disc_count': 1,
            'barcode': '5099902987613',
            'tracks': [
              {
                'disc': 1,
                'side': 'A',
                'number': '1',
                'title': 'Speak to Me',
                'duration_seconds': 65,
              }
            ],
          }
        ],
        'synopsis': 'The eighth studio album by English rock band Pink Floyd.',
        'cover_image_url': 'https://example.com/dsotm.jpg',
        'thumbnail_image_url': 'https://example.com/dsotm_thumb.jpg',
      });

      expect(catalog.id, 'music_dsotm');
      expect(catalog.mediaKind, CatalogMediaKind.music);
      expect(catalog.title, 'The Dark Side of the Moon');
      expect(catalog.artist, 'Pink Floyd');
      expect(catalog.displayCoverUrl, 'https://example.com/dsotm_thumb.jpg');
      expect(catalog.releases.first.tracks.first.title, 'Speak to Me');

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.music);
      expect(envelope.common.title, 'The Dark Side of the Moon');

      final json = catalog.toJson();
      final restored = MusicCatalog.fromJson(json);
      expect(restored.id, 'music_dsotm');
      expect(restored.studio, 'Abbey Road Studios');
      expect(restored.releases.first.catalogNumber, 'SHVL 804');

      final shelfEntry = ShelfEntry(
        itemId: 'music_dsotm',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'music_dsotm',
            mediaKind: CatalogMediaKind.music,
          ),
          common:
              const LibraryCommonMetadata(title: 'The Dark Side of the Moon'),
          kindMetadata: MusicCatalogMetadata.fromJson(json),
        ),
      );

      final entry = MusicEntry.fromShelf(shelfEntry);
      expect(entry.id, 'music_dsotm');
      expect(entry.title, 'The Dark Side of the Moon');
    });
  });
}
