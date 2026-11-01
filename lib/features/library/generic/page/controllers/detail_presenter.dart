part of '../page.dart';

/// Detail presentation shares the existing page session and item command coordinators.
abstract final class _LibraryDetailPresenter {
  static Widget build(GenericLibraryPageState state, BuildContext context,
      LibraryTargetRef target) {
    final item = state.ref.watch(restorableDetailItemProvider(target));
    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context
            .go(AppRoutes.forKind(AppRoutes.libraries, target.kind.apiValue));
      }
    }

    return item.when(
        loading: () => Scaffold(
            appBar: AppBar(
                leading: BackButton(onPressed: back),
                title: const Text('Details')),
            body: const Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
            appBar: AppBar(
                leading: BackButton(onPressed: back),
                title: const Text('Item unavailable')),
            body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                  'Unable to load this item. Your library is unchanged.'),
              TextButton(
                  onPressed: () => state.ref
                      .invalidate(restorableDetailItemProvider(target)),
                  child: const Text('Retry'))
            ]))),
        data: (loaded) {
          if (loaded == null) {
            return Scaffold(
                appBar: AppBar(
                    leading: BackButton(onPressed: back),
                    title: const Text('Item unavailable')),
                body: const Center(
                    child: Text(
                        'This item was removed or is not available offline.')));
          }
          final hint = state.widget.detailHint;
          final request = state._editCoordinator
              .detailRequest(loaded, projection: hint?.projection);
          final shelf = state.ref.watch(shelfProvider).asData?.value;
          final neighbors = hint?.projection?.filteredItems ??
              (shelf == null
                  ? <LibraryProjectionItem>[]
                  : libraryItemsForShelf(shelf, state.widget.type));
          final index = neighbors.indexWhere((item) => item.target == target);
          void neighbor(int offset) {
            final next = neighbors[index + offset];
            context.replace(
                LibraryDetailLocation(next.target).toUri().toString(),
                extra: hint == null
                    ? null
                    : LibraryDetailPageRequest(
                        type: hint.type,
                        item: next,
                        projection: hint.projection,
                        libraryEntrySummary: next.source.libraryEntrySummary,
                        libraryEntryDispatch: next.source.libraryEntryDispatch,
                        accent: hint.accent,
                        onFilterByValue: hint.onFilterByValue,
                        onDetailsLayoutChanged: hint.onDetailsLayoutChanged,
                      ));
          }

          return Scaffold(
              appBar: AppBar(
                  backgroundColor: state.widget.accent,
                  foregroundColor: Colors.white,
                  leading: BackButton(onPressed: back),
                  title: Text(loaded.source.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  actions: [
                    IconButton(
                        tooltip: 'Previous item',
                        onPressed: index > 0 ? () => neighbor(-1) : null,
                        icon: const Icon(Icons.chevron_left)),
                    IconButton(
                        tooltip: 'Next item',
                        onPressed: index >= 0 && index + 1 < neighbors.length
                            ? () => neighbor(1)
                            : null,
                        icon: const Icon(Icons.chevron_right))
                  ]),
              body: LibraryDetailPage.fromRequest(request,
                  popAfterNavigationActions: false, onFilterByValue: (value) {
                final parentFilter = state.widget.detailHint?.onFilterByValue;
                if (parentFilter != null) {
                  parentFilter(value);
                  back();
                  return;
                }
                state._session.facets.linkedMetadataFilter =
                    LibraryLinkedMetadataFilter(value: value);
                final uri = state._buildRouteState().toUri(
                    Uri(path: AppRoutes.libraries),
                    type: state.widget.type);
                context.go(uri.toString());
              }, onDetailsLayoutChanged: (layout) {
                final parentLayout =
                    state.widget.detailHint?.onDetailsLayoutChanged;
                if (parentLayout != null) {
                  parentLayout(layout);
                } else {
                  state._updateViewState(
                      (value) => value.copyWith(detailsLayout: layout));
                }
                back();
              }));
        });
  }
}
