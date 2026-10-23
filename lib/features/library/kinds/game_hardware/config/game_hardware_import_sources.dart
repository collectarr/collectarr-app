import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import '../integrations/import/clz_game_hardware_web_importer.dart';

final gameHardwareKindImport = LibraryKindImportCapability(sources: const [
  LibraryImportSourceDefinition(
      id: 'clz_game_hardware_web',
      title: 'CLZ Games Web (Hardware)',
      importer: ClzGameHardwareWebImporter(),
      fileExtensions: ['xml'],
      description: 'Import one Hardware collection from CLZ Games Web.',
      instructions: [
        'Open the Hardware collection in CLZ Games Web.',
        'Choose Import / Export > Export to XML.',
        'Generate and download the XML file, then upload it here.'
      ],
      filePrompt: 'Upload the CLZ Hardware XML export:'),
]);
