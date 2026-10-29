import 'dart:async';

import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

final LibraryFormSchema<ComicAddManualDraft> comicAddSchema =
    comicAddSchemaFor();

LibraryFormSchema<ComicAddManualDraft> comicAddSchemaFor({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? seriesGroupOptions,
  Iterable<String>? physicalFormatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageSeriesGroup,
  FutureOr<void> Function()? onManagePhysicalFormat,
  bool includeTitle = false,
}) =>
    LibraryFormSchema<ComicAddManualDraft>(
      title: (_) => 'Manual comic issue',
      validate: (draft) => validateComicCatalogItem(draft.values),
      sections: filterLibraryFormSections(
        fieldIds: fieldIds,
        sectionLabels: sectionLabels,
        sections: [
          LibraryFormSectionSpec<ComicAddManualDraft>(
            id: 'issue',
            label: 'Issue',
            fields: [
              LibraryTextFieldSpec<ComicAddManualDraft>(
                id: 'catalog_title',
                label: 'Title',
                value: (draft) => draft.catalogTitle,
                setValue: (draft, value) => draft.catalogTitle = value,
              ),
              ...comicCatalogItemIdentityFields(
                values: (draft) => draft.values,
                includeTitle: includeTitle,
                physicalFormatOptions: physicalFormatOptions ??
                    ComicVocabularies.physicalFormat.builtIns,
                onManagePhysicalFormat: onManagePhysicalFormat,
                includeSeries: true,
              ),
            ],
            fullWidthFieldIds: const {'catalog_title'},
          ),
          LibraryFormSectionSpec<ComicAddManualDraft>(
            id: 'publication',
            label: 'Publication',
            fields: comicCatalogItemPublicationFields(
              values: (draft) => draft.values,
              publisherOptions: publisherOptions,
              imprintOptions: imprintOptions,
              seriesGroupOptions: seriesGroupOptions,
              onManagePublisher: onManagePublisher,
              onManageImprint: onManageImprint,
              onManageSeriesGroup: onManageSeriesGroup,
            ),
          ),
        ],
      ),
    );
