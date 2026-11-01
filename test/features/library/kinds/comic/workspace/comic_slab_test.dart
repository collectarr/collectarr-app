import 'package:collectarr_app/features/library/kinds/comic/edit/grading_options.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpSlab(WidgetTester tester, ComicSlab slab) =>
    tester.pumpWidget(MaterialApp(
        home: Center(child: SizedBox(width: 220, height: 400, child: slab))));

void main() {
  test('grade codes come only from the reference grades', () {
    expect(comicGradeCode('9.8 Near Mint/Mint'), '9.8');
    expect(comicGradeCode('NG - No Grade'), 'NG');
    expect(comicGradeCode('ART - Original Art'), 'ART');
    expect(comicGradeCode('Ungraded'), isNull);
    expect(comicGradeCode(null), isNull);
  });

  test('a slab without a known label type uses the Universal Grade label', () {
    expect(comicSlabLabel(null).name, 'Universal Grade');
    expect(comicSlabLabel('pedigree grade').name, 'Pedigree Grade');
    expect(comicSlabLabels.map((label) => label.name),
        comicLabelTypeOptions.map((option) => option.value));
  });

  test('the ribbon shows the grade, a dash without one, and My Value', () {
    final slabbed = comicGradeAndValuePill(
        grade: '9.8 Near Mint/Mint',
        valueCents: 150000,
        currency: 'USD',
        slabbed: true,
        labelType: 'Signature Series')!;
    expect(slabbed.lead, '9.8');
    expect(slabbed.leadIcon, isNotNull);
    expect(slabbed.leadBackground,
        comicSlabLabelGradient(comicSlabLabel('Signature Series')));
    expect(slabbed.valueIcon, Icons.person);

    final raw = comicGradeAndValuePill(
        grade: null,
        valueCents: 150000,
        currency: 'USD',
        slabbed: false,
        labelType: null)!;
    expect(raw.lead, '–');
    expect(raw.leadIcon, isNull);
    expect(raw.leadBackground, isNull);

    expect(
        comicGradeAndValuePill(
            grade: 'Ungraded',
            valueCents: null,
            currency: null,
            slabbed: false,
            labelType: null),
        isNull);
  });

  testWidgets('the slab prints the grade box only for a grade', (tester) async {
    await _pumpSlab(
        tester,
        const ComicSlab(
            grade: 'NG - No Grade',
            gradingCompany: 'CBCS',
            child: SizedBox.expand()));
    expect(find.text('NG'), findsOneWidget);
    expect(find.text('CBCS'), findsOneWidget);
    expect(tester.widget<Text>(find.text('NG')).style?.color, Colors.black);

    await _pumpSlab(tester,
        const ComicSlab(gradingCompany: 'PGX', child: SizedBox.expand()));
    expect(find.text('PGX'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(ComicSlab), matching: find.byType(Transform)),
        findsNothing);
    expect(tester.takeException(), isNull);
  });
}
