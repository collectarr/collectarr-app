import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_browse_state.dart';
import 'library_add_grouped_results.dart';
import 'library_add_pane_dependencies.dart';
import 'library_add_search_pane.dart';

/// The groups found in the browse tab; choosing one lists its items beside.
class LibraryAddBrowseGroupList extends StatelessWidget {
  const LibraryAddBrowseGroupList({
    super.key,
    required this.capability,
    required this.state,
    required this.onOpen,
    this.onAddManually,
  });

  final LibraryAddBrowseCapability capability;
  final LibraryAddBrowseState state;
  final ValueChanged<LibraryAddBrowseGroup> onOpen;

  /// "Not found? Add it manually" under the groups, as in the reference.
  final VoidCallback? onAddManually;

  /// The list's width beside the opened group, as in the reference.
  static const width = 460.0;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final message = state.error ??
        (state.searched
            ? 'No ${capability.label} found.'
            : capability.hintText);
    if (state.isSearching) {
      return ColoredBox(
        color: libraryAddSearchBackground(context),
        child: const LibraryAddSearchingPlaceholder(),
      );
    }
    if (state.found.isEmpty) {
      return ColoredBox(
        color: libraryAddSearchBackground(context),
        child: Center(
          child: Text(
            message,
            key: const ValueKey('library-add-browse-message'),
            style: TextStyle(
              color: palette.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    final count = state.found.length;
    // The rows end where they end; the dialog's grey shows below them.
    return ColoredBox(
      color: libraryAddSearchBackground(context),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: count + (onAddManually == null ? 0 : 1),
              itemBuilder: (context, index) => index == count
                  ? LibraryAddNotFoundRow(
                      message: 'Add it manually', onTap: onAddManually!)
                  : _BrowseGroupRow(
                      group: state.found[index],
                      selected: identical(state.found[index], state.opened),
                      onTap: () => onOpen(state.found[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseGroupRow extends StatelessWidget {
  const _BrowseGroupRow({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final LibraryAddBrowseGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final muted = selected ? Colors.white : const Color(0xff888888);
    return Material(
      color: selected
          ? palette.utilityAction
          : libraryAddResultsBackground(context),
      child: InkWell(
        key: ValueKey('library-add-browse-${group.title}-${group.details}'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        // The reference darkens a hovered row, but keeps the opened one blue.
        hoverColor: selected
            ? Colors.transparent
            : palette.isDark
                ? const Color(0xff2d2d2d)
                : null,
        onTap: onTap,
        child: Container(
          height: 61,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: libraryAddResultsDivider(context)),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: selected ? Colors.white : palette.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 95,
                  height: 60,
                  child: LibraryCoverImage(
                    title: group.title,
                    imageUrl: group.coverImageUrl,
                    fallbackAspectRatio: 95 / 60,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 7, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 24 / 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _BrowseCountPill(label: group.countLabel),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DefaultTextStyle.merge(
                          style: TextStyle(color: muted),
                          child: Row(
                            children: [
                              Expanded(child: Text(group.details ?? '')),
                              if (group.period case final period?) Text(period),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrowseCountPill extends StatelessWidget {
  const _BrowseCountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff605c5c),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, height: 18 / 13)),
      );
}

/// The opened group's facts over its title, beside the search field.
class LibraryAddBrowseGroupHeader extends StatelessWidget {
  const LibraryAddBrowseGroupHeader({super.key, required this.group});

  final LibraryAddBrowseGroup? group;

  @override
  Widget build(BuildContext context) {
    final group = this.group;
    final palette = appPalette(context);
    if (group == null) {
      return ColoredBox(color: libraryAddGroupHeaderColor(palette));
    }
    final facts = [
      if (group.details != null) group.details,
      if (group.period != null) '(${group.period})',
    ].join(' ');
    return Container(
      key: const ValueKey('library-add-browse-header'),
      color: libraryAddGroupHeaderColor(palette),
      padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: palette.textPrimary),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (facts.isNotEmpty)
              Text(facts,
                  style: const TextStyle(fontSize: 13, height: 18 / 13)),
            Text(group.title,
                style: const TextStyle(
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// "All (n)": checks or unchecks every listed item; a dash while only some
/// are checked.
class LibraryAddCheckAllToggle extends StatelessWidget {
  const LibraryAddCheckAllToggle({
    super.key,
    required this.count,
    required this.checked,
    required this.onChanged,
    this.partial = false,
  });

  final int count;
  final bool checked;
  final bool partial;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      key: const ValueKey('library-add-check-all'),
      mainAxisSize: MainAxisSize.min,
      children: [
        LibraryAddResultCheckbox(
          checked: checked,
          partial: partial,
          onPressed: () => onChanged(!checked),
        ),
        const SizedBox(width: 7),
        Text(
          'All ($count)',
          style: TextStyle(color: palette.textPrimary, fontSize: 14),
        ),
      ],
    );
  }
}
