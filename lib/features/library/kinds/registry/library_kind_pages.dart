import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_workspace_page.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

Widget buildLibraryKindPage({
  required CatalogMediaKind kind,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
  LibraryLayoutSnapshot? switchLayoutSnapshot,
}) {
  return CatalogItemV1WorkspacePage(
    kind: kind,
    identity: catalogItemV1IdentityForKind(kind),
    topBar: topBar,
    accent: accent,
  );
}
