import 'package:collectarr_app/features/library/ui/library_section_state_message.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Shared edit-dialog building blocks used by both the comics-specific and
// the generic library edit dialogs.
// ---------------------------------------------------------------------------

const Color kEditAccent = kAppAccent;
const Color kEditPanel = kAppPanel;
const Color kEditPanelRaised = kAppPanelRaised;
const Color kEditToolbar = kAppToolbar;
const Color kEditDivider = kAppDivider;
const Color kEditTextMuted = kAppTextMuted;
const Color kEditChartBar = kAppAccentLight;
const Color kEditValueChip = kAppPanel;
const Color kEditValueChipBorder = kAppSurfaceBright;
const BorderRadius kEditMenuBorderRadius = kAppMenuBorderRadius;

/// Theme preset for edit dialogs – resolves from [palette] for light/dark.
ThemeData editDialogTheme({
  Color? seedColor,
  AppThemePalette palette = kDefaultAppThemePalette,
  bool compactDesktop = false,
}) {
  final accent = seedColor ?? palette.accent;
  final base = palette.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    extensions: [palette],
    visualDensity: VisualDensity.compact,
    canvasColor: palette.panel,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: palette.brightness,
      surface: palette.panel,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: palette.divider),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: palette.textPrimary),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: kAppMenuBorderRadius,
        side: BorderSide(color: palette.divider),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(palette.panelRaised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: kAppMenuBorderRadius,
            side: BorderSide(color: palette.divider),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: compactDesktop ? 8 : 9,
        vertical: compactDesktop ? 6 : 7,
      ),
      floatingLabelBehavior: compactDesktop
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: palette.textMuted,
        fontSize: compactDesktop ? 12 : null,
      ),
      floatingLabelStyle: TextStyle(
        color: accent,
        fontSize: compactDesktop ? 12 : null,
        fontWeight: compactDesktop ? FontWeight.w700 : null,
      ),
      hintStyle: TextStyle(
        color: palette.textMuted.withValues(alpha: 0.7),
        fontSize: compactDesktop ? 12 : null,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: palette.divider),
        borderRadius: BorderRadius.circular(2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.divider),
        borderRadius: BorderRadius.circular(2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    ),
    datePickerTheme: buildAppDatePickerTheme(
      palette: palette,
      accent: accent,
      surface: palette.panel,
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
        final palette = appPalette(context);
        final scrollContent = DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            border: Border(
              top: const BorderSide(color: Colors.transparent),
              left: BorderSide(color: palette.divider),
              right: BorderSide(color: palette.divider),
              bottom: BorderSide(color: palette.divider),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        );
        if (cover == null || constraints.maxWidth < 720) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: scrollContent,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 188,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: appPalette(context).surface,
                border: Border(
                    right: BorderSide(color: appPalette(context).divider)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 2 / 3, child: cover!),
                    ),
                  ),
                  if (constraints.maxHeight >= 430) ...[
                    const SizedBox(height: 8),
                    const EditMiniBadge('Local item'),
                    const SizedBox(height: 6),
                    const Text(
                      'Personal fields stay on this device or your sync service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kEditTextMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: scrollContent,
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}

class EditSectionStateMessage extends LibrarySectionStateMessage {
  const EditSectionStateMessage({
    super.key,
    required super.message,
    super.icon,
  });
}

class EditSectionLoadingState extends StatelessWidget {
  const EditSectionLoadingState({
    super.key,
    this.message = 'Loading…',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 3),
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
              const SizedBox(width: 6),
              children[i + 1],
            ],
          ],
        ),
      );
      if (i + 2 < children.length) {
        rows.add(const SizedBox(height: 6));
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
        color: (color ?? appPalette(context).accent).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: (color ?? appPalette(context).accent).withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: color ?? appPalette(context).accent,
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
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> kLibraryCurrencyCodes = <String>[
  'USD',
  'EUR',
  'GBP',
  'RON',
  'CHF',
  'JPY',
  'CAD',
  'AUD',
  'NZD',
  'SEK',
  'NOK',
  'DKK',
  'PLN',
  'CZK',
  'HUF',
  'TRY',
  'INR',
  'BRL',
  'MXN',
];

String libraryCurrencySymbol(String? currency) {
  final normalized = currency?.trim().toUpperCase() ?? '';
  return switch (normalized) {
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'RON' => 'lei',
    'CHF' => 'CHF',
    'JPY' => '¥',
    'CAD' => r'$',
    'AUD' => r'$',
    'NZD' => r'$',
    'SEK' => 'kr',
    'NOK' => 'kr',
    'DKK' => 'kr',
    'PLN' => 'zł',
    'CZK' => 'Kč',
    'HUF' => 'Ft',
    'TRY' => '₺',
    'INR' => '₹',
    'BRL' => 'R\$',
    'MXN' => r'$',
    _ when normalized.isNotEmpty => normalized,
    _ => '¤',
  };
}

class LibraryCurrencyField extends StatelessWidget {
  const LibraryCurrencyField({
    super.key,
    required this.controller,
    this.label = 'Currency',
    this.enabled = true,
    this.onChanged,
    this.currencyCodes = kLibraryCurrencyCodes,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final ValueChanged<String?>? onChanged;
  final List<String> currencyCodes;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final normalized = value.text.trim().toUpperCase();
        final items = <String>{
          for (final code in currencyCodes) code.trim().toUpperCase(),
          if (normalized.isNotEmpty) normalized,
        }.toList(growable: false);
        return DropdownButtonFormField<String>(
          key: ValueKey(normalized.isEmpty ? 'currency-empty' : normalized),
          isExpanded: true,
          initialValue: normalized.isEmpty ? null : normalized,
          dropdownColor: appPalette(context).panelRaised,
          borderRadius: kEditMenuBorderRadius,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final code in items)
              DropdownMenuItem<String>(
                value: code,
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        libraryCurrencySymbol(code),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(child: Text(code)),
                  ],
                ),
              ),
          ],
          onChanged: enabled
              ? (selected) {
                  final next = selected?.trim().toUpperCase() ?? '';
                  if (controller.text != next) {
                    controller.text = next;
                  }
                  onChanged?.call(selected);
                }
              : null,
        );
      },
    );
  }
}

