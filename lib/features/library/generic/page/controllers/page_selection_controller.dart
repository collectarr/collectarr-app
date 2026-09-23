import 'dart:async';

import 'package:collectarr_app/features/library/generic/page/library_page_session.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:flutter/material.dart';

final class LibraryPageSelectionController {
  const LibraryPageSelectionController({
    required this.selection,
    required this.facets,
    required this.isMounted,
    required this.mutateState,
    required this.hasItemDrilldown,
    required this.drilldownRootItemId,
    required this.closeItemDrilldown,
    required this.hydrateSelectedItem,
    required this.removeVisibleSelection,
  });

  final LibraryPageSelectionSession selection;
  final LibraryPageFacetSession facets;
  final bool Function() isMounted;
  final void Function(VoidCallback callback) mutateState;
  final bool Function() hasItemDrilldown;
  final String? Function() drilldownRootItemId;
  final VoidCallback closeItemDrilldown;
  final Future<void> Function(String id) hydrateSelectedItem;
  final void Function(LibraryProjection projection) removeVisibleSelection;

  void selectItem(String id) {
    mutateState(() {
      selection.selectedId = id;
      if (hasItemDrilldown() && drilldownRootItemId() != id) {
        closeItemDrilldown();
      }
    });
    selection.hydrationDebounce?.cancel();
    selection.hydrationDebounce = Timer(
      const Duration(milliseconds: 250),
      () {
        if (!isMounted() || selection.selectedId != id) return;
        unawaited(hydrateSelectedItem(id));
      },
    );
  }

  void activateItem(String id) {
    if (selection.value.enabled) {
      mutateState(() => selection.value = selection.value.clear());
    }
    selection.anchorId = id;
    selectItem(id);
  }

  void toggleSelectionItem(String id) {
    mutateState(() {
      selection.value = selection.value.toggle(id);
      selection.selectedId = id;
      selection.anchorId = id;
    });
  }

  void applySelection(Set<String> ids, String focusedId) {
    mutateState(() {
      selection.value = selection.value.replace(ids);
      selection.selectedId = focusedId;
      selection.anchorId ??= focusedId;
    });
  }

  void selectAllVisible(LibraryProjection projection) {
    if (_isTextInputFocused()) return;
    final visibleIds = _visibleSelectionItemIds(projection);
    if (visibleIds.isEmpty) return;
    applySelection(visibleIds, selection.selectedId ?? visibleIds.first);
  }

  void removeVisibleItems(LibraryProjection projection) {
    if (_isTextInputFocused() || selection.value.itemIds.isEmpty) return;
    removeVisibleSelection(projection);
  }

  Set<String> _visibleSelectionItemIds(LibraryProjection projection) {
    final letter = facets.selectedLetter;
    final visibleItems = letter == null
        ? projection.filteredItems
        : projection.filteredItems
            .where((item) => LibraryAlphaJumpBar.matchesLetter(
                item.dto.primaryLabel, letter))
            .toList(growable: false);
    return visibleItems.map((item) => item.node.id).toSet();
  }

  bool _isTextInputFocused() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    return focusedContext?.widget is EditableText;
  }
}
