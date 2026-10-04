import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

final AddSchema<ComicAddManualDraft> comicAddSchema = comicAddSchemaFor();

AddSchema<ComicAddManualDraft> comicAddSchemaFor({
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
    AddSchema<ComicAddManualDraft>(
      title: (_) => 'Manual comic issue',
      validate: (draft) {
        final pageCount = draft.values.pageCount;
        if (pageCount != null && pageCount < 0) {
          return 'Page count cannot be negative';
        }
        return null;
      },
      sections: filterAddSchemaSections(
        fieldIds: fieldIds,
        sectionLabels: sectionLabels,
        sections: [
          AddSectionSpec<ComicAddManualDraft>(
            id: 'issue',
            label: 'Issue',
            fields: [
              libraryAddCatalogTitleField<ComicAddManualDraft>(),
              ...comicCatalogItemIdentityFields(
                values: (draft) => draft.values,
                includeTitle: includeTitle,
                physicalFormatOptions: physicalFormatOptions ??
                    ComicVocabularies.physicalFormat.builtIns,
                onManagePhysicalFormat: onManagePhysicalFormat,
                includeSeries: false,
              ),
            ],
            fullWidthFieldIds: const {'catalog_title'},
          ),
          AddSectionSpec<ComicAddManualDraft>(
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
