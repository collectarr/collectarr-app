import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sidebar max width can exceed the old hard cap when viewport allows it', () {
    final maxWidth = resolveLibrarySidebarMaxWidth(
      viewportWidth: 1680,
      workspaceMinWidth: kLibraryWorkspaceMinWidth,
      hasRightDetails: true,
      rightDetailsWidth: 520,
    );

    expect(maxWidth, 816);
    expect(maxWidth, greaterThan(kLibrarySidebarMaxWidth));
  });

  test('details max width can exceed the old hard cap when viewport allows it', () {
    final maxWidth = resolveLibraryDetailsMaxWidth(
      viewportWidth: 1680,
      workspaceMinWidth: kLibraryWorkspaceMinWidth,
      hasSidebar: true,
      sidebarWidth: 360,
    );

    expect(maxWidth, 976);
    expect(maxWidth, greaterThan(kLibraryDetailsMaxWidth));
  });

  test('details max height can exceed the old fixed pane height', () {
    final maxHeight = resolveLibraryDetailsMaxHeight(
      viewportHeight: 1200,
      workspaceMinHeight: kLibraryWorkspaceMinHeight,
    );

    expect(maxHeight, 968);
    expect(maxHeight, greaterThan(kLibraryDetailsDefaultHeight));
  });
}
