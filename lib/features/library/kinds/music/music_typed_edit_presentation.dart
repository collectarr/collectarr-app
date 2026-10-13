import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';

/// Presentation marker for Music's Catalog Item and Collection Item editors.
///
/// Music never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class MusicTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const MusicTypedEditPresentationBuilder();

  @override
  String buildDialogTitle({required CatalogSearchCandidate kindItem}) {
    final album = MusicCatalogMapper.mapMetadataItemToMusic(
      kindItem.kindCapability.mapTransport((item) => item),
    );
    return musicEditHeaderTitle(title: album.title, artist: album.artist);
  }

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

const musicTypedEditPresentation = LibraryEditPresentation(
  builder: MusicTypedEditPresentationBuilder(),
);
