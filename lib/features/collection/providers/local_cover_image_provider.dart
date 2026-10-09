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
