import 'package:collectarr_app/features/settings/standard_kind_settings.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'custom_label_icons.dart';

const comicKindSettings = LibraryKindSettingsContribution(
  sections: [
    buildStandardKindSettings,
    _buildRawGradeSetting,
    buildComicCustomLabelIconsSettings,
  ],
);

Widget _buildRawGradeSetting(BuildContext context, CatalogMediaKind kind) =>
    Consumer(
        builder: (context, ref, _) => Padding(
            padding: const EdgeInsets.only(top: 14),
            child: SettingsCheck(
                label:
                    'Show Grade as letters for raw comics (NM instead of 9.4)',
                value: ref.watch(uiPreferencesProvider
                    .select((value) => value.showCardPillLetters)),
                onChanged: ref
                    .read(uiPreferencesProvider.notifier)
                    .setShowCardPillLetters)));
