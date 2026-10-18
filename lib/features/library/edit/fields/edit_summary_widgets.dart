import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';

// Badges, pills and summary panels of library edit dialogs.

class EditMiniBadge extends StatelessWidget {
  const EditMiniBadge(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = color ?? palette.accent;
    final background = Color.alphaBlend(
      accent.withValues(alpha: 0.14),
      palette.surface,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: accent.withValues(alpha: 0.34),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: libraryAccentTextColor(accent, background),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Value context chip (icon + label: value)
// ---------------------------------------------------------------------------

class ValueContextChip extends StatelessWidget {
  const ValueContextChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.surfaceBright),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: p.accent),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.fieldLabel.copyWith(
                  color: p.textMuted,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.controlText.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class SoldSummaryPanel extends StatelessWidget {
  const SoldSummaryPanel({
    super.key,
    required this.pricePaidCents,
    required this.sellPriceCents,
    required this.currency,
  });

  final int? pricePaidCents;
  final int? sellPriceCents;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final symbol = normalizedCurrency == 'EUR'
        ? '€'
        : normalizedCurrency == 'GBP'
            ? '£'
            : r'$';
    final paid = pricePaidCents;
    final sold = sellPriceCents;
    final profitCents = (paid != null && sold != null) ? sold - paid : null;
    final profitLabel = profitCents == null
        ? '—'
        : '${profitCents >= 0 ? '+' : ''}$symbol${(profitCents / 100).toStringAsFixed(2)}';
    final profitColor = profitCents == null || profitCents == 0
        ? appPalette(context).textMuted
        : profitCents > 0
            ? const Color(0xFF4CAF50)
            : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appPalette(context).field,
        border: Border.all(color: appPalette(context).divider),
      ),
      child: Row(
        children: [
          ValueContextChip(
            icon: Icons.payments_outlined,
            label: 'Paid',
            value: paid == null
                ? '—'
                : '$symbol${(paid / 100).toStringAsFixed(2)}',
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward,
              size: 14, color: appPalette(context).textMuted),
          const SizedBox(width: 6),
          ValueContextChip(
            icon: Icons.sell_outlined,
            label: 'Sold for',
            value: sold == null
                ? '—'
                : '$symbol${(sold / 100).toStringAsFixed(2)}',
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward,
              size: 14, color: appPalette(context).textMuted),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: appPalette(context).panel,
              border: Border.all(color: profitColor),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profitCents == null || profitCents == 0
                      ? Icons.remove
                      : profitCents > 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                  size: 14,
                  color: profitColor,
                ),
                const SizedBox(width: 5),
                Text(
                  profitLabel,
                  style: TextStyle(
                    color: profitColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer readonly / editable field
// ---------------------------------------------------------------------------

class FooterReadonlyField extends StatelessWidget {
  const FooterReadonlyField({
    super.key,
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: 48,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kAppPanel,
          border: Border.all(color: kAppSurfaceBright),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.informationalText.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              Text(
                display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.controlText.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditSummaryPill extends StatelessWidget {
  const EditSummaryPill({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.width,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kAppField,
        border: Border.all(color: kEditDivider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: kEditChartBar),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.fieldLabel.copyWith(
                        color: kEditTextMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '-' : value.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.controlText.copyWith(
                        color: appPalette(context).textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (width == null) {
      return body;
    }
    return SizedBox(width: width, child: body);
  }
}

// ---------------------------------------------------------------------------
// Issue / number badge pill
// ---------------------------------------------------------------------------

class IssuePill extends StatelessWidget {
  const IssuePill({super.key, required this.label, this.color = kEditAccent});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = appContrastingTextColor(color);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.controlText.copyWith(
                color: foreground,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utility parse functions shared across edit dialogs
// ---------------------------------------------------------------------------

String formatDate(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
