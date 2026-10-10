import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAlphaJumpBar extends StatelessWidget {
  const LibraryAlphaJumpBar({
    super.key,
    required this.availableLetters,
    required this.selectedLetter,
    required this.accent,
    required this.onLetterSelected,
  });

  final Set<String> availableLetters;
  final String? selectedLetter;
  final Color accent;
  final ValueChanged<String?> onLetterSelected;

  static const _letters = [
    'All',
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
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          bottom: BorderSide(color: palette.divider),
        ),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final minimumWidth =
            560 * MediaQuery.textScalerOf(context).scale(11) / 11;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < minimumWidth
                ? minimumWidth
                : constraints.maxWidth,
            child: Row(children: [
              const SizedBox(width: 6),
              for (final letter in _letters) _buildLetterChip(context, letter),
              const SizedBox(width: 6),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildLetterChip(BuildContext context, String letter) {
    final isAll = letter == 'All';
    final isSelected =
        isAll ? selectedLetter == null : selectedLetter == letter;
    final isAvailable = isAll || availableLetters.contains(letter);

    return Flexible(
      flex: isAll || letter == '0-9' ? 2 : 1,
      child: _JumpBarLetterChip(
        letter: letter,
        isAll: isAll,
        isSelected: isSelected,
        isAvailable: isAvailable,
        accent: accent,
        onTap: isAvailable ? () => onLetterSelected(isAll ? null : letter) : null,
      ),
    );
  }

  /// Compute the set of available first-letters from a list of titles.
  static Set<String> lettersFromTitles(Iterable<String> titles) {
    final letters = <String>{};
    for (final title in titles) {
      final letter = normalizedLetterForTitle(title);
      if (letter != null) {
        letters.add(letter);
      }
    }
    return letters;
  }

  static String? normalizedLetterForTitle(String title) {
    final trimmedTitle = title.trimLeft();
    if (trimmedTitle.isEmpty) {
      return null;
    }
    final first = trimmedTitle[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(first)) {
      return first;
    }
    if (RegExp(r'[0-9]').hasMatch(first)) {
      return '0-9';
    }
    return '#';
  }

  /// Filter items by selected letter. Returns true if the item matches.
  static bool matchesLetter(String title, String letter) {
    return normalizedLetterForTitle(title) == letter;
  }
}

class _JumpBarLetterChip extends StatefulWidget {
  const _JumpBarLetterChip({
    required this.letter,
    required this.isAll,
    required this.isSelected,
    required this.isAvailable,
    required this.accent,
    required this.onTap,
  });

  final String letter;
  final bool isAll;
  final bool isSelected;
  final bool isAvailable;
  final Color accent;
  final VoidCallback? onTap;

  @override
  State<_JumpBarLetterChip> createState() => _JumpBarLetterChipState();
}

class _JumpBarLetterChipState extends State<_JumpBarLetterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isSelected = widget.isSelected;
    final isAvailable = widget.isAvailable;
    final canTap = widget.onTap != null;

    final bgColor = isSelected
        ? widget.accent.withValues(alpha: 0.35)
        : _hovered && isAvailable
            ? (palette.isDark
                ? const Color(0x33FFFFFF)
                : const Color(0x1A000000))
            : null;

    final textColor = isSelected
        ? widget.accent
        : _hovered && isAvailable
            ? palette.textPrimary
            : isAvailable
                ? palette.textMuted.withValues(alpha: 0.85)
                : palette.textMuted.withValues(alpha: 0.35);

    return MouseRegion(
      cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: widget.accent, width: 2),
                  )
                : null,
          ),
          child: Text(
            widget.letter,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: widget.isAll ? 10 : 11,
              fontWeight: isSelected || _hovered ? FontWeight.w700 : FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
