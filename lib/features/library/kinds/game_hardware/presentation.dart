import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'inspector/sections.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'workspace/dto.dart';

final class GameHardwarePresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GameHardwarePresentationBuilder();
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

  @override
  LibraryCardPresentation buildCardPresentation(LibraryProjectionView item,
      {bool coverFocused = false}) {
    final dto = item.dto as GameHardwareWorkspaceDto;
    final personal = dto.entry?.personal;
    return LibraryCardPresentation(
        detailLine: dto.metadata.releaseDateParts?.isoString,
        seriesTitle: dto.metadata.seriesTitle,
        format: dto.metadata.platform,
        valueLabel:
            personal == null ? null : gameHardwareValueSummary(personal),
        synopsis: dto.metadata.description,
        identifierCode: dto.metadata.barcode);
  }
}

final gameHardwareLibraryMediaPresentation = LibraryMediaPresentation(
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
