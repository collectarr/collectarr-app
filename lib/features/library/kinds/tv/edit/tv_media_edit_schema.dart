import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';

final EditSchema<TvSeries, TvSeriesFormValues> tvMediaEditSchema = EditSchema(
  title: (series) => 'Edit ${series.title}',
  validate: (_, values) {
    if (values.title.trim().isEmpty) return 'Series title is required';
    if (values.originalAirDate != null &&
        values.endDate != null &&
        values.endDate!.isBefore(values.originalAirDate!)) {
      return 'End date cannot be before first air date';
    }
    return null;
  },
  tabs: [
    EditTabSpec<TvSeriesFormValues>(
      id: 'series',
      label: 'Series',
      sections: [
        EditSectionSpec<TvSeriesFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: tvSeriesIdentityFields<TvSeriesFormValues>(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<TvSeriesFormValues>(
          id: 'broadcast',
          label: 'Broadcast',
          fields: tvSeriesBroadcastFields<TvSeriesFormValues>(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<TvSeriesFormValues>(
          id: 'classification',
          label: 'Classification',
          fields: tvSeriesClassificationFields<TvSeriesFormValues>(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
