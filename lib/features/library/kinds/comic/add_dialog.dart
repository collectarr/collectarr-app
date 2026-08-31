import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_registry.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_shell.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      manualPaneBuilder: buildComicManualPane,
      previewPaneBuilder: buildComicAddPreviewPane,
      bottomBarBuilder: buildComicAddBottomBar,
    );
  }
}

Widget buildComicManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return ComicAddManualPane(request: request);
}

// Register the comic add dialog builders so the generic dialog can use them.
void registerComicAddBuilders() {
  LibraryAddRegistry.registerHeaderBuilder(
    CatalogMediaKind.comic,
    buildComicAddHeader,
  );
  LibraryAddRegistry.registerModeBarBuilder(
    CatalogMediaKind.comic,
    buildComicAddModeBar,
  );
  LibraryAddRegistry.registerSearchBuilder(
    CatalogMediaKind.comic,
    buildComicAddSearchPane,
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.comic,
    buildComicManualPane,
  );
  LibraryAddRegistry.registerPreviewBuilder(
    CatalogMediaKind.comic,
    buildComicAddPreviewPane,
  );
  LibraryAddRegistry.registerBottomBarBuilder(
    CatalogMediaKind.comic,
    buildComicAddBottomBar,
  );
}
