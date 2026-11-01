import 'package:collectarr_app/features/library/kinds/comic/inspector/publisher_logo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('publisher names match their logo whatever company words they carry',
      () {
    for (final (name, file) in [
      ('Marvel', 'marvel.svg'),
      ('Marvel Comics', 'marvel.svg'),
      ('DC Comics', 'dc.svg'),
      ('Viz Media', 'viz.svg'),
      ('VIZ Media LLC', 'viz.svg'),
      ('Viz Comics', 'viz.svg'),
      ('Dark Horse Manga', 'dark_horse.svg'),
      ('IDW Publishing', 'idw.svg'),
      ('Kodansha Comics USA', 'kodansha.svg'),
      ('Kōdansha', 'kodansha.svg'),
      ('Archie Comic Publications', 'archie.svg'),
      ('Fantagraphics Books', 'fantagraphics.png'),
      ('TOKYOPOP', 'tokyopop.png'),
    ]) {
      expect(comicPublisherLogoAsset(name), 'assets/publisher_logos/$file',
          reason: name);
    }
    expect(comicPublisherLogoAsset('Boom! Studios'), isNull);
    expect(comicPublisherLogoAsset('Square Enix Manga'), isNull);
    expect(comicPublisherLogoAsset('Image Entertainment Weekly'), isNull);
  });

  test('every logo asset loads and parses', () async {
    final assets = {
      for (final name in [
        'Archie',
        'Dark Horse',
        'DC',
        'Dynamite',
        'Fantagraphics',
        'IDW',
        'Image',
        'Kodansha',
        'Marvel',
        'Panini',
        'Shueisha',
        'Tokyopop',
        'Valiant',
        'Vertigo',
        'Viz',
      ])
        comicPublisherLogoAsset(name)!,
    };
    expect(assets, hasLength(15));
    for (final asset in assets) {
      final bytes = await rootBundle.load(asset);
      expect(bytes.lengthInBytes, greaterThan(0), reason: asset);
      if (asset.endsWith('.svg')) {
        final picture = await vg.loadPicture(SvgAssetLoader(asset), null);
        expect(picture.size.width, greaterThan(0), reason: asset);
        picture.picture.dispose();
      }
    }
  });
}
