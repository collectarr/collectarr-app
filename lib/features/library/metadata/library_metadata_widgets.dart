import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryMetadataCreditsList extends StatelessWidget {
  const LibraryMetadataCreditsList({
    super.key,
    required this.title,
    required this.credits,
    this.onValueTap,
  });

  final String title;
  final List<Map<String, dynamic>> credits;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 4),
        for (final credit in credits)
          _LibraryMetadataCreditRow(
            credit: credit,
            onTap: onValueTap == null ||
                    (credit['name']?.toString().trim().isEmpty ?? true)
                ? null
                : () => onValueTap!(credit['name'].toString().trim()),
          ),
      ],
    );
  }
}

class _LibraryMetadataCreditRow extends StatelessWidget {
  const _LibraryMetadataCreditRow({
    required this.credit,
    this.onTap,
  });

  final Map<String, dynamic> credit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = appPalette(context);
    final content = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: credit['name']?.toString() ?? '?',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: onTap == null ? null : TextDecoration.underline,
              decorationColor: palette.textMuted.withValues(alpha: 0.5),
            ),
          ),
          if (credit['role'] != null)
            TextSpan(
              text: '  ${credit['role']}',
              style: textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: content,
            ),
    );
  }
}