import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_local_edit_change.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

final class LibraryVocabularyEditChange implements LibraryLocalEditChange {
  LibraryVocabularyEditChange(Iterable<({String listName, String value, String? mediaKind})> values)
      : values = List.unmodifiable(values);
  final List<({String listName, String value, String? mediaKind})> values;

  @override
  Future<void> persist(LocalDatabase database) async {
    final repository = PickListRepository(database);
    for (final value in values) {
      await repository.addValue(value.listName, value.value, mediaKind: value.mediaKind);
    }
  }
}
