import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';

final class LibraryAddSearchContext {
  LibraryAddSearchContext({
    this.query = '',
    this.barcode = '',
    Map<LibraryAddFilterId, Object?> advancedFilters = const {},
  }) : advancedFilters = Map.unmodifiable(advancedFilters);

  final String query;
  final String barcode;
  final Map<LibraryAddFilterId, Object?> advancedFilters;

  Object? valueFor(LibraryAddFilterId id) => advancedFilters[id];

  String textValueFor(LibraryAddFilterId id) {
    final value = valueFor(id);
    return value is String ? value.trim() : value?.toString().trim() ?? '';
  }

  bool get hasAnyInput {
    if (query.trim().isNotEmpty || barcode.trim().isNotEmpty) {
      return true;
    }
    return advancedFilters.values.any(_hasValue);
  }

  bool _hasValue(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}

String buildLibraryAddSearchQuery(Iterable<Object?> parts) {
  final seen = <String>{};
  return parts.map((part) => part?.toString().trim() ?? '').where((part) {
    if (part.isEmpty) return false;
    return seen.add(part.toLowerCase());
  }).join(' ');
}
