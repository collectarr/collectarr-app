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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            color: palette.panelRaised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: palette.cardBorder),
            ),
            child: InkWell(
              key: Key('import_source_${source.id}'),
              borderRadius: BorderRadius.circular(4),
              hoverColor: Colors.white.withValues(alpha: 0.04),
              onTap: () => onSelect(source.id),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    _buildSourceLogo(source, 45),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        source.title,
                        style: TextStyle(
                          fontSize: 18,
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
  ) {
    if (source.assetLogoPath != null) {
      if (source.isSvg) {
        return SvgPicture.asset(
          source.assetLogoPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(source.fallbackIcon, size: size * 0.6, color: Colors.white70),
    );
  }
}
