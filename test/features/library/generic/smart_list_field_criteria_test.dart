import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/smart_list_resolver.dart';
import 'package:collectarr_app/features/library/generic/smart_list_field_rules_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('field rule editor loads many-value rules and saves them', (
    tester,
  ) async {
    Map<String, SmartListFieldCriterion>? saved;
    const initial = {
      'music.disc.format': SmartListFieldCriterion(
        operator: SmartListFieldOperator.notEquals,
        value: 'Cassette',
      ),
      'music.disc.is_live': SmartListFieldCriterion(
        operator: SmartListFieldOperator.equals,
        value: 'true',
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLibraryTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  saved = await showSmartListFieldRulesDialog(
                    context: context,
                    kind: catalogMediaKindFromApiValue('music'),
                    target: SmartListCriteriaTarget.catalog,
                    initial: initial,
                    kinds: const ['music'],
                  );
                },
                child: const Text('Edit Rules'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit Rules'));
    await tester.pumpAndSettle();

    expect(find.text('Disc Format'), findsOneWidget);
    expect(find.text('not equals'), findsOneWidget);
    expect(find.text('Cassette'), findsOneWidget);
    expect(find.text('true'), findsOneWidget);
    await tester.tap(find.text('Save rules'));
    await tester.pumpAndSettle();

    expect(saved, initial);
  });

  group('Smart List field criterion matching', () {
    test('equals matches any contained value', () {
      expect(
        librarySmartListCriterionMatches(
          ['CD', 'Vinyl'],
          const SmartListFieldCriterion(
            operator: SmartListFieldOperator.equals,
            value: 'vinyl',
          ),
        ),
        isTrue,
      );
    });

    test('numeric equality compares numeric values', () {
      expect(
        librarySmartListCriterionMatches(
          [2025, 2026],
          const SmartListFieldCriterion(
            operator: SmartListFieldOperator.equals,
            value: '2025.0',
          ),
        ),
        isTrue,
      );
    });

    test('not equals requires no contained value to match', () {
      const criterion = SmartListFieldCriterion(
        operator: SmartListFieldOperator.notEquals,
        value: 'Vinyl',
      );

      expect(librarySmartListCriterionMatches(['CD', 'Vinyl'], criterion),
          isFalse);
      expect(librarySmartListCriterionMatches(['CD'], criterion), isTrue);
      expect(librarySmartListCriterionMatches(<String>[], criterion), isTrue);
    });

    test('contains matches text in any contained value, case-insensitively',
        () {
      expect(
        librarySmartListCriterionMatches(
          ['The Blue Album', 'Live at Wembley'],
          const SmartListFieldCriterion(
            operator: SmartListFieldOperator.contains,
            value: 'WEM',
          ),
        ),
        isTrue,
      );
      expect(
        librarySmartListCriterionMatches(
          ['CD', 'Vinyl'],
          const SmartListFieldCriterion(
            operator: SmartListFieldOperator.contains,
            value: 'dvd',
          ),
        ),
        isFalse,
      );
    });

    test('is empty checks null, empty collections, and scalar text', () {
      const criterion = SmartListFieldCriterion(
        operator: SmartListFieldOperator.isEmpty,
      );

      expect(librarySmartListCriterionMatches(null, criterion), isTrue);
      expect(librarySmartListCriterionMatches(<String>[], criterion), isTrue);
      expect(librarySmartListCriterionMatches('', criterion), isTrue);
      expect(librarySmartListCriterionMatches(['CD'], criterion), isFalse);
      expect(librarySmartListCriterionMatches(false, criterion), isFalse);
    });
  });

  group('SmartListResolver field capabilities', () {
    test('resolves Music disc format many-value rules', () {
      final smartList = SmartListResolver.resolve(
        id: 'id',
        name: 'Vinyl albums',
        kind: catalogMediaKindFromApiValue('music'),
        criteria: SmartListCriteria(
          target: SmartListCriteriaTarget.catalog,
          kinds: const ['music'],
          expression: const {
            'fields': {
              'music.disc.format': {
                'operator': 'not_equals',
                'value': 'Cassette',
              },
            },
          },
        ),
      );

      expect(
          smartList
              .filterSelection.fieldCriteria['music.disc.format']?.operator,
          SmartListFieldOperator.notEquals);
      expect(smartList.degradedFieldTokens, isEmpty);
    });

    test('keeps is_live boolean and rejects text contains for it', () {
      final accepted = SmartListResolver.resolve(
        id: 'id',
        name: 'Live albums',
        kind: catalogMediaKindFromApiValue('music'),
        criteria: SmartListCriteria(
          target: SmartListCriteriaTarget.catalog,
          kinds: const ['music'],
          expression: const {
            'fields': {
              'music.disc.is_live': {'operator': 'equals', 'value': 'true'},
            },
          },
        ),
      );
      final rejectedTextOperator = SmartListResolver.resolve(
        id: 'id',
        name: 'Invalid live text rule',
        kind: catalogMediaKindFromApiValue('music'),
        criteria: SmartListCriteria(
          target: SmartListCriteriaTarget.catalog,
          kinds: const ['music'],
          expression: const {
            'fields': {
              'music.disc.is_live': {'operator': 'contains', 'value': 'live'},
            },
          },
        ),
      );
      final rejectedLabelValue = SmartListResolver.resolve(
        id: 'id',
        name: 'Invalid Live label rule',
        kind: catalogMediaKindFromApiValue('music'),
        criteria: SmartListCriteria(
          target: SmartListCriteriaTarget.catalog,
          kinds: const ['music'],
          expression: const {
            'fields': {
              'music.disc.is_live': {'operator': 'equals', 'value': 'Live'},
            },
          },
        ),
      );

      expect(accepted.degradedFieldTokens, isEmpty);
      expect(rejectedTextOperator.degradedFieldTokens, ['music.disc.is_live']);
      expect(rejectedLabelValue.degradedFieldTokens, ['music.disc.is_live']);
    });
  });
}
