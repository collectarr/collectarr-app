import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/schema.dart';

/// Presentation marker for Book's dedicated editor.
///
/// Book never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class BookTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const BookTypedEditPresentationBuilder();

  @override
  String buildDialogTitle({required CatalogSearchCandidate kindItem}) =>
      bookEditHeaderTitle(kindItem.kindCapability
          .mapTransport(const BookCatalogTransportCodec().decode));

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) =>
      const <LibraryEditTabSpec>[];

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) =>
      const <String>[];

  @override
  LibraryEditPresentationState build({
    required LibraryEditPresentationContext context,
  }) =>
      const LibraryEditPresentationState(
        usesEntryMainArtworkLayout: false,
        usesDetailsTab: false,
        usesArtworkCoverTab: false,
        usesArtworkPhotosTab: false,
        trackingSectionTitle: 'Tracking',
      );
}

const bookTypedEditPresentation = LibraryEditPresentation(
  builder: BookTypedEditPresentationBuilder(),
);
