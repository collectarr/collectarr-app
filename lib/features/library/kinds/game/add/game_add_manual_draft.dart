import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

/// Game Add state contains typed catalog values; the schema renderer owns inputs.
final class GameAddManualDraft
    implements GameCatalogFormDraft, LibraryKindAddDraftWithResources {
  GameAddManualDraft({
    GameCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? GameCatalogFormValues();

  @override
  final GameCatalogFormValues values;
  @override
  String catalogTitle;

  final List<LibraryExternalLinkDraftRow> externalLinks = [];

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
