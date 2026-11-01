import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The key a Custom Label's image is stored under: its trimmed, lower-case
/// name, or null for an empty label.
String? comicCustomLabelKey(String? label) => switch (label?.trim()) {
      null || '' => null,
      final name => name.toLowerCase(),
    };

/// The images users load for their Custom Labels from their own files.
class ComicCustomLabelImages {
  const ComicCustomLabelImages(this._db);

  final LocalDatabase _db;

  Stream<Uint8List?> watch(String label) {
    final key = comicCustomLabelKey(label);
    if (key == null) return Stream.value(null);
    final rows = _db.comicCustomLabelImageRows;
    return (_db.select(rows)..where((row) => row.labelKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.labelImage);
  }

  /// The names of the labels that have an image, by name.
  Stream<List<String>> watchLabels() {
    final rows = _db.comicCustomLabelImageRows;
    return (_db.selectOnly(rows)
          ..addColumns([rows.label])
          ..orderBy([OrderingTerm.asc(rows.labelKey)]))
        .map((row) => row.read(rows.label)!)
        .watch();
  }

  Future<void> save(String label, Uint8List image) async {
    final key = comicCustomLabelKey(label);
    if (key == null) return;
    await _db.into(_db.comicCustomLabelImageRows).insertOnConflictUpdate(
          ComicCustomLabelImageRowsCompanion.insert(
            labelKey: key,
            label: label.trim(),
            labelImage: image,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> remove(String label) async {
    final key = comicCustomLabelKey(label);
    if (key == null) return;
    final rows = _db.comicCustomLabelImageRows;
    await (_db.delete(rows)..where((row) => row.labelKey.equals(key))).go();
  }
}

final comicCustomLabelImagesProvider = Provider<ComicCustomLabelImages>(
    (ref) => ComicCustomLabelImages(ref.watch(localDatabaseProvider)));

/// The image loaded for a Custom Label, by the label's name.
final comicCustomLabelImageProvider = StreamProvider.autoDispose
    .family<Uint8List?, String>(
        (ref, label) => ref.watch(comicCustomLabelImagesProvider).watch(label));

/// The names of the Custom Labels that have an image.
final comicCustomLabelNamesProvider = StreamProvider.autoDispose<List<String>>(
    (ref) => ref.watch(comicCustomLabelImagesProvider).watchLabels());
