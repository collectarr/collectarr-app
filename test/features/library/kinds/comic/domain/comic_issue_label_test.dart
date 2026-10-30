import 'package:collectarr_app/features/library/kinds/comic/domain/comic_issue_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the headline names series and issue once, then a distinct title', () {
    String? headline(String title, {String? variant}) => comicHeadline(
        series: 'Absolute Batman',
        issueNumber: '2',
        variant: variant,
        title: title);

    expect(
        headline('Absolute Batman #2A', variant: 'A'), 'Absolute Batman #2A');
    expect(headline('Absolute Batman'), 'Absolute Batman #2');
    expect(headline(''), 'Absolute Batman #2');
    expect(headline('The Zoo'), 'Absolute Batman #2 - The Zoo');
    expect(
        comicHeadline(
            series: null, issueNumber: null, variant: null, title: 'One-shot'),
        'One-shot');
  });
}
