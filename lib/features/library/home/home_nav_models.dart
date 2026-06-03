import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';

class LibraryNavGroup {
  const LibraryNavGroup({
    required this.id,
    required this.label,
    required this.types,
  });

  final String id;
  final String label;
  final List<CatalogMediaType> types;

  CatalogMediaType get primaryType => types.first;

  bool get hasChildren => types.length > 1;

  bool containsKind(String kind) {
    for (final type in types) {
      if (type.kind == kind) {
        return true;
      }
    }
    return false;
  }

  String? activeChildLabel(String selectedKind) {
    if (!hasChildren) {
      return null;
    }
    final selected =
        _firstWhereOrNull(types, (type) => type.kind == selectedKind);
    if (selected == null) {
      return null;
    }
    final childLabel = libraryNavLabel(selected);
    return childLabel == label ? null : childLabel;
  }
}

class _LibraryNavGroupSpec {
  const _LibraryNavGroupSpec({
    required this.id,
    required this.label,
    required this.memberKinds,
  });

  final String id;
  final String label;
  final List<String> memberKinds;
}

const _libraryNavGroupSpecs = [
  _LibraryNavGroupSpec(
    id: 'comic',
    label: 'Comics',
    memberKinds: ['comic'],
  ),
  _LibraryNavGroupSpec(
    id: 'manga',
    label: 'Manga',
    memberKinds: ['manga'],
  ),
  _LibraryNavGroupSpec(
    id: 'movie',
    label: 'Movies',
    memberKinds: ['movie'],
  ),
  _LibraryNavGroupSpec(
    id: 'tv',
    label: 'TV',
    memberKinds: ['tv'],
  ),
  _LibraryNavGroupSpec(
    id: 'anime',
    label: 'Anime',
    memberKinds: ['anime'],
  ),
];

String? canonicalLibraryNavKind(String? kind) {
  final normalized = kind?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

class NavTypeSplit {
  const NavTypeSplit({
    required this.visible,
    required this.overflow,
  });

  final List<CatalogMediaType> visible;
  final List<CatalogMediaType> overflow;
}

List<LibraryNavGroup> buildLibraryNavGroups(List<CatalogMediaType> types) {
  final byKind = {
    for (final type in types) type.kind: type,
  };
  final handledKinds = <String>{};
  final groups = <LibraryNavGroup>[];
  for (final type in types) {
    if (handledKinds.contains(type.kind)) {
      continue;
    }
    final spec = _libraryNavGroupSpecForKind(type.kind);
    if (spec == null) {
      groups.add(
        LibraryNavGroup(
          id: type.kind,
          label: libraryNavLabel(type),
          types: [type],
        ),
      );
      handledKinds.add(type.kind);
      continue;
    }
    final members = <CatalogMediaType>[];
    for (final kind in spec.memberKinds) {
      final member = byKind[kind];
      if (member != null) {
        members.add(member);
        handledKinds.add(kind);
      }
    }
    if (members.isEmpty) {
      continue;
    }
    groups.add(
      LibraryNavGroup(
        id: spec.id,
        label: spec.label,
        types: members,
      ),
    );
  }
  return groups;
}

LibraryNavGroup selectedLibraryNavGroup(
  List<LibraryNavGroup> groups,
  String selectedKind,
) {
  final canonicalSelectedKind =
      canonicalLibraryNavKind(selectedKind) ?? selectedKind;
  for (final group in groups) {
    if (group.containsKind(canonicalSelectedKind)) {
      return group;
    }
  }
  return groups.first;
}

NavTypeSplit splitLibraryNavTypes(
  List<CatalogMediaType> types,
  String selectedKind,
  int maxVisible,
) {
  if (types.length <= maxVisible) {
    return NavTypeSplit(visible: types, overflow: const []);
  }
  final canonicalSelectedKind =
      canonicalLibraryNavKind(selectedKind) ?? selectedKind;
  final visible = types.take(maxVisible).toList();
  final selected =
      _firstWhereOrNull(types, (type) => type.kind == canonicalSelectedKind);
  if (selected != null &&
      !visible.any((type) => type.kind == canonicalSelectedKind)) {
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
  return catalogDisplayPluralLabel(type);
}

_LibraryNavGroupSpec? _libraryNavGroupSpecForKind(String kind) {
  for (final spec in _libraryNavGroupSpecs) {
    if (spec.memberKinds.contains(kind)) {
      return spec;
    }
  }
  return null;
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}
