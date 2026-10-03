import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';

/// Projects a complete local entry into its kind's typed form state.
/// There is one persisted record, not a catalog row plus physical-copy rows.
abstract class TypedLibraryEntryRepository<T>
    implements ReadRepository<LibraryEntryId, T> {
  const TypedLibraryEntryRepository(this.database);
  final LocalDatabase database;
  CatalogMediaKind get kind;
  T decode(Map<String, dynamic> json);
  Map<String, dynamic> encode(T item);
  T deleted(T item, DateTime at);

  @override
  Future<T?> findById(LibraryEntryId id) async {
    final record = await LibraryEntryStore(database).find(kind, id.value);
    return record == null ? null : decode(record.toKindJson());
  }

  Future<List<T>> listActive() async => [
        for (final record in await LibraryEntryStore(database).list(kind: kind))
          decode(record.toKindJson()),
      ];

  Future<void> upsert(T item) =>
      LibraryEntryStore(database).putKindJson(kind, encode(item));

  Future<void> upsertAll(Iterable<T> items) => database.transaction(() async {
        for (final item in items) {
          await upsert(item);
        }
      });

  Future<void> markDeleted(T item, DateTime at) => upsert(deleted(item, at));
}
