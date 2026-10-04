import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

/// Game Add state contains typed catalog values; the schema renderer owns inputs.
final class GameAddManualDraft implements GameCatalogFormDraft {
  GameAddManualDraft({
    GameCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? GameCatalogFormValues();

  @override
  final GameCatalogFormValues values;
  @override
  String catalogTitle;
}
