import 'package:collectarr_app/ui/adaptive/mobile_metrics.dart';
import 'package:collectarr_app/features/library/workspace/config/view_enums.dart';
import 'package:collectarr_app/features/library/workspace/mobile/mobile_view_mode.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The toolbar button showing the current presentation, opening the short list
/// of the three phone presentations.
class LibraryMobileViewMenu extends StatelessWidget {
  const LibraryMobileViewMenu({
    super.key,
    required this.viewMode,
    required this.background,
    required this.onChanged,
  });

  final LibraryViewMode viewMode;
  final Color background;
  final ValueChanged<LibraryViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = LibraryMobileViewMode.from(viewMode);
    final palette = appPalette(context);
    return PopupMenuButton<LibraryMobileViewMode>(
      key: const Key('library.mobile-views'),
      tooltip: 'Change view',
      initialValue: current,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      onSelected: (mode) => onChanged(mode.workspaceMode),
      itemBuilder: (_) => [
        for (final mode in LibraryMobileViewMode.values)
          PopupMenuItem(
            key: ValueKey('mobile_view_${mode.name}'),
            value: mode,
            child: Row(children: [
              Icon(mode.icon,
                  color: mode == current
                      ? palette.utilityAction
                      : palette.textPrimary),
              const SizedBox(width: 12),
              Text(mode.label),
            ]),
          ),
      ],
      child: Container(
        width: kMobileToolbarButtonSize,
        height: kMobileToolbarButtonSize,
        margin: const EdgeInsets.symmetric(
            vertical: (kMobileToolbarHeight - kMobileToolbarButtonSize) / 2),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(5)),
        child: Icon(current.icon,
            size: kMobileToolbarIconSize, color: palette.textPrimary),
      ),
    );
  }
}

/// The alphabet filter as one toolbar button: the phone toolbar has a single
/// row, as in the reference, so the desktop's letter bar has no place on it.
class LibraryMobileAlphabetButton extends StatelessWidget {
  const LibraryMobileAlphabetButton({
    super.key,
    required this.letters,
    required this.alphabet,
    required this.selectedLetter,
    required this.background,
    required this.onLetterSelected,
  });

  final Set<String> letters;
  final List<String> alphabet;
  final String? selectedLetter;
  final Color background;
  final ValueChanged<String?> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    final available =
        letters.map((letter) => letter.trim().toUpperCase()).toSet();
    final palette = appPalette(context);
    return PopupMenuButton<String>(
      key: const Key('library.mobile-alphabet'),
      tooltip: 'Filter A–Z',
      popUpAnimationStyle: AnimationStyle.noAnimation,
      onSelected: (value) => onLetterSelected(
          value == 'All' || value == selectedLetter ? null : value),
      itemBuilder: (_) => [
        for (final label in ['All', ...alphabet])
          PopupMenuItem(
            value: label,
            height: 36,
            enabled: label == 'All' || available.contains(label),
            child: Text(label,
                style: TextStyle(
                    fontWeight: label == (selectedLetter ?? 'All')
                        ? FontWeight.w700
                        : FontWeight.w500)),
          ),
      ],
      child: Container(
        width: kMobileToolbarButtonSize,
        height: kMobileToolbarButtonSize,
        margin: const EdgeInsets.symmetric(
            vertical: (kMobileToolbarHeight - kMobileToolbarButtonSize) / 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(5)),
        child: selectedLetter == null
            ? Icon(Icons.filter_alt_outlined,
                size: kMobileToolbarIconSize, color: palette.textPrimary)
            : Text(selectedLetter!,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: palette.utilityAction)),
      ),
    );
  }
}

/// The cover size slider above the Images view, as in the reference.
class LibraryMobileCoverSizeSlider extends StatelessWidget {
  const LibraryMobileCoverSizeSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: palette.utilityAction,
        inactiveTrackColor: palette.utilityAction.withValues(alpha: .3),
        thumbColor: palette.utilityAction,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Slider(
          key: const Key('library.mobile-cover-size'),
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
