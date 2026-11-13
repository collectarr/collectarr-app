const _accentedByBase = {
  'a': 'àáâãäåāăą',
  'c': 'çćĉċč',
  'd': 'ďđ',
  'e': 'èéêëēĕėęě',
  'g': 'ĝğġģ',
  'h': 'ĥħ',
  'i': 'ìíîïĩīĭįı',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ĺļľŀł',
  'n': 'ñńņň',
  'o': 'òóôõöøōŏő',
  'r': 'ŕŗř',
  's': 'śŝşš',
  't': 'ţťŧ',
  'u': 'ùúûüũūŭůűų',
  'w': 'ŵ',
  'y': 'ýÿŷ',
  'z': 'źżž',
  'ss': 'ß',
  'ae': 'æ',
  'oe': 'œ',
};

final Map<int, String> _fold = {
  for (final entry in _accentedByBase.entries)
    for (final rune in entry.value.runes) rune: entry.key,
};

bool _isAscii(String text) {
  for (var index = 0; index < text.length; index++) {
    if (text.codeUnitAt(index) >= 0x80) return false;
  }
  return true;
}

/// Lower-cases [text] and strips accents so "Édith" sorts with the Es.
String foldForSort(String text) {
  // Plain ASCII has no accents to strip, which covers most titles and names.
  if (_isAscii(text)) return text.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    buffer.write(_fold[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

int _lowerAscii(int unit) => unit >= 0x41 && unit <= 0x5A ? unit | 0x20 : unit;

/// Orders text the way people read it, as the reference does: ignoring letter
/// case and accents, and comparing digit runs by value ("Raft 2" before
/// "Raft 10"). Text that differs only in case or accents keeps a stable order.
int compareNaturalText(String first, String second) {
  // A sort calls this for every comparison. Plain ASCII, which covers most
  // titles and names, is compared in place without building folded copies.
  final a = _isAscii(first) ? first : foldForSort(first);
  final b = _isAscii(second) ? second : foldForSort(second);
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    final ca = _lowerAscii(a.codeUnitAt(i));
    final cb = _lowerAscii(b.codeUnitAt(j));
    if (_isDigit(ca) && _isDigit(cb)) {
      var endA = i;
      while (endA < a.length && _isDigit(a.codeUnitAt(endA))) {
        endA++;
      }
      var endB = j;
      while (endB < b.length && _isDigit(b.codeUnitAt(endB))) {
        endB++;
      }
      // Leading zeros do not count: the longer number is the larger one.
      var startA = i;
      while (startA < endA - 1 && a.codeUnitAt(startA) == 0x30) {
        startA++;
      }
      var startB = j;
      while (startB < endB - 1 && b.codeUnitAt(startB) == 0x30) {
        startB++;
      }
      if (endA - startA != endB - startB) {
        return (endA - startA) - (endB - startB);
      }
      for (var offset = 0; offset < endA - startA; offset++) {
        final order =
            a.codeUnitAt(startA + offset) - b.codeUnitAt(startB + offset);
        if (order != 0) return order;
      }
      i = endA;
      j = endB;
      continue;
    }
    if (ca != cb) return ca - cb;
    i++;
    j++;
  }
  final rest = (a.length - i) - (b.length - j);
  if (rest != 0) return rest;
  return first.compareTo(second);
}
