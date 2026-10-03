import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';

import 'package:drift/drift.dart';

final class ComicLocalMapper {
  const ComicLocalMapper._();

  static ComicReadingRowsCompanion toReadingRow(ComicLibraryEntry item) {
    return ComicReadingRowsCompanion.insert(
      libraryEntryRefKey: LibraryEntryRef(
        kind: CatalogMediaKind.comic,
        id: LibraryEntryId(item.id.value),
      ).key,
      rating: Value(item.personal.reading.rating),
      status: Value(item.personal.reading.status),
      startedAt: Value(item.personal.reading.startedAt),
      finishedAt: Value(item.personal.reading.finishedAt),
    );
  }

  static ComicReadingState fromReadingRow(ComicReadingRow row) {
    return ComicReadingState(
      rating: row.rating,
      status: row.status,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
    );
  }
}
