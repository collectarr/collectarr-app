import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/features/library/add/controllers/browse_state.dart';
import 'package:collectarr_app/features/library/add/panes/search_pane.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Ownership { all, inCollection, notInCollection }

/// The browse tab of a kind with [LibraryAddBrowseTiles]: a page of group
/// tiles with owned and total counts, then the opened group as tick boxes
/// under its section headings, narrowed by ownership, section and text.
class LibraryAddBrowseTilesPane extends StatefulWidget {
  const LibraryAddBrowseTilesPane({
    super.key,
    required this.capability,
    required this.tiles,
    required this.state,
    required this.results,
    required this.ownedCounts,
    required this.ownedRefs,
    required this.checkedIds,
    required this.accent,
    required this.onOpen,
    required this.onBack,
    required this.onToggle,
  });

  final LibraryAddBrowseCapability capability;
  final LibraryAddBrowseTiles tiles;
  final LibraryAddBrowseState state;
  final List<CatalogSearchCandidate> results;

  /// Library entries per group, by [LibraryAddBrowseGroup.ownedKey].
  final Map<String, int> ownedCounts;
  final Set<CatalogItemRef> ownedRefs;
  final Set<String> checkedIds;
  final Color accent;
  final ValueChanged<LibraryAddBrowseGroup> onOpen;
  final VoidCallback onBack;
  final ValueChanged<String> onToggle;

  @override
  State<LibraryAddBrowseTilesPane> createState() =>
      _LibraryAddBrowseTilesPaneState();
}

class _LibraryAddBrowseTilesPaneState extends State<LibraryAddBrowseTilesPane> {
  var _ownership = _Ownership.all;
  String? _section;
  String _text = '';

