import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Shared edit-dialog building blocks used by both the comics-specific and
// the generic library edit dialogs.
// ---------------------------------------------------------------------------

const Color kEditAccent = kClzAccent;
const Color kEditPanel = kClzPanel;
const Color kEditPanelRaised = kClzPanelRaised;
const Color kEditToolbar = kClzToolbar;
const Color kEditDivider = kClzDivider;
const Color kEditTextMuted = kClzTextMuted;
const Color kEditChartBar = Color(0xFF7EDAF3);
const Color kEditValueChip = Color(0xFF1B1B1B);
const Color kEditValueChipBorder = Color(0xFF3A3A3A);

/// Dark theme preset for edit dialogs.
ThemeData editDialogTheme({Color seedColor = kEditAccent}) {
  return ThemeData.dark(useMaterial3: true).copyWith(
    visualDensity: VisualDensity.compact,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: kEditPanel,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: kEditPanel,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF101010),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      labelStyle: const TextStyle(color: kEditTextMuted),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: kEditDivider),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kEditDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: seedColor),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tab shell – scrollable content with optional cover sidebar
// ---------------------------------------------------------------------------

class EditTabShell extends StatelessWidget {
  const EditTabShell({super.key, required this.children, this.cover});

  final List<Widget> children;
  final Widget? cover;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = ListView(
          padding: const EdgeInsets.all(14),
          children: children,
        );
        if (cover == null || constraints.maxWidth < 720) {
          return content;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 204,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF101010),
                border: Border(right: BorderSide(color: kEditDivider)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 2 / 3, child: cover!),
                    ),
                  ),
                  if (constraints.maxHeight >= 360) ...[
                    const SizedBox(height: 10),
                    const EditMiniBadge('Local item'),
                    const SizedBox(height: 8),
                    const Text(
                      'Personal fields stay on this device or your sync service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kEditTextMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section card (accent left border)
// ---------------------------------------------------------------------------

class EditSection extends StatelessWidget {
  const EditSection({
    super.key,
    required this.title,
    required this.child,
    this.accent = kEditAccent,
  });

  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF202426),
        border: Border(
          left: BorderSide(color: accent, width: 2),
          top: const BorderSide(color: Color(0xFF3D3D3D)),
          right: const BorderSide(color: Color(0xFF3D3D3D)),
          bottom: const BorderSide(color: Color(0xFF3D3D3D)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab label with icon
// ---------------------------------------------------------------------------

class EditTab extends StatelessWidget {
  const EditTab({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Two-column grid for form fields
// ---------------------------------------------------------------------------

class EditGrid extends StatelessWidget {
  const EditGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        Row(
          children: [
            children[i],
            if (i + 1 < children.length) ...[
              const SizedBox(width: 8),
              children[i + 1],
            ],
          ],
        ),
      );
      if (i + 2 < children.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return Column(children: rows);
  }
}

// ---------------------------------------------------------------------------
// Small badge pill
// ---------------------------------------------------------------------------

class EditMiniBadge extends StatelessWidget {
  const EditMiniBadge(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF0E81A6),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: kEditValueChip,
        border: Border.all(color: kEditValueChipBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kEditChartBar),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(
              color: kEditTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sold summary – Paid → Sold for → Profit/Loss
// ---------------------------------------------------------------------------

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
        ? kEditTextMuted
        : profitCents > 0
            ? const Color(0xFF4CAF50)
            : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border.all(color: kEditDivider),
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
          const Icon(Icons.arrow_forward, size: 14, color: kEditTextMuted),
          const SizedBox(width: 6),
          ValueContextChip(
            icon: Icons.sell_outlined,
            label: 'Sold for',
            value: sold == null
                ? '—'
                : '$symbol${(sold / 100).toStringAsFixed(2)}',
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 14, color: kEditTextMuted),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: kEditValueChip,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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
    return SizedBox(
      width: width,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(color: const Color(0xFF3D3D3D)),
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
                style: const TextStyle(color: kEditTextMuted, fontSize: 10),
              ),
              Text(
                display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FooterTextField extends StatelessWidget {
  const FooterTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.width,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final double width;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Issue pill (comics-specific but placed here for consistency)
// ---------------------------------------------------------------------------

class IssuePill extends StatelessWidget {
  const IssuePill({super.key, required this.label, this.color = kEditAccent});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utility parse functions shared across edit dialogs
// ---------------------------------------------------------------------------

String? emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? parseDate(String value) {
  final normalized = emptyToNull(value);
  return normalized == null ? null : DateTime.tryParse(normalized);
}

int? parseInt(String value) {
  final normalized = emptyToNull(value);
  return normalized == null ? null : int.tryParse(normalized);
}

int? parseMoneyCents(String value, {int? fallback}) {
  final normalized = emptyToNull(value)?.replaceAll(',', '.');
  if (normalized == null) {
    return fallback;
  }
  final parsed = double.tryParse(normalized);
  return parsed == null ? fallback : (parsed * 100).round();
}

String formatDate(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String? optionalDateValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim()) == null ? 'Invalid date' : null;
}

String? optionalIntValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim()) == null ? 'Enter a number' : null;
}

String? positiveIntValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final parsed = int.tryParse(value.trim());
  return parsed == null || parsed < 1 ? 'Enter a positive number' : null;
}

String? optionalMoneyValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized) == null
      ? 'Enter a valid price, for example 3.99'
      : null;
}
