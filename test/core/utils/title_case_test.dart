import 'package:collectarr_app/core/utils/title_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each word with exceptions keeps inner minor words lowercase', () {
    expect(applyTitleCase('a NIGHT at THE opera'), 'A Night at the Opera');
    expect(applyTitleCase('songs to sing along to'), 'Songs to Sing Along To');
    expect(applyTitleCase('live in the USA'), 'Live in the USA');
  });

  test('custom exceptions replace the default list', () {
    const settings = TitleCaseSettings(exceptions: ['in']);
    expect(applyTitleCase('live in the usa', settings), 'Live in The Usa');
  });

  test('other methods capitalize every word or only the first', () {
    expect(
      applyTitleCase('a night at the opera',
          const TitleCaseSettings(method: TitleCaseMethod.eachWord)),
      'A Night At The Opera',
    );
    expect(
      applyTitleCase('A NIGHT AT THE OPERA',
          const TitleCaseSettings(method: TitleCaseMethod.firstWord)),
      'A night at the opera',
    );
  });
}