  @override
  void didUpdateWidget(covariant LibraryAddBrowseTilesPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.state.opened, widget.state.opened)) {
      _ownership = _Ownership.all;
      _section = null;
      _text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final opened = state.opened;
    if (state.isSearching) return const LibraryAddSearchingPlaceholder();
    if (state.error != null) return _Message(state.error!);
    return opened == null ? _tiles(context) : _group(context, opened);
  }

  Widget _tiles(BuildContext context) {
    final palette = appPalette(context);
    return ColoredBox(
      color: libraryAddSearchBackground(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(widget.tiles.prompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: GridView(
            key: const ValueKey('library-add-browse-tiles'),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 192,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12),
            children: [
              for (final group in state.found)
                _GroupTile(
                  group: group,
                  owned: widget.ownedCounts[group.ownedKey] ?? 0,
                  imageList: widget.tiles.imageList,
                  onTap: () => widget.onOpen(group),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  LibraryAddBrowseState get state => widget.state;

  bool _owned(CatalogSearchCandidate item) =>
      widget.ownedRefs.contains(item.reference);

  Widget _group(BuildContext context, LibraryAddBrowseGroup group) {
    final palette = appPalette(context);
    final sectionOf = widget.tiles.sectionOf;
    final sections = <String>{
      for (final item in widget.results) sectionOf(item) ?? '',
    }.toList()
      ..sort();
    final text = _text.trim().toLowerCase();
    bool shown(CatalogSearchCandidate item) =>
        (_section == null || (sectionOf(item) ?? '') == _section) &&
        switch (_ownership) {
          _Ownership.all => true,
          _Ownership.inCollection => _owned(item),
          _Ownership.notInCollection => !_owned(item),
        } &&
        (text.isEmpty ||
            item.summary.primaryLabel.toLowerCase().contains(text));
    final bySection = <String, List<CatalogSearchCandidate>>{};
    for (final item in widget.results) {
      (bySection[sectionOf(item) ?? ''] ??= []).add(item);
    }
    final visible = {
      for (final name in sections)
        if (bySection[name]!.where(shown).toList() case final items
            when items.isNotEmpty)
          name: items,
    };
    final ownedTotal = widget.results.where(_owned).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ColoredBox(
        color: libraryAddSearchRowBackground(context),
        child: SizedBox(
          height: 40,
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const ValueKey('library-add-browse-back'),
                tooltip: 'Back',
                onPressed: widget.onBack,
                icon: Icon(AppIcons.chevronLeft,
                    size: 16, color: palette.textPrimary),
              ),
            ),
            Text(group.title,
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
      ColoredBox(
        color: libraryAddSearchBackground(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child: Row(children: [
            _Menu<_Ownership>(
              key: const ValueKey('library-add-browse-ownership'),
              label: switch (_ownership) {
                _Ownership.all => 'All ${group.title}',
                _Ownership.inCollection => 'In Collection',
                _Ownership.notInCollection => 'Not in Collection',
              },
              values: {
                _Ownership.all: 'All ${group.title}',
                _Ownership.inCollection: 'In Collection',
                _Ownership.notInCollection: 'Not in Collection',
              },
              current: _ownership,
              onSelected: (value) => setState(() => _ownership = value),
            ),
            const Spacer(),
            _Menu<String>(
              key: const ValueKey('library-add-browse-section'),
              label: _section == null
                  ? 'All ${widget.tiles.sectionLabel}'
                  : _section!.isEmpty
                      ? 'None'
                      : _section!,
              values: {
                '\u0000': 'All ${widget.tiles.sectionLabel}',
                for (final name in sections) name: name.isEmpty ? 'None' : name,
              },
              current: _section ?? '\u0000',
              onSelected: (value) =>
                  setState(() => _section = value == '\u0000' ? null : value),
            ),
          ]),
        ),
      ),
      ColoredBox(
        color: libraryAddSearchBackground(context),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(children: [
            SizedBox(
              width: 250,
              height: 34,
              child: TextField(
                key: const ValueKey('library-add-browse-filter'),
                onChanged: (value) => setState(() => _text = value),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search ${group.title}',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 7),
                  suffixIcon: const Icon(AppIcons.search, size: 14),
                ),
              ),
            ),
            const Spacer(),
            Text('$ownedTotal/${widget.results.length}',
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
      Expanded(
        child: state.isLoadingItems
            ? const LibraryAddSearchingPlaceholder()
            : ColoredBox(
                color: libraryAddSearchBackground(context),
                child: visible.isEmpty
                    ? const _Message('No items found.')
                    : CustomScrollView(
                        key: const ValueKey('library-add-browse-group'),
                        slivers: [
                          for (final MapEntry(key: name, value: items)
                              in visible.entries) ...[
                            SliverToBoxAdapter(
                              child: _SectionHeading(
                                name: name.isEmpty ? 'None' : name,
                                owned: bySection[name]!.where(_owned).length,
                                total: bySection[name]!.length,
                                accent: widget.accent,
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.all(3),
                              sliver: SliverGrid.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 226,
                                        mainAxisExtent: 300,
                                        mainAxisSpacing: 6,
                                        crossAxisSpacing: 6),
                                itemCount: items.length,
                                itemBuilder: (context, index) => _ItemTile(
                                  item: items[index],
                                  section: name,
                                  owned: _owned(items[index]),
                                  checked: widget.checkedIds
                                      .contains(items[index].reference.id),
                                  onToggle: () => widget
                                      .onToggle(items[index].reference.id),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
      ),
    ]);
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message,
              style: TextStyle(
                  color: appPalette(context).textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
      );
}

/// A named tile. The reference shows each line's logo here; those are its
/// licensors' artwork, so the tile carries the name instead.
class _GroupTile extends ConsumerWidget {
  const _GroupTile(
      {required this.group,
      required this.owned,
      required this.imageList,
      required this.onTap});

  final LibraryAddBrowseGroup group;
  final int owned;
  final String? imageList;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final list = imageList;
    final image = list == null
        ? null
        : ref
            .watch(listValueImageProvider((list: list, value: group.title)))
            .value;
    // Logos are drawn for a white ground, as on the reference's tiles.
    final textColor = image == null ? palette.textPrimary : Colors.black;
    return Material(
      color: image == null ? palette.panelRaised : Colors.white,
      child: InkWell(
        key: ValueKey('library-add-browse-tile-${group.title}'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        child: Column(children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: image != null
                    ? Tooltip(
                        message: group.title,
                        child: ListValueImageView(image),
                      )
                    : Text(group.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('$owned / ${group.countLabel}',
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(
      {required this.name,
      required this.owned,
      required this.total,
      required this.accent});

  final String name;
  final int owned;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        color: accent,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          child: Row(children: [
            Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
            Text('$owned/$total'),
          ]),
        ),
      );
}

class _ItemTile extends StatelessWidget {
  const _ItemTile(
      {required this.item,
      required this.section,
      required this.owned,
      required this.checked,
      required this.onToggle});

  final CatalogSearchCandidate item;
  final String section;
  final bool owned;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final title = item.summary.primaryLabel;
    return Material(
      color: palette.isDark ? const Color(0xffe6e6e6) : palette.surface,
      child: InkWell(
        key: ValueKey('library-add-browse-item-${item.reference.id}'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: owned ? null : onToggle,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(children: [
            Text(section,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xff666666), fontSize: 13)),
            const SizedBox(height: 3),
            Expanded(
              child: LibraryCoverImage(
                title: title,
                mediaKind: item.summary.kind,
                imageUrl: item.summary.imageUrl,
                fallbackAspectRatio: 1,
                borderRadius: 0,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              IgnorePointer(
                child: Icon(
                  checked || owned
                      ? AppIcons.check
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: palette.utilityAction,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xff222222),
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu(
      {super.key,
      required this.label,
      required this.values,
      required this.current,
      required this.onSelected});

  final String label;
  final Map<T, String> values;
  final T current;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final menu = AppDropdownMenuStyle.of(context);
    return PopupMenuButton<T>(
      tooltip: '',
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: PopupMenuPosition.under,
      color: menu.background,
      shape: menu.shape,
      elevation: AppDropdownMenuStyle.elevation,
      menuPadding: AppDropdownMenuStyle.padding,
      constraints: const BoxConstraints(maxHeight: 400),
      itemBuilder: (context) => [
        for (final MapEntry(key: value, value: text) in values.entries)
          menu.row(
              value: value,
              current: value == current,
              child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
      onSelected: onSelected,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: palette.isDark ? const Color(0xff444444) : palette.field,
            borderRadius: BorderRadius.circular(4)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Icon(AppIcons.chevronDown, size: 12, color: palette.textPrimary),
        ]),
      ),
    );
  }
}
