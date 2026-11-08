import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/features/library/add/mobile/cover_grid.dart';
import 'package:collectarr_app/features/library/add/presentation_tokens.dart';

import 'dependencies.dart';
import 'search_pane.dart';

/// How the browse tab shows a group's items.
enum LibraryAddBlockLayout { grid, list }

/// A group's items as the reference's cover blocks: a 153 x 234 cover over a
/// checkbox, the boxed badge with its month and year, and a caption. The
/// list layout keeps the same labels beside a small cover.
class LibraryAddCoverBlocks extends StatelessWidget {
  const LibraryAddCoverBlocks({
    super.key,
    required this.layout,
    required this.results,
    required this.block,
    required this.selectedResultId,
    required this.checkedResultIds,
    required this.onSelectResult,
    required this.onToggleResultCheck,
    this.onAddManually,
    this.wide = false,
  });

  /// The larger blocks of a full-width dialog.
  final bool wide;

  static const blockWidth = 163.0;
  static const blockHeight = 299.0;
  static const blockMargin = 5.0;
  static const coverWidth = 153.0;
  static const coverHeight = 234.0;
  static const listRowHeight = 71.0;
  static const _wideBlockWidth = 176.0;
  static const _wideBlockHeight = 360.0;
  static const _wideCoverHeight = 270.0;
  static const _titleHeight = 40.0;

  final LibraryAddBlockLayout layout;
  final List<CatalogSearchCandidate> results;
  final LibraryAddCoverBlock Function(CatalogSearchCandidate item) block;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;

  /// The grid ends with a "Not found?" block opening Add Manually.
  final VoidCallback? onAddManually;

  @override
  Widget build(BuildContext context) {
    final desktopCoverHeight = wide ? _wideCoverHeight : null;
    final width = wide ? _wideBlockWidth : blockWidth;
    final titled = results.any((item) => block(item).title != null);
    final height = (wide ? _wideBlockHeight : blockHeight) +
        (titled ? _titleHeight : 0);
    Widget tile(int index, {double? coverHeight}) {
      final item = results[index];
      final id = item.reference.id;
      final args = (
        item: item,
        block: block(item),
        selected: id == selectedResultId,
        checked: checkedResultIds.contains(id),
        onSelect: () => onSelectResult(id),
        onToggleCheck: () => onToggleResultCheck(id),
      );
      return layout == LibraryAddBlockLayout.grid
          ? _GridBlock(args, coverHeight: coverHeight ?? desktopCoverHeight)
          : _ListBlock(args);
    }

    if (layout == LibraryAddBlockLayout.list) {
      return ListView.builder(
        key: const ValueKey('library-add-cover-list'),
        itemCount: results.length,
        itemExtent: listRowHeight,
        itemBuilder: (context, index) => tile(index),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final tokens = LibraryAddPresentationTokens.current;
      if (appPresentationPlatform.isNativeMobile) {
        return LibraryAddMobileCoverGrid(
          width: constraints.maxWidth,
          count: results.length,
          coverAspectRatio: coverHeight / coverWidth,
          minimumWidth: tokens.gridMinimumWidth,
          margin: blockMargin,
          itemBuilder: (index, height) => tile(index, coverHeight: height),
          onAddManually: onAddManually,
        );
      }
      final extent = width + 2 * blockMargin;
      final columns = ((constraints.maxWidth - 2 * blockMargin) /
              (wide ? extent : tokens.gridMinimumWidth))
              .floor()
              .clamp(
                1,
                1 << 20,
              );
      // Fixed-width blocks flow from the left, as in the reference.
      final spare = constraints.maxWidth - columns * extent;
      final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: height + 2 * blockMargin,
      );
      return GridView.builder(
        key: const ValueKey('library-add-cover-grid'),
        padding: EdgeInsets.fromLTRB(blockMargin, blockMargin,
            spare.clamp(blockMargin, double.infinity), blockMargin),
        gridDelegate: gridDelegate,
        itemCount: results.length + (onAddManually == null ? 0 : 1),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(blockMargin),
          child: index == results.length
              ? _NotFoundBlock(onTap: onAddManually!)
              : tile(index),
        ),
      );
    });
  }
}

typedef _BlockArgs = ({
  CatalogSearchCandidate item,
  LibraryAddCoverBlock block,
  bool selected,
  bool checked,
  VoidCallback onSelect,
  VoidCallback onToggleCheck,
});

class _GridBlock extends StatelessWidget {
  const _GridBlock(this.args, {this.coverHeight});

  final double? coverHeight;

