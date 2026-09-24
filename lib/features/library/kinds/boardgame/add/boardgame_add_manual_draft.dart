import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

/// Board Game Add state contains typed catalog values; schema renderers own inputs.
final class BoardgameAddManualDraft implements LibraryKindAddDraft {
  BoardgameAddManualDraft({BoardGameCatalogFormValues? values})
      : values = values ?? BoardGameCatalogFormValues();

  final BoardGameCatalogFormValues values;

  @override
  void dispose() {}
}
