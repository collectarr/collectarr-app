import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_item_edit_schema.dart';

/// Presentation marker for Game's dedicated editor.
///
/// Game never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class GameTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const GameTypedEditPresentationBuilder();

  @override
  String buildDialogTitle({required CatalogSearchCandidate kindItem}) =>
      gameEditHeaderTitle(kindItem.kindCapability
          .mapTransport(const GameCatalogTransportCodec().decode));

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

const gameTypedEditPresentation = LibraryEditPresentation(
  builder: GameTypedEditPresentationBuilder(),
);
