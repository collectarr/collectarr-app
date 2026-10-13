import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_sections.dart';
import 'package:flutter/material.dart';

Widget buildMusicCatalogItemInspectorHero(
        BuildContext context, LibraryInspectorRequest request) =>
    buildMusicInspectorHero(context, request);
Widget buildMusicLibraryEntryInspectorHero(
        BuildContext context, LibraryInspectorRequest request) =>
    buildMusicInspectorHero(context, request);
List<Widget> buildMusicCatalogItemInspectorSections(
        BuildContext context, LibraryInspectorRequest request) =>
    buildMusicInspectorSections(context, request);
List<Widget> buildMusicLibraryEntryInspectorSections(
        BuildContext context, LibraryInspectorRequest request) =>
    buildMusicInspectorSections(context, request);
