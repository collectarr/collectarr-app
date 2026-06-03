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
      child: Row(
        children: [
          const SizedBox(width: 6),
          for (final letter in _letters) _buildLetterChip(context, letter),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildLetterChip(BuildContext context, String letter) {
    final palette = appPalette(context);
    final isAll = letter == 'All';
    final isSelected = isAll
        ? selectedLetter == null
        : selectedLetter == letter;
    final isAvailable = isAll || availableLetters.contains(letter);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable
              ? () => onLetterSelected(isAll ? null : letter)
              : null,
          child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.35) : null,
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: accent, width: 2),
                  )
                : null,
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: isAll ? 10 : 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? accent
                  : isAvailable
                      ? palette.textMuted.withValues(alpha: 0.85)
                      : palette.textMuted.withValues(alpha: 0.35),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ),
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
