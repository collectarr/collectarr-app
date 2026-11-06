import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The list platform icons the user loads from their own files are kept
/// for, shared by every kind that names a platform.
const platformIconsList = 'platform';

/// A platform's logo from `assets/platform_logos/` (CC0 Simple Icons, see
/// NOTICE.md there), with the PlayStation generation drawn as a number.
typedef PlatformLogo = ({String asset, String? generation, bool wordmark});

/// The logo for [platform], or null when Simple Icons has none (Xbox,
/// Nintendo, Windows and others keep a generic glyph).
PlatformLogo? platformLogoFor(String platform) {
  final lower = platform.toLowerCase();
  PlatformLogo logo(String name, {String? generation, bool wordmark = false}) =>
      (
        asset: 'assets/platform_logos/$name.svg',
        generation: generation,
        wordmark: wordmark
      );
  if (lower.contains('vita')) {
    return logo('playstationvita', wordmark: true);
  }
  if (lower.contains('psp') || lower.contains('playstation portable')) {
    return logo('playstationportable', wordmark: true);
  }
  final playStation =
      RegExp(r'\b(?:playstation|ps)\s?([2-5])\b').firstMatch(lower);
  if (playStation != null) {
    return logo('playstation', generation: playStation.group(1));
  }
  if (lower.contains('playstation') || lower == 'ps1' || lower == 'psx') {
    return logo('playstation');
  }
  if (lower.contains('steam deck')) return logo('steamdeck');
  if (lower.contains('steam')) return logo('steam');
  if (RegExp(r'sega|genesis|mega drive|master system|game gear|saturn|'
          r'dreamcast|mega-cd|sega cd|32x')
      .hasMatch(lower)) {
    return logo('sega');
  }
  if (lower.contains('atari') || lower.contains('jaguar')) return logo('atari');
  if (RegExp(r'\b(?:mac|macos|ios|iphone|ipad|apple)\b').hasMatch(lower)) {
    return logo('apple');
  }
  if (lower.contains('linux')) return logo('linux');
  if (lower.contains('android')) return logo('android');
  return null;
}

/// The generic glyph for platforms without a logo.
IconData resolvePlatformIcon(String platform) {
  final lower = platform.toLowerCase();
  if (lower.contains('pc') ||
      lower.contains('windows') ||
      lower.contains('dos') ||
      lower.contains('computer')) {
    return Icons.desktop_windows;
  }
  if (lower.contains('mobile') || lower.contains('phone')) {
    return Icons.smartphone;
  }
  // Square, unlike the wide Font Awesome gamepad, which would overflow its box.
  return Icons.sports_esports;
}

/// The icon the user loaded for the platform called [name], else its logo
/// or glyph, at [size] in [color] or the current text color, with the name
/// as tooltip. A loaded icon keeps its own colours.
class PlatformIcon extends ConsumerWidget {
  const PlatformIcon(this.name, {super.key, this.size = 16, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref
        .watch(listValueImageProvider((list: platformIconsList, value: name)))
        .value;
    final ink = color ?? DefaultTextStyle.of(context).style.color;
    if (loaded != null) {
      // An image that keeps its own colours, often dark ones, stays legible
      // on a white tile; every image fills the same square so names line up.
      final tinted = ink != null && isBlackSvg(loaded);
      return Tooltip(
          message: name,
          child: Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(tinted ? 0 : size * 0.06),
              decoration: tinted
                  ? null
                  : BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size * 0.18)),
              child: ListValueImageView(loaded, blackSvgTint: ink)));
    }
    final logo = platformLogoFor(name);
    final Widget mark;
    if (logo == null) {
      mark = Icon(resolvePlatformIcon(name), size: size, color: ink);
    } else {
      final filter =
          ink == null ? null : ColorFilter.mode(ink, BlendMode.srcIn);
      // Wordmarks fill a band across the middle of their square; show only it.
      final picture = logo.wordmark
          ? SizedBox(
              width: size * 2,
              height: size * 0.4,
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: size * 2,
                  maxHeight: size * 2,
                  child: SvgPicture.asset(logo.asset,
                      width: size * 2, height: size * 2, colorFilter: filter),
                ),
              ),
            )
          : SvgPicture.asset(logo.asset,
              width: size, height: size, colorFilter: filter);
      mark = logo.generation == null
          ? picture
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  picture,
                  Text(logo.generation!,
                      style: TextStyle(
                          fontSize: size * 0.6,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: ink)),
                ]);
    }
    // Every mark fills the same square: a wordmark or a generation number
    // scales down instead of running past the tile.
    return Tooltip(
        message: name,
        child: SizedBox.square(
            dimension: size, child: FittedBox(child: Center(child: mark))));
  }
}

/// Builds the platform icon cell of a list, as in the reference Games list.
Widget buildPlatformIcon(String? platform) {
  if (platform == null || platform.trim().isEmpty) {
    return const SizedBox.shrink();
  }
  return Center(heightFactor: 1, child: PlatformIcon(platform.trim()));
}
