import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
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
  group('Manga Kind Vertical Slice Tests (C1)', () {
    test('MangaMetadata serializes and deserializes full domain fields', () {
      const metadata = MangaMetadata(
        nativeTitle: '葬送のフリーレン',
        romajiTitle: 'Sousou no Frieren',
        englishTitle: 'Frieren: Beyond Journey\'s End',
        alternateTitles: ['Frieren the Slayer'],
        authors: ['Kanehito Yamada'],
        artists: ['Tsukasa Abe'],
        demographic: MangaDemographic.shonen,
        serializationPlatform: 'Weekly Shonen Sunday',
        publicationStatus: MangaPublicationStatus.ongoing,
        originalPublisher: 'Shogakukan',
        localizedPublisher: 'VIZ Media',
        volumeNumber: 1,
        totalVolumes: 13,
        chapterCount: 130,
        isbn: '9781974725762',
        editionFormat: MangaEditionFormat.tankobon,
        language: 'en',
        country: 'US',
        genres: ['Adventure', 'Drama', 'Fantasy'],
        themes: ['Magic', 'Time Skip'],
        translator: 'Amanda Haley',
        readingDirection: MangaReadingDirection.rightToLeft,
      );

      final json = metadata.toJson();
      final restored = MangaMetadata.fromJson(json);

      expect(restored.nativeTitle, '葬送のフリーレン');
      expect(restored.romajiTitle, 'Sousou no Frieren');
      expect(restored.englishTitle, 'Frieren: Beyond Journey\'s End');
      expect(restored.authors, contains('Kanehito Yamada'));
      expect(restored.artists, contains('Tsukasa Abe'));
      expect(restored.demographic, MangaDemographic.shonen);
      expect(restored.serializationPlatform, 'Weekly Shonen Sunday');
      expect(restored.publicationStatus, MangaPublicationStatus.ongoing);
      expect(restored.originalPublisher, 'Shogakukan');
      expect(restored.localizedPublisher, 'VIZ Media');
      expect(restored.totalVolumes, 13);
      expect(restored.chapterCount, 130);
      expect(restored.editionFormat, MangaEditionFormat.tankobon);
      expect(restored.readingDirection, MangaReadingDirection.rightToLeft);
      expect(restored.translator, 'Amanda Haley');
    });

    test('MangaOwnedDetails serializes and deserializes collector fields', () {
      const owned = MangaOwnedDetails(
        signedBy: 'Kanehito Yamada',
        obiStripPresent: true,
        slipcoverPresent: true,
        dustJacketPresent: true,
        dustJacketCondition: 'Near Mint',
        boxSetOuterCondition: 'Mint',
        insertsPresent: true,
        printing: '1st Print',
        localizedEdition: 'VIZ Signature',
      );

      final json = owned.toJson();
      final restored = MangaOwnedDetails.fromJson(json);

      expect(restored.signedBy, 'Kanehito Yamada');
      expect(restored.obiStripPresent, isTrue);
      expect(restored.slipcoverPresent, isTrue);
      expect(restored.dustJacketPresent, isTrue);
      expect(restored.dustJacketCondition, 'Near Mint');
      expect(restored.boxSetOuterCondition, 'Mint');
      expect(restored.insertsPresent, isTrue);
      expect(restored.printing, '1st Print');
      expect(restored.localizedEdition, 'VIZ Signature');
    });

    test('MangaWorkspaceProjector projects metadata and ownedDetails', () {
      const mangaMeta = MangaMetadata(
        nativeTitle: '葬送のフリーレン',
        romajiTitle: 'Sousou no Frieren',
        demographic: MangaDemographic.shonen,
        totalVolumes: 13,
        chapterCount: 130,
        originalPublisher: 'Shogakukan',
        localizedPublisher: 'VIZ Media',
      );

      final shelfEntry = ShelfEntry(
        itemId: 'manga_1',
        catalogItem: const LibraryMetadataItem(
          identity: LibraryItemIdentity(
            id: 'manga_1',
            mediaKind: CatalogMediaKind.manga,
          ),
          common: LibraryCommonMetadata(
            title: 'Frieren: Beyond Journey\'s End',
          ),
          kindMetadata: mangaMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'manga_1',
            kind: 'manga',
            entityType: CatalogEntityType.work,
          ),
          condition: 'Near Mint',
          updatedAt: DateTime.now(),
          details: const MangaOwnedDetails(
            obiStripPresent: true,
            printing: '1st Print',
            localizedEdition: 'VIZ Signature',
          ),
        ),
      );

      const projector = MangaWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'manga_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.nativeTitle, '葬送のフリーレン');
      expect(dto.metadata?.demographic, MangaDemographic.shonen);
      expect(dto.metadata?.totalVolumes, 13);
      expect(dto.ownedDetails?.obiStripPresent, isTrue);
      expect(dto.ownedDetails?.printing, '1st Print');

      // Test field projection
      final ctx = LibraryProjectionContext<MangaWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(
        MangaKindSchema.nativeTitle.getValue(ctx),
        '葬送のフリーレン',
      );
      expect(
        MangaKindSchema.demographic.getValue(ctx),
        'Shonen',
      );
      expect(
        MangaKindSchema.totalVolumes.getValue(ctx),
        13,
      );
      expect(
        MangaKindSchema.obiStripPresent.getValue(ctx),
        isTrue,
      );
      expect(
        MangaKindSchema.printing.getValue(ctx),
        '1st Print',
      );
    });

    test('MangaEditDraft builds complete MangaOwnedDetailsDraft', () {
      final textControllers = TextControllerGroup();
      const mapper = MangaLibraryKindProviderMapper();
      final metaItem = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'anilist',
          providerItemId: '123',
          kind: 'manga',
          normalized: const {
            'title': 'Frieren',
            'publisher': 'Shogakukan',
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      final draft = createMangaEditDraft(
        item: metaItem,
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'manga_1',
            kind: 'manga',
            entityType: CatalogEntityType.work,
          ),
          updatedAt: DateTime.now(),
          details: const MangaOwnedDetails(
            obiStripPresent: true,
            slipcoverPresent: true,
            printing: '1st Print',
            localizedEdition: 'VIZ Signature',
          ),
        ),
        textControllers: textControllers,
      ) as MangaEditDraft;

      expect(draft.obiStripPresent, isTrue);
      expect(draft.slipcoverPresent, isTrue);
      expect(draft.printing, '1st Print');
      expect(draft.localizedEdition, 'VIZ Signature');

      final detailsDraft = draft.toDetailsDraft() as MangaOwnedDetailsDraft;
      final savedDetails = detailsDraft.toDetails();

      expect(savedDetails.obiStripPresent, isTrue);
      expect(savedDetails.slipcoverPresent, isTrue);
      expect(savedDetails.printing, '1st Print');
      expect(savedDetails.localizedEdition, 'VIZ Signature');

      draft.dispose();
    });

    test('MangaCatalog and MangaEntry round-trip and preserve all kind fields',
        () {
      final catalog = MangaCatalog.fromJson({
        'id': 'manga_frieren',
        'kind': 'manga',
        'title': 'Frieren: Beyond Journey\'s End',
        'native_title': '葬送のフリーレン',
        'romaji_title': 'Sousou no Frieren',
        'english_title': 'Frieren: Beyond Journey\'s End',
        'authors': ['Kanehito Yamada'],
        'artists': ['Tsukasa Abe'],
        'demographic': 'shonen',
        'serialization_platform': 'Weekly Shonen Sunday',
        'publication_status': 'ongoing',
        'original_publisher': 'Shogakukan',
        'localized_publisher': 'VIZ Media',
        'volume_number': 1,
        'total_volumes': 13,
        'chapter_count': 130,
        'original_publication_date': '2020-04-28T00:00:00.000Z',
        'localized_release_date': '2021-11-09T00:00:00.000Z',
        'isbn': '9781974725762',
        'edition_format': 'tankobon',
        'language': 'en',
        'country': 'US',
        'genres': ['Adventure', 'Drama', 'Fantasy'],
        'themes': ['Magic', 'Time Skip'],
        'translator': 'Amanda Haley',
        'reading_direction': 'rightToLeft',
        'synopsis': 'The adventure is over but life goes on for an elf mage.',
        'cover_image_url': 'https://example.com/frieren.jpg',
        'thumbnail_image_url': 'https://example.com/frieren_thumb.jpg',
      });

      expect(catalog.id, 'manga_frieren');
      expect(catalog.mediaKind, CatalogMediaKind.manga);
      expect(catalog.title, 'Frieren: Beyond Journey\'s End');
      expect(catalog.nativeTitle, '葬送のフリーレン');
      expect(catalog.demographic, MangaDemographic.shonen);
      expect(catalog.readingDirection, MangaReadingDirection.rightToLeft);
      expect(catalog.displayCoverUrl, 'https://example.com/frieren_thumb.jpg');

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.manga);
      expect(envelope.common.title, 'Frieren: Beyond Journey\'s End');

      final json = catalog.toJson();
      final restored = MangaCatalog.fromJson(json);
      expect(restored.id, 'manga_frieren');
      expect(restored.artists, contains('Tsukasa Abe'));
      expect(restored.totalVolumes, 13);

      final shelfEntry = ShelfEntry(
        itemId: 'manga_frieren',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'manga_frieren',
            mediaKind: CatalogMediaKind.manga,
          ),
          common: const LibraryCommonMetadata(
              title: 'Frieren: Beyond Journey\'s End'),
          kindMetadata: MangaMetadata.fromJson(json),
        ),
      );

      final entry = MangaEntry.fromShelf(shelfEntry);
      expect(entry.id, 'manga_frieren');
      expect(entry.title, 'Frieren: Beyond Journey\'s End');
    });
  });
}
