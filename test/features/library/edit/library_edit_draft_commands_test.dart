import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LibraryEditDraft creates AddOwnedItemCommand correctly', () {
    final item = CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'comic-draft-1',
        mediaKind: CatalogMediaKind.comic,
      ),
      kindMetadata: const ComicCatalogMetadata(
        title: 'Spider-Man #1',
      ),
    );

    final draft = LibraryEditDraft.fromFields(
      type: comicKindModule,
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
    comicDraft.ownedEdit.rawOrSlabbed = 'Slabbed';
    comicDraft.ownedEdit.gradingCompany = 'CGC';
    comicDraft.ownedEdit.coverPriceCents = 399;

    final cmd = draft.toAddOwnedItemCommand();

    expect(cmd.catalogRef.id, 'comic-draft-1');
    expect(cmd.catalogRef.kind, 'comic');
    expect(cmd.common.condition, 'Near Mint');
    expect(cmd.common.grade, '9.8');
    expect(cmd.common.pricePaidCents, 1999);
    expect(cmd.common.currency, 'USD');
    expect(cmd.tracking, isNotNull);
    expect(cmd.tracking?.notes, isNull);
    expect(cmd.typedPayload, isNotNull);

    final details = cmd.details;
    expect(details, isA<ComicOwnedDetailsDraft>());
    final comicDetails = details as ComicOwnedDetailsDraft;
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.coverPriceCents, 399);
  });

  test('LibraryEditDraft creates UpdateOwnedItemCommand correctly', () {
    final item = CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'comic-draft-2',
        mediaKind: CatalogMediaKind.comic,
      ),
      kindMetadata: const ComicCatalogMetadata(
        title: 'X-Men #1',
      ),
    );

    final draft = LibraryEditDraft.fromFields(
      type: comicKindModule,
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
    expect(cmd.typedPayload, isA<ComicOwnedItemUpdatePayload>());

    final detailsPatch = cmd.details.valueOrNull();
    expect(detailsPatch, isA<ComicOwnedDetailsDraft>());
  });
}
