import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveGameHardwareEntryFormatHint(
        CatalogSearchCandidate item) =>
    (format: null, label: null);
bool? resolveGameHardwareEntryDigitalFlag(LibraryEntrySummary? entry,
        {String? fallbackFormat,
        String? fallbackLabel,
        required Iterable<PhysicalMediaFormat> formats}) =>
    false;
