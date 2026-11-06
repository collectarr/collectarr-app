import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/type_list.dart';
import 'package:collectarr_app/features/settings/list_value_images_panel.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:flutter/material.dart';

Widget buildGameToyTypeLogosSettings(
        BuildContext context, CatalogMediaKind kind) =>
    Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SettingsGroup(
            legend: 'Toy type logos',
            child: ListValueImagesPanel(
                list: gameToyTypeLogosList,
                description:
                    'Load logos from your own files, each named after its toy '
                    'type, such as "Skylanders.svg", or select them with an '
                    'index.csv that has Name and File columns. They replace the '
                    "type's name on the tiles of Add Toys.")));
