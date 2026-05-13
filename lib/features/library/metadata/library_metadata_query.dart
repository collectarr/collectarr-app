import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  LibraryTypeConfig type, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
}) {
  return MetadataSearchQuery(
    query: query,
    kind: type.workspace.kind,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
  );
}
