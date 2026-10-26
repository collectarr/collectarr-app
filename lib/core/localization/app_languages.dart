/// Application languages offered in Settings > Localization.
library;

final class AppLanguage {
  const AppLanguage(this.locale, this.nativeName, this.flagCountry,
      {this.translated = false});

  /// The locale tag, such as `en-US`.
  final String locale;

  /// The language's own name, as the language picker shows it.
  final String nativeName;

  /// The lower-case country code of the flag shown beside the name.
  final String flagCountry;

  /// Whether the interface is available in this language.
  final bool translated;

  String get flagAsset => 'assets/flags/$flagCountry.svg';
}

/// The reference's application languages, in its order. Collectarr's
/// interface is English-only so far; the others are listed but disabled.
const kAppLanguages = <AppLanguage>[
  AppLanguage('en-US', 'English', 'us', translated: true),
  AppLanguage('nl-NL', 'Nederlands', 'nl'),
  AppLanguage('de-DE', 'Deutsch', 'de'),
  AppLanguage('fr-FR', 'Français', 'fr'),
  AppLanguage('es-ES', 'Español', 'es'),
  AppLanguage('hu-HU', 'Magyar', 'hu'),
  AppLanguage('sr-RS', 'српски', 'rs'),
  AppLanguage('da-DK', 'Dansk', 'dk'),
  AppLanguage('it-IT', 'Italiano', 'it'),
  AppLanguage('sv-SE', 'Svenska', 'se'),
  AppLanguage('sk-SK', 'Slovenčina', 'sk'),
  AppLanguage('pt-PT', 'Português', 'pt'),
];
