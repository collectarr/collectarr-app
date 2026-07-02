abstract class LibraryKindBrowserDelegate {
  String? get releaseFolderTitleItemId;

  set releaseFolderTitleItemId(String? value);
}

class LibraryNoopBrowserDelegate implements LibraryKindBrowserDelegate {
  LibraryNoopBrowserDelegate({String? initialReleaseFolderTitleItemId})
      : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }
}

class LibraryReleaseFolderBrowserDelegate
    implements LibraryKindBrowserDelegate {
  LibraryReleaseFolderBrowserDelegate({
    String? initialReleaseFolderTitleItemId,
  }) : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }
}

LibraryKindBrowserDelegate buildReleaseFolderBrowserDelegate() {
  return LibraryReleaseFolderBrowserDelegate();
}
