enum CollectarrItemKind {
  comic('comic'),
  manga('manga'),
  anime('anime'),
  book('book'),
  game('game'),
  boardgame('boardgame'),
  movie('movie'),
  tv('tv'),
  music('music'),
  unknown('unknown');

  const CollectarrItemKind(this.apiValue);

  final String apiValue;

  static CollectarrItemKind fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null) {
      return CollectarrItemKind.unknown;
    }
    for (final kind in CollectarrItemKind.values) {
      if (kind.apiValue == normalized) {
        return kind;
      }
    }
    return CollectarrItemKind.unknown;
  }
}
