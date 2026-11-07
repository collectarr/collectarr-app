import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'alphabet_options.dart';

/// The letter buckets every library's alphabet filter offers.
const libraryToolbarAlphabet = [
  '#',
  '0-9',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z'
];

class LibraryToolbarAlphabetRow extends StatelessWidget {
  const LibraryToolbarAlphabetRow(
      {super.key,
      required this.letters,
      required this.selectedLetter,
      this.alphabetOptions,
      required this.accent,
      required this.onLetterSelected});
  final Set<String> letters;
  final String? selectedLetter;
  final LibraryAlphabetOptions? alphabetOptions;
  final Color accent;
  final ValueChanged<String?> onLetterSelected;
  @override
  Widget build(BuildContext context) {
    final available =
        letters.map((letter) => letter.trim().toUpperCase()).toSet();
    // Reference slot widths at 14 px: letters 24, All 32, 0-9 34.
    double slotWidth(String label) => switch (label) {
          'All' => 32,
          '0-9' => 34,
          _ => 24,
        };
    final designWidth = ['All', ...libraryToolbarAlphabet]
        .fold<double>(0, (sum, l) => sum + slotWidth(l));
    void select(String value) => onLetterSelected(
        value == 'All' || value == selectedLetter ? null : value);
    final palette = appPalette(context);
    return SizedBox(
        height: 30,
        child: LayoutBuilder(builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
          // With a single field there is nothing to choose: no button and
          // no divider.
          final options =
              alphabetOptions != null && alphabetOptions!.fields.length > 1
                  ? alphabetOptions
                  : null;
          final optionsWidth = options == null ? 0.0 : 46.0;
          if (constraints.maxWidth < 480 * scale) {
            return Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  popUpAnimationStyle: AnimationStyle.noAnimation,
                  tooltip: 'Filter A–Z',
                  onSelected: select,
                  itemBuilder: (_) => [
                    for (final label in ['All', ...libraryToolbarAlphabet])
                      PopupMenuItem(
                          value: label,
                          height: 30,
                          enabled: label == 'All' || available.contains(label),
                          child: Text(label,
                              style: TextStyle(
                                  fontWeight: label == (selectedLetter ?? 'All')
                                      ? FontWeight.w700
                                      : FontWeight.w400)))
                  ],
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.filter_alt, size: 17),
                        const SizedBox(width: 4),
                        Text(selectedLetter ?? 'A–Z',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const Icon(Icons.expand_more, size: 16)
                      ])),
                ));
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final label in ['All', ...libraryToolbarAlphabet])
                _AlphabetLetterButton(
                  label: label,
                  width: slotWidth(label) *
                      scale *
                      ((constraints.maxWidth - optionsWidth) /
                              (designWidth * scale))
                          .clamp(0.0, 1.0),
                  // As in the reference, only a chosen letter is highlighted;
                  // All stays plain text.
                  isSelected: label != 'All' && label == selectedLetter,
                  isAvailable: label == 'All' || available.contains(label),
                  accent: palette.utilityAction,
                  palette: palette,
                  onTap: label == 'All' || available.contains(label)
                      ? () => select(label)
                      : null,
                ),
              if (options != null) ...[
                // The reference rules the options button off from the letters.
                const SizedBox(width: 4),
                SizedBox(
                    width: 1,
                    height: 30,
                    child: ColoredBox(
                        color: palette.isDark
                            ? const Color(0xFF262626)
                            : palette.divider)),
                const SizedBox(width: 5),
                PopupMenuButton<String>(
                  popUpAnimationStyle: AnimationStyle.noAnimation,
                  tooltip: 'Alphabet Options',
                  position: PopupMenuPosition.under,
                  color: palette.isDark
                      ? const Color(0xff444444)
                      : palette.panelRaised,
                  surfaceTintColor: Colors.transparent,
                  menuPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: palette.divider)),
                  onSelected: options.onChanged,
                  itemBuilder: (_) => [
                    for (final field in options.fields)
                      PopupMenuItem(
                          value: field.id,
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(
                                width: 18,
                                child: field.id == options.selected.id
                                    ? const Icon(AppIcons.check, size: 14)
                                    : null),
                            Text(field.label,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ])),
                  ],
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                          width: 36,
                          height: 28,
                          child: Icon(AppIcons.settings,
                              size: 14, color: palette.textPrimary))),
                ),
              ],
            ],
          );
        }));
  }
}

class _AlphabetLetterButton extends StatefulWidget {
  const _AlphabetLetterButton({
    required this.label,
    required this.isSelected,
    required this.isAvailable,
    required this.accent,
    required this.palette,
    required this.onTap,
    required this.width,
  });

  final String label;
  final bool isSelected;
  final bool isAvailable;
  final Color accent;
  final AppThemePalette palette;
  final VoidCallback? onTap;
  final double width;

  @override
  State<_AlphabetLetterButton> createState() => _AlphabetLetterButtonState();
}

class _AlphabetLetterButtonState extends State<_AlphabetLetterButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isAvailable = widget.isAvailable;
    final canTap = widget.onTap != null;

    final textColor = isSelected
        ? Colors.white
        : _hovered && isAvailable
            ? Colors.white
            : isAvailable
                ? widget.palette.textPrimary
                : widget.palette.textMuted.withValues(alpha: 0.25);

    final bgColor = isSelected
        ? (_hovered && canTap
            ? Color.lerp(widget.accent, Colors.white, 0.12)!
            : widget.accent)
        : _hovered && isAvailable
            ? (widget.palette.isDark
                ? const Color(0xFF464950)
                : widget.palette.panelRaised)
            : Colors.transparent;

    return SizedBox(
      width: widget.width,
      height: 30,
      child: MouseRegion(
        cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          mouseCursor:
              canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onTap: widget.onTap,
          // Selected and hovered letters share the reference's 5 px pill.
          borderRadius: BorderRadius.circular(5),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              // Labels never wrap ("0-9") when the bar is squeezed.
              child: Text(
                widget.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 14,
                  // The reference keeps every letter regular, also when
                  // chosen or hovered.
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
