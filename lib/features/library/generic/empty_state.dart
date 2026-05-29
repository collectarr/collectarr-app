import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    super.key,
    required this.type,
    required this.icon,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilter,
  });

  final LibraryTypeConfig type;
  final IconData icon;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final animatedAccent = color ?? accent;
        final palette = appPalette(context);
    return ColoredBox(
      color: palette.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: animatedAccent),
              const SizedBox(height: 12),
              Text(
                hasActiveFilter
                    ? 'No matching ${type.pluralLabel.toLowerCase()}'
                    : 'Your local ${type.pluralLabel.toLowerCase()} shelf is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasActiveFilter
                    ? 'Clear filters to return to your local shelf.'
                    : _emptyStateSummary(type),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (hasActiveFilter)
                OutlinedButton.icon(
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear filter'),
                )
              else
                FilledButton.icon(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    backgroundColor: animatedAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add from Collectarr Core'),
                ),
              if (!hasActiveFilter && type.supportedMetadataProviders.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Manual add is enabled even without provider search.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

String _emptyStateSummary(LibraryTypeConfig type) {
  if (type.supportedMetadataProviders.isEmpty) {
    return 'No providers are registered for this library yet.';
  }
  final providers =
      type.supportedMetadataProviders.map((p) => p.label).join(', ');
    final suffix = type.workspace.kind == CatalogMediaKind.movie ||
      type.workspace.kind == CatalogMediaKind.tv
      ? ' Physical formats are tracked as editions.'
      : '';
  return 'Search Core via $providers, scan a barcode, or add a manual local item.$suffix';
}
