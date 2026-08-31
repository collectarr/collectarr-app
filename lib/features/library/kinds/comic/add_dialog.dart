import 'package:collectarr_app/features/library/kinds/comic/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_shell.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:flutter/material.dart';

Future<LibraryAddDialogResult?> showComicLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
) {
  final windowClass = AppWindowClass.of(context);
  if (windowClass.isCompact) {
    return Navigator.of(context).push<LibraryAddDialogResult>(
      MaterialPageRoute<LibraryAddDialogResult>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: SafeArea(
            child: ComicLibraryAddDialog(request: request),
          ),
        ),
      ),
    );
  }
  return showDialog<LibraryAddDialogResult>(
    context: context,
    builder: (context) => ComicLibraryAddDialog(request: request),
  );
}

class ComicLibraryAddDialog extends StatelessWidget {
  const ComicLibraryAddDialog({
    super.key,
    required this.request,
  });

  final LibraryAddDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
      headerBuilder: buildComicAddHeader,
      modeBarBuilder: buildComicAddModeBar,
      searchPaneBuilder: buildComicAddSearchPane,
      previewPaneBuilder: buildComicAddPreviewPane,
      bottomBarBuilder: buildComicAddBottomBar,
    );
  }
}
