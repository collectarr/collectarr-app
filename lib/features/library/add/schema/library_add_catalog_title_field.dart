import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';

/// Catalog-title field contributed by a Manual Add kind form; required unless
/// the kind allows untitled entries.
LibraryTextFieldSpec<TDraft>
    libraryAddCatalogTitleField<TDraft extends LibraryKindAddDraft>({
  List<LibraryTextFieldAction> actions = const [],
  bool required = true,
}) =>
        LibraryTextFieldSpec<TDraft>(
          id: 'catalog_title',
          label: 'Title',
          value: (draft) => draft.catalogTitle,
          setValue: (draft, value) => draft.catalogTitle = value,
          actions: actions,
          validator: (draft) => required && draft.catalogTitle.trim().isEmpty
              ? 'Enter a title'
              : null,
        );
