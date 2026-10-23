import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

List<LibrarySortDefinition<GameHardwareKind, GameHardwareWorkspaceDto>>
    gameHardwareWorkspaceSorts({required bool personal}) => [
          for (final field in gameHardwareTextFields(personal: personal))
            if (field == GameHardwareCatalogWorkspaceFields.title)
              LibrarySortDefinition<GameHardwareKind, GameHardwareWorkspaceDto>(
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
                  group: gameHardwareFieldCategory(field),
                  customCompare: compareNaturalText),
          if (personal)
            for (final field in GameHardwarePersonalWorkspaceFields.money)
              sortFromField(field, group: 'Value'),
        ];
