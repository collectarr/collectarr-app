import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

/// Kind-owned catalog draft shared by Game Add and Edit.
abstract interface class GameCatalogFormDraft implements LibraryKindAddDraft {
  GameCatalogFormValues get values;
}
