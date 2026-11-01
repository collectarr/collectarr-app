import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/config/kind_style.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/generic/page/page.dart';
import 'location.dart';

/// Route reconstruction consumes the same library command host as live navigation.
class RestorableLibraryDetailPage extends StatelessWidget {
  const RestorableLibraryDetailPage({super.key, required this.uri, this.hint});
  final Uri uri;
  final LibraryDetailPageRequest? hint;
  @override
  Widget build(BuildContext context) {
    final location = LibraryDetailLocation.fromUri(uri);
    final type = location == null
        ? null
        : defaultLibraryKindRegistry.tryGet(location.target.kind);
    if (location == null || type == null) {
      return Scaffold(
          appBar: AppBar(
              title: const Text('Item unavailable'),
              leading: BackButton(onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/libraries');
                }
              })),
          body: const Center(
              child: Text(
                  'This item link is invalid or its library is unavailable.')));
    }
    return GenericLibraryPage(
        type: type,
        topBar: const SizedBox.shrink(),
        accent: libraryAccentForKind(type.kind),
        routeUri: uri,
        detailTarget: location.target,
        detailHint: hint?.item.target == location.target ? hint : null);
  }
}
