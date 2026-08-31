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
          'Manual item creation is not configured for kind "${request.type.workspace.title}". Please use provider search to add items.',
      accent: request.accent,
    );
  }
}
