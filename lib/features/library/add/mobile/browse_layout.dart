import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/features/library/add/presentation_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Native browse replaces the group list with the opened group's issues.
class LibraryAddMobileBrowseLayout extends StatelessWidget {
  const LibraryAddMobileBrowseLayout({
    super.key,
    required this.groupList,
    required this.content,
    required this.opened,
    required this.onBack,
  });

  final Widget groupList;
  final Widget content;
  final LibraryAddBrowseGroup? opened;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final group = opened;
    if (group == null) return groupList;
    final facts = [
      if (group.details case final details?) details,
      if (group.period case final period?) '($period)',
    ].join(' ');
    return Column(children: [
      Material(
        color: LibraryAddPresentationTokens.mobile
            .mobileGroupHeaderColor(appPalette(context)),
        child: ListTile(
          dense: true,
          minTileHeight: 48,
          leading: const Icon(Icons.arrow_back),
          title: Text(group.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: facts.isEmpty ? null : Text(facts),
          onTap: onBack,
        ),
      ),
      Expanded(child: content),
    ]);
  }
}
