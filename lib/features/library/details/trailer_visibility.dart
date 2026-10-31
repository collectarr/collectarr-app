import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A details-panel trailer section, shown while Settings > Show trailer
/// videos is on.
class LibraryTrailerVisibility extends ConsumerWidget {
  const LibraryTrailerVisibility({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(uiPreferencesProvider).showInspectorTrailers
          ? child
          : const SizedBox.shrink();
}
