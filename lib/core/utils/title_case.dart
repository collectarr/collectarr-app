/// Title capitalization used by Autocap actions and Settings > Auto
/// Capitalization.
library;

enum TitleCaseMethod {
  eachWordWithExceptions('First Letter of Each Word with Exceptions'),
  eachWord('First Letter of Each Word'),
  firstWord('First Letter of First Word Only');

  const TitleCaseMethod(this.label);

  final String label;
}

/// Short words kept lowercase inside a title unless they start or end it.
const defaultTitleCaseExceptions = [
  'a',
  'an',
  'and',
  'as',
  'at',
  'but',
  'by',
  'for',
  'from',
  'in',
  'into',
  'nor',
  'of',
  'on',
  'or',
  'over',
  'per',
  'the',
  'to',
  'up',
  'via',
  'with',
];

final class TitleCaseSettings {
  const TitleCaseSettings({
    this.method = TitleCaseMethod.eachWordWithExceptions,
    this.exceptions = defaultTitleCaseExceptions,
  });

  final TitleCaseMethod method;
  final List<String> exceptions;
}

final _wordPattern = RegExp(
  r"[A-Za-zÀ-ÖØ-öø-ÿ0-9]+(?:['’][A-Za-zÀ-ÖØ-öø-ÿ0-9]+)*",
);

/// Capitalizes [value] by [settings]. Short all-caps acronyms (2–4 letters,
/// such as "CD" or "USA") inside a mixed-case title are kept as written.
String applyTitleCase(
  String value, [
  TitleCaseSettings settings = const TitleCaseSettings(),
]) {
  final exceptions = {
    for (final word in settings.exceptions) word.trim().toLowerCase(),
  };
  final wordCount = _wordPattern.allMatches(value).length;
  // In an all-caps title every short word looks like an acronym, so
  // acronyms are only recognised when the title also has lowercase letters.
  final hasLowercase = value.contains(RegExp(r'[a-zà-öø-ÿ]'));
  var index = 0;
  return value.replaceAllMapped(_wordPattern, (match) {
    final source = match.group(0)!;
    final wordIndex = index++;
    final normalized = source.toLowerCase();
    final letters = source.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final shortAcronym = hasLowercase &&
        !exceptions.contains(normalized) &&
        letters.length > 1 &&
        letters.length <= 4 &&
        letters == letters.toUpperCase();
    if (shortAcronym) return source;
    final capitalized = normalized[0].toUpperCase() + normalized.substring(1);
    return switch (settings.method) {
      TitleCaseMethod.eachWord => capitalized,
      TitleCaseMethod.firstWord => wordIndex == 0 ? capitalized : normalized,
      TitleCaseMethod.eachWordWithExceptions =>
        exceptions.contains(normalized) &&
                wordIndex > 0 &&
                wordIndex < wordCount - 1
            ? normalized
            : capitalized,
    };
  });
}
