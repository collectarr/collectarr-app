class ComicsPageSelectionState {
  ComicsPageSelectionState({
    required this.enabled,
    required Set<String> itemIds,
  }) : itemIds = Set.unmodifiable(itemIds);

  factory ComicsPageSelectionState.empty() {
    return ComicsPageSelectionState(
      enabled: false,
      itemIds: const {},
    );
  }

  final bool enabled;
  final Set<String> itemIds;

  ComicsPageSelectionState toggle(String itemId) {
    final nextItemIds = Set<String>.of(itemIds);
    if (!nextItemIds.add(itemId)) {
      nextItemIds.remove(itemId);
    }
    return ComicsPageSelectionState(
      enabled: nextItemIds.isNotEmpty,
      itemIds: nextItemIds,
    );
  }

  ComicsPageSelectionState setEnabled(bool value) {
    return ComicsPageSelectionState(
      enabled: value,
      itemIds: value ? itemIds : const {},
    );
  }

  ComicsPageSelectionState clear() => ComicsPageSelectionState.empty();
}
