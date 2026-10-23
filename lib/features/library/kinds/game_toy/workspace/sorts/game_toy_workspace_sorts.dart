import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

List<LibrarySortDefinition<GameToyKind, GameToyWorkspaceDto>>
    gameToyWorkspaceSorts({required bool personal}) => [
          for (final field in gameToyTextFields(personal: personal))
            if (field == GameToyCatalogWorkspaceFields.title)
              LibrarySortDefinition<GameToyKind, GameToyWorkspaceDto>(
                  id: LibrarySortId(field.id.value),
                  label: field.label,
                  compare: (left, right) => compareNaturalText(
                      left.sorting.useSortTitles
                          ? left.dto.metadata.sortKey ?? left.dto.metadata.title
                          : left.dto.metadata.title,
                      right.sorting.useSortTitles
                          ? right.dto.metadata.sortKey ??
                              right.dto.metadata.title
                          : right.dto.metadata.title))
            else
              sortFromField(field,
                  group: gameToyFieldCategory(field),
                  customCompare: compareNaturalText),
          if (personal)
            for (final field in GameToyPersonalWorkspaceFields.money)
              sortFromField(field, group: 'Value'),
        ];
