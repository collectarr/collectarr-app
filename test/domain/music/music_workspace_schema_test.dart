import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_owned_copy_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_item_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music workspace schemas separate catalog items from owned copies', () {
    final itemFieldIds = _fieldIds(musicCatalogItemWorkspaceSchema.fields);
    final itemColumnIds = _columnIds(musicCatalogItemWorkspaceSchema.columns);
    final itemGroupIds = _groupIds(musicCatalogItemWorkspaceSchema.groups);

    expect(itemFieldIds, contains(MusicFieldIds.title.value));
    expect(itemFieldIds, contains(MusicFieldIds.artist.value));
    expect(itemFieldIds, contains(MusicFieldIds.genre.value));
    expect(itemFieldIds, contains(MusicFieldIds.releaseDate.value));
    expect(itemFieldIds, contains(MusicFieldIds.trackCount.value));
    expect(itemFieldIds, contains(MusicFieldIds.listenCount.value));
    expect(itemFieldIds, contains(MusicFieldIds.lastListened.value));
    expect(itemFieldIds, isNot(contains(MusicFieldIds.condition.value)));
    expect(itemFieldIds, isNot(contains(MusicFieldIds.location.value)));
    expect(itemFieldIds, isNot(contains(MusicFieldIds.pricePaid.value)));
    expect(itemFieldIds, isNot(contains(MusicFieldIds.catalogNumber.value)));
    expect(itemColumnIds, isNot(contains(MusicFieldIds.condition.value)));
    expect(itemGroupIds, isNot(contains(MusicGroupIds.condition.value)));

    final copyFieldIds = _fieldIds(musicOwnedCopyWorkspaceSchema.fields);
    expect(copyFieldIds, contains(MusicFieldIds.condition.value));
    expect(copyFieldIds, contains(MusicFieldIds.grade.value));
    expect(copyFieldIds, contains(MusicFieldIds.location.value));
    expect(copyFieldIds, contains(MusicFieldIds.storage.value));
    expect(copyFieldIds, contains(MusicFieldIds.pricePaid.value));
    expect(copyFieldIds, contains(MusicFieldIds.marketValue.value));
    expect(copyFieldIds, contains(MusicFieldIds.purchaseDate.value));
    expect(copyFieldIds, contains(MusicFieldIds.indexNumber.value));
    expect(copyFieldIds, contains(MusicFieldIds.signedBy.value));
    expect(copyFieldIds, contains(MusicFieldIds.lastCleaned.value));
    expect(copyFieldIds, isNot(contains(MusicFieldIds.catalogNumber.value)));
  });

  test('Music workspace exposes catalog item and copy scopes only', () {
    final titleSchema = musicKindWorkspace.fieldsForNode(
      const LibraryWorkRef(workId: 'group-1'),
    );
    final copySchema = musicKindWorkspace.fieldsForNode(
      const LibraryCopyRef(
        workId: 'group-1',
        releaseId: 'release-1',
        ownedRef: OwnedCopyRef(
          kind: CatalogMediaKind.music,
          itemId: 'release-1',
          id: OwnedCopyId('owned-1'),
        ),
      ),
    );

    expect(titleSchema.findColumnDefinition(MusicFieldIds.condition), isNull);
    expect(copySchema.findColumnDefinition(MusicFieldIds.condition), isNotNull);
    expect(
      copySchema.findColumnDefinition(MusicFieldIds.catalogNumber),
      isNull,
    );
  });

  test('browser mode exposes only its Music schema options', () {
    final workspace = musicKindWorkspace;
    final mediaGroups =
        workspace.availableGroupIdsForScope(LibraryEntityScope.work);
    final mediaSorts =
        workspace.availableSortIdsForScope(LibraryEntityScope.work);
    final releaseGroups =
        workspace.availableGroupIdsForScope(LibraryEntityScope.release);
    final releaseSorts =
        workspace.availableSortIdsForScope(LibraryEntityScope.release);

    expect(
      mediaGroups.map((id) => id.value),
      containsAll(['music.artist', 'music.genre']),
    );
    expect(releaseGroups, isEmpty);
    expect(
        mediaSorts.map((id) => id.value), isNot(contains('music.publisher')));
    expect(
      releaseSorts,
      isEmpty,
    );
  });

  test('Music tracking stays attached to its catalog item', () {
    const itemRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: 'album-1',
    );
    final target = musicKindWorkspace.trackingTargetForNode(
      const LibraryWorkRef(workId: 'album-1'),
      itemRef,
    );

    expect(target.entityType, CatalogEntityTypeId.root);
    expect(target.id, 'album-1');
    expect(target.rootId, 'album-1');
  });

  test('Music workspace derives its artist from item credits', () {
    final item = MusicAlbum(
      id: const MusicAlbumId('album-1'),
      title: 'Compilation',
      barcode: '123',
      catalogNumber: 'CAT-1',
      boxSetMembership: const MusicBoxSetMembership(
        boxSetRef: CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId('box_set'),
          id: 'box-1',
        ),
        sequenceNumber: 1,
      ),
      boxSetName: 'The Box',
      contributions: [
        MusicAlbumContribution(
          id: const MusicAlbumContributionId('credit-1'),
          albumId: const MusicAlbumId('album-1'),
          personId: 'artist-1',
          role: 'Performer',
          displayName: 'Typed Artist',
        ),
      ],
    );
    final dto = MusicCatalogItemWorkspaceDto(
      common: const WorkspaceCommonProjection(title: 'Compilation'),
      personal: PersonalCopyProjection(),
      music: item,
    );

    expect(dto.artist, 'Typed Artist');
    expect(dto.artist, 'Typed Artist');
    expect(dto.barcode, '123');
    expect(dto.catalogNumber, 'CAT-1');
    expect(dto.boxSet, 'The Box');
  });
}

List<String> _fieldIds(
  Iterable<LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];

List<String> _columnIds(
  Iterable<
          LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];

List<String> _groupIds(
  Iterable<LibraryGroupDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];
