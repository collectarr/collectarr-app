import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/settings/list_value_images_panel.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:flutter/material.dart';

Widget buildComicCustomLabelIconsSettings(
        BuildContext context, CatalogMediaKind kind) =>
    Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SettingsGroup(
            legend: 'Custom label icons',
            child: ListValueImagesPanel(
                list: ComicVocabularyIds.customLabel.value,
                description:
                    'Load icons from your own files, each named after its '
                    'Custom Label, such as "Absolute Batman.png", or select them '
                    'with an index.csv that has Name and File columns. Loaded icons '
                    'appear beside labels in editors and on slabbed covers.')));
