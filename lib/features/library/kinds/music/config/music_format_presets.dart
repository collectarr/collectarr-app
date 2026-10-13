import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';

/// Canonical family choices for known Music format vocabulary values.
/// Unknown values remain custom and require an explicit family selection.
const musicFormatPresets = <String, MusicDiscFormatFamily>{
  'CD': MusicDiscFormatFamily.opticalDisc,
  'SACD': MusicDiscFormatFamily.opticalDisc,
  'SHM-CD': MusicDiscFormatFamily.opticalDisc,
  'Blu-spec CD': MusicDiscFormatFamily.opticalDisc,
  'Cassette': MusicDiscFormatFamily.tape,
  'Vinyl (12" LP)': MusicDiscFormatFamily.vinyl,
  'Vinyl (7" Single)': MusicDiscFormatFamily.vinyl,
  'Vinyl (10" EP)': MusicDiscFormatFamily.vinyl,
  '12" Vinyl': MusicDiscFormatFamily.vinyl,
  'Vinyl': MusicDiscFormatFamily.vinyl,
  'LP': MusicDiscFormatFamily.vinyl,
  'FLAC': MusicDiscFormatFamily.digital,
  'FLAC / Hi-Res Digital': MusicDiscFormatFamily.digital,
  'Digital Download': MusicDiscFormatFamily.digital,
};

MusicDiscFormatFamily? musicFormatPresetFamily(String? format) {
  final value = format?.trim();
  if (value == null || value.isEmpty) return null;
  return musicFormatPresets[value];
}
