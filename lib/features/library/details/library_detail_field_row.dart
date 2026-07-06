import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDetailFieldRow extends StatelessWidget {
  const LibraryDetailFieldRow({
    super.key,
    required this.field,
    this.labelWidth = 92,
    this.density,
  });

  final LibraryDetailField field;
  final double labelWidth;
  final LibraryDensity? density;

  @override
  Widget build(BuildContext context) {
    final resolvedDensity = density ?? LibraryDensityScope.of(context);
    final resolvedVerticalPadding = switch (resolvedDensity) {
      LibraryDensity.comfortable => 2.0,
      LibraryDensity.compact => 1.5,
      LibraryDensity.dense => 1.0,
    };
    final resolvedLabelWidth = switch (resolvedDensity) {
      LibraryDensity.comfortable => labelWidth,
      LibraryDensity.compact => labelWidth * 0.95,
      LibraryDensity.dense => labelWidth * 0.9,
    };
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context);
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: resolvedVerticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: resolvedLabelWidth,
            child: Text(
              field.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: field.onTap != null && field.value.isNotEmpty && field.value != '-'
                ? Tooltip(
                    message: field.tooltip ?? 'Show all with ${field.value}',
                    child: InkWell(
                      onTap: field.onTap,
                      borderRadius: BorderRadius.circular(4),
                      mouseCursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                field.value,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: onSurfaceColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          accent.withValues(alpha: 0.32),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.filter_alt_outlined,
                                size: 14, color: palette.textMuted),
                          ],
                        ),
                      ),
                    ),
                  )
                : Text(
                    field.value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}
