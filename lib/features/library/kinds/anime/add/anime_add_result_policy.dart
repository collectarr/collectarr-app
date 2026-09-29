import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

const animeAddMediaOptionId = 'anime.media';
const animeAddSeasonOptionId = 'anime.season';
const animeAddReleaseOptionId = 'anime.release';

enum AnimeAddResultScope { media, season, release }

typedef AnimeAddCoreScopeResolver = AnimeAddResultScope Function(
  CatalogSearchCandidate item,
);

LibraryAddResultPolicy buildAnimeAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required AnimeAddCoreScopeResolver coreScopeForItem,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
}) =>
    LibraryAddResultPolicy(
      useGridResults: true,
      options: [
        LibraryAddResultOption(id: animeAddMediaOptionId, label: mediaLabel),
        if (supportsSeasonScope)
          const LibraryAddResultOption(
            id: animeAddSeasonOptionId,
            label: 'Seasons',
          ),
        const LibraryAddResultOption(
          id: animeAddReleaseOptionId,
          label: 'Releases',
        ),
      ],
      coreResultVisibility: (item, context) => context.optionIsEnabled(
        _animeScopeOptionId(
          coreScopeForItem(item),
          supportsSeasonScope: supportsSeasonScope,
        ),
      ),
      coreGroupTitleBuilder: coreGroupTitleBuilder,
    );

String _animeScopeOptionId(
  AnimeAddResultScope scope, {
  required bool supportsSeasonScope,
}) =>
    switch (scope) {
      AnimeAddResultScope.media => animeAddMediaOptionId,
      AnimeAddResultScope.season =>
        supportsSeasonScope ? animeAddSeasonOptionId : animeAddMediaOptionId,
      AnimeAddResultScope.release => animeAddReleaseOptionId,
    };
