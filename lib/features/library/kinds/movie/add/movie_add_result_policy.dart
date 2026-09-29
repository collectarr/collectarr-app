import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';

const movieAddMediaOptionId = 'movie.media';
const movieAddSeasonOptionId = 'movie.season';
const movieAddReleaseOptionId = 'movie.release';

enum MovieAddResultScope { media, season, release }

typedef MovieAddCoreScopeResolver = MovieAddResultScope Function(
  CatalogSearchCandidate item,
);

LibraryAddResultPolicy buildMovieAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required MovieAddCoreScopeResolver coreScopeForItem,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
}) =>
    LibraryAddResultPolicy(
      useGridResults: true,
      options: [
        LibraryAddResultOption(id: movieAddMediaOptionId, label: mediaLabel),
        if (supportsSeasonScope)
          const LibraryAddResultOption(
            id: movieAddSeasonOptionId,
            label: 'Seasons',
          ),
        const LibraryAddResultOption(
          id: movieAddReleaseOptionId,
          label: 'Releases',
        ),
      ],
      coreResultVisibility: (item, context) => context.optionIsEnabled(
        _movieScopeOptionId(
          coreScopeForItem(item),
          supportsSeasonScope: supportsSeasonScope,
        ),
      ),
      coreGroupTitleBuilder: coreGroupTitleBuilder,
    );

String _movieScopeOptionId(
  MovieAddResultScope scope, {
  required bool supportsSeasonScope,
}) =>
    switch (scope) {
      MovieAddResultScope.media => movieAddMediaOptionId,
      MovieAddResultScope.season =>
        supportsSeasonScope ? movieAddSeasonOptionId : movieAddMediaOptionId,
      MovieAddResultScope.release => movieAddReleaseOptionId,
    };
