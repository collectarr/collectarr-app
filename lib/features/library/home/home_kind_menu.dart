import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MediaLibraryKindMenu extends StatelessWidget {
  const MediaLibraryKindMenu({
    super.key,
    required this.types,
    required this.registry,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final LibraryKindRegistry registry;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PopupMenuButton<CatalogMediaType>(
      key: const Key('nav.library-kind-picker'),
      tooltip: 'Switch library',
      color: palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.32),
      elevation: 10,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      constraints: const BoxConstraints(minWidth: 164, maxWidth: 230),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: palette.divider),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final type in types)
          PopupMenuItem(
            key: ValueKey('library-kind-picker-item-${type.kind}'),
            value: type,
            height: kLibraryToolbarPopupItemHeight,
            padding: EdgeInsets.zero,
            child: _KindMenuRow(
              type: type,
              icon: registry.tryGet(type.mediaKind)?.identity.icon ??
                  libraryIconForKind(type.mediaKind),
            ),
          ),
      ],
      icon: const Icon(Icons.apps_rounded),
      iconSize: 19,
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
    );
  }
}

class _KindMenuRow extends StatelessWidget {
  const _KindMenuRow({
    required this.type,
    required this.icon,
  });

  final CatalogMediaType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.mediaKind);
    final palette = appPalette(context);
    return SizedBox(
      height: kLibraryToolbarPopupItemHeight,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(3),
            ),
            child: SizedBox.square(
              dimension: 25,
              child: Icon(icon, size: 16, color: accent),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              type.pluralLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
