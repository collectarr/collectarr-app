import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/provider_imports_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// YamTrack-style import sources grid.
///
/// Shows all available import providers in a 2-column grid of cards.
/// Each card has the provider icon, name, description, and an action
/// button (Import / Select CSV File / Coming Soon).
class ImportSourcesPage extends ConsumerWidget {
  const ImportSourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tmdbSettings = ref.watch(tmdbImportSettingsProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.download_outlined, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Import Sources',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Import your collection and tracking data from external services.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 720 ? 2 : 1;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 160,
                  ),
                  itemCount: providerImportDescriptors.length,
                  itemBuilder: (context, index) {
                    final descriptor = providerImportDescriptors[index];
                    return _ImportSourceCard(
                      descriptor: descriptor,
                      tmdbSettings: tmdbSettings,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportSourceCard extends ConsumerWidget {
  const _ImportSourceCard({
    required this.descriptor,
    required this.tmdbSettings,
  });

  final ProviderImportDescriptor descriptor;
  final TmdbImportSettings tmdbSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAvailable =
        descriptor.availability == ProviderImportAvailability.available;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? theme.colorScheme.outline.withValues(alpha: 0.4)
              : theme.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  providerImportIcon(descriptor.id),
                  size: 24,
                  color: isAvailable
                      ? kAppAccent
                      : theme.hintColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    descriptor.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Coming soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              descriptor.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            _ImportSourceAction(
              descriptor: descriptor,
              tmdbSettings: tmdbSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportSourceAction extends ConsumerWidget {
  const _ImportSourceAction({
    required this.descriptor,
    required this.tmdbSettings,
  });

  final ProviderImportDescriptor descriptor;
  final TmdbImportSettings tmdbSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable =
        descriptor.availability == ProviderImportAvailability.available;

    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    // TMDB — the only currently available provider
    if (descriptor.id == ProviderImportId.tmdb) {
      return FilledButton.icon(
        onPressed: () => _openProviderImportsDialog(context, ref),
        icon: const Icon(Icons.import_export_outlined, size: 18),
        label: const Text('Import'),
      );
    }

    // File-only providers
    if (descriptor.supportsFileImport && !descriptor.supportsAccountSync) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.upload_file_outlined, size: 18),
        label: const Text('Select CSV File'),
      );
    }

    // Account sync providers
    return FilledButton.icon(
      onPressed: null,
      icon: const Icon(Icons.sync_outlined, size: 18),
      label: const Text('Import'),
    );
  }

  void _openProviderImportsDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ProviderImportsDialog(
        initialTmdbSettings: tmdbSettings,
      ),
    );
  }
}
