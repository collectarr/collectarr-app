import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';

LibraryFixedSelectOption _plain(String value) =>
    (value: value, background: null);

/// The reference's grades, best first, then its non-numeric grades.
const comicGrades = [
  '10.0 Gem Mint',
  '9.9 Mint',
  '9.8 Near Mint/Mint',
  '9.6 Near Mint +',
  '9.4 Near Mint',
  '9.2 Near Mint -',
  '9.0 Very Fine/Near Mint',
  '8.5 Very Fine +',
  '8.0 Very Fine',
  '7.5 Very Fine -',
  '7.0 Fine/Very Fine',
  '6.5 Fine +',
  '6.0 Fine',
  '5.5 Fine -',
  '5.0 Very Good/Fine',
  '4.5 Very Good +',
  '4.0 Very Good',
  '3.5 Very Good -',
  '3.0 Good/Very Good',
  '2.5 Good +',
  '2.0 Good',
  '1.8 Good -',
  '1.5 Fair/Good',
  '1.0 Fair',
  '0.5 Poor',
  '0.3 Extremely Poor',
  '0.1 Incomplete',
  'NG - No Grade',
  'PG - Individual Page',
  'CVR - Cover',
  'ART - Original Art',
];

final List<LibraryFixedSelectOption> comicGradeOptions = [
  for (final grade in comicGrades) _plain(grade),
];

/// A reference grade's code before its name: "9.8" from
/// "9.8 Near Mint/Mint" and "NG" from "NG - No Grade". Other values, such
/// as an imported grade the reference does not list, have none.
String? comicGradeCode(String? grade) => switch (grade?.trim()) {
      final value? when comicGrades.contains(value) => value.split(' ').first,
      _ => null,
    };

/// The standard letters of a numeric grade code: "NM" for "9.4".
String? comicGradeLetters(String? code) => const {
      '10.0': 'GM',
      '9.9': 'M',
      '9.8': 'NM/M',
      '9.6': 'NM+',
      '9.4': 'NM',
      '9.2': 'NM-',
      '9.0': 'VF/NM',
      '8.5': 'VF+',
      '8.0': 'VF',
      '7.5': 'VF-',
      '7.0': 'FN/VF',
      '6.5': 'FN+',
      '6.0': 'FN',
      '5.5': 'FN-',
      '5.0': 'VG/FN',
      '4.5': 'VG+',
      '4.0': 'VG',
      '3.5': 'VG-',
      '3.0': 'GD/VG',
      '2.5': 'GD+',
      '2.0': 'GD',
      '1.8': 'GD-',
      '1.5': 'FR/GD',
      '1.0': 'FR',
      '0.5': 'PR',
    }[code];

/// The reference's page qualities, whitest first.
final List<LibraryFixedSelectOption> comicPageQualityOptions = [
  for (final quality in const [
    'White',
    'Off-White to White',
    'Off-White',
    'Cream to Off-White',
    'Cream',
    'Light Tan to Off-White',
    'Light Tan to Cream',
    'Light Tan',
    'Tan to Off-White',
    'Tan to Cream',
    'Tan',
    'Dark Tan to Off-White',
    'Dark Tan',
    'Brown to Off-White',
    'Brown to Tan',
    'Brown',
    'Brown / Brittle',
  ])
    _plain(quality),
];

/// The reference's slab label types in its order, each painted in its
/// label's colours.
final List<LibraryFixedSelectOption> comicLabelTypeOptions = [
  for (final label in comicSlabLabels)
    (value: label.name, background: comicSlabLabelGradient(label)),
];
