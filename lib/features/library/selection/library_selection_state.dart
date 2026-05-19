class LibrarySelectionState {
  LibrarySelectionState({
    required this.enabled,
    required Set<String> itemIds,
  }) : itemIds = Set.unmodifiable(itemIds);

  factory LibrarySelectionState.empty() {
    return LibrarySelectionState(
      enabled: false,
      itemIds: const {},
    );
  }

  final bool enabled;
  final Set<String> itemIds;

  int get selectedCount => itemIds.length;

  LibrarySelectionState toggle(String itemId) {
    final nextItemIds = Set<String>.of(itemIds);
    if (!nextItemIds.add(itemId)) {
      nextItemIds.remove(itemId);
    }
    return LibrarySelectionState(
      enabled: nextItemIds.isNotEmpty,
      itemIds: nextItemIds,
    );
  }

  LibrarySelectionState setEnabled(bool value) {
    return LibrarySelectionState(
      enabled: value,
      itemIds: value ? itemIds : const {},
    );
  }

  LibrarySelectionState clear() => LibrarySelectionState.empty();
}
