import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:flutter/material.dart';

/// Desktop grouped results retain both panes and their divider.
class LibraryAddDesktopGroupedResultsLayout extends StatelessWidget {
  const LibraryAddDesktopGroupedResultsLayout({
    super.key,
    required this.groupList,
    required this.variantList,
  });

  final Widget groupList;
  final Widget variantList;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: LibraryAddResultGrouping.listWidth,
            child: groupList,
          ),
          ColoredBox(
            color: libraryAddPaneDivider(context),
            child: const SizedBox(width: 6),
          ),
          Expanded(child: variantList),
        ],
      );
}
