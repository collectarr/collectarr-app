export 'collection_csv_models.dart';

import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_exporter.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_importer.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';

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
    List<LibraryWorkspaceContext> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
  }) {
    return _exporter.exportShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
      entryRecordsByRef: entryRecordsByRef,
    );
  }

  String exportClzFriendlyShelf(
    List<LibraryWorkspaceContext> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
  }) {
    return _exporter.exportClzFriendlyShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
      entryRecordsByRef: entryRecordsByRef,
    );
  }

  List<CollectionImportRow> parse(String csv) => _importer.parse(csv);
}
