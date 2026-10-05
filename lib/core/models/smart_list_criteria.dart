import 'dart:convert';

enum SmartListCriteriaTarget {
  catalog('catalog'),
  libraryEntry('library_entry');

  const SmartListCriteriaTarget(this.value);

  final String value;

  static SmartListCriteriaTarget parse(Object? value) => switch (value) {
        'catalog' => SmartListCriteriaTarget.catalog,
        'library_entry' => SmartListCriteriaTarget.libraryEntry,
        _ => throw FormatException('Unsupported Smart List target: $value.'),
      };
}

class SmartListSortCriterion {
  const SmartListSortCriterion({
    required this.field,
    required this.ascending,
  });

  final String field;
  final bool ascending;
}

/// Persistence-only Smart List criteria. It has no dependency on UI filters,
/// workspace registries, or kind-specific field definitions.
class SmartListCriteria {
  SmartListCriteria({
    required this.target,
    required List<String> kinds,
    required Map<String, Object?> expression,
    this.search,
    this.quickView,
    List<SmartListSortCriterion> sorts = const [],
  })  : kinds = List.unmodifiable(kinds),
        expression = Map.unmodifiable(expression),
        sorts = List.unmodifiable(sorts) {
    if (this.kinds.isEmpty) {
      throw ArgumentError.value(kinds, 'kinds', 'Must not be empty.');
    }
    if (this.kinds.any((kind) => !_isKindToken(kind))) {
      throw ArgumentError.value(kinds, 'kinds', 'Contains an invalid kind.');
    }
    if (this.kinds.toSet().length != this.kinds.length) {
      throw ArgumentError.value(kinds, 'kinds', 'Must not contain duplicates.');
    }
  }

  final SmartListCriteriaTarget target;
  final List<String> kinds;
  final String? search;
  final String? quickView;
  final List<SmartListSortCriterion> sorts;
  final Map<String, Object?> expression;

  Map<String, Object?> toJson() => {
        'schema_version': 2,
        'target': target.value,
        'kinds': kinds,
        if (search != null) 'search': search,
        if (quickView != null) 'quick_view': quickView,
        if (sorts.isNotEmpty)
          'sorts': [
            for (final sort in sorts)
              {'field': sort.field, 'ascending': sort.ascending},
          ],
        'expression': expression,
      };

  static bool _isKindToken(String value) =>
      value == value.trim() &&
      value.isNotEmpty &&
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value);
}

/// Strict codec for the v2 persisted Smart List contract.
class SmartListCriteriaCodec {
  const SmartListCriteriaCodec._();

  static String encode(SmartListCriteria criteria) =>
      jsonEncode(criteria.toJson());

  static SmartListCriteria decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Smart List criteria must be an object.');
    }
    final json = <String, Object?>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        throw const FormatException('Smart List keys must be strings.');
      }
      json[entry.key as String] = entry.value;
    }

    const allowed = {
      'schema_version',
      'target',
      'kinds',
      'search',
      'quick_view',
      'sorts',
      'expression',
    };
    for (final key in json.keys) {
      if (!allowed.contains(key)) {
        throw FormatException('Unsupported Smart List field: $key.');
      }
    }
    if (json['schema_version'] != 2) {
      throw const FormatException('Unsupported Smart List schema version.');
    }
    if (!json.containsKey('expression')) {
      throw const FormatException(
        'Smart List criteria require an expression object.',
      );
    }
    final rawKinds = json['kinds'];
    if (rawKinds is! List ||
        rawKinds.isEmpty ||
        rawKinds.any((v) => v is! String)) {
      throw const FormatException(
          'Smart List kinds must be a non-empty string list.');
    }
    final rawSearch = json['search'];
    final rawQuickView = json['quick_view'];
    if (rawSearch != null && rawSearch is! String) {
      throw const FormatException('Smart List search must be a string.');
    }
    if (rawQuickView != null && rawQuickView is! String) {
      throw const FormatException('Smart List quick_view must be a string.');
    }

    final rawSorts = json['sorts'] ?? const [];
    if (rawSorts is! List) {
      throw const FormatException('Smart List sorts must be a list.');
    }
    final sorts = <SmartListSortCriterion>[];
    for (var index = 0; index < rawSorts.length; index++) {
      final rawSort = rawSorts[index];
      if (rawSort is! Map || rawSort['field'] is! String) {
        throw FormatException('Smart List sorts[$index] is invalid.');
      }
      const allowedSortKeys = {'field', 'ascending'};
      if (rawSort.keys.any((key) => !allowedSortKeys.contains(key))) {
        throw FormatException(
          'Smart List sorts[$index] contains an unsupported field.',
        );
      }
      final field = (rawSort['field'] as String).trim();
      final ascending = rawSort['ascending'];
      if (field.isEmpty || (ascending != null && ascending is! bool)) {
        throw FormatException('Smart List sorts[$index] is invalid.');
      }
      sorts.add(SmartListSortCriterion(
        field: field,
        ascending: ascending as bool? ?? true,
      ));
    }

    final rawExpression = json['expression'] ?? const {};
    if (rawExpression is! Map) {
      throw const FormatException('Smart List expression must be an object.');
    }
    final expression = <String, Object?>{};
    const expressionKeys = {
      'entries',
      'tracking_status',
      'loan_status',
      'date_field',
      'date_from',
      'date_to',
      'custom_field_definition_id',
      'custom_field_value',
      'fields',
      'missing_cover',
      'missing_metadata',
    };
    for (final entry in rawExpression.entries) {
      if (entry.key is! String) {
        throw const FormatException(
            'Smart List expression keys must be strings.');
      }
      final key = entry.key as String;
      if (!expressionKeys.contains(key)) {
        throw FormatException('Unsupported Smart List expression field: $key.');
      }
      expression[key] = entry.value;
    }
    for (final key in const [
      'entries',
      'tracking_status',
      'loan_status',
      'date_field',
      'custom_field_definition_id',
      'custom_field_value',
    ]) {
      final value = expression[key];
      if (value != null && value is! String) {
        throw FormatException('Smart List expression.$key must be a string.');
      }
    }
    for (final key in const ['date_from', 'date_to']) {
      final value = expression[key];
      if (value != null &&
          (value is! String ||
              (value.isNotEmpty && DateTime.tryParse(value) == null))) {
        throw FormatException('Smart List expression.$key must be a date.');
      }
    }
    for (final key in const ['missing_cover', 'missing_metadata']) {
      final value = expression[key];
      if (value != null && value is! bool) {
        throw FormatException('Smart List expression.$key must be a boolean.');
      }
    }
    final rawFields = expression['fields'];
    if (rawFields != null) {
      if (rawFields is! Map) {
        throw const FormatException(
          'Smart List expression.fields must be an object.',
        );
      }
      for (final entry in rawFields.entries) {
        if (entry.key is! String ||
            (entry.value != null && entry.value is! String)) {
          throw const FormatException(
            'Smart List expression.fields must map strings to strings or null.',
          );
        }
      }
    }

    return SmartListCriteria(
      target: SmartListCriteriaTarget.parse(json['target']),
      kinds: rawKinds.cast<String>(),
      search: rawSearch as String?,
      quickView: rawQuickView as String?,
      sorts: sorts,
      expression: expression,
    );
  }
}
