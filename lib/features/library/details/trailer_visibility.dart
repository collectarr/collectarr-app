import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves preferences for the displayed item, independently of navigation.
class LibraryTrailerVisibility extends ConsumerWidget {
  const LibraryTrailerVisibility(
      {super.key, required this.kind, required this.child});
  final CatalogMediaKind kind;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(kindSettingsProvider).when(
            data: (settings) => (collectarrKindSettings[kind]
                        ?.resolve(settings, trailerVideosSetting, kind)
                        .value ??
                    false)
                ? child
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          );
}
