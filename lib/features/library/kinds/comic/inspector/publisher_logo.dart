import 'package:collectarr_app/features/library/ui/image_load_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Publisher logos from `assets/publisher_logos/` (public-domain text logos
/// from Wikimedia Commons, see `assets/LOGOS.md`), keyed by the publisher's
/// name without words such as "Comics" or "Publishing".
const _logos = {
  'archie': 'archie.svg',
  'dark horse': 'dark_horse.svg',
  'dc': 'dc.svg',
  'dynamite': 'dynamite.png',
  'fantagraphics': 'fantagraphics.png',
  'idw': 'idw.svg',
  'image': 'image.svg',
  'kodansha': 'kodansha.svg',
  'marvel': 'marvel.svg',
  'panini': 'panini.png',
  'shueisha': 'shueisha.svg',
  'tokyopop': 'tokyopop.png',
  'valiant': 'valiant.svg',
  'vertigo': 'vertigo.svg',
  'viz': 'viz.svg',
};

const _companyWords = {
  'books',
  'comic',
  'comics',
  'entertainment',
  'group',
  'inc',
  'llc',
  'manga',
  'media',
  'publications',
  'publishing',
  'usa',
};

/// The logo asset for [publisher], or null when there is none.
String? comicPublisherLogoAsset(String publisher) {
  final words = publisher
      .toLowerCase()
      .replaceAll('ō', 'o')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty && !_companyWords.contains(word));
  final file = _logos[words.join(' ')];
  return file == null ? null : 'assets/publisher_logos/$file';
}

/// A publisher logo at the reference's 30 px height, on a white plate so
/// dark marks stay legible on the dark theme.
class ComicPublisherLogo extends StatelessWidget {
  const ComicPublisherLogo(
      {super.key, required this.asset, required this.name});

  static const double height = 30;
  final String asset;
  final String name;

  @override
  Widget build(BuildContext context) {
    const size = Size.fromHeight(height - 6);
    final isSvg = asset.endsWith('.svg');
    if (isSvg) reportLibraryPanelSvg(context, SvgAssetLoader(asset));
    final image = isSvg
        ? SvgPicture.asset(asset, height: size.height, fit: BoxFit.contain)
        : Image.asset(asset,
            height: size.height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            frameBuilder: libraryPanelImageFrames(context, asset));
    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        image: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(2)),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: image)),
        ),
      ),
    );
  }
}
