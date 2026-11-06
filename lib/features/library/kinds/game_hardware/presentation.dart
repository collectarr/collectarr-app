import 'workspace/card_presentation.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/config/media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/details/models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'workspace/dto.dart';

final class GameHardwarePresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GameHardwarePresentationBuilder();
  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay(
      {required CatalogSearchCandidate item}) {
    final platform = item.kindCapability
        .mapTransport((transport) => transport.kindData['platform'])
        ?.toString()
        .trim();
    return LibraryAddSearchResultDisplay(
        title: item.summary.primaryLabel,
        secondaryLine: null,
        detailLine: null,
        platform: platform == null || platform.isEmpty ? null : platform);
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem(
          {required CatalogSearchCandidate hydrated,
          required CatalogSearchCandidate fallback}) =>
      hydrated;
  @override
  LibraryMetadataPresentation buildMetadataPresentation(
      {required String singularLabel,
      required LibraryProjectionView item,
      required bool includeIdentityFacts,
      required LibraryMetadataFactTapResolver tapFor}) {
    final dto = item.dto as GameHardwareWorkspaceDto;
    return LibraryMetadataPresentation(identityFacts: [
      if (includeIdentityFacts)
        LibraryDetailField(label: 'Title', value: dto.primaryLabel)
    ], contextFacts: [
      if (dto.metadata.seriesTitle case final value?)
        LibraryDetailField(label: 'Series', value: value),
      if (dto.metadata.releaseDateParts?.isoString case final value?)
        LibraryDetailField(label: 'Release Date', value: value),
      if (dto.metadata.barcode case final value?)
        LibraryDetailField(label: 'Barcode', value: value),
      if (dto.metadata.platform case final value?)
        LibraryDetailField(label: 'Platform', value: value),
      if (dto.metadata.hardwareType case final value?)
        LibraryDetailField(label: 'Hardware Type', value: value),
    ], sections: const {});
  }
}

final gameHardwareLibraryMediaPresentation = LibraryMediaPresentation(
    cardPresentationBuilder: buildGameHardwareCardPresentation,
    searchFieldLabels: const LibraryMediaSearchFieldLabels(
        queryHint: 'Enter title...',
        libraryHint: 'Search Hardware...',
        emptySearchMessage: 'Enter a title or barcode.'),
    filterLabels: const LibraryPresentationLabels(),
    groupLabels: const LibraryPresentationLabels(),
    builder: const GameHardwarePresentationBuilder(),
    bucketLabelBuilder: (context) => defaultLibraryBucketLabel(context,
        const LibraryPresentationLabels(), const LibraryPresentationLabels()),
    defaultFolderFavorites: const [
      ['game_hardware.platform'],
      ['game_hardware.completeness']
    ],
    // The reference's one built-in favorite, matching the default sort.
    sortFavorites: const [
      LibrarySortFavorite(
          id: 'platform_title',
          label: 'Platform / Title',
          icon: AppIcons.sortAlpha,
          rules: [
            LibrarySortRule(column: 'game_hardware.platform', ascending: true),
            LibrarySortRule(column: 'game_hardware.title', ascending: true),
          ]),
    ],
    // The reference column favorites, limited to the Hardware columns.
    duplicateColumns: const [
      'game_hardware.title',
      'game_hardware.platform',
      'game_hardware.release_date',
      'game_hardware.index',
      'game_hardware.added_date',
    ],
    columnFavorites: const [
      LibraryTableColumnPreset(label: 'My List View columns', columns: {
        'game_hardware.platform_icon',
        'game_hardware.platform',
        'game_hardware.title',
        'game_hardware.release_date',
      }),
      LibraryTableColumnPreset(label: 'My Find Duplicates columns', columns: {
        'game_hardware.title',
        'game_hardware.platform',
        'game_hardware.release_date',
        'game_hardware.index',
        'game_hardware.added_date',
      }),
      LibraryTableColumnPreset(label: 'My Print / Export columns', columns: {
        'game_hardware.platform',
        'game_hardware.title',
        'game_hardware.release_date',
      }),
    ]);
