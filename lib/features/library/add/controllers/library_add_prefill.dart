import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';

LibraryAddLocalRerankHints buildLibraryAddLocalRerankHints({
  required String query,
  required String series,
  required String issueNumber,
  required String publisher,
  required String year,
}) {
  return LibraryAddLocalRerankHints(
    query: query.trim(),
    series: series.trim(),
    issueNumber: issueNumber.trim(),
    publisher: publisher.trim(),
    year: int.tryParse(year.trim()),
  );
}

String? matchLibraryAddSeriesId(
  List<SeriesRegistryEntry> entries,
  String? value,
) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  final match = entries.cast<SeriesRegistryEntry?>().firstWhere(
        (entry) =>
            entry != null && entry.title.trim().toLowerCase() == normalized,
        orElse: () => null,
      );
  return match?.coreSeriesId;
}

List<String> buildManualPhysicalFormatOptions({
  required List<PhysicalMediaFormat> builtInValues,
  required List<String> customValues,
  required String selectedValue,
}) {
  return mergePickListValues(
    builtInValues: [for (final format in builtInValues) format.label],
    customValues: customValues,
    selectedValues: [selectedValue],
  );
}

String? libraryAddDefaultLocationLabel(
  List<StorageLocation> availableLocations,
  String? defaultLocationId,
) {
  return locationPathForId(availableLocations, defaultLocationId);
}
