import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_controller.dart';

/// Aggregate that wires search, selection, and preview controller facades into
/// a single access point for [_LibraryAddDialogState].
class LibraryAddController {
  const LibraryAddController({
    required this.search,
    required this.selection,
    required this.preview,
  });

  final LibraryAddSearchController search;
  final LibraryAddSelectionController selection;
  final LibraryAddPreviewController preview;
}

