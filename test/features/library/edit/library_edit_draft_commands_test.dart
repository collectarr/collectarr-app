import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LibraryEditDraft creates AddOwnedItemCommand correctly', () {
    final item = LibraryMetadataItem(
      identity: const LibraryItemIdentity(
        id: 'comic-draft-1',
        mediaKind: CatalogMediaKind.comic,
      ),
      common: const LibraryCommonMetadata(
        title: 'Spider-Man #1',
      ),
      kindMetadata: const ComicCatalogMetadata(
        title: 'Spider-Man #1',
      ),
    );

    final draft = LibraryEditDraft.fromFields(
      type: comicsLibraryConfig,
      item: item,
      ownedItem: null,
      wishlistItem: null,
      trackingEntry: null,
      accent: Colors.blue,
    );

    draft.personal.conditionController.text = 'Near Mint';
    draft.personal.gradeController.text = '9.8';
    draft.personal.priceController.text = '19.99';
    draft.personal.currencyController.text = 'USD';
    final comicDraft = draft.kindDetails as ComicEditDraft;
    comicDraft.rawOrSlabbedController.text = 'Slabbed';
    comicDraft.gradingCompanyController.text = 'CGC';
    comicDraft.coverPriceController.text = '3.99';

    final cmd = draft.toAddOwnedItemCommand();

    expect(cmd.catalogRef.id, 'comic-draft-1');
    expect(cmd.catalogRef.kind, 'comic');
    expect(cmd.common.condition, 'Near Mint');
    expect(cmd.common.grade, '9.8');
    expect(cmd.common.pricePaidCents, 1999);
    expect(cmd.common.currency, 'USD');

    final details = cmd.details;
    expect(details, isA<ComicOwnedDetailsDraft>());
    final comicDetails = details as ComicOwnedDetailsDraft;
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.coverPriceCents, 399);
  });

  test('LibraryEditDraft creates UpdateOwnedItemCommand correctly', () {
    final item = LibraryMetadataItem(
      identity: const LibraryItemIdentity(
        id: 'comic-draft-2',
        mediaKind: CatalogMediaKind.comic,
      ),
      common: const LibraryCommonMetadata(
        title: 'X-Men #1',
      ),
      kindMetadata: const ComicCatalogMetadata(
        title: 'X-Men #1',
      ),
    );

    final draft = LibraryEditDraft.fromFields(
      type: comicsLibraryConfig,
      item: item,
      ownedItem: null,
      wishlistItem: null,
      trackingEntry: null,
      accent: Colors.blue,
    );

    draft.personal.conditionController.text = 'Mint';
    draft.personal.gradeController.text = '9.9';
    draft.personal.priceController.text = '49.99';

    final cmd = draft.toUpdateOwnedItemCommand('owned-item-99');

    expect(cmd.ownedItemId, 'owned-item-99');
    expect(cmd.condition.valueOrNull(), 'Mint');
    expect(cmd.grade.valueOrNull(), '9.9');
    expect(cmd.pricePaidCents.valueOrNull(), 4999);

    final detailsPatch = cmd.details.valueOrNull();
    expect(detailsPatch, isA<ComicOwnedDetailsDraft>());
  });
}
