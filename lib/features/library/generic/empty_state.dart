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
    if (hasActiveFilter) return _NoResultsBanner(onReset: onClearFilter);
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
                            'This collection has no ${type.identity.pluralLabel.toLowerCase()} yet',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.panelTitle.copyWith(
                                      color: palette.textPrimary,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _emptyStateSummary(type),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .supportingText
                                .copyWith(
                                  color: palette.textMuted,
                                ),
                          ),
                          const SizedBox(height: 16),
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

/// The reference's blue "No results found..." banner over the empty list,
/// with a white Reset all filters button.
class _NoResultsBanner extends StatelessWidget {
  const _NoResultsBanner({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final blue = palette.utilityAction;
    return ColoredBox(
      color: palette.canvas,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          padding: const EdgeInsets.all(20),
          color: blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(children: [
                Icon(Icons.search, size: 26, color: Colors.white),
                SizedBox(width: 6),
                Flexible(
                  child: Text('No results found...',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: blue,
                  minimumSize: const Size(0, 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
                icon: const Icon(Icons.sync, size: 14),
                label: const Text('Reset all filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _emptyStateSummary(LibraryKindRegistration type) {
  final suffix = libraryPresentationForKind(type.kind).emptyStateSummarySuffix;
  return 'Search Collectarr Core, or propose a missing ${type.identity.singularLabel.toLowerCase()}.$suffix';
}
