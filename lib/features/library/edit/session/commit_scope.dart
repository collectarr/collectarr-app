import 'package:flutter/widgets.dart';

/// Lets an open edit dialog save its item and stay open, as the reference's
/// Next and Previous do before they show the neighbouring item.
final class LibraryEditCommitHandle {
  LibraryEditCommitHandle({required this.itemLabel, this.onKeptOpen});

  /// The kind's item in lower case, as in "Saving comic".
  final String itemLabel;

  /// Called after a save that kept the dialog open, so cached drafts of the
  /// saved item are reloaded when it is shown again.
  final VoidCallback? onKeptOpen;

  bool _keepOpen = false;
  bool _committed = false;

  /// The swap to the next item started by a navigation, if any.
  Future<void>? pendingSwitch;

  /// Runs [save] so a commit inside it keeps the dialog open; returns whether
  /// it committed, which is false when validation stopped it.
  Future<bool> saveKeepingOpen(Future<void> Function() save) async {
    _keepOpen = true;
    _committed = false;
    try {
      await save();
      return _committed;
    } finally {
      _keepOpen = false;
    }
  }

  /// Records a commit; true when the dialog stays open after it.
  bool takeCommit() {
    if (!_keepOpen) return false;
    _committed = true;
    onKeptOpen?.call();
    return true;
  }
}

class LibraryEditCommitScope extends InheritedWidget {
  const LibraryEditCommitScope({
    super.key,
    required this.handle,
    required super.child,
  });

  final LibraryEditCommitHandle handle;

  static LibraryEditCommitHandle? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LibraryEditCommitScope>()?.handle;

  @override
  bool updateShouldNotify(LibraryEditCommitScope oldWidget) =>
      handle != oldWidget.handle;
}
