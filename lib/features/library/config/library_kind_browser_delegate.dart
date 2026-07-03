abstract class LibraryKindBrowserDelegate {
  String? get releaseFolderTitleItemId;

  set releaseFolderTitleItemId(String? value);

  String? get videoShelfDrilldownTitleItemId;

  set videoShelfDrilldownTitleItemId(String? value);

  String? get videoShelfDrilldownReleaseId;

  set videoShelfDrilldownReleaseId(String? value);
}

class LibraryNoopBrowserDelegate implements LibraryKindBrowserDelegate {
  LibraryNoopBrowserDelegate({String? initialReleaseFolderTitleItemId})
      : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  String? _videoShelfDrilldownTitleItemId;
  String? _videoShelfDrilldownReleaseId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownTitleItemId => _videoShelfDrilldownTitleItemId;

  @override
  set videoShelfDrilldownTitleItemId(String? value) {
    _videoShelfDrilldownTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownReleaseId => _videoShelfDrilldownReleaseId;

  @override
  set videoShelfDrilldownReleaseId(String? value) {
    _videoShelfDrilldownReleaseId = value;
  }
}

class LibraryReleaseFolderBrowserDelegate
    implements LibraryKindBrowserDelegate {
  LibraryReleaseFolderBrowserDelegate({
    String? initialReleaseFolderTitleItemId,
  }) : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  String? _videoShelfDrilldownTitleItemId;
  String? _videoShelfDrilldownReleaseId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownTitleItemId => _videoShelfDrilldownTitleItemId;

  @override
  set videoShelfDrilldownTitleItemId(String? value) {
    _videoShelfDrilldownTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownReleaseId => _videoShelfDrilldownReleaseId;

  @override
  set videoShelfDrilldownReleaseId(String? value) {
    _videoShelfDrilldownReleaseId = value;
  }
}

LibraryKindBrowserDelegate buildReleaseFolderBrowserDelegate() {
  return LibraryReleaseFolderBrowserDelegate();
}
