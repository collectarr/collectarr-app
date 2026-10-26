import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import '../domain/game_toy_metadata.dart';
import '../forms/main_form.dart';
import 'draft.dart';

String gameToyEditHeaderTitle(GameToyCatalogMetadata metadata) =>
    metadata.title;
final gameToyItemEditSchema =
    EditSchema<GameToyCatalogMetadata, GameToyItemEditDraft>(
        title: gameToyEditHeaderTitle,
        tabs: [
      EditTabSpec(id: 'main', label: 'Main', icon: AppIcons.gamepad, sections: [
        gameToyMainSection(
            fields: gameToyMainFields<GameToyItemEditDraft>(
                values: (draft) => draft.values))
      ])
    ]);
