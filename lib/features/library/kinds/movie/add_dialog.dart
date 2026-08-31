import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:flutter/material.dart';

Future<LibraryAddDialogResult?> showMovieLibraryAddDialog(
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
            child: MovieLibraryAddDialog(request: request),
          ),
        ),
      ),
    );
  }
  return showDialog<LibraryAddDialogResult>(
    context: context,
    builder: (context) => MovieLibraryAddDialog(request: request),
  );
}

class MovieLibraryAddDialog extends StatelessWidget {
  const MovieLibraryAddDialog({
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
      headerBuilder: buildMovieAddHeader,
      modeBarBuilder: buildMovieAddModeBar,
      searchPaneBuilder: buildMovieAddSearchPane,
      previewPaneBuilder: buildMovieAddPreviewPane,
      bottomBarBuilder: buildMovieAddBottomBar,
    );
  }
}
