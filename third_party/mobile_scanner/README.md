# mobile_scanner, without Android

An unchanged copy of the Dart and Apple code of
[mobile_scanner](https://github.com/juliansteenbakker/mobile_scanner) 7.4.0
(BSD 3-Clause, `LICENSE`). The `android` folder and platform entry are left out,
because that part always brings in Google's closed ML Kit. The app uses ZXing on
Android and this copy on the web and Apple platforms, which never used ML Kit.
