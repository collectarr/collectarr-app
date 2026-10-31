import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';

/// The entry whose custom fields or images the inspector loads.
typedef InspectorEntryDataRequest = ({
  LocalDatabase db,
  LibraryEntryRef libraryEntryRef,
});
