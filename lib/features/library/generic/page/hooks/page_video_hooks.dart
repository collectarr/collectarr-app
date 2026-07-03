part of '../../page.dart';

// ignore_for_file: invalid_use_of_protected_member, unused_element

extension _PageVideoHooks on GenericLibraryPageState {
  bool _canOpenVideoShelfDrilldown(LibraryProjectionItem item) {
    return canOpenVideoShelfDrilldown(widget.type, item.entry);
  }

  @protected
  bool canOpenDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    return _canOpenVideoShelfDrilldown(item);
  }

  void _openVideoShelfDrilldown(LibraryProjectionItem item) {
    setState(() {
      _selectedId = item.entry.id;
      _kindBrowserDelegate.videoShelfDrilldownTitleItemId = item.entry.id;
      _kindBrowserDelegate.videoShelfDrilldownReleaseId = null;
    });
  }

  @protected
  void openDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    _openVideoShelfDrilldown(item);
  }

  Future<void> _refreshVideoTitleFromCore(LibraryProjectionItem item) async {
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      allEntries: [item.entry],
      shownEntries: [item.entry],
      selectedEntry: item.entry,
    );
    if (result == null || !mounted) {
      return;
    }
    ref.invalidate(shelfProvider);
    showAppToast(
      context,
      'Metadata refresh finished: ${result.matched}/${result.targets} matched, ${result.cached} cached, ${result.failed} failed.',
      tone: AppToastTone.success,
    );
  }

  Widget? _buildVideoShelfDrilldown(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final titleItemId = _kindBrowserDelegate.videoShelfDrilldownTitleItemId;
    if (titleItemId == null) {
      return null;
    }
    final itemsById = {
      for (final item in projection.allItems) item.entry.id: item,
    };
    final titleItem = itemsById[titleItemId];
    if (titleItem == null || !_canOpenVideoShelfDrilldown(titleItem)) {
      if (_kindBrowserDelegate.videoShelfDrilldownTitleItemId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _kindBrowserDelegate.videoShelfDrilldownTitleItemId = null;
            _kindBrowserDelegate.videoShelfDrilldownReleaseId = null;
          });
        });
      }
      return null;
    }

    final ownedCopiesByItemId = <String, List<OwnedItem>>{};
    for (final ownedItem in allOwnedCopies) {
      (ownedCopiesByItemId[ownedItem.itemId] ??= <OwnedItem>[]).add(ownedItem);
    }
    final wishlistByItemId = <String, List<WishlistItem>>{};
    for (final wishlistItem in allWishlistItems) {
      (wishlistByItemId[wishlistItem.itemId] ??= <WishlistItem>[])
          .add(wishlistItem);
    }
    final ownedCopies = ownedCopiesByItemId[titleItemId] ?? const <OwnedItem>[];
    final wishlistItems =
        wishlistByItemId[titleItemId] ?? const <WishlistItem>[];
    final drilldownItems = buildVideoShelfReleaseItems(
      titleItem: titleItem,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
      releaseEntryBuilder: widget.type.presentation.releaseEntryBuilder,
    );

    if (_kindBrowserDelegate.videoShelfDrilldownReleaseId == null &&
        drilldownItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _kindBrowserDelegate.videoShelfDrilldownReleaseId != null) {
          return;
        }
        setState(() => _kindBrowserDelegate.videoShelfDrilldownReleaseId =
            drilldownItems.first.entry.id);
      });
    }

    return VideoShelfReleaseDrilldown(
      titleItem: titleItem,
      items: drilldownItems,
      selectedReleaseId: _kindBrowserDelegate.videoShelfDrilldownReleaseId,
      coverSize: viewState.coverSize,
      accent: widget.accent,
      onBack: () => setState(() {
        _kindBrowserDelegate.videoShelfDrilldownTitleItemId = null;
        _kindBrowserDelegate.videoShelfDrilldownReleaseId = null;
      }),
      onRefreshFromCore: () => _refreshVideoTitleFromCore(titleItem),
      onSelectRelease: (releaseId) =>
          setState(() => _kindBrowserDelegate.videoShelfDrilldownReleaseId = releaseId),
      onOpenTitleDetails: () => showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          entry: titleItem.entry,
          ownedItem: titleItem.source.ownedItem,
          accent: widget.accent,
          onAddOwned: () => runCollectionAction(
            (actions) => actions.addOwned(titleItem),
          ),
          onRemoveOwned: titleItem.source.ownedItem == null
              ? null
              : () => confirmAndRemoveOwned(titleItem),
          onAddWishlist: () => runCollectionAction(
            (actions) => actions.addWishlist(titleItem),
          ),
          onRemoveWishlist: titleItem.source.isWishlisted
              ? () => runCollectionAction(
                    (actions) => actions.removeWishlist(titleItem),
                  )
              : null,
          onEdit: (ownedItem) =>
              unawaited(showEditDialog(titleItem, ownedItem)),
          onFilterByValue: _toggleLinkedMetadataFilter,
        ),
      ),
    );
  }

}
