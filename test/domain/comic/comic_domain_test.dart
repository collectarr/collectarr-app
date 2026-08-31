import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ComicCatalogMapper maps dto to ComicCatalogItem', () {
    final dto = testCatalogItem(
      id: 'comic-work-1',
      title: 'Saga',
      itemNumber: '1',
      publisher: 'Image Comics',
      synopsis: 'A sprawling space opera.',
    );

    final comic = ComicCatalogMapper.mapDtoToComic(dto);

    expect(comic.id, 'comic-work-1');
    expect(comic.work.title, 'Saga');
    expect(comic.work.issueNumber, '1');
    expect(comic.publishing.publisher, 'Image Comics');
  });

  test('projects Comic item from shelf entry', () {
    final catalogItem = testCatalogItem(
      id: 'comic-2',
      kind: 'comic',
      title: 'The Last Ronin',
      itemNumber: '1',
      publisher: 'IDW Publishing',
      synopsis: 'The final turtle seeks justice in a ruined future.',
      series: const CatalogSeriesDetailsDto(
        seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
      ),
      publishing: const CatalogPublishingDetailsDto(
        imprint: 'IDW',
        subtitle: 'Director Cut',
        seriesGroup: 'TMNT Event',
      ),
    );

    final shelf = ShelfEntry(
      itemId: 'comic-2',
      catalogItem: catalogItem,
      ownedItem: testOwnedItem(
        id: 'owned-comic-2',
        itemId: 'comic-2',
        kind: 'comic',
        rawOrSlabbed: 'Raw',
        keyComic: false,
        updatedAt: DateTime.utc(2026, 5, 30),
      ),
      trackingEntry: null,
      wishlistItem: null,
      locationPath: 'Shelf B / Box 2',
      watchSessions: const [],
      itemImages: const [],
    );

    final dto = const ComicWorkspaceProjector().projectTitle(
      source: shelf,
      node: const LibraryTitleNodeRef(titleItemId: 'comic-2'),
    );

    expect(dto.title, 'The Last Ronin');
    expect(dto.itemNumber, '1');
    expect(dto.publisher, 'IDW Publishing');
    expect(dto.comic.publishing.imprint, 'IDW');
  });

  test('ComicKindSchema exposes complete ComicOwnedDetails surface', () {
    final catalogItem = testCatalogItem(
      id: 'comic-key-1',
      kind: 'comic',
      title: 'Amazing Fantasy #15',
      itemNumber: '15',
      publisher: 'Marvel Comics',
    );

    final shelf = ShelfEntry(
      itemId: 'comic-key-1',
      catalogItem: catalogItem,
      ownedItem: testOwnedItem(
        id: 'owned-comic-key-1',
        itemId: 'comic-key-1',
        kind: 'comic',
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        graderNotes: 'Off-white to white pages.',
        signedBy: 'Stan Lee',
        labelType: 'Signature Series',
        customLabel: 'Yellow Label',
        pageQuality: '9.4 NM',
        certificationNumber: '1234567890',
        keyComic: true,
        keyReason: '1st appearance of Spider-Man',
        keyCategory: 'First Appearance',
        keySeverity: 'Major',
        coverPriceCents: 12,
        lastBagBoardDate: DateTime.utc(2025, 6, 1),
      ),
    );

    final workspaceDto = const ComicWorkspaceProjector().projectTitle(
      source: shelf,
      node: const LibraryTitleNodeRef(titleItemId: 'comic-key-1'),
    );

    final ctx = LibraryProjectionContext<ComicWorkspaceDto>(
      source: shelf,
      dto: workspaceDto,
      node: const LibraryTitleNodeRef(titleItemId: 'comic-key-1'),
    );

    expect(ComicKindSchema.rawOrSlabbed.getValue(ctx), 'Slabbed');
    expect(ComicKindSchema.gradingCompany.getValue(ctx), 'CGC');
    expect(
        ComicKindSchema.graderNotes.getValue(ctx), 'Off-white to white pages.');
    expect(ComicKindSchema.signedBy.getValue(ctx), 'Stan Lee');
    expect(ComicKindSchema.labelType.getValue(ctx), 'Signature Series');
    expect(ComicKindSchema.customLabel.getValue(ctx), 'Yellow Label');
    expect(ComicKindSchema.pageQuality.getValue(ctx), '9.4 NM');
    expect(ComicKindSchema.certificationNumber.getValue(ctx), '1234567890');
    expect(ComicKindSchema.keyComic.getValue(ctx), isTrue);
    expect(ComicKindSchema.keyReason.getValue(ctx),
        '1st appearance of Spider-Man');
    expect(ComicKindSchema.keyCategory.getValue(ctx), 'First Appearance');
    expect(ComicKindSchema.keySeverity.getValue(ctx), 'Major');
    expect(ComicKindSchema.coverPrice.getValue(ctx), 12);
    expect(ComicKindSchema.lastBagBoardDate.getValue(ctx),
        DateTime.utc(2025, 6, 1));
  });

  test('ComicCatalogMetadata and structured ComicKeyEvent roundtrip', () {
    final meta = ComicCatalogMetadata(
      title: 'Amazing Fantasy #15',
      seriesTitle: 'Amazing Fantasy',
      issueNumber: '15',
      publisher: 'Marvel Comics',
      writers: const ['Stan Lee'],
      artists: const ['Steve Ditko'],
      inkers: const ['Steve Ditko'],
      colorists: const ['Stan Goldberg'],
      letterers: const ['Artie Simek'],
      editors: const ['Stan Lee'],
      coverArtists: const ['Jack Kirby', 'Steve Ditko'],
      characters: const ['Spider-Man (Peter Parker)', 'Uncle Ben', 'Aunt May'],
      storyArcs: const ['Spider-Man Origin'],
      isKeyComic: true,
      keyReason: 'First appearance and origin of Spider-Man',
      keyEvents: const [
        ComicKeyEvent(
          type: ComicKeyEventType.firstAppearance,
          characterOrSubject: 'Spider-Man (Peter Parker)',
          description: 'First appearance of Peter Parker as Spider-Man',
        ),
        ComicKeyEvent(
          type: ComicKeyEventType.origin,
          characterOrSubject: 'Spider-Man',
          description: 'Origin of Spider-Man',
        ),
        ComicKeyEvent(
          type: ComicKeyEventType.death,
          characterOrSubject: 'Uncle Ben',
          description: 'Death of Uncle Ben',
        ),
      ],
      pageCount: 36,
      country: 'US',
      language: 'en',
    );

    final json = meta.toJson();
    final fromJson = ComicCatalogMetadata.fromJson(json);

    expect(fromJson.title, 'Amazing Fantasy #15');
    expect(fromJson.writers, contains('Stan Lee'));
    expect(fromJson.keyEvents, hasLength(3));
    expect(fromJson.keyEvents.first.type, ComicKeyEventType.firstAppearance);
    expect(fromJson.keyEvents[1].type, ComicKeyEventType.origin);
    expect(fromJson.keyEvents.last.type, ComicKeyEventType.death);
  });

  test('ValuationSnapshot models provider-neutral valuation data', () {
    final snapshot = ValuationSnapshot(
      source: ValuationSource.covrPrice,
      amountCents: 450000,
      currency: 'USD',
      gradeOrCondition: '9.4 NM',
      capturedAt: DateTime.utc(2026, 8, 1),
    );

    final json = snapshot.toJson();
    final fromJson = ValuationSnapshot.fromJson(json);

    expect(fromJson.source, ValuationSource.covrPrice);
    expect(fromJson.amountCents, 450000);
    expect(fromJson.gradeOrCondition, '9.4 NM');
    expect(fromJson.currency, 'USD');
  });

  test('comicKindModule registers dedicated Comic capabilities', () {
    expect(comicKindModule.kind, CatalogMediaKind.comic);
    expect(comicKindModule.add.kind, CatalogMediaKind.comic);
    expect(comicKindModule.add.createInitialDraft(), isA<ComicAddDraft>());
    expect(comicKindModule.ownedDetailsCodec, isA<ComicOwnedDetailsCodec>());
    expect(comicKindModule.defaultOwnedDetails(), isA<ComicOwnedDetails>());
  });
}
