import 'inspector/game_toy_inspector_sections.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'workspace/game_toy_workspace_dto.dart';

final class GameToyPresentationBuilder extends LibraryMediaPresentationBuilder {
  const GameToyPresentationBuilder();
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
    final dto = item.dto as GameToyWorkspaceDto;
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
      if (dto.metadata.toyType case final value?)
        LibraryDetailField(label: 'Type', value: value),
      if (dto.metadata.toySubtype case final value?)
        LibraryDetailField(label: 'Subtype', value: value),
    ], sections: const {});
  }

  @override
  LibraryCardPresentation buildCardPresentation(LibraryProjectionView item,
      {bool coverFocused = false}) {
    final dto = item.dto as GameToyWorkspaceDto;
    final personal = dto.entry?.personal;
    return LibraryCardPresentation(
        detailLine: dto.metadata.releaseDateParts?.isoString,
        seriesTitle: dto.metadata.seriesTitle,
        format: dto.metadata.toyType,
        valueLabel: personal == null ? null : gameToyValueSummary(personal),
        synopsis: dto.metadata.description,
        identifierCode: dto.metadata.barcode);
  }
}

final gameToyKindPresentation = LibraryMediaPresentation(
    searchFieldLabels: const LibraryMediaSearchFieldLabels(
        queryHint: 'Enter title...',
        libraryHint: 'Search Toys...',
        emptySearchMessage: 'Enter a title or barcode.'),
    filterLabels: const LibraryPresentationLabels(),
    groupLabels: const LibraryPresentationLabels(),
    builder: const GameToyPresentationBuilder(),
    bucketLabelBuilder: (context) => defaultLibraryBucketLabel(context,
        const LibraryPresentationLabels(), const LibraryPresentationLabels()),
    defaultFolderFavorites: const [
      ['game_toy.toy_type'],
      ['game_toy.completeness']
    ]);
