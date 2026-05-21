import 'package:collectarr_app/ui/clz_style.dart';
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
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(color: kClzDivider),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          for (final letter in _letters) _buildLetterChip(letter),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildLetterChip(String letter) {
    final isAll = letter == 'All';
    final isSelected = isAll
        ? selectedLetter == null
        : selectedLetter == letter;
    final isAvailable = isAll || availableLetters.contains(letter);

    return Expanded(
      child: GestureDetector(
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
                  ? Colors.white
                  : isAvailable
                      ? Colors.white60
                      : Colors.white12,
              letterSpacing: 0.5,
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
      if (title.isEmpty) continue;
      final first = title[0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(first)) {
        letters.add(first);
      } else {
        letters.add('#');
      }
    }
    return letters;
  }

  /// Filter items by selected letter. Returns true if the item matches.
  static bool matchesLetter(String title, String letter) {
    if (title.isEmpty) return letter == '#';
    final first = title[0].toUpperCase();
    if (letter == '#') {
      return !RegExp(r'[A-Z]').hasMatch(first);
    }
    return first == letter;
  }
}
