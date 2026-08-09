import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryAddSessionController extends ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionController({
    required this.kind,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    LibraryAddSessionState? initialState,
  }) : super(
          initialState ??
              LibraryAddSessionState(
                mode: LibraryAddDialogMode.search,
                target: LibraryAddTarget.owned,
                search: LibraryAddSearchState.initial(),
                selection: LibraryAddSelectionState(),
                preview: const LibraryAddPreviewState.initial(),
                commonDraft: const LibraryAddCommonDraft(),
                manualDraft: defaultAddKindDraftForKind(kind),
                submitState: const AsyncValue.data(null),
              ),
        );

  final CatalogMediaKind kind;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  Timer? _searchDebounceTimer;

  LibraryAddSessionState get state => value;
  set state(LibraryAddSessionState newState) => value = newState;

  void setMode(LibraryAddDialogMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setTarget(LibraryAddTarget target) {
    state = state.copyWith(target: target);
  }

  void updateQuery(String query) {
    state = state.copyWith(
      search: state.search.copyWith(query: query),
    );
    _searchDebounceTimer?.cancel();
    if (query.trim().isNotEmpty) {
      _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
        executeSearch();
      });
    }
  }

  Future<void> executeSearch() async {
    final q = state.search.query.trim();
    if (q.isEmpty) return;

    state = state.copyWith(
      search: state.search.copyWith(isSearching: true, error: null),
    );

    try {
      state = state.copyWith(
        search: state.search.copyWith(isSearching: false),
      );
    } catch (e) {
      state = state.copyWith(
        search: state.search.copyWith(
          isSearching: false,
          error: e.toString(),
        ),
      );
    }
  }

  void cancelSearch() {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(
      search: state.search.copyWith(isSearching: false),
    );
  }

  void selectResult(String id) {
    state = state.copyWith(
      selection: state.selection.copyWith(selectedId: id),
    );
  }

  void updateCommonDraft(LibraryAddCommonDraft Function(LibraryAddCommonDraft) update) {
    state = state.copyWith(commonDraft: update(state.commonDraft));
  }

  void updateKindDraft(LibraryAddKindDraft Function(LibraryAddKindDraft) update) {
    state = state.copyWith(manualDraft: update(state.manualDraft));
  }

  Future<bool> submitSelectedItem(CatalogItem item) async {
    state = state.copyWith(submitState: const AsyncValue.loading());
    try {
      final capability = LibraryAddCapabilityRegistry.instance.getForKind(kind);
      final command = capability.buildCommand(item, state.commonDraft, state.manualDraft);

      switch (state.target) {
        case LibraryAddTarget.owned:
          await ownedMutations.addOwnedItem(command);
        case LibraryAddTarget.wishlist:
          await wishlistMutations.addToWishlist(item.id);
        case LibraryAddTarget.track:
          await trackingMutations.addLocalOnlyTrackingEntry(item);
      }

      state = state.copyWith(submitState: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(submitState: AsyncValue.error(e, st));
      return false;
    }
  }

  void retry() {
    state = state.copyWith(submitState: const AsyncValue.data(null));
    executeSearch();
  }

  void reset() {
    _searchDebounceTimer?.cancel();
    state = LibraryAddSessionState(
      mode: LibraryAddDialogMode.search,
      target: LibraryAddTarget.owned,
      search: LibraryAddSearchState.initial(),
      selection: LibraryAddSelectionState(),
      preview: const LibraryAddPreviewState.initial(),
      commonDraft: const LibraryAddCommonDraft(),
      manualDraft: defaultAddKindDraftForKind(kind),
      submitState: const AsyncValue.data(null),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}
