/// Title capitalization shared by album and track actions.
String autocapMusicTitle(String value) {
  const minorWords = {
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
  };
  final wordPattern = RegExp(
    r"[A-Za-zÀ-ÖØ-öø-ÿ0-9]+(?:['’][A-Za-zÀ-ÖØ-öø-ÿ0-9]+)*",
  );
  final words = wordPattern.allMatches(value).toList(growable: false);
  var index = 0;
  return value.replaceAllMapped(wordPattern, (match) {
    final source = match.group(0)!;
    final wordIndex = index++;
    final normalized = source.toLowerCase();
    final letters = source.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final shortAcronym = letters.length > 1 &&
        letters.length <= 4 &&
        letters == letters.toUpperCase();
    if (shortAcronym) return source;
    if (minorWords.contains(normalized) &&
        wordIndex > 0 &&
        wordIndex < words.length - 1) {
      return normalized;
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  });
}
