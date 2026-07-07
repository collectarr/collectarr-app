import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_layout_snapshot.dart';

final libraryLayoutSnapshotProvider =
    NotifierProvider<LibraryLayoutSnapshotController, LibraryLayoutSnapshot?>(
  LibraryLayoutSnapshotController.new,
);

class LibraryLayoutSnapshotController extends Notifier<LibraryLayoutSnapshot?> {
  @override
  LibraryLayoutSnapshot? build() => null;

  void update(LibraryLayoutSnapshot? snapshot) {
    if (state == snapshot) {
      return;
    }
    state = snapshot;
  }
}
