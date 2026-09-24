import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

final AddSchema<ComicAddManualDraft> comicAddSchema = comicAddSchemaFor();

AddSchema<ComicAddManualDraft> comicAddSchemaFor({
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? seriesGroupOptions,
  Iterable<String>? physicalFormatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageSeriesGroup,
  FutureOr<void> Function()? onManagePhysicalFormat,
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
      sections: [
        AddSectionSpec<ComicAddManualDraft>(
          id: 'issue',
          label: 'Issue',
          fields: comicMediaIdentityFields(
            values: (draft) => draft.values,
            physicalFormatOptions: physicalFormatOptions ??
                ComicVocabularies.physicalFormat.builtIns,
            onManagePhysicalFormat: onManagePhysicalFormat,
            includeSeries: false,
          ),
        ),
        AddSectionSpec<ComicAddManualDraft>(
          id: 'publication',
          label: 'Publication',
          fields: comicMediaPublicationFields(
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
    );
