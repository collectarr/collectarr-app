import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryCollectionStatusScopeDropdown extends StatelessWidget {
  const LibraryCollectionStatusScopeDropdown({
    super.key,
    required this.collectionStatusScope,
    required this.onCollectionStatusScopeChanged,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>
      onCollectionStatusScopeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        );
    final menuWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: LibraryCollectionStatusScope.values.map((scope) => scope.label),
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 8,
      trailingWidth: 24,
      horizontalPadding: 24,
      minWidth: 132,
    );
    final triggerWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: [collectionStatusScope.label],
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 8,
      trailingWidth: 24,
      horizontalPadding: 24,
      minWidth: 0,
    );
    return SizedBox(
      width: triggerWidth,
      child: PopupMenuButton<LibraryCollectionStatusScope>(
        key: const Key('collection-status-scope-dropdown'),
        tooltip: 'Collection status scope',
        initialValue: collectionStatusScope,
        onSelected: onCollectionStatusScopeChanged,
        padding: EdgeInsets.zero,
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        position: PopupMenuPosition.under,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: double.infinity,
        ).copyWith(minWidth: menuWidth, maxWidth: menuWidth),
        shape: libraryToolbarDropdownMenuShape(context),
        itemBuilder: (context) => [
          for (final scope in LibraryCollectionStatusScope.values)
            PopupMenuItem<LibraryCollectionStatusScope>(
              value: scope,
              height: kLibraryToolbarTextDropdownHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LibraryCollectionStatusScopeMenuItem(
                scope: scope,
                isSelected: scope == collectionStatusScope,
                accent: accent,
                muted: menuMuted,
                textColor: menuText,
              ),
            ),
        ],
        child: DecoratedBox(
          decoration: libraryToolbarDropdownDecoration(context),
          child: SizedBox(
            height: kLibraryToolbarTextDropdownHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  LibraryCollectionStatusScopeBadge(
                    scope: collectionStatusScope,
                    accent: accent,
                    muted: palette.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      collectionStatusScope.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dropdownTextStyle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryToolbarSortButton extends StatelessWidget {
  const LibraryToolbarSortButton({
    super.key,
    required this.onPressed,
    required this.sortFavorites,
    required this.activeSortFavoriteId,
  });

  final VoidCallback onPressed;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;

  @override
  Widget build(BuildContext context) {
    LibrarySortFavorite? activeFavorite;
    for (final favorite in sortFavorites) {
      if (favorite.id == activeSortFavoriteId) {
        activeFavorite = favorite;
        break;
      }
    }
    return Tooltip(
      message: activeFavorite == null
          ? 'Change sorting'
          : 'Sorting: ${activeFavorite.label}',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.zero,
        child: LibraryToolbarCompactDropdownTrigger(
          icon: activeFavorite?.icon ?? Icons.sort,
        ),
      ),
    );
  }
}

double measureLibraryToolbarDropdownWidth(
  BuildContext context, {
  required Iterable<String> labels,
  required TextStyle? textStyle,
  required double leadingWidth,
  required double leadingSpacing,
  required double trailingWidth,
  required double horizontalPadding,
  required double minWidth,
}) {
  final textDirection = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final painter = TextPainter(
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
  );
  var maxLabelWidth = 0.0;

  for (final label in labels) {
    painter.text = TextSpan(text: label, style: textStyle);
    painter.layout();
    if (painter.width > maxLabelWidth) {
      maxLabelWidth = painter.width;
    }
  }

  return (horizontalPadding +
          leadingWidth +
          leadingSpacing +
          maxLabelWidth +
          trailingWidth)
      .clamp(minWidth, double.infinity);
}

class LibraryCollectionStatusScopeMenuItem extends StatelessWidget {
  const LibraryCollectionStatusScopeMenuItem({
    super.key,
    required this.scope,
    required this.isSelected,
    required this.accent,
    required this.muted,
    required this.textColor,
  });

  final LibraryCollectionStatusScope scope;
  final bool isSelected;
  final Color accent;
  final Color muted;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LibraryWorkspaceMenuRow(
        label: scope.label,
        leading: LibraryCollectionStatusScopeBadge(
          scope: scope,
          accent: accent,
          muted: muted,
        ),
        trailing: isSelected ? Icon(Icons.check, size: 16, color: textColor) : null,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
      ),
    );
  }
}

class LibraryCollectionStatusScopeBadge extends StatelessWidget {
  const LibraryCollectionStatusScopeBadge({
    super.key,
    required this.scope,
    required this.accent,
    required this.muted,
  });

  final LibraryCollectionStatusScope scope;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final color = libraryCollectionStatusScopeColor(scope, accent, muted);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(scope.icon, size: 13, color: Colors.white),
    );
  }
}

