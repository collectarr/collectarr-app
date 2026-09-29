import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

const tvAddMediaOptionId = 'tv.media';
const tvAddSeasonOptionId = 'tv.season';
const tvAddReleaseOptionId = 'tv.release';

enum TvAddResultScope { media, season, release }

typedef TvAddCoreScopeResolver = TvAddResultScope Function(
  CatalogSearchCandidate item,
);

LibraryAddResultPolicy buildTvAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required TvAddCoreScopeResolver coreScopeForItem,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
}) =>
    LibraryAddResultPolicy(
      useGridResults: true,
      options: [
        LibraryAddResultOption(id: tvAddMediaOptionId, label: mediaLabel),
        if (supportsSeasonScope)
          const LibraryAddResultOption(
            id: tvAddSeasonOptionId,
            label: 'Seasons',
          ),
        const LibraryAddResultOption(
          id: tvAddReleaseOptionId,
          label: 'Releases',
        ),
      ],
      coreResultVisibility: (item, context) => context.optionIsEnabled(
        _tvScopeOptionId(
          coreScopeForItem(item),
          supportsSeasonScope: supportsSeasonScope,
        ),
      ),
      coreGroupTitleBuilder: coreGroupTitleBuilder,
    );

String _tvScopeOptionId(
  TvAddResultScope scope, {
  required bool supportsSeasonScope,
}) =>
    switch (scope) {
      TvAddResultScope.media => tvAddMediaOptionId,
      TvAddResultScope.season =>
        supportsSeasonScope ? tvAddSeasonOptionId : tvAddMediaOptionId,
      TvAddResultScope.release => tvAddReleaseOptionId,
    };
