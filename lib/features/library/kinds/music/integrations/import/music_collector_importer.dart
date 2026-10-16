import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'collectorz_music_xml.dart';

final class MusicCollectorImporter implements LibraryGuidedImporter {
  const MusicCollectorImporter();
  @override
  List<CollectionImportRow> parse(String source) =>
      parseCollectorzMusicXml(source, web: false);
}