Color libraryCollectionStatusScopeColor(
  LibraryCollectionStatusScope scope,
  Color accent,
  Color muted,
) {
  return switch (scope) {
    LibraryCollectionStatusScope.all => muted,
    LibraryCollectionStatusScope.inCollection => accent,
    LibraryCollectionStatusScope.forSale => const Color(0xFF2E7D32),
    LibraryCollectionStatusScope.wishList => const Color(0xFFFF9800),
    LibraryCollectionStatusScope.onOrder => const Color(0xFF0EA5E9),
    LibraryCollectionStatusScope.sold => const Color(0xFFC44B4F),
    LibraryCollectionStatusScope.notInCollection => const Color(0xFF9E9E9E),
  };
}

final RegExp _libraryToolbarLetterPattern = RegExp(r'[A-Z]');

class LibraryToolbarAlphabetRow extends StatelessWidget {
  const LibraryToolbarAlphabetRow({
    super.key,
    required this.letters,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  final Set<String> letters;
  final String? selectedLetter;
  final ValueChanged<String?> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final availableLetters = letters
        .map((letter) => letter.trim().toUpperCase())
        .where(
          (letter) =>
              letter == '#' ||
              letter == '0-9' ||
          (letter.length == 1 &&
            _libraryToolbarLetterPattern.hasMatch(letter)),
        )
        .toSet();
    const alphabet = [
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

    Widget buildLetterButton({
      required String label,
      required bool selected,
      required bool enabled,
      required VoidCallback? onTap,
    }) {
      final foreground = selected
          ? Colors.white
          : enabled
              ? palette.textPrimary
              : palette.textMuted.withValues(alpha: 0.38);
      final background = selected
          ? palette.selection
          : enabled
              ? palette.surfaceSubtle.withValues(alpha: 0.42)
              : Colors.transparent;
      final borderColor = selected
          ? palette.selection.withValues(alpha: 0.9)
          : enabled
              ? palette.divider.withValues(alpha: 0.7)
              : palette.divider.withValues(alpha: 0.24);

      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              constraints: BoxConstraints(
                minWidth: label == 'All' ? 34 : 22,
                minHeight: 24,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: label == 'All' ? 8 : 0,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildLetterButton(
                      label: 'All',
                      selected: selectedLetter == null,
                      enabled: true,
                      onTap: () => onLetterSelected(null),
                    ),
                    for (final letter in alphabet)
                      buildLetterButton(
                        label: letter,
                        selected: selectedLetter == letter,
                        enabled: availableLetters.contains(letter),
                        onTap: availableLetters.contains(letter)
                            ? () => onLetterSelected(
                                  selectedLetter == letter ? null : letter,
                                )
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LibraryInlineIssueJumpField extends StatefulWidget {
  const LibraryInlineIssueJumpField({super.key, required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<LibraryInlineIssueJumpField> createState() =>
      _LibraryInlineIssueJumpFieldState();
}

class _LibraryInlineIssueJumpFieldState
    extends State<LibraryInlineIssueJumpField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      final value = _controller.text.trim();
      if (value.isEmpty) {
        return;
      }
      widget.onSubmitted(value);
      _controller.clear();
    }

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Issue #',
        prefixIcon: const Icon(Icons.tag, size: 16),
        suffixIcon: IconButton(
          tooltip: 'Jump to issue',
          onPressed: submit,
          icon: const Icon(Icons.arrow_forward, size: 16),
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (_) => submit(),
    );
  }
}

void showLibraryCompactCoverSizeSheet(
  BuildContext context,
  LibraryViewMode viewMode,
  ValueChanged<LibraryViewMode> onViewModeChanged,
  ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged,
  ValueChanged<double> onCoverSizeChanged,
) {
  final coverSizeEnabled = viewMode.supportsCoverSize;
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Grid view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.grid);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Cards view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_agenda),
            title: const Text('Flow view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.cardFlow);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('List view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.list);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.view_sidebar_outlined),
            title: const Text('Details on right'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.right);
            },
          ),
          ListTile(
            leading: const Icon(Icons.splitscreen_outlined),
            title: const Text('Details on bottom'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.bottom);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close_fullscreen_outlined),
            title: const Text('Hide details'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.hidden);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_size_select_small),
            title: const Text('Small covers'),
            enabled: coverSizeEnabled,
            onTap: coverSizeEnabled
                ? () {
                    Navigator.of(context).pop();
                    onCoverSizeChanged(96);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.photo_size_select_large),
            title: const Text('Large covers'),
            enabled: coverSizeEnabled,
            onTap: coverSizeEnabled
                ? () {
                    Navigator.of(context).pop();
                    onCoverSizeChanged(188);
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

class LibraryFilterButton extends StatelessWidget {
  const LibraryFilterButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text(activeCount.toString()),
      child: IconButton(
        icon: Icon(
          activeCount > 0 ? Icons.filter_alt : Icons.filter_alt_outlined,
          size: 20,
        ),
        tooltip: 'Edit filters',
        onPressed: onPressed,
      ),
    );
  }
}

