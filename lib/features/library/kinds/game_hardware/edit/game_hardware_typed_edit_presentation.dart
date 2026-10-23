import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/data/game_hardware_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_item_edit_schema.dart';

/// Presentation marker for GameHardware's dedicated editor.
///
/// GameHardware never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class GameHardwareTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const GameHardwareTypedEditPresentationBuilder();

  @override
  String buildDialogTitle({required CatalogSearchCandidate kindItem}) =>
      gameHardwareEditHeaderTitle(kindItem.kindCapability
          .mapTransport(const GameHardwareCatalogTransportCodec().decode));

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

const gameHardwareTypedEditPresentation = LibraryEditPresentation(
  builder: GameHardwareTypedEditPresentationBuilder(),
);
