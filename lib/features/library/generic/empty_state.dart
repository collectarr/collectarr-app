import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
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

  final LibraryKindRegistration type;
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
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
                                ? 'No matching ${type.identity.pluralLabel.toLowerCase()}'
                                : 'Your local ${type.identity.pluralLabel.toLowerCase()} shelf is empty',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.panelTitle.copyWith(
                                      color: palette.textPrimary,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasActiveFilter
                                ? 'Clear filters to return to your local shelf.'
                                : _emptyStateSummary(type),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .supportingText
                                .copyWith(
                                  color: palette.textMuted,
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
                                backgroundColor:
                                    libraryAccentActionColor(animatedAccent),
                                foregroundColor: appContrastingTextColor(
                                  libraryAccentActionColor(animatedAccent),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add from Collectarr Core'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

String _emptyStateSummary(LibraryKindRegistration type) {
  final suffix = libraryPresentationForKind(type.kind).emptyStateSummarySuffix;
  return 'Search Collectarr Core, or propose a missing ${type.identity.singularLabel.toLowerCase()}.$suffix';
}
