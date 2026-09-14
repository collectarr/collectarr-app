import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

Widget buildLibraryKindPage({
  required LibraryKindRegistration registration,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
  LibraryLayoutSnapshot? switchLayoutSnapshot,
}) {
  return registration.buildLibraryPage(
    topBar: topBar,
    accent: accent,
    routeUri: routeUri,
    switchLayoutSnapshot: switchLayoutSnapshot,
  );
}
