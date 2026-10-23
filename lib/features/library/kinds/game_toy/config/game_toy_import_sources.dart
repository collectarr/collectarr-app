import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import '../integrations/import/clz_game_toy_web_importer.dart';

final gameToyKindImport = LibraryKindImportCapability(sources: const [
  LibraryImportSourceDefinition(
      id: 'clz_game_toy_web',
      title: 'CLZ Games Web (Toys)',
      importer: ClzGameToyWebImporter(),
      fileExtensions: ['xml'],
      description: 'Import one Toys collection from CLZ Games Web.',
      instructions: [
        'Open the Toys collection in CLZ Games Web.',
        'Choose Import / Export > Export to XML.',
        'Generate and download the XML file, then upload it here.'
      ],
      filePrompt: 'Upload the CLZ Toys XML export:'),
]);
