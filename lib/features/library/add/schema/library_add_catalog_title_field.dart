import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

/// Required catalog-title field contributed by a Manual Add kind form.
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
          validator: (draft) =>
              draft.catalogTitle.trim().isEmpty ? 'Enter a title' : null,
        );
