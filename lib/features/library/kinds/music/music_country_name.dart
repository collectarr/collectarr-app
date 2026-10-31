import 'package:country_iso/country_iso.dart';

/// Converts MusicBrainz's ISO country codes into readable English names.
///
/// Country codes remain the stored and synced values; this is only for labels
/// shown in the app.
String? musicCountryName(String? value) {
  final country = value?.trim();
  if (country == null || country.isEmpty) return null;

  final code = country.toUpperCase();
  final musicBrainzArea = switch (code) {
    'AN' => 'Netherlands Antilles',
    'CS' => 'Serbia and Montenegro',
    'DD' => 'East Germany',
    'FX' => 'Metropolitan France',
    'SU' || 'XU' => 'Soviet Union',
    'UK' => 'United Kingdom',
    'XK' => 'Kosovo',
    'YU' => 'Yugoslavia',
    'XE' => 'Europe',
    'XW' => 'Worldwide',
    'XG' => 'East Germany',
    'XC' => 'Czechoslovakia',
    _ => null,
  };
  if (musicBrainzArea != null) return musicBrainzArea;

  final isoName = CountryISO.name(code);
  if (isoName != null) return isoName;

  if (country == country.toUpperCase()) {
    final lowercase = country.toLowerCase();
    return '${lowercase[0].toUpperCase()}${lowercase.substring(1)}';
  }
  return '${country[0].toUpperCase()}${country.substring(1)}';
}
