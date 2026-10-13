import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

/// Kind-owned catalog draft shared by Board Game Add and Edit.
abstract interface class BoardGameCatalogFormDraft
    implements LibraryKindAddDraft {
  BoardGameCatalogFormValues get values;
}
