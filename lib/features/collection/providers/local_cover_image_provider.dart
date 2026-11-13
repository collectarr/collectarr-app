import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalItemImageRequest = ({
  LibraryEntryRef libraryEntryRef,
  String imageType
});

final localItemImageProvider = StreamProvider.autoDispose
    .family<Uint8List?, LocalItemImageRequest>((ref, request) {
  requireKnownLibraryEntryRef(request.libraryEntryRef);
  // Most entries have no local image, so a cover scrolling into view asks the
  // database only when one is stored. Until the stored keys are in, ask.
  final stored =
      ref.watch(_storedItemImageKeysProvider.select((keys) => keys.hasValue
          ? keys.requireValue.contains(
              (request.libraryEntryRef.key, request.imageType),
            )
          : null));
  if (stored == false) return Stream.value(null);
  final db = ref.watch(localDatabaseProvider);
  return (db.select(db.itemImagesCache)
        ..where((row) =>
            row.libraryEntryRefKey.equals(request.libraryEntryRef.key) &
            row.imageType.equals(request.imageType))
        ..orderBy([
          (row) => OrderingTerm.asc(row.sortOrder),
          (row) => OrderingTerm.asc(row.createdAt)
        ])
        ..limit(1))
      .watchSingleOrNull()
      .map((image) => image?.imageData);
});

/// The entry and image type of every stored image, read without the image data.
final _storedItemImageKeysProvider =
    StreamProvider<Set<(String, String)>>((ref) {
  final db = ref.watch(localDatabaseProvider);
  final table = db.itemImagesCache;
  final query = db.selectOnly(table, distinct: true)
    ..addColumns([table.libraryEntryRefKey, table.imageType]);
  return query.watch().map((rows) => {
        for (final row in rows)
          (row.read(table.libraryEntryRefKey)!, row.read(table.imageType)!),
      });
});
