part of '../../page.dart';

extension _PageKindHooks on GenericLibraryPageState {
  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  bool get _supportsMusicTrackSearch =>
      widget.type.workspace.kind == CatalogMediaKind.music;

  LibrarySearchTarget get _effectiveSearchTarget =>
      _supportsMusicTrackSearch ? _searchTarget : LibrarySearchTarget.all;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);

  bool get _supportsMediaReleaseSplit {
    return widget.type.capabilities.supportsMediaReleaseSplit;
  }

  bool get _isMovieMediaEditionScope {
    return widget.type.workspace.kind == CatalogMediaKind.movie &&
        _supportsMediaReleaseSplit;
  }

  static const Set<LibraryGroupMode> _movieMediaGroupModes = {
    LibraryGroupMode.title,
    LibraryGroupMode.movieOrTvSeries,
    LibraryGroupMode.genre,
    LibraryGroupMode.publisher,
    LibraryGroupMode.releaseDate,
    LibraryGroupMode.releaseMonth,
    LibraryGroupMode.releaseYear,
    LibraryGroupMode.country,
    LibraryGroupMode.language,
    LibraryGroupMode.ageRating,
    LibraryGroupMode.audienceRating,
    LibraryGroupMode.actor,
    LibraryGroupMode.director,
    LibraryGroupMode.producer,
    LibraryGroupMode.writer,
    LibraryGroupMode.photography,
    LibraryGroupMode.musician,
    LibraryGroupMode.collectionStatus,
    LibraryGroupMode.condition,
    LibraryGroupMode.location,
    LibraryGroupMode.addedDate,
    LibraryGroupMode.addedMonth,
    LibraryGroupMode.addedYear,
    LibraryGroupMode.modifiedDate,
    LibraryGroupMode.modifiedMonth,
    LibraryGroupMode.watchDate,
    LibraryGroupMode.watchMonth,
    LibraryGroupMode.watchYear,
  };

  static const Set<LibraryGroupMode> _movieEditionGroupModes = {
    LibraryGroupMode.title,
    LibraryGroupMode.edition,
    LibraryGroupMode.editionReleaseDate,
    LibraryGroupMode.editionReleaseMonth,
    LibraryGroupMode.editionReleaseYear,
    LibraryGroupMode.format,
    LibraryGroupMode.boxSet,
    LibraryGroupMode.distributor,
    LibraryGroupMode.hdr,
    LibraryGroupMode.layers,
    LibraryGroupMode.packaging,
    LibraryGroupMode.regions,
    LibraryGroupMode.screenRatios,
    LibraryGroupMode.subtitles,
    LibraryGroupMode.audioTracks,
    LibraryGroupMode.extras,
    LibraryGroupMode.collectionStatus,
    LibraryGroupMode.condition,
    LibraryGroupMode.location,
    LibraryGroupMode.addedDate,
    LibraryGroupMode.addedMonth,
    LibraryGroupMode.addedYear,
    LibraryGroupMode.modifiedDate,
    LibraryGroupMode.modifiedMonth,
    LibraryGroupMode.watchDate,
    LibraryGroupMode.watchMonth,
    LibraryGroupMode.watchYear,
  };

  static const Set<LibrarySortColumn> _movieMediaSortColumns = {
    LibrarySortColumn.status,
    LibrarySortColumn.title,
    LibrarySortColumn.publisher,
    LibrarySortColumn.releaseDate,
    LibrarySortColumn.country,
    LibrarySortColumn.language,
    LibrarySortColumn.ageRating,
    LibrarySortColumn.condition,
    LibrarySortColumn.price,
    LibrarySortColumn.location,
    LibrarySortColumn.collectionStatus,
    LibrarySortColumn.wishlist,
    LibrarySortColumn.added,
    LibrarySortColumn.updated,
  };

  static const Set<LibrarySortColumn> _movieEditionSortColumns = {
    LibrarySortColumn.status,
    LibrarySortColumn.title,
    LibrarySortColumn.variant,
    LibrarySortColumn.format,
    LibrarySortColumn.publisher,
    LibrarySortColumn.releaseDate,
    LibrarySortColumn.barcode,
    LibrarySortColumn.condition,
    LibrarySortColumn.price,
    LibrarySortColumn.location,
    LibrarySortColumn.collectionStatus,
    LibrarySortColumn.wishlist,
    LibrarySortColumn.added,
    LibrarySortColumn.updated,
  };

  List<LibraryGroupMode> get _scopeAvailableGroupModes {
    final allowed = widget.type.availableGroupModes;
    if (!_isMovieMediaEditionScope) {
      return allowed;
    }
    final scoped = _activeBrowserMode == LibraryWorkspaceBrowserMode.releases
        ? _movieEditionGroupModes
        : _movieMediaGroupModes;
    return [
      for (final mode in allowed)
        if (scoped.contains(mode)) mode,
    ];
  }

  List<LibrarySortColumn> get _scopeAvailableSortColumns {
    final allowed = widget.type.availableSortColumns;
    if (!_isMovieMediaEditionScope) {
      return allowed;
    }
    final scoped = _activeBrowserMode == LibraryWorkspaceBrowserMode.releases
        ? _movieEditionSortColumns
        : _movieMediaSortColumns;
    return [
      for (final column in allowed)
        if (scoped.contains(column)) column,
    ];
  }
}
