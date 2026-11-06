import 'package:collectarr_app/features/settings/standard_kind_settings.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'toy_type_logos.dart';

const gameToyKindSettings = LibraryKindSettingsContribution(
    sections: [buildStandardKindSettings, buildGameToyTypeLogosSettings],
    settings: [trailerVideosSetting]);