class LibraryDateFieldButton extends StatefulWidget {
  const LibraryDateFieldButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  State<LibraryDateFieldButton> createState() => _LibraryDateFieldButtonState();
}

class _LibraryDateFieldButtonState extends State<LibraryDateFieldButton> {
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;
  DateTime? _lastEmittedValue;

  @override
  void initState() {
    super.initState();
    final initial = widget.value?.toLocal();
    _yearController = TextEditingController(
      text: initial?.year.toString() ?? '',
    );
    _monthController = TextEditingController(
      text: initial?.month.toString().padLeft(2, '0') ?? '',
    );
    _dayController = TextEditingController(
      text: initial?.day.toString().padLeft(2, '0') ?? '',
    );
    _lastEmittedValue = widget.value;
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LibraryDateFieldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) {
      return;
    }
    _syncFromValue(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final labelStyle =
        Theme.of(context).inputDecorationTheme.floatingLabelStyle ??
            TextStyle(
              color: palette.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: SizedBox(
                  height: 38,
                  child: Row(
                    children: [
                      Expanded(
                        child: _datePartField(
                          controller: _yearController,
                          hintText: 'YYYY',
                        ),
                      ),
                      _separator(palette),
                      Expanded(
                        child: _datePartField(
                          controller: _monthController,
                          hintText: 'MM',
                        ),
                      ),
                      _separator(palette),
                      Expanded(
                        child: _datePartField(
                          controller: _dayController,
                          hintText: 'DD',
                        ),
                      ),
                      _separator(palette),
                      IconButton(
                        tooltip: 'Pick with calendar',
                        onPressed: _pickWithCalendar,
                        icon: const Icon(Icons.calendar_today, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(widget.label, style: labelStyle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _datePartField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (_) {
        _emitValueIfPossible();
      },
    );
  }

  Future<void> _pickWithCalendar() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? widget.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      _syncFromValue(picked);
      widget.onChanged(picked);
    }
  }

  DateTime? get _selectedDate {
    final yearText = _yearController.text.trim();
    final monthText = _monthController.text.trim();
    final dayText = _dayController.text.trim();
    if (yearText.isEmpty && monthText.isEmpty && dayText.isEmpty) {
      return null;
    }
    final year = int.tryParse(yearText);
    final month = int.tryParse(monthText);
    final day = int.tryParse(dayText);
    if (year == null || month == null || day == null) {
      return null;
    }
    final picked = DateTime(year, month, day);
    if (picked.year != year || picked.month != month || picked.day != day) {
      return null;
    }
    return picked;
  }

  void _syncFromValue(DateTime? value) {
    final local = value?.toLocal();
    _yearController.text = local?.year.toString() ?? '';
    _monthController.text = local?.month.toString().padLeft(2, '0') ?? '';
    _dayController.text = local?.day.toString().padLeft(2, '0') ?? '';
    _lastEmittedValue = value;
  }

  void _emitValueIfPossible() {
    final rawYear = _yearController.text.trim();
    final rawMonth = _monthController.text.trim();
    final rawDay = _dayController.text.trim();
    if (rawYear.isEmpty && rawMonth.isEmpty && rawDay.isEmpty) {
      if (_lastEmittedValue != null) {
        _lastEmittedValue = null;
        widget.onChanged(null);
      }
      return;
    }
    final selected = _selectedDate;
    if (selected != null && selected != _lastEmittedValue) {
      _lastEmittedValue = selected;
      widget.onChanged(selected);
      return;
    }
    if (selected == null) {
      return;
    }
  }

  Widget _separator(AppThemePalette palette) {
    return Container(width: 1, height: 26, color: palette.divider);
  }
}

Future<DateTime?> showLibraryDateEntryDialog(
  BuildContext context, {
  required String label,
  DateTime? initialDate,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: DateTime(1900),
    lastDate: DateTime(now.year + 10),
  );
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
                  style: const TextStyle(
                    color: kEditTextMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '-' : value.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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

class EditTokenListField extends StatefulWidget {
  const EditTokenListField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  State<EditTokenListField> createState() => _EditTokenListFieldState();
}

class _EditTokenListFieldState extends State<EditTokenListField> {
  late final TextEditingController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = TextEditingController();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  List<String> get _tokens => widget.controller.text
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);

  void _setTokens(List<String> values) {
    widget.controller.text = values.join(', ');
    setState(() {});
  }

  void _addCurrentToken() {
    final token = _entryController.text.trim();
    if (token.isEmpty) {
      return;
    }
    final values = _tokens.toList(growable: true);
    final exists = values.any(
      (value) => value.toLowerCase() == token.toLowerCase(),
    );
    if (!exists) {
      values.add(token);
      _setTokens(values);
    }
    _entryController.clear();
  }

  void _removeToken(String token) {
    final values = _tokens
        .where((value) => value.toLowerCase() != token.toLowerCase())
        .toList(growable: false);
    _setTokens(values);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _tokens;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        alignLabelWithHint: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final token in tokens)
                InputChip(
                  label: Text(token),
                  onDeleted: () => _removeToken(token),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: kAppPanel,
                  side: const BorderSide(color: kEditDivider),
                  deleteIconColor: kEditTextMuted,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (tokens.isEmpty)
                const Text(
                  'No values yet',
                  style: TextStyle(color: kEditTextMuted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _entryController,
                  onSubmitted: (_) => _addCurrentToken(),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Add value',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _addCurrentToken,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ],
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

double? parseDouble(String value) {
  final normalized = emptyToNull(value)?.replaceAll(',', '.');
  return normalized == null ? null : double.tryParse(normalized);
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

String? optionalNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized) == null ? 'Enter a number' : null;
}

String? positiveIntValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final parsed = int.tryParse(value.trim());
  return parsed == null || parsed < 1 ? 'Enter a positive number' : null;
}

String? optionalPositiveIntValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value.trim());
  return parsed == null || parsed < 0 ? 'Enter a positive number' : null;
}

String? optionalMoneyValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized) == null
      ? 'Enter a valid price, for example 3.99'
      : null;
}
