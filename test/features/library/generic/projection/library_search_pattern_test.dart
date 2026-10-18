import 'package:collectarr_app/features/library/generic/projection/library_search_index.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plain text matches values that contain it, in any case', () {
    final pattern = LibrarySearchPattern.parse(' Wall ');
    expect(pattern.matches('The Wall'), isTrue);
    expect(pattern.matches('Wish You Were Here'), isFalse);
  });

  test('"matches:" turns the rest into a case-insensitive expression', () {
    final pattern = LibrarySearchPattern.parse(r'matches: ^the\s+\w+$');
    expect(pattern.regExpError, isNull);
    expect(pattern.matches('The Wall'), isTrue);
    expect(pattern.matches('the wall'), isTrue);
    expect(pattern.matches('The Dark Side'), isFalse);
    expect(
        LibrarySearchPattern.parse('MATCHES:wall').matches('The Wall'), isTrue);
  });

  test('an invalid expression explains itself and matches nothing', () {
    final pattern = LibrarySearchPattern.parse('matches:(unclosed');
    expect(pattern.regExpError, isNotNull);
    expect(pattern.isEmpty, isFalse);
    expect(pattern.matches('(unclosed'), isFalse);
  });

  test('"matches:" alone filters nothing yet', () {
    expect(LibrarySearchPattern.parse('matches:  ').isEmpty, isTrue);
  });

  test('search documents apply the expression to albums and to tracks', () {
    const doc = LibrarySearchDocument(
      itemId: 'album',
      normalizedTokens: ['the wall', 'pink floyd'],
      containedTokens: ['another brick in the wall, part 2'],
    );
    expect(doc.matches(r'matches:^pink'), isTrue);
    expect(doc.matches(r'matches:part \d$'), isTrue);
    expect(
        doc.matches(r'matches:part \d$',
            searchTarget: LibrarySearchTarget.mediaOnly),
        isFalse);
    expect(doc.matches(r'matches:^floyd'), isFalse);
  });
}
