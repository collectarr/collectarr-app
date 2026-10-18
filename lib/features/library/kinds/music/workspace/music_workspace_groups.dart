import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_catalog_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_credit_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_disc_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_grouping_field.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_personal_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/sorts/music_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_grouping_field.dart'
    show MusicGroupingField, MusicGroupingFieldConfiguration;

List<LibraryGroupDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
    musicWorkspaceGroupDefinitions({required bool includePersonal}) => [
          for (final field in MusicGroupingField.values)
            if (includePersonal || !field.localOnly)
              if (field.fieldMetadata.groupable)
                LibraryGroupDefinition(
                  id: LibraryGroupId<MusicKind, Object?>(
                    field.id,
                    semantic: field == MusicGroupingField.location
                        ? LibraryGroupSemantic.location
                        : LibraryGroupSemantic.value,
                  ),
                  label: field.label,
                  bucketVocabulary: field.bucketVocabulary,
                  sidebarTitle: field.label,
                  category: field.category,
                  icon: switch (field.category) {
                    'Images' => Icons.image_outlined,
                    'Credits' => Icons.people_outline,
                    'Personal' => Icons.person_outline,
                    'Details' => Icons.info_outline,
                    _ => Icons.folder_outlined,
                  },
                  getValue: (context) => _groupValue(field, context),
                  bucketSortNames: switch (field) {
                    MusicGroupingField.artist => _artistSortNames,
                    MusicGroupingField.creditContributor =>
                      _contributorSortNames,
                    _ => null,
                  },
                ),
        ];

/// Artist folders are ordered by the artists' sort names, as albums are.
Map<String, String> _artistSortNames(
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) =>
    {
      for (final credit in context.dto.music.artistCredits)
        if (credit.creditedName.trim().isNotEmpty)
          credit.creditedName.trim():
              musicCreditSortName(credit.creditedName, credit.sortName),
    };

/// A name credited more than once keeps the sort name someone set over the
/// automatic one.
Map<String, String> _contributorSortNames(
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) {
  final album = context.dto.music;
  final sortNames = <String, String>{};
  void add(String name, String? sortName) {
    final key = name.trim();
    if (key.isEmpty) return;
    if (sortName?.trim().isNotEmpty == true) {
      sortNames[key] = sortName!.trim();
    } else {
      sortNames.putIfAbsent(key, () => musicCreditSortName(key, null));
    }
  }

  for (final credit in album.artistCredits) {
    add(credit.creditedName, credit.sortName);
  }
  for (final credit in [
    ...album.credits,
    for (final disc in album.discs) ...disc.credits,
  ]) {
    add(credit.name, credit.sortName);
  }
  return sortNames;
}

Object? _groupValue(
  MusicGroupingField field,
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) {
  if (musicCatalogGroupingFields.contains(field)) {
    return musicCatalogGroupValue(field, context);
  }
  if (musicDiscGroupingFields.contains(field)) {
    return musicDiscGroupValue(field, context);
  }
  if (musicCreditGroupingFields.contains(field)) {
    return musicCreditGroupValue(field, context);
  }
  if (musicPersonalGroupingFields.contains(field)) {
    return musicPersonalGroupValue(field, context);
  }
  throw StateError('Music grouping field $field has no scope module.');
}
