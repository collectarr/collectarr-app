import 'package:collectarr_app/features/library/add/models/advanced_filter.dart';

final class LibraryAddSearchContext {
  LibraryAddSearchContext({
    this.query = '',
    this.identifierCode = '',
    this.codeQuery = '',
    this.isListing = false,
    Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters = const {},
  }) : advancedFilters = Map.unmodifiable(advancedFilters);

  final String query;
  final String identifierCode;
  final String codeQuery;

  /// The search fills a listing tab, whose scope alone is enough input.
  final bool isListing;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters;

  LibraryAddFilterValue? valueFor(LibraryAddFilterId id) => advancedFilters[id];

  String textValueFor(LibraryAddFilterId id) {
    final value = valueFor(id);
    return value?.displayValue.trim() ?? '';
  }

  bool get hasAnyInput {
    if (query.trim().isNotEmpty ||
        identifierCode.trim().isNotEmpty ||
        codeQuery.trim().isNotEmpty) {
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
