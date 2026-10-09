import 'dart:convert';

import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartListCriteria v3 field rules', () {
    test('round-trips every field operator', () {
      final criteria = SmartListCriteria(
        target: SmartListCriteriaTarget.catalog,
        kinds: const ['music'],
        expression: {
          'fields': {
            'music.disc.format': const SmartListFieldCriterion(
              operator: SmartListFieldOperator.equals,
              value: 'CD',
            ).toJson(),
            'music.disc.recording_year': const SmartListFieldCriterion(
              operator: SmartListFieldOperator.notEquals,
              value: '2025',
            ).toJson(),
            'music.artist': const SmartListFieldCriterion(
              operator: SmartListFieldOperator.contains,
              value: 'john',
            ).toJson(),
            'music.disc.recording_locations': const SmartListFieldCriterion(
              operator: SmartListFieldOperator.isEmpty,
            ).toJson(),
          },
        },
      );

      final decoded = SmartListCriteriaCodec.decode(
        SmartListCriteriaCodec.encode(criteria),
      );

      expect(decoded.toJson(), criteria.toJson());
      expect(decoded.toJson()['schema_version'], 3);
    });

    test('rejects the old schema version without decoding it', () {
      final json = <String, Object?>{
        'schema_version': 2,
        'target': 'catalog',
        'kinds': ['music'],
        'expression': {},
      };

      expect(
        () => SmartListCriteriaCodec.decode(jsonEncode(json)),
        throwsFormatException,
      );
    });

    test('rejects unknown field-rule keys and malformed empty rules', () {
      for (final fieldRule in [
        {'operator': 'equals', 'value': 'CD', 'case_sensitive': true},
        {'operator': 'is_empty', 'value': null},
        {'operator': 'contains'},
      ]) {
        final json = <String, Object?>{
          'schema_version': 3,
          'target': 'catalog',
          'kinds': ['music'],
          'expression': {
            'fields': {'music.disc.format': fieldRule},
          },
        };

        expect(
          () => SmartListCriteriaCodec.decode(jsonEncode(json)),
          throwsFormatException,
        );
      }
    });
  });
}
