import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

/// Game Add state contains typed catalog values; the schema renderer owns inputs.
final class GameAddManualDraft implements LibraryKindAddDraft {
  GameAddManualDraft({
    GameCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? GameCatalogFormValues();

  final GameCatalogFormValues values;
  @override
  String catalogTitle;
}
