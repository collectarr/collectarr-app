import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import '../integrations/import/clz_game_web_importer.dart';

final gameKindImport = LibraryKindImportCapability(sources: const [
  LibraryImportSourceDefinition(
      id: 'clz_game_web',
      title: 'CLZ Games Web (Games)',
      importer: ClzGameWebImporter(),
      fileExtensions: ['xml'],
      description: 'Import one Games collection from CLZ Games Web.',
      instructions: [
        'Open the Games collection in CLZ Games Web.',
        'Choose Import / Export > Export to XML.',
        'Generate and download the XML file, then upload it here.'
      ],
      filePrompt: 'Upload the CLZ Games XML export:'),
]);
