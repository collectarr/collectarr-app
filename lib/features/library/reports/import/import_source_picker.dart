import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImportSourcePicker extends StatelessWidget {
  const ImportSourcePicker(
      {super.key, required this.sources, required this.onSelect});
  final List<LibraryImportSourceDefinition> sources;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => _buildRootMenuView(appPalette(context));
  Widget _buildRootMenuView(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import from:',
          style: TextStyle(
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panel,
            border: Border.all(
                color: palette.isDark
                    ? const Color(0xff262626)
                    : palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              for (final source in sources) ...[
                _buildSourceCard(palette, source),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceCard(
    AppThemePalette palette,
    LibraryImportSourceDefinition source,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 700
            ? (constraints.maxWidth - 30) / 2
            : constraints.maxWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Material(
            color: palette.panel,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: palette.isDark
                      ? const Color(0xff262626)
                      : palette.cardBorder),
            ),
            child: InkWell(
              key: Key('import_source_${source.id}'),
              hoverColor: Colors.white.withValues(alpha: 0.04),
              onTap: () => onSelect(source.id),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Row(
                  children: [
                    _buildSourceLogo(source, 45, palette.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        source.title,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceLogo(
    LibraryImportSourceDefinition source,
    double size,
    Color ink,
  ) {
    if (source.assetLogoPath != null) {
      if (source.isSvg) {
        // SVG logos are single-color Simple Icons, drawn in the text color.
        return SvgPicture.asset(
          source.assetLogoPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
        );
      } else {
        return Image.asset(
          source.assetLogoPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(source.fallbackIcon,
          size: size * 0.6, color: ink.withValues(alpha: 0.7)),
    );
  }
}
