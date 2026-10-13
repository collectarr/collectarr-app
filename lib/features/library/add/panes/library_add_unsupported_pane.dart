import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class LibraryAddUnsupportedManualPane extends StatelessWidget {
  const LibraryAddUnsupportedManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEmptyVisualState(
      icon: Icons.block_outlined,
      title: 'Manual add not supported',
      message:
          'Collectarr Core has no manual form configured for ${request.type.identity.title} yet. Search the Core catalog or propose the missing item.',
      accent: request.accent,
    );
  }
}
