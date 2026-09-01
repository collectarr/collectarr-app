import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';

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
