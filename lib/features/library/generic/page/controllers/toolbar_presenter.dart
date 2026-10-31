import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';

Widget buildLibraryToolbar(LibraryToolbarPresentation presentation) {
  return LibraryToolbar.grouped(
    config: presentation.config,
    state: presentation.state,
    actions: presentation.actions,
  );
}
