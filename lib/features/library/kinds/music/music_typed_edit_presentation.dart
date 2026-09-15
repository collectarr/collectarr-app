import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';

/// Marker presentation for Music's dedicated Group/Release/Copy editors.
///
/// Music never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class MusicTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const MusicTypedEditPresentationBuilder();

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
        showsOwnershipReferenceSection: false,
        usesOwnedMainArtworkLayout: false,
        usesDetailsTab: false,
        usesArtworkCoverTab: false,
        usesArtworkPhotosTab: false,
        trackingSectionTitle: 'Tracking',
        ownershipReferenceTitle: 'Ownership reference',
        ownedBundleLabel: 'Owned copy',
      );
}

const musicTypedEditPresentation = LibraryEditPresentation(
  builder: MusicTypedEditPresentationBuilder(),
);
