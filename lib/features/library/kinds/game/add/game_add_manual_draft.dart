import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

/// Catalog state of a manually added Game: Main and Description values,
/// links and YouTube trailers.
final class GameAddManualDraft implements LibraryKindAddDraftWithResources {
  GameAddManualDraft({GameCatalogFormValues? values, this.catalogTitle = ''})
      : values = values ?? GameCatalogFormValues();

  final GameCatalogFormValues values;
  @override
  String catalogTitle;

  final List<LibraryExternalLinkDraftRow> externalLinks = [];
  final List<LibraryExternalLinkDraftRow> trailers = [];

  @override
  void dispose() {
    for (final link in [...externalLinks, ...trailers]) {
      link.dispose();
    }
  }
}
