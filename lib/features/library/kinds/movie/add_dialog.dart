import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_pane.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/features/library/add/library_add_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/ui/adaptive/window_class.dart';

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
      manualPaneBuilder: buildMovieManualPane,
      previewPaneBuilder: buildMovieAddPreviewPane,
      bottomBarBuilder: buildMovieAddBottomBar,
    );
  }
}

Widget buildMovieManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return MovieAddManualPane(request: request);
}

// Register the movie add dialog builders so the generic dialog can use them.
void registerMovieAddBuilders() {
  LibraryAddRegistry.registerHeaderBuilder(
    CatalogMediaKind.movie,
    buildMovieAddHeader,
  );
  LibraryAddRegistry.registerModeBarBuilder(
    CatalogMediaKind.movie,
    buildMovieAddModeBar,
  );
  LibraryAddRegistry.registerSearchBuilder(
    CatalogMediaKind.movie,
    buildMovieAddSearchPane,
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.movie,
    buildMovieManualPane,
  );
  LibraryAddRegistry.registerPreviewBuilder(
    CatalogMediaKind.movie,
    buildMovieAddPreviewPane,
  );
  LibraryAddRegistry.registerBottomBarBuilder(
    CatalogMediaKind.movie,
    buildMovieAddBottomBar,
  );
}
