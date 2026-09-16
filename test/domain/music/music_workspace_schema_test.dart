import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_owned_copy_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_release_group_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_release_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music workspace schemas keep entity-owned fields separate', () {
    final groupFieldIds = _fieldIds(musicReleaseGroupWorkspaceSchema.fields);
    final groupColumnIds = _columnIds(musicReleaseGroupWorkspaceSchema.columns);
    final groupGroupIds = _groupIds(musicReleaseGroupWorkspaceSchema.groups);

    expect(groupFieldIds, contains(MusicFieldIds.title.value));
    expect(groupFieldIds, contains(MusicFieldIds.artist.value));
    expect(groupFieldIds, contains(MusicFieldIds.genre.value));
    expect(groupFieldIds, contains(MusicFieldIds.releaseCount.value));
    expect(groupFieldIds, contains(MusicFieldIds.aggregateListenCount.value));
    expect(groupFieldIds, contains(MusicFieldIds.aggregateLastListened.value));
    expect(groupFieldIds, contains(MusicFieldIds.listenedReleaseCount.value));
    expect(groupFieldIds, isNot(contains(MusicFieldIds.condition.value)));
    expect(groupFieldIds, isNot(contains(MusicFieldIds.location.value)));
    expect(groupFieldIds, isNot(contains(MusicFieldIds.pricePaid.value)));
    expect(groupFieldIds, isNot(contains(MusicFieldIds.catalogNumber.value)));
    expect(groupColumnIds, isNot(contains(MusicFieldIds.condition.value)));
    expect(groupGroupIds, isNot(contains(MusicGroupIds.condition.value)));

    final releaseFieldIds = _fieldIds(musicReleaseWorkspaceSchema.fields);
    expect(releaseFieldIds, contains(MusicFieldIds.catalogNumber.value));
    expect(releaseFieldIds, contains(MusicFieldIds.barcode.value));
    expect(releaseFieldIds, contains(MusicFieldIds.format.value));
    expect(releaseFieldIds, contains(MusicFieldIds.releaseType.value));
    expect(releaseFieldIds, contains(MusicFieldIds.releaseStatus.value));
    expect(releaseFieldIds, contains(MusicFieldIds.language.value));
    expect(releaseFieldIds, contains(MusicFieldIds.packaging.value));
    expect(releaseFieldIds, contains(MusicFieldIds.boxSet.value));
    expect(releaseFieldIds, contains(MusicFieldIds.listenCount.value));
    expect(releaseFieldIds, contains(MusicFieldIds.lastListened.value));
    expect(releaseFieldIds, isNot(contains(MusicFieldIds.condition.value)));
    expect(releaseFieldIds, isNot(contains(MusicFieldIds.location.value)));

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

  test('generic workspace selects Music schema from structural node type', () {
    final titleSchema = musicKindWorkspace.fieldsForNode(
      const LibraryTitleNodeRef(titleItemId: 'group-1'),
    );
    final releaseSchema = musicKindWorkspace.fieldsForNode(
      const LibraryReleaseNodeRef(
        titleItemId: 'group-1',
        releaseId: 'release-1',
        release: LibraryWorkspaceReleaseSummary(
          id: 'release-1',
          title: 'Release 1',
        ),
      ),
    );
    final copySchema = musicKindWorkspace.fieldsForNode(
      const LibraryCopyNodeRef(
        titleItemId: 'group-1',
        ownedRef: OwnedItemRef(
          kind: CatalogMediaKind.music,
          id: OwnedItemId('owned-1'),
        ),
      ),
    );

    expect(titleSchema.findColumnDefinition(MusicFieldIds.condition), isNull);
    expect(
      releaseSchema.findColumnDefinition(MusicFieldIds.catalogNumber),
      isNotNull,
    );
    expect(copySchema.findColumnDefinition(MusicFieldIds.condition), isNotNull);
    expect(
      copySchema.findColumnDefinition(MusicFieldIds.catalogNumber),
      isNull,
    );
  });

  test('browser mode exposes only its Music schema options', () {
    final workspace = musicKindWorkspace;
    final mediaGroups = workspace.availableGroupIdsForBrowserMode(
      LibraryWorkspaceBrowserMode.media,
    );
    final releaseGroups = workspace.availableGroupIdsForBrowserMode(
      LibraryWorkspaceBrowserMode.releases,
    );
    final mediaSorts = workspace.availableSortIdsForBrowserMode(
      LibraryWorkspaceBrowserMode.media,
    );
    final releaseSorts = workspace.availableSortIdsForBrowserMode(
      LibraryWorkspaceBrowserMode.releases,
    );

    expect(
      mediaGroups.map((id) => id.value),
      containsAll(['music.artist', 'music.genre']),
    );
    expect(releaseGroups.map((id) => id.value), contains('music.publisher'));
    expect(
        mediaSorts.map((id) => id.value), isNot(contains('music.publisher')));
    expect(releaseSorts.map((id) => id.value), contains('music.track_count'));
  });

  test('release nodes resolve an exact Music tracking target', () {
    const groupRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: 'group-1',
    );
    const releaseNode = LibraryReleaseNodeRef(
      titleItemId: 'group-1',
      releaseId: 'release-2',
      release: LibraryWorkspaceReleaseSummary(
        id: 'release-2',
        title: 'Release 2',
      ),
    );

    final target = musicKindWorkspace.trackingTargetForNode(
      releaseNode,
      groupRef,
    );

    expect(target.entityType.apiValue, 'release');
    expect(target.id, 'release-2');
    expect(target.rootId, 'group-1');
  });

  test('Music workspace artist falls back to a typed release credit', () {
    final group = MusicReleaseGroup(
      id: const MusicReleaseGroupId('group-1'),
      title: 'Compilation',
      releases: [
        MusicRelease(
          id: const MusicReleaseId('release-1'),
          releaseGroupId: const MusicReleaseGroupId('group-1'),
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
            MusicReleaseContribution(
              id: const MusicReleaseContributionId('credit-1'),
              releaseId: const MusicReleaseId('release-1'),
              personId: 'artist-1',
              role: 'Performer',
              displayName: 'Typed Artist',
            ),
          ],
        ),
      ],
    );
    final dto = MusicWorkspaceDto(
      common: const WorkspaceCommonProjection(title: 'Compilation'),
      personal: PersonalCopyProjection(),
      music: group,
      release: group.primaryRelease!,
    );

    expect(dto.artist, 'Typed Artist');
    expect(dto.seriesTitle, 'Typed Artist');
    expect(dto.barcode, '123');
    expect(dto.catalogNumber, 'CAT-1');
    expect(dto.boxSet, 'The Box');
  });
}

List<String> _fieldIds(
  Iterable<LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];

List<String> _columnIds(
  Iterable<LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];

List<String> _groupIds(
  Iterable<LibraryGroupDefinition<MusicKind, MusicWorkspaceDto, Object?>>
      definitions,
) =>
    [for (final definition in definitions) definition.id.value];