  final _BlockArgs args;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final tokens = LibraryAddPresentationTokens.current;
    final block = args.block;
    return AppClickTarget(
      key: ValueKey('library-add-cover-block-${args.item.reference.id}'),
      onClick: args.onSelect,
      builder: (context, hovered) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: args.selected
              ? palette.utilityAction
              : palette.isDark
                  ? const Color(0xff383838)
                  : palette.panelRaised,
          border:
              tokens.borderedCover ? Border.all(color: palette.divider) : null,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
              color: args.selected ? Colors.white : palette.textPrimary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (block.title case final title?)
                SizedBox(
                  height: LibraryAddCoverBlocks._titleHeight,
                  child: Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14)),
                ),
              SizedBox(
                height: coverHeight ?? LibraryAddCoverBlocks.coverHeight,
                child: LibraryCoverImage(
                  title: args.item.summary.primaryLabel,
                  mediaKind: args.item.summary.kind,
                  imageUrl: args.item.summary.imageUrl,
                  borderRadius: 0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 31,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LibraryAddResultCheckbox(
                      checked: args.checked,
                      size: 22,
                      onPressed: args.onToggleCheck,
                    ),
                    const SizedBox(width: 5),
                    if (tokens.badgeFillsRow)
                      Expanded(child: _BadgeBox(block.badge))
                    else
                      _BadgeBox(block.badge),
                    if (!tokens.badgeFillsRow) const Spacer(),
                    Text(
                      [
                        if (block.month case final month?) month,
                        if (block.year case final year?) '$year',
                      ].join('\n'),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11, height: 15 / 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                block.caption ?? '',
                maxLines: tokens.captionLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, height: 17 / 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock(this.args);

  final _BlockArgs args;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final block = args.block;
    final period = [
      if (block.year case final year?) '$year',
      if (block.month case final month?) '$month.',
    ].join(', ');
    final selected = args.selected;
    return AppClickTarget(
      key: ValueKey('library-add-cover-row-${args.item.reference.id}'),
      onClick: args.onSelect,
      builder: (context, hovered) => Container(
        decoration: BoxDecoration(
          color: selected ? palette.utilityAction : null,
          border: Border(
              bottom: BorderSide(color: libraryAddResultsDivider(context))),
        ),
        padding: const EdgeInsets.only(left: 13, right: 7),
        child: DefaultTextStyle.merge(
          style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: selected ? Colors.white : palette.textPrimary),
          child: Row(
            children: [
              LibraryAddResultCheckbox(
                checked: args.checked,
                onPressed: args.onToggleCheck,
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 52,
                height: 70,
                child: LibraryCoverImage(
                  title: args.item.summary.primaryLabel,
                  mediaKind: args.item.summary.kind,
                  imageUrl: args.item.summary.imageUrl,
                  borderRadius: 0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        _BadgeBox(block.badge),
                        const Spacer(),
                        Text(period),
                      ]),
                      Text(
                        block.caption ?? '',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xff888888)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The last grid block: a large plus over "Not found? Add it manually".
class _NotFoundBlock extends StatelessWidget {
  const _NotFoundBlock({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AppClickTarget(
      key: const ValueKey('library-add-cover-not-found'),
      onClick: onTap,
      builder: (context, hovered) => Container(
        padding: const EdgeInsets.all(5),
        color: hovered
            ? libraryAddResultsDivider(context)
            : palette.isDark
                ? const Color(0xff383838)
                : palette.panelRaised,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Icon(Icons.add, size: 90, color: palette.textPrimary),
              ),
            ),
            Text('Not found?',
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            Text('Add it manually',
                style: TextStyle(color: palette.textPrimary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// The reference's outlined issue box, as "#1A".
class _BadgeBox extends StatelessWidget {
  const _BadgeBox(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color ?? Colors.white;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14, height: 1, fontWeight: FontWeight.w700)),
    );
  }
}

/// The browse tab's cover blocks with their layout and issue order.
class LibraryAddCoverBlockView {
  const LibraryAddCoverBlockView({
    required this.block,
    required this.layout,
    required this.onLayoutChanged,
    required this.descending,
    required this.onDescendingChanged,
    this.onAddManually,
    this.wide = false,
  });

  final bool wide;
  final LibraryAddCoverBlock Function(CatalogSearchCandidate item) block;
  final VoidCallback? onAddManually;
  final LibraryAddBlockLayout layout;
  final ValueChanged<LibraryAddBlockLayout> onLayoutChanged;
  final bool descending;
  final ValueChanged<bool> onDescendingChanged;
}
