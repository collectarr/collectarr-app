enum MusicDiscFormatFamily {
  vinyl,
  cd,
  sacd,
  cassette,
  minidisc,
  digital,
  other;

  String get value => name;

  static MusicDiscFormatFamily? tryParse(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().toLowerCase();
    for (final candidate in values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return null;
  }

  static MusicDiscFormatFamily fromFormatName(String? formatName) {
    if (formatName == null) return MusicDiscFormatFamily.other;
    final lower = formatName.trim().toLowerCase();
    if (lower.contains('vinyl') ||
        lower == 'lp' ||
        lower.contains('7"') ||
        lower.contains('12"') ||
        lower.contains('10"')) {
      return MusicDiscFormatFamily.vinyl;
    }
    if (lower.contains('sacd')) return MusicDiscFormatFamily.sacd;
    if (lower.contains('cd')) return MusicDiscFormatFamily.cd;
    if (lower.contains('cassette') || lower.contains('tape')) {
      return MusicDiscFormatFamily.cassette;
    }
    if (lower.contains('minidisc')) return MusicDiscFormatFamily.minidisc;
    if (lower.contains('digital') ||
        lower.contains('file') ||
        lower.contains('mp3') ||
        lower.contains('flac')) {
      return MusicDiscFormatFamily.digital;
    }
    return MusicDiscFormatFamily.other;
  }
}
