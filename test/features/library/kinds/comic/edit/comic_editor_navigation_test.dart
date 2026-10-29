import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/catalog_item/catalog_item_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/contribution.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/presentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const context = LibraryEditPresentationContext(
    isEntry: true,
    isTrackingOnly: false,
    hasTrackingContext: true,
    hasWishlistContext: false,
    isDigitalFormat: false,
    hasPhysicalFormats: true,
    hasCustomFields: false,
  );

  test('collection editor follows the eleven observed CLZ tabs', () {
    final tabs = comicsLibraryEditPresentation.buildTabs(
      context: context,
      isEntry: true,
    );
    expect(tabs.map((tab) => tab.label), [
      'Main',
      'Details',
      'Value',
      'Personal',
      'Custom Fields',
      'Covers',
      'My Images',
      'Creators',
      'Characters',
      'Plot',
      'Links',
    ]);
    expect(tabs.any((tab) => tab.id == 'entry'), isFalse);
  });

  test('catalog and collection targets use their respective editors', () {
    final registry =
        comicKindEditCapabilities.presentationCapability.editRegistry;
    expect(registry.catalogItem, buildComicCatalogItemLibraryEditDialog);
    expect(registry.libraryEntry, buildComicLibraryEditDialog);
  });
}
