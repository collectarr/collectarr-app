import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Excel-style tab bar showing user smart lists as clickable collection tabs.
class LibraryCollectionTabBar extends ConsumerStatefulWidget {
  const LibraryCollectionTabBar({
    super.key,
    required this.mediaKind,
    required this.activeSmartListId,
    required this.onSmartListSelected,
    required this.onAllSelected,
  });

  final String mediaKind;
  final String? activeSmartListId;
  final ValueChanged<SmartList> onSmartListSelected;
  final VoidCallback onAllSelected;

  @override
  ConsumerState<LibraryCollectionTabBar> createState() =>
      _LibraryCollectionTabBarState();
}

class _LibraryCollectionTabBarState
    extends ConsumerState<LibraryCollectionTabBar> {
  List<SmartList> _smartLists = const [];

  @override
  void initState() {
    super.initState();
    _loadSmartLists();
  }

  @override
  void didUpdateWidget(LibraryCollectionTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaKind != widget.mediaKind) {
      _loadSmartLists();
    }
  }

  Future<void> _loadSmartLists() async {
    final mediaKind = widget.mediaKind;
    final db = ref.read(localDatabaseProvider);
    final repo = SmartListRepository(db);
    final lists = await repo.getAll(mediaKind: mediaKind);
    if (mounted && widget.mediaKind == mediaKind) {
      setState(() => _smartLists = lists);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_smartLists.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isAllActive = widget.activeSmartListId == null;

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: appPalette(context).canvas,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            LibraryCollectionTab(
              label: 'All',
              isActive: isAllActive,
              onTap: widget.onAllSelected,
            ),
            for (final list in _smartLists)
              LibraryCollectionTab(
                label: list.name,
                isActive: widget.activeSmartListId == list.id,
                onTap: () => widget.onSmartListSelected(list),
              ),
          ],
        ),
      ),
    );
  }
}

class LibraryCollectionTab extends StatelessWidget {
  const LibraryCollectionTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: Material(
        color:
            isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}