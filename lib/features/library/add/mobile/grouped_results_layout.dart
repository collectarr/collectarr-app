import 'package:flutter/material.dart';

/// Native grouped results navigate from groups to variants in one column.
class LibraryAddMobileGroupedResultsLayout extends StatelessWidget {
  const LibraryAddMobileGroupedResultsLayout({
    super.key,
    required this.groupList,
    required this.variantList,
    required this.selectedTitle,
    required this.onBack,
  });

  final Widget groupList;
  final Widget variantList;
  final String? selectedTitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final title = selectedTitle;
    if (title == null) return groupList;
    return Column(children: [
      ListTile(
        leading: const Icon(Icons.arrow_back),
        title: Text(title),
        onTap: onBack,
      ),
      Expanded(child: variantList),
    ]);
  }
}
