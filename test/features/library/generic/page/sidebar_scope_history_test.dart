import 'package:collectarr_app/features/library/generic/page/sidebar_scope_history.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LibrarySidebarScopeSnapshot buildScope({
    String groupMode = 'series',
    String? bucket,
    String? letter,
    String? smartListName,
    String searchQuery = '',
  }) {
    return LibrarySidebarScopeSnapshot(
      groupMode: groupMode,
      selectedBucket: bucket,
      selectedLetter: letter,
      activeSmartListName: smartListName,
      searchQuery: searchQuery,
    );
  }

  test('updateLibrarySidebarScopeHistory appends previous non-root scope', () {
    final previous = buildScope(bucket: 'Batman');
    final next = buildScope(letter: 'B');

    final history = updateLibrarySidebarScopeHistory(
      history: const [],
      previous: previous,
      next: next,
    );

    expect(history, [previous]);
  });

  test('updateLibrarySidebarScopeHistory clears history for root scope', () {
    final history = updateLibrarySidebarScopeHistory(
      history: [buildScope(bucket: 'Batman')],
      previous: buildScope(letter: 'B'),
      next: buildScope(),
    );

    expect(history, isEmpty);
  });

  test('updateLibrarySidebarScopeHistory keeps previous bucket on group drilldown', () {
    final previous = buildScope(
      groupMode: 'series',
      bucket: 'Batman',
    );
    final next = buildScope(groupMode: 'publisher');

    final history = updateLibrarySidebarScopeHistory(
      history: const [],
      previous: previous,
      next: next,
    );

    expect(history, [previous]);
  });

  test('buildLibrarySidebarBreadcrumbs avoids duplicating current label', () {
    final current = buildScope(bucket: 'Batman');
    final breadcrumbs = buildLibrarySidebarBreadcrumbs(
      rootLabel: 'All Comics',
      history: [current],
      current: current,
      labelForScope: (scope) => scope.selectedBucket ?? 'Root',
    );

    expect(breadcrumbs, ['All Comics', 'Batman']);
  });

  test('popLibrarySidebarScopeHistory returns target and trimmed history', () {
    final first = buildScope(bucket: 'Batman');
    final second = buildScope(letter: 'B');

    final navigation = popLibrarySidebarScopeHistory([first, second]);

    expect(navigation, isNotNull);
    expect(navigation!.history, [first]);
    expect(navigation.target, second);
  });

  test('navigateLibrarySidebarScopeHistoryToBreadcrumb returns root target', () {
    final root = buildScope();
    final navigation = navigateLibrarySidebarScopeHistoryToBreadcrumb(
      history: [buildScope(bucket: 'Batman')],
      index: 0,
      rootScope: root,
    );

    expect(navigation, isNotNull);
    expect(navigation!.history, isEmpty);
    expect(navigation.target, root);
  });
}