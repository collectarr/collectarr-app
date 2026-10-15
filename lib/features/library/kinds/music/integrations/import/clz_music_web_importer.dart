import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'collectorz_music_xml.dart';

final class ClzMusicWebImporter implements LibraryGuidedImporter {
  const ClzMusicWebImporter();
  @override
  List<CollectionImportRow> parse(String source) =>
      parseCollectorzMusicXml(source, web: true);
}
