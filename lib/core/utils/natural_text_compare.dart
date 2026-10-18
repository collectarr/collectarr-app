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

/// Lower-cases [text] and strips accents so "Édith" sorts with the Es.
String foldForSort(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    buffer.write(_fold[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

/// Orders text the way people read it, as the reference does: ignoring letter
/// case and accents, and comparing digit runs by value ("Raft 2" before
/// "Raft 10"). Text that differs only in case or accents keeps a stable order.
int compareNaturalText(String first, String second) {
  final a = foldForSort(first);
  final b = foldForSort(second);
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    final ca = a.codeUnitAt(i);
    final cb = b.codeUnitAt(j);
    if (_isDigit(ca) && _isDigit(cb)) {
      var endA = i;
      while (endA < a.length && _isDigit(a.codeUnitAt(endA))) {
        endA++;
      }
      var endB = j;
      while (endB < b.length && _isDigit(b.codeUnitAt(endB))) {
        endB++;
      }
      final numA = a.substring(i, endA).replaceFirst(RegExp(r'^0+(?=\d)'), '');
      final numB = b.substring(j, endB).replaceFirst(RegExp(r'^0+(?=\d)'), '');
      if (numA.length != numB.length) return numA.length - numB.length;
      final order = numA.compareTo(numB);
      if (order != 0) return order;
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
