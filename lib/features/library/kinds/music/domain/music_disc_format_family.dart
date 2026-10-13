import 'music_disc_capabilities.dart';

enum MusicDiscFormatFamily {
  vinyl,
  opticalDisc,
  tape,
  digital,
  other;

  String get value => name;

  MusicDiscCapabilities get capabilities =>
      MusicDiscCapabilities.forFamily(this);

  static MusicDiscFormatFamily? tryParse(String? raw) {
    if (raw == null) return null;
    for (final candidate in values) {
      if (candidate.value == raw) return candidate;
    }
    return null;
  }
}
