import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mediaBuilder = BookLibraryMediaEditPresentationBuilder();
  const releaseBuilder = BookLibraryReleaseEditPresentationBuilder();
  const presentation = LibraryEditPresentation(
    builder: mediaBuilder,
    workBuilder: mediaBuilder,
    releaseBuilder: releaseBuilder,
  );

  LibraryEditPresentationContext contextFor(LibraryEntityScope scope) {
    return LibraryEditPresentationContext(
      isOwned: true,
      isTrackingOnly: false,
      hasTrackingContext: true,
      hasWishlistContext: false,
      isDigitalFormat: false,
      hasPhysicalFormats: false,
      hasOwnedTargetOptions: true,
      hasAdditionalTargetOptions: false,
      hasCustomFields: true,
      scope: scope,
    );
  }

  test('uses separate builders for media and release', () {
    final mediaTabs = mediaBuilder.buildTabs(
      context: contextFor(LibraryEntityScope.work),
    );
    final releaseTabs = releaseBuilder.buildTabs(
      context: contextFor(LibraryEntityScope.release),
    );

    expect(mediaTabs.map((tab) => tab.id).toList(), [
      'main',
      'credits',
      'custom',
      'read_history',
      'covers',
      'plot',
      'links',
      'owned',
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
      presentation.builderForScope(LibraryEntityScope.work).buildTabSectionIds(
            context: contextFor(LibraryEntityScope.work),
            tabId: 'read_history',
          ),
      ['book_read_history'],
    );
    expect(
      presentation
          .builderForScope(LibraryEntityScope.release)
          .buildTabSectionIds(
            context: contextFor(LibraryEntityScope.release),
            tabId: 'read_history',
          ),
      ['book_read_history'],
    );
  });
}
