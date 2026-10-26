import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which Settings > Sorting display option a cell follows.
enum MusicSortValueKind { title, name }

/// A list cell that shows the sort title or sort name instead of the display
/// value when Settings > Sorting asks for it.
class MusicSortValueCell extends ConsumerWidget
    implements LibraryMeasuredTableCell {
  const MusicSortValueCell({
    super.key,
    required this.kind,
    required this.display,
    required this.sortValue,
  });

  final MusicSortValueKind kind;
  final String? display;
  final String sortValue;

  // Either value may be shown, so a wrapped row fits the longer one.
  @override
  String get measuredText {
    final shown = display ?? '';
    return shown.length >= sortValue.length ? shown : sortValue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSort = ref.watch(uiPreferencesProvider.select((p) =>
        kind == MusicSortValueKind.title ? p.showSortTitles : p.showSortNames));
    return LibraryTableCellText(showSort ? sortValue : display);
  }
}
