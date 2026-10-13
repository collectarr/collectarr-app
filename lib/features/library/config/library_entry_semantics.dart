import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

/// Kind-entry resolver used by generic edit/detail hosts.
///
/// The host may provide catalog-derived formats, but the callback owns the
/// meaning of a digital copy for its kind.
typedef LibraryEntryDigitalFlagResolver = bool? Function(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  required Iterable<PhysicalMediaFormat> formats,
});
