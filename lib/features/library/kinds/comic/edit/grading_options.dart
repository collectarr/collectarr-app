import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:flutter/painting.dart';

LibraryFixedSelectOption _plain(String value) =>
    (value: value, background: null);

/// The reference's grades, best first, then its non-numeric grades.
final List<LibraryFixedSelectOption> comicGradeOptions = [
  for (final grade in const [
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
  ])
    _plain(grade),
];

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

LinearGradient _slab(int start, int end) =>
    LinearGradient(colors: [Color(start), Color(end)]);

final _blue = _slab(0xffdde4f4, 0xff90b2de);
final _gold = _slab(0xfffff5dd, 0xfffddd97);

/// The reference's slab label types in its order, each painted in its
/// label's colours.
final List<LibraryFixedSelectOption> comicLabelTypeOptions = [
  (value: 'Universal Grade', background: _blue),
  (value: 'Signature Series', background: _gold),
  (value: 'Qualified Grade', background: _slab(0xffdce6dc, 0xff86ae8c)),
  (value: 'Restored Grade', background: _slab(0xffe2deed, 0xffa08dc5)),
  (value: 'Pedigree Grade', background: _slab(0xffe0c59a, 0xff9f8965)),
  (value: 'Conserved Grade', background: _blue),
  (value: 'Signature Series Qualified', background: _gold),
  (value: 'Signature Series Restored', background: _gold),
  (value: 'Signature Series Conserved', background: _gold),
  (value: 'CGC x JSA Authentic Autograph', background: _gold),
  (value: 'CBCS Certified', background: _blue),
  (value: 'CBCS Authentic Signature', background: _gold),
  (value: 'CBCS Verified Signature', background: _gold),
  (value: 'CBCS Restored Grade', background: _blue),
  (
    value: 'CBCS Verified Red Label (legacy)',
    background: _slab(0xfff1d5dd, 0xffcb5d65)
  ),
];
