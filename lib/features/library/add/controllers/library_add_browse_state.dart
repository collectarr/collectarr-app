import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:flutter/foundation.dart';

/// The browse tab: found groups, then the items of the opened one.
@immutable
class LibraryAddBrowseState {
  const LibraryAddBrowseState({
    this.query = '',
    this.isSearching = false,
    this.searched = false,
    this.found = const [],
    this.opened,
    this.isLoadingItems = false,
    this.error,
  });

  final String query;
  final bool isSearching;
  final bool searched;
  final List<LibraryAddBrowseGroup> found;

  /// The group whose items are the current results.
  final LibraryAddBrowseGroup? opened;
  final bool isLoadingItems;
  final String? error;

  bool get isBusy => isSearching || isLoadingItems;

  LibraryAddBrowseState copyWith({
    String? query,
    bool? isSearching,
    bool? searched,
    List<LibraryAddBrowseGroup>? found,
    LibraryAddBrowseGroup? opened,
    bool clearOpened = false,
    bool? isLoadingItems,
    String? error,
    bool clearError = false,
  }) {
    return LibraryAddBrowseState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      searched: searched ?? this.searched,
      found: found ?? this.found,
      opened: clearOpened ? null : (opened ?? this.opened),
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
