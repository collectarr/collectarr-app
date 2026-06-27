import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mediaBuilder = BookLibraryMediaEditPresentationBuilder();
  const releaseBuilder = BookLibraryReleaseEditPresentationBuilder();
  const presentation = LibraryEditPresentation(
    builder: mediaBuilder,
    mediaBuilder: mediaBuilder,
    releaseBuilder: releaseBuilder,
  );

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

  test('uses separate builders for media and release', () {
    final mediaTabs = mediaBuilder.buildTabs(
      context: contextFor(LibraryEditScope.media),
    );
    final releaseTabs = releaseBuilder.buildTabs(
      context: contextFor(LibraryEditScope.release),
    );

    expect(mediaTabs.map((tab) => tab.id).toList(), [
      'main',
      'credits',
      'custom',
      'read_history',
      'covers',
      'plot',
      'links',
    ]);
    expect(releaseTabs.map((tab) => tab.id).toList(), [
      'details',
      'personal',
      'custom',
      'read_history',
      'value',
      'photos',
    ]);
  });

  test('maps read history to different builders through scope selection', () {
    expect(
      presentation.builderForScope(LibraryEditScope.media).buildTabSectionIds(
        context: contextFor(LibraryEditScope.media),
        tabId: 'read_history',
      ),
      ['book_read_history'],
    );
    expect(
      presentation.builderForScope(LibraryEditScope.release).buildTabSectionIds(
        context: contextFor(LibraryEditScope.release),
        tabId: 'read_history',
      ),
      ['book_read_history'],
    );
  });
}
