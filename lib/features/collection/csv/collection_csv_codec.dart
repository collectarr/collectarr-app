export 'collection_csv_models.dart';

import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_exporter.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_importer.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Stable schema-v1 facade for collection CSV callers.
///
/// The implementation is split into transport models, import mechanics,
/// and export mechanics so Collection does not own semantic media models.
final class CollectionCsvCodec {
  CollectionCsvCodec({required Iterable<CollectionCsvKindProfile> profiles})
      : _exporter = CollectionCsvExporter(profiles: profiles),
        _importer = CollectionCsvImporter(profiles: profiles);

  final CollectionCsvExporter _exporter;
  final CollectionCsvImporter _importer;

  String exportShelf(
    List<LibraryWorkspaceSource> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    return _exporter.exportShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
    );
  }

  String exportClzFriendlyShelf(
    List<LibraryWorkspaceSource> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    return _exporter.exportClzFriendlyShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
    );
  }

  List<CollectionImportRow> parse(String csv) => _importer.parse(csv);
}
