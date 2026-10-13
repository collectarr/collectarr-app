import 'package:collectarr_app/core/db/local_database.dart';

/// Kind-owned draft changes committed with the complete local entry.
abstract interface class LibraryLocalEditChange {
  Future<void> persist(LocalDatabase database);
}
