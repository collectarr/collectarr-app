import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/grouping_field.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/group_helpers.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/field_labels.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

const musicDiscGroupingFields = <MusicGroupingField>{
  MusicGroupingField.discFormat,
  MusicGroupingField.discFormatFamily,
  MusicGroupingField.recordingDate,
  MusicGroupingField.recordingMonth,
  MusicGroupingField.recordingYear,
  MusicGroupingField.isLive,
  MusicGroupingField.rpm,
  MusicGroupingField.spars,
  MusicGroupingField.sound,
  MusicGroupingField.recordingLocation,
  MusicGroupingField.vinylColor,
  MusicGroupingField.trackComposition,
};

Object? musicDiscGroupValue(
  MusicGroupingField field,
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) {
  final facts = context.dto.facts;
  return switch (field) {
    MusicGroupingField.discFormat =>
      MusicCatalogWorkspaceFields.discFormat.getValue(context),
    MusicGroupingField.discFormatFamily =>
      MusicCatalogWorkspaceFields.discFormatFamily.getValue(context),
    MusicGroupingField.recordingDate =>
      MusicCatalogWorkspaceFields.recordingDate.getValue(context),
    MusicGroupingField.recordingMonth => facts.discRecordingMonths
        .map((month) => musicGroupMonthLabel(PartialDate(month: month)))
        .whereType<String>(),
    MusicGroupingField.recordingYear =>
      MusicCatalogWorkspaceFields.recordingYear.getValue(context),
    MusicGroupingField.isLive => musicLiveStudioLabels(
        MusicCatalogWorkspaceFields.liveStudio.getValue(context),
      ),
    MusicGroupingField.rpm =>
      MusicCatalogWorkspaceFields.discRpm.getValue(context),
    MusicGroupingField.spars =>
      MusicCatalogWorkspaceFields.discSpars.getValue(context),
    MusicGroupingField.sound =>
      MusicCatalogWorkspaceFields.discSound.getValue(context),
    MusicGroupingField.recordingLocation =>
      MusicCatalogWorkspaceFields.recordingLocation.getValue(context),
    MusicGroupingField.vinylColor =>
      MusicCatalogWorkspaceFields.discColor.getValue(context),
    MusicGroupingField.trackComposition =>
      MusicCatalogWorkspaceFields.trackComposition.getValue(context),
    _ => throw ArgumentError.value(field, 'field', 'Not a disc grouping.'),
  };
}
