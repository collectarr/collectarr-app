import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class LibraryMetaChip extends StatelessWidget {
  const LibraryMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
  });

  final IconData icon;
  final String label;
  final Color accent;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: borderRadius ?? kAppRadiusSmall,
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: accent,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String genericLibraryStatusLabel(LibraryProjectionRuntime item) {
  final kind = item.source.catalogItem?.kind ?? '';
  final labels = collectarrLibraryTypes
          .byKind(catalogMediaKindFromValue(kind))
          ?.presentation
          .statusLabels ??
      const LibraryStatusLabels();
  if (item.source.isOwned) {
    return labels.owned;
  }
  if (item.source.isTracked) {
    return labels.tracked;
  }
  if (item.source.isWishlisted) {
    return labels.wishlist;
  }
  return labels.localCatalog;
}

String genericLibraryDash(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}
