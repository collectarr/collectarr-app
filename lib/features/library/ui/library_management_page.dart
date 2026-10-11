import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Page chrome for collection management tools opened from the library menu.
class LibraryManagementPage extends StatelessWidget {
  const LibraryManagementPage({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.bottomBar,
    this.svgAsset,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;
  final Widget? bottomBar;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) => Theme(
        data: libraryAccentTheme(context, accent),
        child: Builder(builder: (context) {
          final palette = appPalette(context);
          return Scaffold(
            backgroundColor: palette.surface,
            appBar: AppBar(
              toolbarHeight: 48,
              leadingWidth: 90,
              leading: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
              titleSpacing: 8,
              title: Row(children: [
                if (svgAsset != null)
                  SvgPicture.asset(svgAsset!,
                      width: 18,
                      height: 18,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn))
                else
                  Icon(icon, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ]),
              backgroundColor: libraryAccentChromeFallbackColor(accent),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: LibraryAccentChrome(
                accent: accent,
                animationDuration: Duration.zero,
              ),
            ),
            body: child,
            bottomNavigationBar: bottomBar,
          );
        }),
      );
}
