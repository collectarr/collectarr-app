import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';

final class LibraryAddSearchContext {
  LibraryAddSearchContext({
    this.query = '',
    this.identifierCode = '',
    Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters = const {},
  }) : advancedFilters = Map.unmodifiable(advancedFilters);

  final String query;
  final String identifierCode;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters;

  LibraryAddFilterValue? valueFor(LibraryAddFilterId id) => advancedFilters[id];

  String textValueFor(LibraryAddFilterId id) {
    final value = valueFor(id);
    return value?.displayValue.trim() ?? '';
  }

  bool get hasAnyInput {
    if (query.trim().isNotEmpty || identifierCode.trim().isNotEmpty) {
      return true;
    }
    return advancedFilters.values.any((value) => value.hasValue);
  }
}

String buildLibraryAddSearchQuery(Iterable<Object?> parts) {
  final seen = <String>{};
  return parts.map((part) => part?.toString().trim() ?? '').where((part) {
    if (part.isEmpty) return false;
    return seen.add(part.toLowerCase());
  }).join(' ');
}
