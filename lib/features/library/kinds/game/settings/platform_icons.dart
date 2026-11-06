import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/settings/list_value_images_panel.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:flutter/material.dart';

Widget buildGamePlatformIconsSettings(
        BuildContext context, CatalogMediaKind kind) =>
    Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SettingsGroup(
            legend: 'Platform icons',
            child: ListValueImagesPanel(
                list: platformIconsList,
                description:
                    'Load icons from your own files, each named after its platform, '
                    'such as "Nintendo Switch.svg", or select them with an index.csv '
                    'that has Name and File columns. They replace the built-in logo '
                    'wherever the platform shows.',
                previewBuilder: (value) => PlatformIcon(value, size: 18))));
