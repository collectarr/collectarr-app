part of '../library_page.dart';

Widget buildLibraryToolbar(LibraryToolbarPresentation presentation) {
  return LibraryToolbar.grouped(
    config: presentation.config,
    state: presentation.state,
    actions: presentation.actions,
  );
}
