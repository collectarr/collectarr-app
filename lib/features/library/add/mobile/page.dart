import 'package:collectarr_app/features/library/ui/density_scope.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Native Add page chrome over the shared Add content and session.
class LibraryAddMobilePage extends StatelessWidget {
  const LibraryAddMobilePage({
    super.key,
    required this.pluralLabel,
    required this.singularLabel,
    required this.accent,
    required this.themeData,
    required this.contextBar,
    required this.body,
    required this.footer,
    required this.overlay,
    required this.coverSelected,
    required this.onBack,
    required this.onManual,
    required this.onCoreDataSettings,
  });

  final String pluralLabel;
  final String singularLabel;
  final Color accent;
  final ThemeData themeData;
  final Widget contextBar;
  final Widget body;
  final Widget? footer;
  final Widget? overlay;
  final bool coverSelected;
  final VoidCallback onBack;
  final VoidCallback onManual;
  final VoidCallback onCoreDataSettings;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: themeData,
      child: LibraryDensityScope(
        density: LibraryDensity.comfortable,
        child: MobilePage(
          title: 'Add $pluralLabel',
          titleWidget: Text(
            'My $pluralLabel',
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          onBack: onBack,
          headerColor: accent,
          backgroundColor: palette.panel,
          contextBarBottomPadding: 0,
          actions: [
            Center(
              child: Text(
                MediaQuery.sizeOf(context).width < 360
                    ? 'COLLECTARR'
                    : 'COLLECTARR ${pluralLabel.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Add options',
              onSelected: (action) =>
                  action == 'manual' ? onManual() : onCoreDataSettings(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'manual', child: Text('Add Manually')),
                PopupMenuItem(
                  value: 'settings',
                  child: Text('Add/Update from Core settings'),
                ),
              ],
            ),
          ],
          contextBar: contextBar,
          body: coverSelected
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Scan the cover to find a ${singularLabel.toLowerCase()} in Core.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.utilityAction,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              : body,
          footer: footer,
          overlay: overlay,
        ),
      ),
    );
  }
}
