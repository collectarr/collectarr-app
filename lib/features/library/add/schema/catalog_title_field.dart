import 'package:collectarr_app/features/library/add/models/kind_add_draft.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';

/// Catalog-title field contributed by a Manual Add kind form. As in the
/// reference, an entry may have no title; only proposing it to Core needs one.
LibraryTextFieldSpec<TDraft>
    libraryAddCatalogTitleField<TDraft extends LibraryKindAddDraft>({
  List<LibraryTextFieldAction> actions = const [],
}) =>
        LibraryTextFieldSpec<TDraft>(
          id: 'catalog_title',
          label: 'Title',
          value: (draft) => draft.catalogTitle,
          setValue: (draft, value) => draft.catalogTitle = value,
          actions: actions,
        );
