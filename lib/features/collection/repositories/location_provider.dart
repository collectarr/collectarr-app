import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides all [StorageLocation] entries from the local cache, sorted by
/// [StorageLocation.sortOrder].
///
/// Invalidate this provider to force a reload after location mutations.
final allLocationsProvider = FutureProvider<List<StorageLocation>>((ref) {
  final db = ref.watch(localDatabaseProvider);
  return LocationRepository(db).getAll();
});
