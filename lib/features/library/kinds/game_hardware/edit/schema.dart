import 'package:collectarr_app/features/library/edit/schema/schema.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import '../domain/game_hardware_metadata.dart';
import '../forms/main_form.dart';
import 'draft.dart';

String gameHardwareEditHeaderTitle(GameHardwareCatalogMetadata metadata) =>
    metadata.title;
final gameHardwareItemEditSchema = EditSchema<GameHardwareCatalogMetadata,
    GameHardwareItemEditDraft>(title: gameHardwareEditHeaderTitle, tabs: [
  EditTabSpec(id: 'main', label: 'Main', icon: AppIcons.gamepad, sections: [
    gameHardwareMainSection(
        fields: gameHardwareMainFields<GameHardwareItemEditDraft>(
            values: (draft) => draft.values,
            serialNumberBuilder: (context, draft) {
              final personal = LibraryEntryEditScope.maybeOf(context);
              return LibraryFormField(
                  label: 'Serial No.',
                  child: LibraryTextFormControl(
                      initialValue:
                          personal?.text('game_hardware_serial_number') ?? '',
                      onChanged: (value) => personal?.set(
                          'game_hardware_serial_number',
                          value.trim().isEmpty ? null : value.trim())));
            }))
  ])
]);
