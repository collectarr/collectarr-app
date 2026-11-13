import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/foundation.dart';

/// What the quick search box asks for: text the values contain, or, after a
/// "matches:" prefix as in CLZ, a regular expression they match. Both ignore
/// letter case.
@immutable
final class LibrarySearchPattern {
  const LibrarySearchPattern._({
    required this.text,
    this.regExp,
    this.regExpError,
  });

  /// The prefix that turns the rest of the query into a regular expression.
  static const regExpPrefix = 'matches:';

  static LibrarySearchPattern? _last;
  static String? _lastQuery;

  /// Parses [query]; the last parse is reused, so filtering a whole list
  /// compiles its expression once.
  factory LibrarySearchPattern.parse(String query) {
    if (query == _lastQuery) return _last!;
    final trimmed = query.trim();
    final LibrarySearchPattern pattern;
    if (trimmed.toLowerCase().startsWith(regExpPrefix)) {
      final source = trimmed.substring(regExpPrefix.length).trim();
      RegExp? regExp;
      String? error;
      try {
        regExp = source.isEmpty ? null : RegExp(source, caseSensitive: false);
      } on FormatException catch (exception) {
        error = exception.message;
      }
      pattern =
          LibrarySearchPattern._(text: '', regExp: regExp, regExpError: error);
    } else {
      pattern = LibrarySearchPattern._(text: trimmed.toLowerCase());
    }
    _lastQuery = query;
    return _last = pattern;
  }

  /// Lower-cased text to look for, when the query is not an expression.
  final String text;
  final RegExp? regExp;

  /// Why the expression after "matches:" is not valid; nothing matches then.
  final String? regExpError;

  bool get isEmpty => text.isEmpty && regExp == null && regExpError == null;

  bool matches(String value) {
    if (regExpError != null) return false;
    return regExp?.hasMatch(value) ?? value.toLowerCase().contains(text);
  }
}

@immutable
final class LibrarySearchDocument {
  const LibrarySearchDocument({
    required this.itemId,
    required this.normalizedTokens,
    this.containedTokens = const [],
  });

  final String itemId;
  final List<String> normalizedTokens;
  final List<String> containedTokens;

  bool matches(
    String query, {
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final pattern = LibrarySearchPattern.parse(query);
    if (pattern.isEmpty) return true;
    return (searchTarget.includesMedia &&
            normalizedTokens.any(pattern.matches)) ||
        (searchTarget.includesTracks && containedTokens.any(pattern.matches));
  }
}

class LibrarySearchIndex {
  // Documents are kept on the shelf entry, which outlives the engine built
  // for every projection, so typing a search indexes each entry once.
  static final _documents = Expando<_IndexedDocument>();

  /// The document already built for [item] with these custom field values.
  LibrarySearchDocument? existing(
    LibraryProjectionItem item,
    Map<String, List<String>> customFieldValuesByItem,
  ) {
    final indexed = _documents[item.source];
    return indexed != null &&
            identical(indexed.customFieldValuesByItem, customFieldValuesByItem)
        ? indexed.document
        : null;
  }

  LibrarySearchDocument getOrBuild(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
    Iterable<String> searchFieldValues = const [],
    Iterable<String> containedSearchValues = const [],
  ]) {
    final indexed = existing(item, customFieldValuesByItem);
    if (indexed != null) return indexed;

    final tokens = <String>{};
    final dto = item.dto;
    final card = libraryCardPresentationForEntry(item);
    final source = item.source;

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        tokens.add(value.trim().toLowerCase());
      }
    }

    add(dto.primaryLabel);
    add(source.title);
    add(source.catalogSummary?.primaryLabel);
    add(source.catalogSummary?.subtitle);
    for (final token in source.catalogSearchTokens) {
      add(token);
    }
    add(card.seriesTitle);
    add(card.itemNumber);
    add(card.variant);
    add(card.format);
    for (final token in searchFieldValues) {
      add(token);
    }
    if (card.releaseDate != null) {
      add(card.releaseDate!.year.toString());
    }
    add(source.locationPath);

    for (final targetId in customFieldTargetIds(
      source: source,
      target: item.target,
    )) {
      final cfValues = customFieldValuesByItem[targetId];
      if (cfValues == null) continue;
      for (final value in cfValues) {
        add(value);
      }
    }

    final doc = LibrarySearchDocument(
      itemId: item.target.id,
      normalizedTokens: List<String>.unmodifiable(tokens),
      containedTokens: List<String>.unmodifiable({
        for (final value in containedSearchValues)
          if (value.trim().isNotEmpty) value.trim().toLowerCase(),
      }),
    );
    _documents[item.source] = _IndexedDocument(customFieldValuesByItem, doc);
    return doc;
  }
}

final class _IndexedDocument {
  const _IndexedDocument(this.customFieldValuesByItem, this.document);

  final Map<String, List<String>> customFieldValuesByItem;
  final LibrarySearchDocument document;
}
