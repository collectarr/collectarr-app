import 'package:collectarr_app/features/library/workspace/config/library_shelf_style.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_shelf_backdrop.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryShelfStyleDropdown extends ConsumerWidget {
  const LibraryShelfStyleDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(libraryShelfStyleProvider).value ??
        LibraryShelfStyle.woodLight;
    final accent = LibraryAccentScope.accentOf(context);
    Widget preview(LibraryShelfStyle style) => SizedBox(
        width: 28,
        height: 18,
        child: LibraryShelfBackdrop(
          style: style,
          color: style.background,
          shelfPitch: 18,
          child: const SizedBox.expand(),
        ));
    return PopupMenuButton<LibraryShelfStyle>(
      tooltip: 'Shelf Style',
      position: PopupMenuPosition.under,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      color: libraryToolbarMenuSurface(context),
      surfaceTintColor: Colors.transparent,
      shape: libraryToolbarDropdownMenuShape(context),
      onSelected: ref.read(libraryShelfStyleProvider.notifier).select,
      itemBuilder: (context) => [
        for (final style in LibraryShelfStyle.values)
          PopupMenuItem(
            value: style,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: LibraryWorkspaceMenuRow(
              padding: EdgeInsets.zero,
              leading: preview(style),
              label: style.label,
              textStyle: TextStyle(
                  fontSize: 14,
                  color: style == current ? accent : Colors.white),
              trailing: style == current
                  ? Icon(AppIcons.check, size: 14, color: accent)
                  : null,
            ),
          ),
      ],
      child: LibraryToolbarHoverSurface(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            preview(current),
            const SizedBox(width: 5),
            const Icon(AppIcons.chevronDown, size: 12),
          ]),
        ),
      ),
    );
  }
}
