import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';

class LibrarySidebarHistoryNavigationResult {
  const LibrarySidebarHistoryNavigationResult({
    required this.history,
    required this.target,
  });

  final List<LibrarySidebarScopeSnapshot> history;
  final LibrarySidebarScopeSnapshot target;
}

List<LibrarySidebarScopeSnapshot> updateLibrarySidebarScopeHistory({
  required List<LibrarySidebarScopeSnapshot> history,
  required LibrarySidebarScopeSnapshot previous,
  required LibrarySidebarScopeSnapshot next,
}) {
  if (next.isRootScope) {
    if (previous.selectedBucket != null && next.groupMode != previous.groupMode) {
      final updatedHistory = List<LibrarySidebarScopeSnapshot>.from(history);
      if (updatedHistory.isEmpty || updatedHistory.last != previous) {
        updatedHistory.add(previous);
      }
      return updatedHistory;
    }
    return const [];
  }

  final updatedHistory = List<LibrarySidebarScopeSnapshot>.from(history);
  final existingIndex = updatedHistory.lastIndexOf(next);
  if (existingIndex != -1) {
    return updatedHistory.sublist(0, existingIndex);
  }

  if (!previous.isRootScope &&
      (updatedHistory.isEmpty || updatedHistory.last != previous)) {
    updatedHistory.add(previous);
  }
  return updatedHistory;
}

List<String> buildLibrarySidebarBreadcrumbs({
  required String rootLabel,
  required List<LibrarySidebarScopeSnapshot> history,
  required LibrarySidebarScopeSnapshot current,
  required String Function(LibrarySidebarScopeSnapshot snapshot) labelForScope,
}) {
  final breadcrumbs = <String>[rootLabel];
  breadcrumbs.addAll(history.map(labelForScope));
  final currentLabel = labelForScope(current);
  if (breadcrumbs.last != currentLabel) {
    breadcrumbs.add(currentLabel);
  }
  return breadcrumbs;
}

LibrarySidebarHistoryNavigationResult? popLibrarySidebarScopeHistory(
  List<LibrarySidebarScopeSnapshot> history,
) {
  if (history.isEmpty) {
    return null;
  }
  final updatedHistory = List<LibrarySidebarScopeSnapshot>.from(history);
  final target = updatedHistory.removeLast();
  return LibrarySidebarHistoryNavigationResult(
    history: updatedHistory,
    target: target,
  );
}

LibrarySidebarHistoryNavigationResult? navigateLibrarySidebarScopeHistoryToBreadcrumb({
  required List<LibrarySidebarScopeSnapshot> history,
  required int index,
  required LibrarySidebarScopeSnapshot rootScope,
}) {
  if (index <= 0) {
    return LibrarySidebarHistoryNavigationResult(
      history: const [],
      target: rootScope,
    );
  }
  if (index > history.length) {
    return null;
  }
  return LibrarySidebarHistoryNavigationResult(
    history: history.sublist(0, index - 1),
    target: history[index - 1],
  );
}