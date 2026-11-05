import 'package:collectarr_app/features/settings/standard_kind_settings.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'custom_label_icons.dart';

const comicKindSettings = LibraryKindSettingsContribution(
  sections: [buildStandardKindSettings, buildComicCustomLabelIconsSettings],
);
