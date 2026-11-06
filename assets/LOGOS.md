# Third-party logos

These files come unchanged from [Simple Icons](https://simpleicons.org)
16.35.0, released under
[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/):

- `logos/ebay.svg`: eBay, a trademark of eBay Inc.
- `import_logos/discogs.svg`: Discogs, a trademark of Zink Media, LLC.
- `platform_logos/`: PlayStation, PSP and PS Vita (Sony Interactive
  Entertainment); Steam and Steam Deck (Valve Corporation); Sega (Sega
  Corporation); Atari (Atari Interactive); Apple (Apple Inc.); Linux (Linus
  Torvalds; the drawing is Tux); Android (Google LLC). PlayStation
  generations are the PlayStation symbol followed by the number as text.

The marks belong to their owners. Collectarr shows them only to identify an
external service or an item's platform and is not affiliated with or
endorsed by these companies. Simple Icons drawings are single-color; the app
tints them.

## Local image overrides

Optional local icon downloads belong in `local-assets/CLZ/` at the repository
root. Git ignores `local-assets/`; these files are not bundled app assets.

- `comics-custom-labels/`: Custom Label images for Comics.
- `games-platform-icons/`: platform images for Games.

Each folder's `index.csv` maps the displayed names to the original filenames.
Load images through Settings > Customization > Comics > Custom label icons or
Games > Platform icons: select every file in the folder, including `index.csv`,
and each image is stored under the names the index gives it. A file the index
does not list, or one loaded without an index, must be named after its label or
platform.

Except for the import-source marks listed below, use a known free license for
new logos. Sources and platforms without a logo here (Xbox, Nintendo and
Windows have none in Simple Icons) use a generic icon.

## Games and Comics import source marks

The following marks are displayed only to identify the application or service
whose export is being imported. They were requested for this purpose and are
hosted by CLZ; a redistribution license has not been established. Their names
and logos remain the property of their respective owners.

| File | Source |
| --- | --- |
| `import_logos/delicious-library.png` | [Delicious Library](https://app-assets.clz.com/static/images/logos/import/delicious.png) |
| `import_logos/game-collector.png` | [Game Collector](https://app-assets.clz.com/static/images/logos/game/logo-desktop.png) |
| `import_logos/clz-games.svg` | [CLZ Games](https://app-assets.clz.com/static/images/logos/game/clz-games-icon.svg) |
| `import_logos/pricecharting.png` | [PriceCharting](https://app-assets.clz.com/static/images/logos/import/pricecharting.png) |
| `import_logos/comic-collector.png` | [Comic Collector](https://app-assets.clz.com/static/images/logos/comic/logo-desktop.png) |
| `import_logos/clz-comics.svg` | [CLZ Comics](https://app-assets.clz.com/static/images/logos/comic/clz-comics-icon.svg) |
| `import_logos/comic-collector-live.png` | [Comic Collector Live](https://app-assets.clz.com/static/images/logos/import/ccl.png) |

## Publisher logos

`publisher_logos/` holds the logos the Comics details panel shows in place of
a publisher's or imprint's name, as CLZ does. Each comes from Wikimedia
Commons, where it is marked
[PD-textlogo](https://commons.wikimedia.org/wiki/Template:PD-textlogo): it
consists only of simple typography and shapes, so it is below the threshold
of originality and not protected by copyright in the United States, the
publishers' home country. The SVGs are unchanged; the PNGs are scaled down to
96 px high.

| File | Publisher | Source |
| --- | --- | --- |
| `archie.svg` | Archie Comics | [Archie Comics logo 1987.svg](https://commons.wikimedia.org/wiki/File:Archie_Comics_logo_1987.svg) |
| `dark_horse.svg` | Dark Horse Comics | [Dark Horse Comics wordmark.svg](https://commons.wikimedia.org/wiki/File:Dark_Horse_Comics_wordmark.svg) |
| `dc.svg` | DC Comics | [DC 2024 flat.svg](https://commons.wikimedia.org/wiki/File:DC_2024_flat.svg) |
| `dynamite.png` | Dynamite Entertainment | [Dynamite logo.png](https://commons.wikimedia.org/wiki/File:Dynamite_logo.png) |
| `fantagraphics.png` | Fantagraphics Books | [Fantagraphics logo.png](https://commons.wikimedia.org/wiki/File:Fantagraphics_logo.png) |
| `idw.svg` | IDW Publishing | [IDW Publishing logo 2025.svg](https://commons.wikimedia.org/wiki/File:IDW_Publishing_logo_2025.svg) |
| `image.svg` | Image Comics | [Image Comics logo.svg](https://commons.wikimedia.org/wiki/File:Image_Comics_logo.svg) |
| `kodansha.svg` | Kodansha | [Kōdansha logo.svg](https://commons.wikimedia.org/wiki/File:K%C5%8Ddansha_logo.svg) |
| `marvel.svg` | Marvel Comics | [Marvel Logo.svg](https://commons.wikimedia.org/wiki/File:Marvel_Logo.svg) |
| `panini.png` | Panini Comics | [Panini comics logo.png](https://commons.wikimedia.org/wiki/File:Panini_comics_logo.png) |
| `shueisha.svg` | Shueisha | [Shueisha Logo.svg](https://commons.wikimedia.org/wiki/File:Shueisha_Logo.svg) |
| `tokyopop.png` | Tokyopop | [TOKYOPOP logo.png](https://commons.wikimedia.org/wiki/File:TOKYOPOP_logo.png) |
| `valiant.svg` | Valiant Comics | [Valiant Comics logo (April 2012).svg](https://commons.wikimedia.org/wiki/File:Valiant_Comics_logo_(April_2012).svg) |
| `vertigo.svg` | Vertigo (DC Comics) | [Vertigo-Comics-Logo.svg](https://commons.wikimedia.org/wiki/File:Vertigo-Comics-Logo.svg) |
| `viz.svg` | Viz Media | [Viz Media 2017 logo.svg](https://commons.wikimedia.org/wiki/File:Viz_Media_2017_logo.svg) |

The logos remain trademarks of their publishers. Collectarr shows them only
to identify who published an item and is not affiliated with or endorsed by
these publishers. Copyright on simple logos differs between countries;
anyone redistributing Collectarr elsewhere should check the local rules.

Only add a publisher logo whose Commons file is marked PD-textlogo (or has a
free license) and that `flutter_svg` draws correctly. Logos Wikipedia keeps
as non-free or fair use (Aspen Comics, Zenescope) and CLZ's own
`publishericons` images are not allowed; those publishers show their name.

## Flags

`flags/` holds the 4:3 country flags of the languages in Settings >
Localization, unchanged from [flag-icons](https://github.com/lipis/flag-icons)
7.2.3 by Panayiotis Lipiridis, released under the MIT License
(`flags/LICENSE.flag-icons.txt`). Do not use the reference's flag images.
