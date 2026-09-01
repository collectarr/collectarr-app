class LibraryGroupModeCategory {
  const LibraryGroupModeCategory(this.label, this.modes);

  final String label;
  final List<dynamic> modes;
}

typedef LibraryGroupModeCategoryBuilder = List<LibraryGroupModeCategory>
    Function(
  List<String> modes,
);
