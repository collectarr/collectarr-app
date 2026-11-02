import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:flutter/material.dart';

/// Desktop browse keeps groups and issues visible side by side.
class LibraryAddDesktopBrowseLayout extends StatelessWidget {
  const LibraryAddDesktopBrowseLayout({
    super.key,
    required this.groupList,
    required this.content,
    required this.groupWidth,
  });

  final Widget groupList;
  final Widget content;
  final double groupWidth;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: groupWidth, child: groupList),
          ColoredBox(
            color: libraryAddPaneDivider(context),
            child: const SizedBox(width: 6),
          ),
          Expanded(child: content),
        ],
      );
}
