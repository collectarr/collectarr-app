import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = BookLibraryEditPresentationBuilder();

  LibraryEditPresentationContext contextFor(LibraryEditScope scope) {
    return LibraryEditPresentationContext(
      isOwned: true,
      isTrackingOnly: false,
      hasTrackingContext: true,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: false,
      hasEditionAnchors: true,
      hasBundleReleaseAnchors: false,
      hasCustomFields: true,
      scope: scope,
    );
  }

  test('shows read history in media and release scopes', () {
    final mediaTabs = builder.buildTabs(context: contextFor(LibraryEditScope.media));
    final releaseTabs =
        builder.buildTabs(context: contextFor(LibraryEditScope.release));

    expect(mediaTabs.map((tab) => tab.id), contains('read_history'));
    expect(releaseTabs.map((tab) => tab.id), contains('read_history'));
  });

  test('uses the same read history section in media and release scopes', () {
    expect(
      builder.buildTabSectionIds(
        context: contextFor(LibraryEditScope.media),
        tabId: 'read_history',
      ),
      ['book_read_history'],
    );
    expect(
      builder.buildTabSectionIds(
        context: contextFor(LibraryEditScope.release),
        tabId: 'read_history',
      ),
      ['book_read_history'],
    );
  });
}