class LibraryItemCountLabel extends StatelessWidget {
  const LibraryItemCountLabel({
    super.key,
    required this.shown,
    required this.total,
    required this.pluralLabel,
  });

  final int shown;
  final int total;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final label = shown == total
        ? '$total ${pluralLabel.toLowerCase()}'
        : '$shown of $total ${pluralLabel.toLowerCase()}';
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: appPalette(context).textMuted,
      ),
    );
  }
}

class LibraryToolbarScopeChip extends StatelessWidget {
  const LibraryToolbarScopeChip({
    super.key,
    required this.label,
    required this.onClear,
  });

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      visualDensity: VisualDensity.compact,
      backgroundColor: appPalette(context).selection,
      label: Text(label),
      onDeleted: onClear,
    );
  }
}

class LibraryCollectionValueChip extends StatelessWidget {
  const LibraryCollectionValueChip({
    super.key,
    required this.totalPaidCents,
    required this.totalCoverCents,
    required this.totalSellCents,
    required this.currency,
  });

  final int totalPaidCents;
  final int totalCoverCents;
  final int totalSellCents;
  final String? currency;

  String _fmt(int cents) {
    final cur = currency ?? 'USD';
    return '${(cents / 100).toStringAsFixed(2)} $cur';
  }

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (totalPaidCents > 0) parts.add('Paid ${_fmt(totalPaidCents)}');
    if (totalCoverCents > 0) parts.add('Cover ${_fmt(totalCoverCents)}');
    if (totalSellCents > 0) parts.add('Sold ${_fmt(totalSellCents)}');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: parts.join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_money,
              size: 13,
              color: Colors.greenAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 3),
            Text(
              _fmt(
                totalPaidCents > 0
                    ? totalPaidCents
                    : (totalCoverCents > 0 ? totalCoverCents : totalSellCents),
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
