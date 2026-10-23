import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/data/game_toy_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/edit/game_toy_item_edit_schema.dart';

/// Presentation marker for GameToy's dedicated editor.
///
/// GameToy never enters the generic draft renderer. The registry still carries
/// the shared presentation slot because other library kinds use it.
final class GameToyTypedEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const GameToyTypedEditPresentationBuilder();

  @override
  String buildDialogTitle({required CatalogSearchCandidate kindItem}) =>
      gameToyEditHeaderTitle(kindItem.kindCapability
          .mapTransport(const GameToyCatalogTransportCodec().decode));

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

const gameToyTypedEditPresentation = LibraryEditPresentation(
  builder: GameToyTypedEditPresentationBuilder(),
);
