import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';

final class TvAddManualDraft implements LibraryKindAddDraft {
  TvAddManualDraft({TvCatalogItemFormValues? values})
      : values = values ?? TvCatalogItemFormValues();

  final TvCatalogItemFormValues values;

  @override
  void dispose() {}
}
