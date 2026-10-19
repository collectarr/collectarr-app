import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_item_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_main_form_section.dart';
import 'package:collectarr_app/ui/app_icons.dart';

/// Header title as in the reference: "Title (Platform)".
String gameEditHeaderTitle(GameCatalogMetadata metadata) {
  final platform = metadata.platforms.firstOrNull?.trim() ?? '';
  return platform.isEmpty ? metadata.title : '${metadata.title} ($platform)';
}

final EditSchema<GameCatalogMetadata, GameItemEditDraft> gameItemEditSchema =
    EditSchema(
  title: gameEditHeaderTitle,
  tabs: [
    EditTabSpec<GameItemEditDraft>(
      id: 'main',
      label: 'Main',
      icon: AppIcons.gamepad,
      sections: [
        gameMainFormSection<GameItemEditDraft>(
          fields: gameMainFields<GameItemEditDraft>(
              values: (draft) => draft.values),
        ),
      ],
    ),
  ],
);
