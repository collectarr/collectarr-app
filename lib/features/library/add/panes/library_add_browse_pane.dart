import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_browse_state.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'library_add_pane_dependencies.dart';
import 'library_add_search_pane.dart';

/// The groups found in the browse tab; choosing one lists its items.
class LibraryAddBrowseGroupList extends StatelessWidget {
  const LibraryAddBrowseGroupList({
    super.key,
    required this.capability,
    required this.state,
    required this.onOpen,
  });

  final LibraryAddBrowseCapability capability;
  final LibraryAddBrowseState state;
  final ValueChanged<LibraryAddBrowseGroup> onOpen;

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
    return ColoredBox(
      color: libraryAddResultsBackground(context),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 31),
            alignment: Alignment.center,
            child: Text(
              '$count ${capability.label}',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) => _BrowseGroupRow(
                group: state.found[index],
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
  const _BrowseGroupRow({required this.group, required this.onTap});

  final LibraryAddBrowseGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('library-add-browse-${group.title}-${group.details}'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        child: Container(
          height: 71,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: libraryAddResultsDivider(context)),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
                fontSize: 14, height: 20 / 14, color: palette.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Row(
              children: [
                SizedBox(
                  width: 65,
                  height: 70,
                  child: LibraryCoverImage(
                    title: group.title,
                    imageUrl: group.coverImageUrl,
                    fallbackAspectRatio: 65 / 70,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 21.4 / 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (group.details case final details?) Text(details),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Text(group.countLabel),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 13),
                  child: Icon(AppIcons.chevronRight,
                      size: 14, color: palette.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Above the items of the opened group: back to the group list, and the
/// group it lists.
class LibraryAddOpenedGroupBar extends StatelessWidget {
  const LibraryAddOpenedGroupBar({
    super.key,
    required this.label,
    required this.group,
    required this.onBack,
  });

  final String label;
  final LibraryAddBrowseGroup group;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      color: libraryAddResultsBackground(context),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('library-add-browse-back'),
            tooltip: 'Back to $label',
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            onPressed: onBack,
            icon: Icon(AppIcons.chevronLeft, color: palette.textPrimary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              [group.title, if (group.details != null) group.details]
                  .join('  |  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "All (n)": checks or unchecks every listed item.
class LibraryAddCheckAllToggle extends StatelessWidget {
  const LibraryAddCheckAllToggle({
    super.key,
    required this.count,
    required this.checked,
    required this.onChanged,
  });

  final int count;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      key: const ValueKey('library-add-check-all'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'All ($count)',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        LibraryAddResultCheckbox(
          checked: checked,
          onPressed: () => onChanged(!checked),
        ),
      ],
    );
  }
}
