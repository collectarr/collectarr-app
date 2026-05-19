import 'package:collectarr_app/core/models/media_catalog.dart';

class NavTypeSplit {
  const NavTypeSplit({
    required this.visible,
    required this.overflow,
  });

  final List<CatalogMediaType> visible;
  final List<CatalogMediaType> overflow;
}

NavTypeSplit splitLibraryNavTypes(
  List<CatalogMediaType> types,
  String selectedKind,
  int maxVisible,
) {
  if (types.length <= maxVisible) {
    return NavTypeSplit(visible: types, overflow: const []);
  }
  final visible = types.take(maxVisible).toList();
  final selected =
      _firstWhereOrNull(types, (type) => type.kind == selectedKind);
  if (selected != null && !visible.any((type) => type.kind == selectedKind)) {
    visible[visible.length - 1] = selected;
  }
  final visibleKinds = {for (final type in visible) type.kind};
  return NavTypeSplit(
    visible: visible,
    overflow: [
      for (final type in types)
        if (!visibleKinds.contains(type.kind)) type,
    ],
  );
}

String libraryNavLabel(CatalogMediaType type) {
  return switch (type.kind) {
    'boardgame' => 'Board Games',
    'music' => 'Music',
    'tv' => 'TV Shows',
    _ => type.pluralLabel,
  };
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}
