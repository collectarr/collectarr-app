import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_grouping_field.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

const musicCreditGroupingFields = <MusicGroupingField>{
  MusicGroupingField.creditContributor,
  MusicGroupingField.creditRole,
  MusicGroupingField.creditInstrument,
};

Object? musicCreditGroupValue(
  MusicGroupingField field,
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) =>
    switch (field) {
      MusicGroupingField.creditContributor =>
        MusicCatalogWorkspaceFields.creditContributor.getValue(context),
      MusicGroupingField.creditRole =>
        MusicCatalogWorkspaceFields.creditRole.getValue(context),
      MusicGroupingField.creditInstrument =>
        MusicCatalogWorkspaceFields.creditInstrument.getValue(context),
      _ => throw ArgumentError.value(field, 'field', 'Not a credit grouping.'),
    };
