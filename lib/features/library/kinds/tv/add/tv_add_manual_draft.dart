import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';

final class TvAddManualDraft implements LibraryKindAddDraft {
  TvAddManualDraft({
    TvSeriesFormValues? series,
    TvReleaseFormValues? release,
    this.seasonNumber,
    this.firstAirYear,
  })  : series = series ?? TvSeriesFormValues(),
        release = release ?? TvReleaseFormValues();

  final TvSeriesFormValues series;
  final TvReleaseFormValues release;
  int? seasonNumber;
  int? firstAirYear;

  @override
  void dispose() {}
}
