import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';

/// An external export boundary. Parsing never reads or writes storage.
abstract interface class LibraryGuidedImporter {
  List<CollectionImportRow> parse(String source);
}

/// A kind owns the meaning of user-mapped columns as well as guided exports.
abstract interface class LibraryMappedCsvImporter {
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
  });
}

final class LibraryImportFormatException implements FormatException {
  const LibraryImportFormatException(this.message);

  @override
  final String message;
  @override
  int? get offset => null;
  @override
  String? get source => null;

  @override
  String toString() =>
      'Unsupported / invalid export. 0 records parsed. $message';
}
