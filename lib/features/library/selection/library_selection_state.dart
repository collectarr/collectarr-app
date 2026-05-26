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

  LibrarySelectionState merge(Iterable<String> itemIdsToAdd) {
    final nextItemIds = Set<String>.of(itemIds)..addAll(itemIdsToAdd);
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

  LibrarySelectionState replace(Iterable<String> nextItemIds) {
    final ids = Set<String>.from(nextItemIds);
    return LibrarySelectionState(
      enabled: ids.isNotEmpty,
      itemIds: ids,
    );
  }
}

Set<String> selectionRangeItemIds(
  List<String> orderedItemIds, {
  required String anchorId,
  required String targetId,
}) {
  final anchorIndex = orderedItemIds.indexOf(anchorId);
  final targetIndex = orderedItemIds.indexOf(targetId);
  if (anchorIndex < 0 || targetIndex < 0) {
    return {targetId};
  }
  final start = anchorIndex < targetIndex ? anchorIndex : targetIndex;
  final end = anchorIndex < targetIndex ? targetIndex : anchorIndex;
  return orderedItemIds.sublist(start, end + 1).toSet();
}

Set<String> contextMenuSelectionItemIds(
  Set<String> selectedItemIds, {
  required String clickedId,
}) {
  if (selectedItemIds.length > 1 && selectedItemIds.contains(clickedId)) {
    return Set<String>.from(selectedItemIds);
  }
  return {clickedId};
}
